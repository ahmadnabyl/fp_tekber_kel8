import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';  // Import Google Fonts
import 'product_catalog.dart';
import 'product_history.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SingleChildScrollView(
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF6F92D8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 50,
                          color: Color.fromARGB(255, 247, 247, 247),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Toko Nabil',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Admin',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        title: Text(
                          "Saldo",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Color.fromARGB(255, 32, 132, 213),
                          ),
                        ),
                        subtitle: Text(
                          "Rp0",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 88, 88, 88),
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 111, 146, 216),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          ),
                          child: Text(
                            "Dompet",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text(
                'Katalog Produk',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductCatalog()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text(
                'Riwayat Transaksi',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductHistory()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text(
                'Penjualan',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Aksi untuk penjualan
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Aksi untuk logout
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // Mengatur latar belakang keseluruhan putih
        child: Column(
          children: [
            AppBar(
              backgroundColor: Color(0xFFF5F5F5), // Warna putih tulang
              elevation: 0,
              title: Text(
                "Dasbor",
                style: GoogleFonts.poppins(
                  color: Color(0xFF6F92D8), // Warna teks
                  fontWeight: FontWeight.w600, // Sedikit tebal
                ),
              ),
              centerTitle: true,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/header.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Halo, ",
                                  style: GoogleFonts.poppins(
                                    color: const Color.fromARGB(255, 88, 88, 88),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Toko Sinyo!",
                                  style: GoogleFonts.poppins(
                                    color: const Color.fromARGB(255, 88, 88, 88),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                "Pusat Bantuan",
                                style: GoogleFonts.poppins(
                                    color: Color.fromARGB(255, 111, 146, 216)),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.account_circle,
                            color: const Color.fromARGB(255, 182, 182, 182),
                            size: 55,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Saldo",
                              style: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 32, 132, 213),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Rp0",
                              style: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 88, 88, 88),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 111, 146, 216),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          ),
                          child: Text(
                            "Dompet",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    HomeCard(
                      title: "Katalog Produk",
                      icon: Icons.shopping_cart_outlined,
                      color: Color(0xFFEFF4FA),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductCatalog(),
                          ),
                        );
                      },
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14, 
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 20),
                    HomeCard(
                      title: "Penjualan",
                      icon: Icons.monetization_on_outlined,
                      color: Color(0xFFEFF4FA),
                      onTap: () {},
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 20),
                    HomeCard(
                      title: "Riwayat Transaksi",
                      icon: Icons.history,
                      color: Color(0xFFEFF4FA),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductHistory(),
                          ),
                        );
                      },
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
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
}

class HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final TextStyle textStyle;

  const HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                icon,
                size: 40,
                color: const Color.fromARGB(255, 94, 122, 172),
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
