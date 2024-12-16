import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:intl/intl.dart'; // Untuk format angka
import 'product_catalog.dart';
import 'product_history.dart';
import 'sales_page.dart'; // Impor halaman SalesPage
import 'wallet_page.dart'; // Impor halaman WalletPage
import 'pusatbantuan.dart'; // Impor halaman Pusat Bantuan
import 'landing_page.dart';

class HomePage extends StatefulWidget {
  final String userId; // Tambahkan userId sebagai parameter
  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBalanceHidden =
      false; // State untuk menyembunyikan/memperlihatkan saldo

  Stream<double> _getWalletBalanceStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('wallet')
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] as num).toDouble();
      }
      return total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFFA4C8EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFFA4C8EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Data tidak ditemukan",
                        style: GoogleFonts.poppins(color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  );
                }

                final userDoc = snapshot.data!;
                final storeName = userDoc['name'] ?? 'Toko Sinyo';

                return StreamBuilder<double>(
                  stream: _getWalletBalanceStream(),
                  builder: (context, saldoSnapshot) {
                    final saldo = saldoSnapshot.data ?? 0.0;

                    return DrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFFA4C8EA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                size: 50,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storeName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Admin',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Saldo",
                                      style: GoogleFonts.poppins(
                                        color: Color(0xFF4A90E2),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _isBalanceHidden
                                          ? "*****"
                                          : "Rp${NumberFormat('#,###', 'id_ID').format(saldo)}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isBalanceHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Color(0xFF4A90E2),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isBalanceHidden = !_isBalanceHidden;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.black),
              title: Text(
                'Dasbor',
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.black),
              title: Text(
                'Katalog Produk',
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProductCatalog(userId: widget.userId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on, color: Colors.black),
              title: Text(
                'Penjualan',
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SalesPage(userId: widget.userId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.black),
              title: Text(
                'Riwayat Produk',
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProductHistory(userId: widget.userId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.black),
              title: Text(
                'Dompet',
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WalletPage(userId: widget.userId)),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // Sudut membulat
                      ),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Ukuran sesuai isi
                          children: [
                            // Judul
                            Text(
                              "Logout",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 12),
                            // Isi teks
                            Text(
                              "Apakah kamu yakin ingin keluar dari aplikasi?",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            // Tombol Tidak dan Ya
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // Pusatkan tombol
                              children: [
                                // Tombol Tidak
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(
                                        dialogContext); // Tutup dialog
                                  },
                                  child: Text(
                                    "Tidak",
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12), // Jarak antara tombol
                                // Tombol Ya
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(
                                        dialogContext); // Tutup dialog
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LandingPage()),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Text(
                                    "Ya",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                "Data tidak ditemukan",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          final userDoc = snapshot.data!;
          final storeName = userDoc['name'] ?? 'Toko Sinyo';

          return StreamBuilder<double>(
            stream: _getWalletBalanceStream(),
            builder: (context, saldoSnapshot) {
              final saldo = saldoSnapshot.data ?? 0.0;

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 255, 255),
                      Color.fromARGB(255, 255, 255, 255)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      title: Text(
                        "Dasbor",
                        style: GoogleFonts.poppins(
                          color: Color(0xFF6F92D8),
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      centerTitle: true,
                      leading: Builder(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.menu, color: Color(0xFF6F92D8)),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4A90E2), Color(0xFFA4C8EA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Halo, Toko $storeName!",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Saldo",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _isBalanceHidden
                                              ? "*****"
                                              : "Rp${NumberFormat('#,###', 'id_ID').format(saldo)}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.account_circle,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PusatBantuan()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                child: Text(
                                  "Pusat Bantuan",
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF4A90E2),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            buildCard(
                              title: "Katalog Produk",
                              icon: Icons.shopping_cart_outlined,
                              context: context,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProductCatalog(userId: widget.userId)),
                              ),
                            ),
                            buildCard(
                              title: "Penjualan",
                              icon: Icons.monetization_on_outlined,
                              context: context,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SalesPage(userId: widget.userId)),
                              ),
                            ),
                            buildCard(
                              title: "Riwayat Produk",
                              icon: Icons.history_outlined,
                              context: context,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProductHistory(userId: widget.userId)),
                              ),
                            ),
                            buildCard(
                              title: "Dompet",
                              icon: Icons.account_balance_wallet_outlined,
                              context: context,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WalletPage(userId: widget.userId)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildCard({
    required String title,
    required IconData icon,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 242, 242),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Color(0xFF4A90E2)),
            SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
