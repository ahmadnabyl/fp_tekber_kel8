import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KatalogProdukPage extends StatefulWidget {
  @override
  _KatalogProdukPageState createState() => _KatalogProdukPageState();
}

class _KatalogProdukPageState extends State<KatalogProdukPage> {
  final List<Item> items = [
    Item(
      title: "Bagaimana cara menambahkan produk baru ke katalog?",
      description: "1. Klik fitur katalog produk pada home screen.\n"
          "2. Pilih tombol plus untuk menambah produk.\n"
          "3. Isi nama produk, stok, dan deskripsi produk.\n"
          "4. Setelah informasi selesai ditambah, pilih simpan.",
    ),
    Item(
      title: "Bagaimana cara menghapus produk dari katalog?",
      description: "Anda dapat menghapus produk melalui halaman 'Kelola Produk'. Pilih produk yang ingin dihapus, lalu klik ikon tempat sampah.",
    ),
    Item(
      title: "Bagaimana cara memperbarui stok produk?",
      description: "Untuk memperbarui stok produk, buka detail produk di menu 'Katalog', lalu edit jumlah stok sesuai kebutuhan.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Katalog Produk",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: const Color(0xFF6F92D8), // Warna biru seperti contoh
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
        color: Colors.white, // Warna background putih
        child: ListView(
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
                  Text(
                    "Pertanyaan yang sering diajukan seputar produk",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
  bool isExpanded;

  Item({
    required this.title,
    required this.description,
    this.isExpanded = false,
  });
}

class DropdownItem extends StatefulWidget {
  final Item item;

  DropdownItem({required this.item});

  @override
  _DropdownItemState createState() => _DropdownItemState();
}

class _DropdownItemState extends State<DropdownItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white, // Warna background putih untuk box
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
          widget.item.title,
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
              widget.item.description,
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
