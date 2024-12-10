import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sales_page.dart';

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
      await firestore.collection('payments').add({
        'customerName': _customerNameController.text.isNotEmpty
            ? _customerNameController.text
            : "Tidak Diketahui",
        'totalAmount': widget.totalAmount,
        'paidAmount': double.tryParse(_amountController.text) ?? 0.0,
        'change': _change,
        'date': Timestamp.now(),
        'items': widget.items.map((item) {
          return {
            'name': item['name'],
            'quantity': item['quantity'],
            'price': item['price'],
          };
        }).toList(),
      });

      await firestore.collection('wallet').add({
        'amount': widget.totalAmount,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi: $e');
    }
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Pembayaran",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
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
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Nama Pelanggan",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                hintText: "Masukkan Nama Pelanggan (Optional)",
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Jumlah Uang",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Masukkan Jumlah Uang",
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _calculateChange();
              },
            ),
            SizedBox(height: 20),
            Text(
              "Kembalian",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "Rp${NumberFormat('#,###', 'id_ID').format(_change)}",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _setAmount(widget.totalAmount),
                  child: Text("Uang Pas", style: GoogleFonts.poppins(fontSize: 14)),
                ),
                ElevatedButton(
                  onPressed: () => _setAmount(recommendations[0]),
                  child: Text(
                    "Rp${NumberFormat('#,###', 'id_ID').format(recommendations[0])}",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _setAmount(recommendations[1]),
                  child: Text(
                    "Rp${NumberFormat('#,###', 'id_ID').format(recommendations[1])}",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final currentContext = context;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/confirmation_image.png', height: 150),
                          SizedBox(height: 20),
                          Text(
                            "Pembayaran Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}",
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Konfirmasi pembayaran dengan total Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)} telah dibayarkan oleh pembeli.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Batal", style: GoogleFonts.poppins(color: Colors.red)),
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
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Toko Sinyo",
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "No. Toko: 08956432324",
                                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                      ),
                                      Divider(),
                                      Text(
                                        "Atas Nama: ${_customerNameController.text.isEmpty ? "Tidak Diketahui" : _customerNameController.text}",
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text(
                                        "Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text("Pembayaran: Tunai", style: GoogleFonts.poppins(fontSize: 14)),
                                      Divider(),
                                      Text(
                                        "Detail Pemesanan:",
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      ...widget.items.map((item) {
                                        return Text(
                                          "${item['name']} x ${item['quantity']} - Rp${NumberFormat('#,###', 'id_ID').format(item['price'] * item['quantity'])}",
                                          style: GoogleFonts.poppins(fontSize: 14),
                                        );
                                      }).toList(),
                                      Divider(),
                                      Text(
                                        "Total Pesanan: Rp${NumberFormat('#,###', 'id_ID').format(widget.totalAmount)}",
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text(
                                        "Bayar: Rp${NumberFormat('#,###', 'id_ID').format(double.tryParse(_amountController.text) ?? 0.0)}",
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Text(
                                        "Kembalian: Rp${NumberFormat('#,###', 'id_ID').format(_change)}",
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                      Divider(),
                                      Center(
                                        child: Text(
                                          "Terima Kasih\nSudah Berbelanja di Toko Kami",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // Tutup semua dialog dan navigasi ke SalesPage
                                      Navigator.popUntil(context, (route) => route.isFirst);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SalesPage(),
                                        ),
                                      );
                                    },
                                    child: Text("Tutup"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text("OK", style: GoogleFonts.poppins(color: Colors.green)),
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
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
