import 'package:cloud_firestore/cloud_firestore.dart';

class Barang {
  String? id; // ID dokumen Firestore
  String name;
  int buyPrice;
  int sellPrice;
  int stock;
  String description;
  String imagePath; // Path gambar atau URL

  Barang({
    this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.description,
    required this.imagePath,
  });

  // Konversi dari Firestore Document ke Barang
  factory Barang.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Ambil data sebagai Map
    return Barang(
      id: doc.id, // ID dokumen
      name: data['name'] ?? '',
      buyPrice: data['buyPrice'] ?? 0,
      sellPrice: data['sellPrice'] ?? 0,
      stock: data['stock'] ?? 0,
      description: data['description'] ?? '',
      imagePath: data['imagePath'] ?? '',
    );
  }

  // Konversi dari Barang ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'description': description,
      'imagePath': imagePath,
    };
  }
}
