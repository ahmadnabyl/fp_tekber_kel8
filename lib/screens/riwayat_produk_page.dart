import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiwayatProdukPage extends StatelessWidget {
  final List<Item> items = [
    Item(
      title: "Bagaimana cara melihat riwayat produk?",
      description: "1. Klik menu 'Riwayat Produk' di home screen.\n"
          "2. Semua riwayat akan ditampilkan dalam urutan terbaru.\n"
          "3. Anda dapat melihat aksi yang dilakukan pada riwayat tersebut.",
    ),
    Item(
      title: "Bisakah saya menghapus riwayat produk?",
      description:
          "Anda dapat menghapus riwayat yang ada dengan mengklik tombol sampah jika terdapat kesalahan riwayat.",
    ),
    Item(
      title: "Apakah transaksi lama otomatis terhapus?",
      description:
          "Tidak, transaksi lama tidak akan terhapus otomatis kecuali dihapus secara manual.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Riwayat Transaksi",
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
                    "Pertanyaan yang sering diajukan seputar riwayat produk",
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
      child: ExpansionTile(
        title: Text(
          item.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: const Color(0xFF333333),
          ),
        ),
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
    );
  }
}