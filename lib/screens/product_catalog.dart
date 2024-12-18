import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Untuk format ribuan
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk deteksi platform Web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product.dart'; // Import halaman AddProductPage
import '../models/barang.dart';

class ProductCatalog extends StatefulWidget {
  final String userId; // Tambahkan userId sebagai parameter
  ProductCatalog({required this.userId});

  @override
  _ProductCatalogState createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchQuery = ""; // Untuk menyimpan input pencarian

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: Text(
          "Katalog Produk",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18, // Menyesuaikan ukuran font
            color: Color(0xFF6F92D8), // Warna biru pastel
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Ubah warna latar belakang menjadi putih
        elevation: 4.0, // Tambahkan shadow pada app bar
      ),
      body: Builder(
        builder: (scaffoldContext) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase(); // Simpan query pencarian
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Cari produk kamu di sini",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14, // Ukuran font placeholder diperkecil
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20, // Ukuran ikon diperkecil
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10, // Mengurangi tinggi padding box
                      horizontal: 12, // Mengurangi padding horizontal
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), // Radius tetap proporsional
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: firestore
                      .collection('users')
                      .doc(widget.userId) // Dokumen pengguna
                      .collection('products') // Subkoleksi produk pengguna
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/bismillah.png',
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Produk Tidak Ditemukan",
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

                    // Filter produk berdasarkan searchQuery
                    final filteredProducts = snapshot.data!.docs.where((product) {
                      final name = product['name'].toString().toLowerCase();
                      return name.contains(searchQuery); // Filter berdasarkan nama produk
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "Produk tidak ditemukan",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final productDoc = filteredProducts[index];
                        final product = Barang.fromFirestore(productDoc);

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Konten di sisi kiri
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        product.description,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Rp${NumberFormat('#,###', 'id_ID').format(product.sellPrice)}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Stok: ${product.stock}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Gambar dan tombol aksi di sisi kanan
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: kIsWeb
                                          ? Image.network(
                                              product.imagePath, // URL untuk Web
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : product.imagePath.isNotEmpty &&
                                                  File(product.imagePath)
                                                      .existsSync()
                                              ? Image.file(
                                                  File(product.imagePath), // File untuk Mobile
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(
                                                  Icons.broken_image,
                                                  size: 90,
                                                  color: Colors.grey,
                                                ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue, size: 20),
                                          onPressed: () {
                                            _showProductForm(context, productDoc.id, product);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red, size: 20),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (dialogContext) => AlertDialog(
                                                title: Text(
                                                  "Hapus Produk",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Text(
                                                  "Apakah kamu yakin untuk menghapus produk '${product.name}'?",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                actionsAlignment:
                                                    MainAxisAlignment.center,
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(dialogContext, false),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.grey.shade300,
                                                      elevation: 0,
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                    ),
                                                    child: Text(
                                                      "Tidak",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(dialogContext, true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      elevation: 0,
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                    ),
                                                    child: Text(
                                                      "Ya",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            );

                                            if (confirm == true) {
                                              try {
                                                // Simpan riwayat penghapusan ke 'product_history'
                                                await firestore
                                                    .collection('users')
                                                    .doc(widget.userId)
                                                    .collection('product_history')
                                                    .add({
                                                  'type': 'delete',
                                                  'name': product.name,
                                                  'timestamp': Timestamp.now(),
                                                  'productId': productDoc.id,
                                                  'stock': product.stock,
                                                });

                                                // Hapus produk dari koleksi
                                                await firestore
                                                    .collection('users')
                                                    .doc(widget.userId)
                                                    .collection('products')
                                                    .doc(productDoc.id)
                                                    .delete();

                                                // Tampilkan SnackBar dengan konteks yang valid
                                                ScaffoldMessenger.of(scaffoldContext)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Produk '${product.name}' berhasil dihapus"),
                                                  ),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(scaffoldContext)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Gagal menghapus produk: $e"),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
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
            ],
          );
        },
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(-10, -20), // Memindahkan tombol ke kiri dan naik
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddProductPage(userId: widget.userId),
              ),
            );
          },
          backgroundColor: Color(0xFF6F92D8), // Warna biru pastel
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10), // Tombol berbentuk kotak dengan radius
          ),
          child: Icon(Icons.add, color: Colors.white), // Ikon tombol
          tooltip: "Tambah Produk", // Tooltip untuk tombol
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, String productId, Barang product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(
          userId: widget.userId,
          product: product,
        ),
      ),
    ).then((updatedProduct) {
      if (updatedProduct != null) {
        firestore
            .collection('products')
            .doc(productId)
            .set(updatedProduct.toMap());
      }
    });
  }
}
