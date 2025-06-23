import 'package:flutter/material.dart';
import 'login.dart'; // Impor file login
import 'register_screen.dart';
import 'transaction_screen.dart';
import 'main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Tenun',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) => MainScreen(), // <-- ini halaman utama
      },
    );
  }
}

// Placeholder untuk HomeScreen (buat file terpisah nanti)
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beranda')),
      body: Center(child: Text('Selamat datang di Beranda!')),
    );
  }
}