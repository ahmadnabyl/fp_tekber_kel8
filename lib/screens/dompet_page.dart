import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DompetPage extends StatelessWidget {
  final List<Item> items = [
    Item(
      title: "Bagaimana cara mengecek dompet?",
      description: "1. Klik menu 'Dompet' di home screen.\n"
          "2. Hasil transaksi yang dilakukan akan tercatat di dompet.\n",
    ),
    Item(
      title: "Bisakah saya menghapus saldo yang sudah tercatat?",
      description:
          "Anda dapat menghapus saldo yang telah tercatat dengan mengklik tombol sampah jika sekiranya terdapat kesalahan transaksi.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dompet",
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
              Color(0xFFFFFFFF), // Warna putih
              Color.fromARGB(255, 190, 207, 253), // Warna biru muda
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                  Text(
                    "Pertanyaan yang sering diajukan seputar dompet",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ...items.map((item) => DropdownItem(item: item)).toList(),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String title;
  final String description;

  Item({
    required this.title,
    required this.description,
  });
}

class DropdownItem extends StatelessWidget {
  final Item item;

  DropdownItem({required this.item});

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