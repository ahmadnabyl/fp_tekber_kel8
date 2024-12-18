import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk font Poppins
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductHistory extends StatefulWidget {
  final String userId; // Tambahkan userId sebagai parameter

  ProductHistory({required this.userId});

  @override
  _ProductHistoryState createState() => _ProductHistoryState();
}

class _ProductHistoryState extends State<ProductHistory> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Riwayat Produk",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF6F92D8), // Warna baru untuk judul
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4.0,
      ),
      body: StreamBuilder(
        stream: firestore
            .collection('users')
            .doc(widget.userId) // Akses berdasarkan userId
            .collection('product_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Tampilan jika riwayat kosong
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/bismillah.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Riwayat Tidak Ditemukan",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Jika riwayat tersedia, tampilkan datanya
          var historyList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final historyDoc = historyList[index];
              final history = historyDoc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(
                    history['type'] == 'add'
                        ? Icons.add
                        : history['type'] == 'edit'
                            ? Icons.edit
                            : history['type'] == 'sale'
                                ? Icons.shopping_cart
                                : Icons.delete,
                    color: Colors.blue,
                  ),
                  title: Text(
                    history['name'] ?? 'Produk',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: _buildSubtitle(history),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Hapus Riwayat",
                            textAlign: TextAlign.center, // Teks judul di tengah
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "Apakah kamu yakin untuk menghapus riwayat produk '${history['name']}'?",
                            textAlign:
                                TextAlign.center, // Teks konten di tengah
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: Text(
                                "Tidak",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: Text(
                                "Ya",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );

                      if (confirm == true) {
                        await firestore
                            .collection('users')
                            .doc(widget.userId) // Akses berdasarkan userId
                            .collection('product_history')
                            .doc(historyDoc.id)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Riwayat '${history['name']}' berhasil dihapus",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubtitle(Map<String, dynamic> history) {
    String action = _getActionText(history['type']);
    String timestamp = _formatTimestamp(history['timestamp']);

    // Detail tambahan untuk penjualan
    String saleDetail = '';
    if (history['type'] == 'sale') {
      saleDetail =
          '\nJumlah Terjual: ${history['quantitySold'] ?? 0}\nTotal Harga: Rp${history['totalPrice']?.toStringAsFixed(2) ?? '0.00'}';
    }

    // Jika ada daftar perubahan
    String changesDetail = '';
    if (history['changes'] != null && history['changes'] is List) {
      changesDetail =
          (history['changes'] as List).map((change) => '- $change').join('\n');
    }

    return Text(
      "Aksi: $action\nWaktu: $timestamp${saleDetail.isNotEmpty ? saleDetail : ''}${changesDetail.isNotEmpty ? '\nPerubahan:\n$changesDetail' : ''}",
      style: GoogleFonts.poppins(),
    );
  }

  String _getActionText(String? type) {
    switch (type) {
      case 'add':
        return 'Produk Ditambahkan';
      case 'edit':
        return 'Produk Diedit';
      case 'delete':
        return 'Produk Dihapus';
      case 'sale':
        return 'Penjualan';
      default:
        return 'Tidak Diketahui';
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
