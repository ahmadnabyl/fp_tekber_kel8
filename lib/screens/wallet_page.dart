import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk font Poppins
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:intl/intl.dart'; // Import untuk NumberFormat

class WalletPage extends StatelessWidget {
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
      body: FutureBuilder(
        // Mengambil data saldo dari Hive
        future: _getWalletData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final walletData = snapshot.data as List<double>?;

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
                            fontSize: 18,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          "Rp${NumberFormat('#,###', 'id_ID').format(walletData[index])}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.green[700],
                          ),
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

  // Fungsi untuk mengambil data saldo (list transaksi) dari Hive
  Future<List<double>?> _getWalletData() async {
    var walletBox = await Hive.openBox('wallet');
    List<double> walletList = walletBox.get('transactions', defaultValue: <double>[]);
    return walletList;
  }
}
