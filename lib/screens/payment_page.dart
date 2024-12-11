import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sales_page.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  PaymentPage({required this.totalAmount, required this.items});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  double _change = 0.0;

  void _calculateChange() {
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _change = enteredAmount - widget.totalAmount;
    });
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
    _calculateChange();
  }

  List<double> _getRecommendations() {
    if (widget.totalAmount <= 100000) {
      return [widget.totalAmount + 15000, widget.totalAmount + 45000];
    } else {
      return [widget.totalAmount + 5000, widget.totalAmount + 35000];
    }
  }

  Future<void> _savePayment() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Simpan data pembayaran ke koleksi 'payments'
      await firestore.collection('payments').add({
        'customerName': _customerNameController.text.isNotEmpty
            ? _customerNameController.text
            : "Tidak Diketahui",
        'totalAmount': widget.totalAmount,
        'paidAmount': double.tryParse(_amountController.text) ?? 0.0,
        'change': _change,
        'timestamp': Timestamp.now(),
        'items': widget.items.map((item) {
          return {
            'name': item['name'],
            'quantity': item['quantity'],
            'price': item['price'],
          };
        }).toList(),
      });

      // Simpan data ke koleksi 'wallet'
      await firestore.collection('wallet').add({
        'amount': widget.totalAmount,
        'timestamp': Timestamp.now(),
      });

      // Simpan data ke koleksi 'product_history'
      for (var item in widget.items) {
        await firestore.collection('product_history').add({
          'type': 'sale',
          'name': item['name'],
          'quantitySold': item['quantity'],
          'price': item['price'],
          'totalPrice': item['price'] * item['quantity'],
          'customerName': _customerNameController.text.isNotEmpty
              ? _customerNameController.text
              : "Tidak Diketahui",
          'timestamp': Timestamp.now(),
        });
      }

      // Perbarui stok produk di Firestore
      final batch = firestore.batch();
      for (var item in widget.items) {
        final productRef = firestore.collection('products').doc(item['id']);
        batch.update(productRef, {
          'stock': FieldValue.increment(-item['quantity']), // Kurangi stok
        });
      }
      await batch.commit(); // Eksekusi pembaruan stok
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi: $e');
    }
  }

  Future<void> _generatePDF() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Toko Sinyo",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
          pw.Divider(),
          pw.Text("Atas Nama: ${_customerNameController.text.isEmpty ? "Tidak Diketahui" : _customerNameController.text}"),
          pw.Text("Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.now())}"),
          pw.Text("Pembayaran: Tunai"),
          pw.Divider(),
          pw.Text("Detail Pemesanan:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...widget.items.map((item) {
            return pw.Text("${item['name']} x ${item['quantity']} - Rp${NumberFormat('#,###', 'id_ID').format(item['price'] * item['quantity'])}");
          }).toList(),
          pw.Divider(),
          pw.Text("Total Pesanan: Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}"),
          pw.Text("Bayar: Rp${NumberFormat('#,###', 'id_ID').format(double.tryParse(_amountController.text) ?? 0.0)}"),
          pw.Text("Kembalian: Rp${NumberFormat('#,###', 'id_ID').format(_change)}"),
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              "Terima Kasih\nSudah Berbelanja di Toko Kami",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );

  // Tampilkan dialog print/save
  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: Text(
          "Pembayaran",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Pembayaran",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}",
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Nama Pelanggan",
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                hintText: "Masukkan Nama Pelanggan (Optional)",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 13, // Perkecil ukuran teks hint di sini
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Jumlah Uang",
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Masukkan Jumlah Uang",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 13, // Ubah ukuran hint di sini
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _calculateChange();
              },
            ),
            SizedBox(height: 20),
            Text(
              "Kembalian",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "Rp${NumberFormat('#,###', 'id_ID').format(_change)}",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Wrap(
                  spacing: 6.0, // Jarak horizontal antar tombol
                  runSpacing:
                      6.0, // Jarak vertikal antar tombol jika wrap terjadi
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _setAmount(widget.totalAmount),
                      child: Text("Uang Pas",
                          style: GoogleFonts.poppins(fontSize: 11)),
                    ),
                    ElevatedButton(
                      onPressed: () => _setAmount(recommendations[0]),
                      child: Text(
                        "Rp${NumberFormat('#,###', 'id_ID').format(recommendations[0])}",
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _setAmount(recommendations[1]),
                      child: Text(
                        "Rp${NumberFormat('#,###', 'id_ID').format(recommendations[1])}",
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Validasi field "Jumlah Uang"
                  if (_amountController.text.isEmpty ||
                      (double.tryParse(_amountController.text) ?? 0) <
                          widget.totalAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Jumlah Uang tidak boleh kosong dan harus mencukupi total pembayaran.",
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return; // Batalkan aksi jika validasi gagal
                  }

                  // Jika validasi berhasil, lanjutkan
                  final currentContext = context;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/confirmation_image.png',
                              height: 150),
                          SizedBox(height: 20),
                          Text(
                            "Pembayaran Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Konfirmasi pembayaran dengan total Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)} telah dibayarkan oleh pembeli.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Batal",
                              style: GoogleFonts.poppins(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _savePayment();
                            showDialog(
                              context: currentContext,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  "Struk Pembayaran",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Toko Sinyo",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Divider(),
                                      Text(
                                        "Atas Nama: ${_customerNameController.text.isEmpty ? "Tidak Diketahui" : _customerNameController.text}",
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text(
                                        "Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text(
                                        "Pembayaran: Tunai",
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Divider(),
                                      Text(
                                        "Detail Pemesanan:",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      ...widget.items.map((item) {
                                        return Text(
                                          "${item['name']} x ${item['quantity']} - Rp${NumberFormat('#,###', 'id_ID').format(item['price'] * item['quantity'])}",
                                          style:
                                              GoogleFonts.poppins(fontSize: 14),
                                        );
                                      }).toList(),
                                      Divider(),
                                      Text(
                                        "Total Pesanan: Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}",
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text(
                                        "Bayar: Rp${NumberFormat('#,###', 'id_ID').format(double.tryParse(_amountController.text) ?? 0.0)}",
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text(
                                        "Kembalian: Rp${NumberFormat('#,###', 'id_ID').format(_change)}",
                                        style:
                                            GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Divider(),
                                      Center(
                                        child: Text(
                                          "Terima Kasih\nSudah Berbelanja di Toko Kami",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.popUntil(context, (route) => route.isFirst);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SalesPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 238, 115, 106),
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Tutup",
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Panggil fungsi untuk generate PDF
                                      await _generatePDF();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 119, 158, 238),
                                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Cetak",
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text("OK",
                              style: GoogleFonts.poppins(color: Colors.green)),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Konfirmasi Pembayaran",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}