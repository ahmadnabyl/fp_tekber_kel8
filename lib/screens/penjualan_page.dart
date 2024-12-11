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
          "Untuk membuat transaksi penjualan baru, buka halaman 'Penjualan', lalu pilih produk, masukkan jumlah, dan klik tombol 'Bayar'.",
    ),
    SaleItem(
      title: "Bagaimana cara membatalkan transaksi penjualan?",
      description:
          "Anda dapat membatalkan transaksi sebelum menyelesaikannya dengan mengklik tombol 'Kembali' yang terletak di pojok kiri atas layar.",
    ),
    SaleItem(
      title: "Bagaimana cara menyelesaikan bukti transaksi?",
      description:
          "Setelah transaksi dibuat, Anda dapat mengisi nama pelanggan dan memasukkan jumlah uang pembayaran, setelah itu klik tombol konfirmasi dan akan muncul bukti struk.",
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
            fontSize: 18,
            color: const Color(0xFF6F92D8),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 190, 207, 253),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Pertanyaan yang sering diajukan seputar penjualan",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ...sales.map((sale) => SaleDropdownItem(item: sale)).toList(),
          ],
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Menghilangkan garis hitam
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero, // Menghapus padding bawaan
          title: Text(
            item.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: const Color(0xFF333333),
            ),
          ),
          childrenPadding: EdgeInsets.zero, // Menghilangkan padding anak
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item.description,
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}