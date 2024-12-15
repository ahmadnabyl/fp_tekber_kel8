import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'payment_page.dart';
import 'homepage.dart';

class SalesPage extends StatefulWidget {
  final String userId; // Menambahkan userId sebagai parameter
  SalesPage({required this.userId});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, int> _quantities = {}; // Melacak jumlah kuantitas produk
  double _totalPrice = 0.0;
  String searchQuery = ""; // Variabel untuk pencarian produk

  void _updateTotalPrice(List<QueryDocumentSnapshot> products) {
    double total = 0.0;
    _quantities.forEach((productId, quantity) {
      final product = products.firstWhere((p) => p.id == productId);
      total += product['sellPrice'] * quantity;
    });
    setState(() {
      _totalPrice = total;
    });
  }

  Future<void> _updateStockAfterPayment() async {
    final batch = firestore.batch();
    _quantities.forEach((productId, quantity) {
      final productRef = firestore
          .collection('users')
          .doc(widget.userId)
          .collection('products')
          .doc(productId);
      batch.update(productRef, {
        'stock': FieldValue.increment(-quantity),
      });
    });

    try {
      await batch.commit();
      setState(() {
        _quantities.clear(); // Reset kuantitas produk setelah pembayaran
        _totalPrice = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok produk berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui stok: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(userId: widget.userId),
              ),
              (route) => false,
            );
          },
        ),
        title: Text(
          "Produk Penjualan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
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
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); // Menyimpan pencarian
                });
              },
              decoration: InputDecoration(
                hintText: "Cari produk kamu di sini",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore
                  .collection('users')
                  .doc(widget.userId)
                  .collection('products')
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

                final filteredProducts = snapshot.data!.docs.where((product) {
                  final name = product['name'].toString().toLowerCase();
                  return name.contains(searchQuery);
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
                    final product = filteredProducts[index];
                    final productId = product.id;
                    final quantity = _quantities[productId] ?? 0;
                    final availableStock = product['stock'];

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
                                      product['imagePath'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(
                                        Icons.broken_image,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : product['imagePath'].isNotEmpty &&
                                          File(product['imagePath'])
                                              .existsSync()
                                      ? Image.file(
                                          File(product['imagePath']),
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
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    product['description'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Rp${NumberFormat('#,###', 'id_ID').format(product['sellPrice'])}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Stok Tersedia: $availableStock",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
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
                                              _quantities[productId] = 1;
                                            });
                                            _updateTotalPrice(filteredProducts);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(
                                              255,
                                              125,
                                              163,
                                              237),
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(10, 10),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 11, vertical: 7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          "Tambah",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              if (quantity > 0) {
                                                setState(() {
                                                  _quantities[productId] =
                                                      quantity - 1;
                                                });
                                                _updateTotalPrice(
                                                    filteredProducts);
                                              }
                                            },
                                          ),
                                          Text(
                                            "$quantity",
                                            style: GoogleFonts.poppins(
                                                fontSize: 16),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              if (quantity < availableStock) {
                                                setState(() {
                                                  _quantities[productId] =
                                                      quantity + 1;
                                                });
                                                _updateTotalPrice(
                                                    filteredProducts);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
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
            ),
          ),
          StreamBuilder(
            stream: firestore
                .collection('users')
                .doc(widget.userId)
                .collection('products')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return SizedBox();
              var products = snapshot.data!.docs;

              if (_quantities.values.any((q) => q > 0)) {
                return Container(
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
                        onPressed: () async {
                          final selectedItems = _quantities.entries
                              .where((entry) => entry.value > 0)
                              .map((entry) {
                            final product =
                                products.firstWhere((p) => p.id == entry.key);
                            return {
                              'id': product.id,
                              'name': product['name'],
                              'quantity': entry.value,
                              'price': product['sellPrice'],
                            };
                          }).toList();

                          final paymentCompleted = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                totalAmount: _totalPrice,
                                items: selectedItems,
                                userId: widget.userId, // Tambahkan userId
                              ),
                            ),
                          );

                          if (paymentCompleted == true) {
                            await _updateStockAfterPayment();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 98, 193, 99),
                          foregroundColor: Colors.white,
                          minimumSize: Size(80, 20),
                          padding: EdgeInsets.symmetric(
                              horizontal: 13, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Bayar",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
