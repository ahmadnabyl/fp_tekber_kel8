import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PenjualanPage extends StatefulWidget {
  @override
  _PenjualanPageState createState() => _PenjualanPageState();
}

class _PenjualanPageState extends State<PenjualanPage> {
  final List<SaleItem> sales = [
    SaleItem(
      title: "Bagaimana cara membuat transaksi penjualan baru?",
      description:
          "Untuk membuat transaksi penjualan baru, buka halaman 'Penjualan', lalu pilih produk, masukkan jumlah, dan klik tombol 'Proses Penjualan'.",
    ),
    SaleItem(
      title: "Bagaimana cara membatalkan transaksi penjualan?",
      description:
          "Anda dapat membatalkan transaksi sebelum menyelesaikannya dengan mengklik tombol 'Batalkan' di pojok kanan atas layar transaksi.",
    ),
    SaleItem(
      title: "Bagaimana cara mencetak bukti transaksi?",
      description:
          "Setelah transaksi selesai, Anda dapat mencetak bukti transaksi melalui tombol 'Cetak Struk' yang tersedia di layar konfirmasi.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Penjualan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: const Color(0xFF6F92D8), // Warna biru
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 4.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF6F92D8)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white, // Warna background putih murni
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  "FAQ",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6F92D8), // Warna biru
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Pertanyaan yang sering diajukan seputar penjualan",
                    textAlign: TextAlign.center, // Pastikan teks rata tengah
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...sales.map((sale) => SaleDropdownItem(item: sale)).toList(),
        ],
      ),
    );
  }
}

class SaleItem {
  final String title;
  final String description;

  SaleItem({
    required this.title,
    required this.description,
  });
}

class SaleDropdownItem extends StatelessWidget {
  final SaleItem item;

  SaleDropdownItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white, // Latar belakang putih murni
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2), // Shadow di bawah
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          item.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14.0,
            color: const Color(0xFF333333), // Warna teks utama
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.description,
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
