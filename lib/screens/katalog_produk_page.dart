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
      description: "Anda dapat menghapus produk melalui halaman 'Katalog Produk'. Pilih produk yang ingin dihapus, lalu klik ikon tempat sampah.",
    ),
    Item(
      title: "Bagaimana cara memperbarui stok produk?",
      description: "Untuk memperbarui stok produk, buka detail produk di menu 'Katalog' yang bergambar pensil, lalu edit jumlah stok sesuai kebutuhan.",
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
              Color.fromARGB(255, 255, 255, 255),
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
                    "Pertanyaan yang sering diajukan seputar produk",
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
        color: const Color.fromARGB(255, 245, 245, 245),
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
            widget.item.title,
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
                widget.item.description,
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
