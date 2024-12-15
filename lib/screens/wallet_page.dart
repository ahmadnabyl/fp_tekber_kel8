import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk font Poppins
import 'package:intl/intl.dart'; // Import untuk NumberFormat
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore

class WalletPage extends StatelessWidget {
  final String userId; // Tambahkan userId sebagai parameter
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Tambahkan GlobalKey

  WalletPage({required this.userId}); // Konstruktor dengan userId

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey, // Tambahkan GlobalKey di sini
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Dompet",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF6F92D8), // Warna untuk judul
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 4.0,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('users')
              .doc(userId)
              .collection('wallet')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Terjadi error: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              );
            }

            final walletData = snapshot.data?.docs;

            if (walletData == null || walletData.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/dompet.png', // Gambar placeholder
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada transaksi di dompet.",
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

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: walletData.length,
              itemBuilder: (context, index) {
                final transaction = walletData[index];
                final amount = transaction['amount'] ?? 0.0;
                final timestamp = transaction['timestamp'] as Timestamp?;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transaksi ${index + 1}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              timestamp != null
                                  ? DateFormat('dd MMM yyyy, HH:mm')
                                      .format(timestamp.toDate())
                                  : "Tanggal tidak tersedia",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Rp${NumberFormat('#,###', 'id_ID').format(amount)}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: Text(
                                      "Hapus Transaksi",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      "Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.",
                                      style: GoogleFonts.poppins(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: Text(
                                          "Batal",
                                          style: GoogleFonts.poppins(
                                              color: Colors.grey),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(dialogContext);

                                            await firestore
                                                .collection('users')
                                                .doc(userId)
                                                .collection('wallet')
                                                .doc(transaction.id)
                                                .delete();

                                            scaffoldMessengerKey.currentState!
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Transaksi berhasil dihapus!",
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            scaffoldMessengerKey.currentState!
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Gagal menghapus transaksi: $e",
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          "Hapus",
                                          style: GoogleFonts.poppins(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
