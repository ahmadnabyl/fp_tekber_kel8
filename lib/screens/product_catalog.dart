import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Untuk format ribuan
import 'package:flutter/foundation.dart'
    show kIsWeb; // Untuk deteksi platform Web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product.dart'; // Import halaman AddProductPage
import '../models/barang.dart';

class ProductCatalog extends StatefulWidget {
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
        backgroundColor:
            Colors.white, // Ubah warna latar belakang menjadi putih
        elevation: 4.0, // Tambahkan shadow pada app bar
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                  borderRadius:
                      BorderRadius.circular(10), // Radius tetap proporsional
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection('products').snapshots(),
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
                  return name
                      .contains(searchQuery); // Filter berdasarkan nama produk
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
                              color: Colors.grey),
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
                                              File(product
                                                  .imagePath), // File untuk Mobile
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
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () {
                                        _showProductForm(
                                            context, productDoc.id, product);
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () async {
                                        try {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text("Hapus Produk"),
                                              content: Text(
                                                  "Apakah Anda yakin ingin menghapus produk '${product.name}'?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: Text("Batal"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: Text("Hapus"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              // Hapus produk dari Firestore
                                              await firestore
                                                  .collection('products')
                                                  .doc(productDoc.id)
                                                  .delete();

                                              // Tambahkan ke history
                                              await firestore
                                                  .collection('product_history')
                                                  .add({
                                                'type': 'delete',
                                                'name': product.name,
                                                'timestamp': Timestamp.now(),
                                                'changes': []
                                              });

                                              // Tampilkan pesan berhasil
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Produk '${product.name}' berhasil dihapus")),
                                              );
                                            } catch (e) {
                                              // Log error Firestore
                                              print(
                                                  "Gagal menghapus produk dari Firestore: $e");
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Gagal menghapus produk: $e")),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          // Log error dialog
                                          print(
                                              "Kesalahan saat menampilkan dialog konfirmasi: $e");
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        backgroundColor: Color(0xFF6F92D8),
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
        tooltip: "Tambah Produk",
      ),
    );
  }

  void _showProductForm(
      BuildContext context, String productId, Barang product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(
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
