import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk font Poppins
import 'katalog_produk_page.dart'; // Import halaman Katalog Produk
import 'penjualan_page.dart'; // Import halaman Penjualan

class PusatBantuan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pusat Bantuan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: const Color(0xFF6F92D8), // Warna untuk judul navbar
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4.0,
        leading: IconButton(
          icon: Icon(Icons.close, color: const Color(0xFF6F92D8)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Warna latar belakang
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      "FAQ",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6F92D8),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Pertanyaan yang sering diajukan",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Info Umum",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6F92D8),
                ),
              ),
              SizedBox(height: 10),
              HelpButton(
                icon: Icons.shopping_cart,
                label: "Katalog Produk",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => KatalogProdukPage()),
                  );
                },
              ),
              HelpButton(
                icon: Icons.monetization_on,
                label: "Penjualan",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PenjualanPage()),
                  );
                },
              ),
              HelpButton(
                icon: Icons.history,
                label: "Riwayat Transaksi",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Fitur Riwayat Transaksi belum tersedia."),
                  ));
                },
              ),
              HelpButton(
                icon: Icons.account_balance_wallet,
                label: "Dompet",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Fitur Dompet belum tersedia."),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  HelpButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FA), // Warna background box
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 23, color: const Color.fromARGB(255, 66, 66, 66)),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}