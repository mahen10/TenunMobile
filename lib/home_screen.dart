import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:intl/intl.dart';
import 'transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  String? vendorName;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProducts();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vendorName = prefs.getString('vendor_name') ?? 'Admin Vendor';
    });
  }

  Future<void> _fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/produk'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data is List ? data : [];
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
        HomeContent(products: products, vendorName: vendorName ?? 'Admin Vendor'),
        TransactionScreen(),
        Center(child: Text('Produk Page', style: TextStyle(fontSize: 24))),
        Center(child: Text('Laporan Page', style: TextStyle(fontSize: 24))),
        Center(child: Text('Akun Page', style: TextStyle(fontSize: 24))),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        elevation: 0,
        toolbarHeight: 0, // Menyembunyikan tinggi AppBar
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.yellow[700],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Transaksi'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),
            BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Laporan'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<dynamic> products;
  final String vendorName;

  HomeContent({this.products = const [], required this.vendorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/user.png'),
                  radius: 30,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat Datang', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(vendorName, style: TextStyle(color: Colors.black87, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightGreen[100],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tahun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Container(height: 150, child: CustomPaint(painter: BarChartPainter())),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text('Produk Tenun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ...products.map((product) => ProductCard(
                      image: 'assets/${product['gambar'] ?? 'default.jpg'}',
                      name: product['nama_produk'],
                      category: 'Kategori: ${product['kategori'] ?? 'Unknown'}',
                      stock: 'Stok: ${product['stok'] ?? 0}',
                      price: product['harga_jual'] != null
                          ? 'Rp ${numberFormat.format(product['harga_jual'])}'
                          : 'Rp 0',
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;
    final List<double> data = [2, 5, 8, 3];
    final maxValue = 10.0;
    final barWidth = size.width / data.length / 1.5;
    final barSpacing = barWidth / 2;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * (size.height - 20);
      final rect = Rect.fromLTWH(
        i * (barWidth + barSpacing),
        size.height - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final String category;
  final String stock;
  final String price;

  ProductCard({required this.image, required this.name, required this.category, required this.stock, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(image, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(category, style: TextStyle(color: Colors.blue)), Text(stock)],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(price),
            TextButton(onPressed: () {}, child: Text('Detail')),
          ],
        ),
      ),
    );
  }
}

final numberFormat = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
