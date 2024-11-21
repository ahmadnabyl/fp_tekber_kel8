import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ProductHistory extends StatefulWidget {
  @override
  _ProductHistoryState createState() => _ProductHistoryState();
}

class _ProductHistoryState extends State<ProductHistory> {
  late Box<Map> historyBox;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Hive dengan menggunakan Hive Flutter
    historyBox = Hive.box<Map>('product_history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Produk"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(), // Ini mendengarkan perubahan data
        builder: (context, Box<Map> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                "Belum ada riwayat transaksi.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Membalikkan urutan data sehingga yang terbaru muncul di atas
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
                  title: Text(history['name'] ?? 'Produk'),
                  subtitle: Text(
                    "Aksi: ${_getActionText(history['type'], history['change'])}\nWaktu: ${_formatTimestamp(history['timestamp'])}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        // Menghapus riwayat produk sesuai dengan index yang benar
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

  String _getActionText(String type, [String? change]) {
    switch (type) {
      case 'add':
        return 'Produk Ditambahkan';
      case 'edit':
        return change ?? 'Perubahan Tidak Diketahui';
      case 'delete':
        return 'Produk Dihapus';
      default:
        return 'Tidak Diketahui';
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    // Menghapus milisecond dari format waktu
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}
