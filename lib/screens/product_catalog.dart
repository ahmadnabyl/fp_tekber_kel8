import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Untuk format ribuan
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk deteksi platform Web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product.dart'; // Import halaman AddProductPage
import '../models/barang.dart';

class ProductCatalog extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
            fontSize: 20, // Menyesuaikan ukuran font
            color: Color(0xFF6F92D8), // Warna biru pastel
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Ubah warna latar belakang menjadi putih
        elevation: 4.0, // Tambahkan shadow pada app bar
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari produk kamu disini",
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
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

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final productDoc = snapshot.data!.docs[index];
                    final product = Barang.fromFirestore(productDoc);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
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
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    product.description,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Rp${NumberFormat('#,###', 'id_ID').format(product.sellPrice)}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Stok: ${product.stock}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
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
                                              File(product.imagePath).existsSync()
                                          ? Image.file(
                                              File(product.imagePath), // File untuk Mobile
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.broken_image,
                                              size: 80,
                                              color: Colors.grey,
                                            ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _showProductForm(
                                            context, productDoc.id, product);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Hapus Produk"),
                                            content: Text("Apakah Anda yakin ingin menghapus produk '${product.name}'?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: Text("Batal"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: Text("Hapus"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          try {
                                            await firestore.collection('products').doc(productDoc.id).delete();
                                            await firestore.collection('product_history').add({
                                              'type': 'delete',
                                              'name': product.name,
                                              'timestamp': Timestamp.now(),
                                              'changes': []
                                            });

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Produk '${product.name}' berhasil dihapus")),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Gagal menghapus produk: $e")),
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
        firestore.collection('products').doc(productId).set(updatedProduct.toMap());
      }
    });
  }
}
