import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk font Poppins
import 'package:intl/intl.dart'; // Import untuk NumberFormat
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore

class WalletPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: StreamBuilder(
        // Mengambil data saldo dari Firestore
        stream: firestore.collection('wallet').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final walletData = snapshot.data?.docs;

          if (walletData == null || walletData.isEmpty) {
            // Jika tidak ada transaksi atau saldo
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    // Gambar placeholder atau kosong
                    Image.asset(
                      'assets/dompet.png', // Gambar kosong (opsional)
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Dompet Kosong",
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

          // Menampilkan setiap pembayaran dalam box terpisah
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: walletData.length,
              itemBuilder: (context, index) {
                final transaction = walletData[index];
                final amount = transaction['amount'] ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tunai ${index + 1}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.green[700],
                          ),
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
                                // Dialog konfirmasi
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      "Hapus Transaksi",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      "Apakah Anda yakin ingin menghapus transaksi ini?",
                                      style: GoogleFonts.poppins(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "Batal",
                                          style: GoogleFonts.poppins(color: Colors.grey),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await firestore
                                              .collection('wallet')
                                              .doc(transaction.id)
                                              .delete();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Transaksi berhasil dihapus!",
                                                style: GoogleFonts.poppins(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Hapus",
                                          style: GoogleFonts.poppins(color: Colors.red),
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
            ),
          );
        },
      ),
    );
  }
}
