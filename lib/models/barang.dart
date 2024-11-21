import 'package:hive_flutter/hive_flutter.dart'; // Gunakan ini

part 'barang.g.dart'; // Untuk code generation

@HiveType(typeId: 0)
class Barang extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int buyPrice;

  @HiveField(2)
  int sellPrice;

  @HiveField(3)
  int stock;

  @HiveField(4)
  String description;

  @HiveField(5)
  String imagePath;

  Barang({
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.description,
    required this.imagePath,
  });
}
