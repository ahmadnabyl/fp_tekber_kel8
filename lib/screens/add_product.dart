import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/barang.dart';

class AddProductPage extends StatefulWidget {
  final Barang? product;
  final String userId; // Tambahkan userId sebagai parameter

  AddProductPage({this.product, required this.userId});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _buyPriceController.text = widget.product!.buyPrice.toString();
      _sellPriceController.text = widget.product!.sellPrice.toString();
      _stockController.text = widget.product!.stock.toString();
      _descriptionController.text = widget.product!.description;
      if (widget.product!.imagePath.isNotEmpty) {
        _image = File(widget.product!.imagePath);
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

Future<void> _saveProduct() async {
  if (_nameController.text.isNotEmpty &&
      _buyPriceController.text.isNotEmpty &&
      _sellPriceController.text.isNotEmpty &&
      _stockController.text.isNotEmpty) {
    // Buat objek Barang baru
    final newProduct = Barang(
      name: _nameController.text,
      buyPrice: int.parse(_buyPriceController.text),
      sellPrice: int.parse(_sellPriceController.text),
      stock: int.parse(_stockController.text),
      description: _descriptionController.text,
      imagePath: _image?.path ?? '', // Path gambar (opsional)
    );

    try {
      final firestore = FirebaseFirestore.instance;

      if (widget.product != null) {
        // Update produk yang sudah ada
        await firestore
            .collection('users')
            .doc(widget.userId) // Gunakan userId untuk menentukan user spesifik
            .collection('products')
            .doc(widget.product!.id) // Akses dokumen produk
            .update(newProduct.toMap());

        // Tambahkan ke riwayat produk (update)
        await firestore
            .collection('users')
            .doc(widget.userId)
            .collection('product_history')
            .add({
          'type': 'edit',
          'name': _nameController.text,
          'timestamp': Timestamp.now(),
          'changes': [
            'Harga beli: ${widget.product!.buyPrice} -> ${newProduct.buyPrice}',
            'Harga jual: ${widget.product!.sellPrice} -> ${newProduct.sellPrice}',
            'Stok: ${widget.product!.stock} -> ${newProduct.stock}',
          ],
        });
      } else {
        // Tambahkan produk baru ke subkoleksi 'products' pengguna
        final productDoc = await firestore
            .collection('users')
            .doc(widget.userId)
            .collection('products')
            .add(newProduct.toMap());

        // Tambahkan ke riwayat produk (add)
        await firestore
            .collection('users')
            .doc(widget.userId)
            .collection('product_history')
            .add({
          'type': 'add',
          'name': _nameController.text,
          'timestamp': Timestamp.now(),
          'productId': productDoc.id,
          'stock': newProduct.stock,
        });
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mohon lengkapi semua data produk!')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color.fromARGB(255, 156, 205, 239)],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 10),
                    Text(
                      widget.product != null ? "Edit Produk" : "Tambah Produk",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      SizedBox(height: 16), // Menurunkan field nama produk
                      _buildTextField(
                          _nameController, "Nama Produk", TextInputType.text),
                      SizedBox(height: 16),
                      _buildTextField(_buyPriceController, "Harga Beli",
                          TextInputType.number),
                      SizedBox(height: 16),
                      _buildTextField(_sellPriceController, "Harga Jual",
                          TextInputType.number),
                      SizedBox(height: 16),
                      _buildTextField(
                          _stockController, "Stok", TextInputType.number),
                      SizedBox(height: 16),
                      _buildTextField(_descriptionController, "Deskripsi",
                          TextInputType.text,
                          maxLines: 3),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: _pickImageFromCamera,
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          size: 30, color: Colors.grey),
                                      SizedBox(height: 4),
                                      Text(
                                        "Ambil Foto",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6F92D8),
                            minimumSize: Size(140, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.product != null
                                ? "Simpan Perubahan"
                                : "Simpan Produk",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
        hintText: 'Masukkan $label',
        hintStyle:
            GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF6F92D8), width: 2),
        ),
      ),
    );
  }
}
