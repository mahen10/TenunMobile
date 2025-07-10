import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'transaction_screen.dart';
import 'product/product_screen.dart'; // Halaman produk
import 'report_screen.dart'; // Dummy
import 'account_screen.dart'; // ⬅ Pastikan ini diimpor juga

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // ✅ Lengkapi dengan 5 halaman sesuai navbar
  final List<Widget> _pages = [
    HomeScreen(), // index 0
    TransactionScreen(), // index 1
    ProdukPage(), // index 2
    ReportScreen(), // index 3
    AccountScreen(), // index 4
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onTap,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.receipt),
      //       label: 'Transaksi',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.description),
      //       label: 'Laporan',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      //   ],
      //   selectedItemColor: Colors.yellow,
      //   unselectedItemColor: Colors.grey,
      //   type: BottomNavigationBarType.fixed,
      // ),
    );
  }
}
