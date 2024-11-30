import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Untuk format ribuan
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk deteksi platform Web
import '../models/barang.dart';
import 'payment_page.dart'; // Pastikan untuk mengimpor PaymentPage

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  Map<int, int> _quantities = {}; // Untuk melacak jumlah kuantitas setiap produk
  double _totalPrice = 0.0;

  void _updateTotalPrice(Box<Barang> box) {
    double total = 0.0;
    _quantities.forEach((index, quantity) {
      final product = box.getAt(index);
      if (product != null) {
        total += product.sellPrice * quantity;
      }
    });
    setState(() {
      _totalPrice = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Produk Penjualan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF6F92D8),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4.0,
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
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final product = box.getAt(index);

                        if (product == null) {
                          return SizedBox(); // Skip jika `null`
                        }

                        final quantity = _quantities[index] ?? 0;
                        final availableStock = product.stock; // Menampilkan stok yang tersedia

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(
                                          product.imagePath,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : product.imagePath.isNotEmpty
                                          ? Image.file(
                                              File(product.imagePath),
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
                                SizedBox(width: 12),
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
                                      SizedBox(height: 8),
                                      Text(
                                        "Stok Tersedia: $availableStock", // Menampilkan stok
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    quantity == 0
                                        ? ElevatedButton(
                                            onPressed: () {
                                              if (availableStock > 0) {
                                                setState(() {
                                                  _quantities[index] = 1;
                                                });
                                                _updateTotalPrice(box);
                                              }
                                            },
                                            child: Text("Tambah"),
                                          )
                                        : Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: () {
                                                  if (quantity > 0) {
                                                    setState(() {
                                                      _quantities[index] = quantity - 1;
                                                    });
                                                    _updateTotalPrice(box);
                                                  }
                                                },
                                              ),
                                              Text(
                                                "$quantity",
                                                style: GoogleFonts.poppins(fontSize: 16),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: () {
                                                  if (quantity < availableStock) {
                                                    setState(() {
                                                      _quantities[index] = quantity + 1;
                                                    });
                                                    _updateTotalPrice(box);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Stok habis"),
                                                      ),
                                                    );
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
          if (_quantities.values.any((q) => q > 0))
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: Rp${NumberFormat('#,###', 'id_ID').format(_totalPrice)}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final selectedItems = _quantities.entries
                          .where((entry) => entry.value > 0)
                          .map((entry) {
                            final product = Hive.box<Barang>('products').getAt(entry.key);
                            return {
                              'name': product!.name,
                              'quantity': entry.value,
                              'price': product.sellPrice,
                            };
                          })
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            totalAmount: _totalPrice,
                            items: selectedItems,
                          ),
                        ),
                      );
                    },
                    child: Text("Bayar"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
