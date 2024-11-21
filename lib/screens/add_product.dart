import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk deteksi platform Web
import '../models/barang.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  dynamic _image; // Untuk mendukung Web (URL) dan Mobile (File)

  Future<void> _pickImage() async {
    // Menggunakan ImagePicker untuk memilih gambar
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          // Pada Web, gunakan path sementara sebagai URL
          _image = pickedFile.path;
        } else {
          // Pada Mobile, gunakan File
          _image = File(pickedFile.path);
        }
      });
    }
  }

  void _saveProduct() {
    if (_nameController.text.isNotEmpty &&
        _buyPriceController.text.isNotEmpty &&
        _sellPriceController.text.isNotEmpty &&
        _stockController.text.isNotEmpty) {
      final newProduct = Barang(
        name: _nameController.text,
        buyPrice: int.parse(_buyPriceController.text),
        sellPrice: int.parse(_sellPriceController.text),
        stock: int.parse(_stockController.text),
        description: _descriptionController.text,
        imagePath: _image?.toString() ?? '',
      );

      final productBox = Hive.box<Barang>('products');
      productBox.add(newProduct);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tambah Produk",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Color(0xFF6F92D8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(_nameController, "Nama Produk", TextInputType.text),
            SizedBox(height: 16),
            _buildTextField(_buyPriceController, "Harga Beli", TextInputType.number),
            SizedBox(height: 16),
            _buildTextField(_sellPriceController, "Harga Jual", TextInputType.number),
            SizedBox(height: 16),
            _buildTextField(_stockController, "Stok", TextInputType.number),
            SizedBox(height: 16),
            _buildTextField(_descriptionController, "Deskripsi", TextInputType.text, maxLines: 3),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildImageWidget(), // Menampilkan gambar yang dipilih atau placeholder
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6F92D8),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Simpan Produk",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        hintText: 'Masukkan $label',
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

  Widget _buildImageWidget() {
    if (_image != null) {
      return kIsWeb
          ? Image.network(
              _image.toString(), // URL untuk Web
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _image as File, // File untuk Mobile
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            );
    } else {
      // Placeholder default jika belum ada gambar yang dipilih
      return SizedBox(
        width: 150,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "Ambil Foto Produk",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }
}
