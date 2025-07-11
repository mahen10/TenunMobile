import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tenunapp/service/config.dart';
import 'package:tenunapp/transaction/tambah_pembelian_screen.dart';
import 'package:tenunapp/transaction/tambah_penjualan_screen.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool isPembelian = true;
  List<dynamic> _pembelian = [];
  List<dynamic> _penjualan = [];
  List<dynamic> produkList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final responses = await Future.wait([
        http.get(Uri.parse('${Config.apiUrl}/api/pembelian-bahan'),
            headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('${Config.apiUrl}/api/penjualan'),
            headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('${Config.apiUrl}/api/produk'),
            headers: {'Authorization': 'Bearer $token'}),
      ]);

      setState(() {
        _pembelian = responses[0].statusCode == 200 ? json.decode(responses[0].body) : [];
        _penjualan = responses[1].statusCode == 200 ? json.decode(responses[1].body) : [];
        produkList = responses[2].statusCode == 200 ? json.decode(responses[2].body) : [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isPembelian
            ? TambahPembelianScreen(onSaved: _fetchData)
            : TambahPenjualanScreen(onSaved: _fetchData),
      ),
    );
  }

  String _getNamaProduk(dynamic produkId) {
    final produk = produkList.firstWhere(
      (p) => p['id'].toString() == produkId.toString(),
      orElse: () => {'nama_produk': 'Produk Tidak Ditemukan'},
    );
    return produk['nama_produk'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 192, 45, 1),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: const Color.fromARGB(255, 255, 255, 255)),
                SizedBox(width: 16),
                Text('Transaksi',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => isPembelian = true),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isPembelian ? Colors.black : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text("Pembelian",
                                      style: TextStyle(
                                          color: isPembelian ? Colors.white : Colors.black)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => isPembelian = false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !isPembelian ? Colors.black : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text("Penjualan",
                                      style: TextStyle(
                                          color: !isPembelian ? Colors.white : Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToAddTransaction,
                          child: Row(
                            children: [
                              Icon(Icons.add_circle, color: Colors.cyan),
                              SizedBox(width: 5),
                              Text(isPembelian ? 'Pembelian' : 'Penjualan',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: isPembelian ? _pembelian.length : _penjualan.length,
                        itemBuilder: (context, index) {
                          final data = isPembelian ? _pembelian[index] : _penjualan[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 65,
                                      height: 65,
                                      color: Colors.yellow[100],
                                      child: Icon(
                                        isPembelian ? Icons.shopping_cart : Icons.sell,
                                        size: 36,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isPembelian
                                              ? data['nama_bahan']
                                              : _getNamaProduk(data['produk_id']),
                                          style: GoogleFonts.poppins(
                                              fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isPembelian
                                              ? 'Jumlah: ${data['jumlah']} | Total: Rp${data['harga_total']}'
                                              : 'Jumlah: ${data['jumlah_terjual']} | Total: Rp${data['total_harga']}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tanggal: ${data[isPembelian ? 'tanggal_pembelian' : 'tanggal_penjualan']}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13, color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
