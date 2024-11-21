import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk font Poppins
import 'package:intl/intl.dart';
import '../models/barang.dart';

class ProductHistory extends StatefulWidget {
  @override
  _ProductHistoryState createState() => _ProductHistoryState();
}

class _ProductHistoryState extends State<ProductHistory> {
  late Box<Map> historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box<Map>('product_history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Riwayat Produk",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF6F92D8), // Warna baru untuk judul
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4.0,
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, Box<Map> box, _) {
          if (box.isEmpty) {
            // Tampilan jika riwayat kosong
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      "Riwayat Tidak Ditemukan",
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

          // Jika riwayat tersedia, tampilkan datanya
          var historyList = box.values.toList().reversed.toList();

          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(
                    history['type'] == 'add'
                        ? Icons.add
                        : history['type'] == 'edit'
                            ? Icons.edit
                            : Icons.delete,
                    color: Colors.blue,
                  ),
                  title: Text(
                    history['name'] ?? 'Produk',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: _buildSubtitle(history),
                  isThreeLine: false, // Tidak perlu menampilkan harga
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        box.deleteAt(historyList.length - index - 1);
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubtitle(Map history) {
    String action = _getActionText(history['type'], history['changes']);
    String timestamp = _formatTimestamp(history['timestamp']);

  // Jika ada daftar perubahan, tambahkan detail perubahan ke subtitle
    String changesDetail = '';
    if (history['changes'] != null && history['changes'] is List) {
      changesDetail = (history['changes'] as List)
          .map((change) => '- $change')
          .join('\n');
    }

    return Text(
      "Aksi: $action\nWaktu: $timestamp${changesDetail.isNotEmpty ? '\nPerubahan:\n$changesDetail' : ''}",
      style: GoogleFonts.poppins(),
    );
  }

  String _getActionText(String type, [List<String>? changes]) {
    switch (type) {
      case 'add':
        return 'Produk Ditambahkan';
      case 'edit':
        return 'Produk Diedit';
      case 'delete':
        return 'Produk Dihapus';
      default:
        return 'Tidak Diketahui';
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  void editProduct({
    required Barang oldProduct,
    required Barang newProduct,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final changes = _generateChangeLog(oldProduct: oldProduct, newProduct: newProduct);

    historyBox.add({
      'type': 'edit',
      'name': newProduct.name,
      'timestamp': timestamp,
      'changes': changes.split(', '), // Pisahkan perubahan menjadi daftar untuk tampilan
    });
  }
  String _generateChangeLog({Barang? oldProduct, Barang? newProduct}) {
    List<String> changes = [];

    if (oldProduct != null && newProduct != null) {
      if (oldProduct.name != newProduct.name) {
        changes.add('Nama diubah dari ${oldProduct.name} menjadi ${newProduct.name}');
      }
      if (oldProduct.sellPrice != newProduct.sellPrice) {
        changes.add(
          'Harga jual diubah dari Rp ${NumberFormat("#,##0", "id_ID").format(oldProduct.sellPrice)} '
          'menjadi Rp ${NumberFormat("#,##0", "id_ID").format(newProduct.sellPrice)}',
        );
      }
      if (oldProduct.stock != newProduct.stock) {
        changes.add('Stok diubah dari ${oldProduct.stock} menjadi ${newProduct.stock}');
      }
    }

    return changes.isNotEmpty ? changes.join(', ') : 'Tidak ada perubahan signifikan';
  }
}