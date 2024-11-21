// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barang.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BarangAdapter extends TypeAdapter<Barang> {
  @override
  final int typeId = 0;

  @override
  Barang read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Barang(
      name: fields[0] as String,
      stock: fields[1] as int,
      description: fields[2] as String,
      imagePath: fields[3] as String,
      buyPrice: fields[4] as int,
      sellPrice: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Barang obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.stock)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.buyPrice)
      ..writeByte(5)
      ..write(obj.sellPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarangAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
