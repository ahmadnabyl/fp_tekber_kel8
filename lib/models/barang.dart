import 'package:hive_flutter/hive_flutter.dart'; // Gunakan ini

part 'barang.g.dart'; // Untuk code generation

@HiveType(typeId: 0)
class Barang {
  @HiveField(0)
  String name;

  @HiveField(1)
  int stock;

  @HiveField(2)
  String description;

  @HiveField(3)
  String imagePath; // Path untuk foto produk (opsional)

  @HiveField(4)
  int buyPrice; // Tambahkan harga beli

  @HiveField(5)
  int sellPrice; // Tambahkan harga jual

  Barang({
    required this.name,
    required this.stock,
    required this.description,
    required this.imagePath,
    required this.buyPrice, // Tambahkan ke konstruktor
    required this.sellPrice, // Tambahkan ke konstruktor
  });
}
