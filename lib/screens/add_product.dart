import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Untuk deteksi platform Web
import '../models/barang.dart';

class AddProductPage extends StatefulWidget {
  final Barang? product; // Tambahkan parameter opsional `product`

  AddProductPage({this.product}); // Konstruktor menerima produk opsional

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

  @override
  void initState() {
    super.initState();
    // Jika `product` diberikan, isi nilai pada form
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _buyPriceController.text = widget.product!.buyPrice.toString();
      _sellPriceController.text = widget.product!.sellPrice.toString();
      _stockController.text = widget.product!.stock.toString();
      _descriptionController.text = widget.product!.description;
      _image = widget.product!.imagePath;
    }
  }

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

      if (widget.product != null) {
        // Jika produk sudah ada, buat log perubahan
        Map<String, dynamic> oldValues = {
          'name': widget.product!.name,
          'buyPrice': widget.product!.buyPrice,
          'sellPrice': widget.product!.sellPrice,
          'stock': widget.product!.stock,
          'description': widget.product!.description,
        };

        Map<String, dynamic> newValues = {
          'name': newProduct.name,
          'buyPrice': newProduct.buyPrice,
          'sellPrice': newProduct.sellPrice,
          'stock': newProduct.stock,
          'description': newProduct.description,
        };

        // Bandingkan nilai lama dengan nilai baru untuk membuat log perubahan
        List<String> changes = [];
        oldValues.forEach((key, oldValue) {
          var newValue = newValues[key];
          if (oldValue != newValue) {
            changes.add('$key diubah dari "$oldValue" menjadi "$newValue"');
          }
        });

        widget.product!
          ..name = newProduct.name
          ..buyPrice = newProduct.buyPrice
          ..sellPrice = newProduct.sellPrice
          ..stock = newProduct.stock
          ..description = newProduct.description
          ..imagePath = newProduct.imagePath;
        widget.product!.save();

        // Simpan ke riwayat
        final historyBox = Hive.box<Map>('product_history');
        final timestamp = DateTime.now().toIso8601String();
        historyBox.add({
          'type': 'edit',
          'name': _nameController.text,
          'timestamp': timestamp,
          'changes': changes,
        });
      } else {
        // Jika produk baru, tambahkan ke Hive
        productBox.add(newProduct);

        // Simpan ke riwayat
        final historyBox = Hive.box<Map>('product_history');
        final timestamp = DateTime.now().toIso8601String();
        historyBox.add({
          'type': 'add',
          'name': _nameController.text,
          'timestamp': timestamp,
        });
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product != null ? "Edit Produk" : "Tambah Produk", // Judul dinamis
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
                widget.product != null ? "Simpan Perubahan" : "Simpan Produk", // Teks dinamis
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