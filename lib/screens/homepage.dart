import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:intl/intl.dart'; // Untuk format angka
import 'product_catalog.dart';
import 'product_history.dart';
import 'sales_page.dart'; // Impor halaman SalesPage
import 'wallet_page.dart'; // Impor halaman WalletPage
import 'pusatbantuan.dart'; // Impor halaman Pusat Bantuan

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBalanceHidden = false; // State untuk menyembunyikan/memperlihatkan saldo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Bagian header dengan gradasi
            DrawerHeader(
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
                            'Toko Sinyo',
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
                  // Bagian saldo dengan StreamBuilder untuk mengambil data dari Firestore
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('wallet').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error', style: GoogleFonts.poppins(color: Colors.red));
                      }

                      // Menghitung total saldo dari data wallet
                      final walletData = snapshot.data?.docs ?? [];
                      final totalBalance = walletData.fold<double>(
                        0.0,
                        (previousValue, element) => previousValue + (element['amount'] ?? 0.0),
                      );

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                      : "Rp${NumberFormat('#,###', 'id_ID').format(totalBalance)}",
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
                                _isBalanceHidden ? Icons.visibility_off : Icons.visibility,
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
                      );
                    },
                  ),
                ],
              ),
            ),
            // Menu item
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.black),
              title: Text(
                'Dasbor',
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
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
                  MaterialPageRoute(builder: (context) => ProductCatalog()),
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
                  MaterialPageRoute(builder: (context) => SalesPage()),
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
                  MaterialPageRoute(builder: (context) => ProductHistory()),
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
                  MaterialPageRoute(builder: (context) => WalletPage()),
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
                Navigator.pop(context); // Tambahkan aksi logout jika diperlukan
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color.fromARGB(255, 190, 207, 253)], // Gradasi putih ke biru muda
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
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                              "Halo, Toko Sinyo!",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16 ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Saldo",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        StreamBuilder(
                                          stream: FirebaseFirestore.instance.collection('wallet').snapshots(),
                                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Text("Loading...");
                                            }

                                            final walletData = snapshot.data?.docs ?? [];
                                            final totalBalance = walletData.fold<double>(
                                              0.0,
                                              (previousValue, element) => previousValue + (element['amount'] ?? 0.0),
                                            );

                                            return Text(
                                              _isBalanceHidden
                                                  ? "*****"
                                                  : "Rp${NumberFormat('#,###', 'id_ID').format(totalBalance)}",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 17,
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            _isBalanceHidden
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isBalanceHidden = !_isBalanceHidden;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
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
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PusatBantuan()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductCatalog())),
                    ),
                    buildCard(
                      title: "Penjualan",
                      icon: Icons.monetization_on_outlined,
                      context: context,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SalesPage())),
                    ),
                    buildCard(
                      title: "Riwayat Produk",
                      icon: Icons.history_outlined,
                      context: context,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductHistory())),
                    ),
                    buildCard(
                      title: "Dompet",
                      icon: Icons.account_balance_wallet_outlined,
                      context: context,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WalletPage())),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          color: Colors.white,
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