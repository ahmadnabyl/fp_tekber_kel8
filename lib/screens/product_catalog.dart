import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Untuk format ribuan
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk deteksi platform Web
import 'add_product.dart'; // Import halaman AddProductPage
import '../models/barang.dart';

class ProductCatalog extends StatelessWidget {
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
            child: FutureBuilder(
              future: Hive.openBox<Barang>('products'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                var productBox = Hive.box<Barang>('products');
                return ValueListenableBuilder(
                  valueListenable: productBox.listenable(),
                  builder: (context, Box<Barang> box, _) {
                    if (box.isEmpty) {
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
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final product = box.getAt(index) as Barang?;
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
                                        product?.name ?? 'Tidak ada nama',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        product?.description ?? 'Tidak ada deskripsi',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Rp${NumberFormat('#,###', 'id_ID').format(product?.sellPrice ?? 0)}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        "Stok: ${product?.stock ?? 0}",
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
                                              product?.imagePath ?? '', // URL untuk Web
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : product?.imagePath != null && product!.imagePath.isNotEmpty
                                              ? Image.file(
                                                  File(product.imagePath), // File untuk Mobile
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(
                                                  Icons.inventory,
                                                  size: 80,
                                                  color: Colors.grey,
                                                ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            if (product != null) {
                                              _showProductForm(context, productBox, product, index);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            var deletedProduct = box.getAt(index);
                                            box.deleteAt(index);

                                            if (deletedProduct != null) {
                                              // Simpan ke riwayat
                                              var historyBox = Hive.box<Map>('product_history');
                                              var timestamp = DateTime.now().toIso8601String();
                                              historyBox.add({
                                                'type': 'delete',
                                                'name': deletedProduct.name,
                                                'timestamp': timestamp,
                                              });
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
        backgroundColor: Color(0xFF6F92D8), // Ubah warna tombol menjadi biru pastel
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(), // Bentuk tombol menjadi bundar
        tooltip: "Tambah Produk",
      ),
    );
  }

  void _showProductForm(BuildContext context, Box<Barang> productBox, [Barang? product, int? index]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(
          product: product, // Kirim data produk yang akan diedit
        ),
      ),
    ).then((updatedProduct) {
      if (updatedProduct != null) {
        // Update produk di Hive Box
        productBox.putAt(index!, updatedProduct);

        // Simpan perubahan ke riwayat
        var historyBox = Hive.box<Map>('product_history');
        var timestamp = DateTime.now().toIso8601String();
        historyBox.add({
          'type': 'edit',
          'name': updatedProduct.name,
          'timestamp': timestamp,
          'change': _generateChangeLog(
            oldProduct: product,
            newProduct: updatedProduct,
          ),
          'details': {
            'old': {
              'name': product?.name,
              'price': product?.sellPrice,
              'stock': product?.stock,
            },
            'new': {
              'name': updatedProduct.name,
              'price': updatedProduct.sellPrice,
              'stock': updatedProduct.stock,
            },
          },
        });
      }
    });
  }

  String _generateChangeLog({Barang? oldProduct, Barang? newProduct}) {
    if (oldProduct == null || newProduct == null) return 'Tidak ada perubahan signifikan';

    List<String> changes = [];
    final Map<String, String> propertyMapping = {
      'name': 'Nama',
      'buyPrice': 'Harga Beli',
      'sellPrice': 'Harga Jual',
      'stock': 'Stok',
      'description': 'Deskripsi',
    };

    if (oldProduct.name != newProduct.name) {
      changes.add('${propertyMapping['name']} diubah dari ${oldProduct.name} menjadi ${newProduct.name}');
    }
    if (oldProduct.buyPrice != newProduct.buyPrice) {
      changes.add(
        '${propertyMapping['buyPrice']} diubah dari Rp ${NumberFormat("#,##0", "id_ID").format(oldProduct.buyPrice)} menjadi Rp ${NumberFormat("#,##0", "id_ID").format(newProduct.buyPrice)}',
      );
    }
    if (oldProduct.sellPrice != newProduct.sellPrice) {
      changes.add(
        '${propertyMapping['sellPrice']} diubah dari Rp ${NumberFormat("#,##0", "id_ID").format(oldProduct.sellPrice)} menjadi Rp ${NumberFormat("#,##0", "id_ID").format(newProduct.sellPrice)}',
      );
    }
    if (oldProduct.stock != newProduct.stock) {
      changes.add('${propertyMapping['stock']} diubah dari ${oldProduct.stock} menjadi ${newProduct.stock}');
    }
    if (oldProduct.description != newProduct.description) {
      changes.add('${propertyMapping['description']} diubah dari ${oldProduct.description} menjadi ${newProduct.description}');
    }

    return changes.isNotEmpty ? changes.join(', ') : 'Tidak ada perubahan signifikan';
  }
}