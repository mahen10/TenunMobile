import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tenunapp/config.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool isPembelian = true;
  List<dynamic> _pembelian = [];
  List<dynamic> _penjualan = [];
  List<dynamic> produkList = []; // Tambahkan ini di atas

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
        http.get(
          Uri.parse('${Config.apiUrl}/api/pembelian-bahan'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        http.get(
          Uri.parse('${Config.apiUrl}/api/penjualan'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        http.get(
          // FETCH PRODUK SEKALIAN!
          Uri.parse('${Config.apiUrl}/api/produk'),
          headers: {'Authorization': 'Bearer $token'},
        ),
      ]);

      setState(() {
        _pembelian =
            responses[0].statusCode == 200
                ? json.decode(responses[0].body)
                : [];
        _penjualan =
            responses[1].statusCode == 200
                ? json.decode(responses[1].body)
                : [];
        produkList =
            responses[2].statusCode == 200
                ? json.decode(responses[2].body)
                : [];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                isPembelian
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
      backgroundColor: Colors.yellow[700],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.black),
                SizedBox(width: 16),
                Text(
                  'Transaksi',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isPembelian
                                            ? Colors.black
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "Pembelian",
                                    style: TextStyle(
                                      color:
                                          isPembelian
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () => setState(() => isPembelian = false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        !isPembelian
                                            ? Colors.black
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "Penjualan",
                                    style: TextStyle(
                                      color:
                                          !isPembelian
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
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
                              Text(
                                isPembelian ? 'Pembelian' : 'Penjualan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            isPembelian ? _pembelian.length : _penjualan.length,
                        itemBuilder: (context, index) {
                          final data =
                              isPembelian
                                  ? _pembelian[index]
                                  : _penjualan[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ikon
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 65,
                                      height: 65,
                                      color: Colors.yellow[100],
                                      child: Icon(
                                        isPembelian
                                            ? Icons.shopping_cart
                                            : Icons.sell,
                                        size: 36,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Info Transaksi
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isPembelian
                                              ? data['nama_bahan']
                                              : _getNamaProduk(
                                                data['produk_id'],
                                              ),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isPembelian
                                              ? 'Jumlah: ${data['jumlah']} | Total: Rp${data['harga_total']}'
                                              : 'Jumlah: ${data['jumlah_terjual']} | Total: Rp${data['total_harga']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tanggal: ${data[isPembelian ? 'tanggal_pembelian' : 'tanggal_penjualan']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
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

// Tambah Pembelian
class TambahPembelianScreen extends StatefulWidget {
  final VoidCallback onSaved;
  TambahPembelianScreen({required this.onSaved});

  @override
  State<TambahPembelianScreen> createState() => _TambahPembelianScreenState();
}

class _TambahPembelianScreenState extends State<TambahPembelianScreen> {
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _hargaController = TextEditingController();
  final _tanggalController = TextEditingController();

  Future<void> _simpanPembelian() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    await http.post(
      Uri.parse('${Config.apiUrl}/api/pembelian-bahan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nama_bahan': _namaController.text,
        'jumlah': int.parse(_jumlahController.text),
        'harga_total': double.parse(_hargaController.text),
        'tanggal_pembelian': _tanggalController.text,
      }),
    );

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Pembelian')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama Bahan'),
            ),
            TextField(
              controller: _jumlahController,
              decoration: InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _hargaController,
              decoration: InputDecoration(labelText: 'Harga Total'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _tanggalController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Tanggal Pembelian'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  _tanggalController.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(picked);
                }
              },
            ),
            ElevatedButton(onPressed: _simpanPembelian, child: Text('Simpan')),
          ],
        ),
      ),
    );
  }
}

// Tambah Penjualan
class TambahPenjualanScreen extends StatefulWidget {
  final VoidCallback onSaved;
  TambahPenjualanScreen({required this.onSaved});

  @override
  State<TambahPenjualanScreen> createState() => _TambahPenjualanScreenState();
}

class _TambahPenjualanScreenState extends State<TambahPenjualanScreen> {
  List<dynamic> produkList = [];
  int? selectedProdukId;
  final _jumlahController = TextEditingController();
  final _tanggalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  Future<void> _fetchProduk() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('${Config.apiUrl}/api/produk'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        produkList = json.decode(response.body);
      });
    }
  }

  Future<void> _simpanPenjualan() async {
    if (selectedProdukId == null ||
        _jumlahController.text.isEmpty ||
        _tanggalController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Harap lengkapi semua data')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('${Config.apiUrl}/api/penjualan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'produk_id': selectedProdukId,
        'jumlah_terjual': int.parse(_jumlahController.text),
        'tanggal_penjualan': _tanggalController.text,
      }),
    );

    if (response.statusCode == 201) {
      widget.onSaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Penjualan berhasil disimpan!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan penjualan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Penjualan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedProdukId,
              items:
                  produkList.map((produk) {
                    return DropdownMenuItem<int>(
                      value: produk['id'],
                      child: Text(produk['nama_produk']),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProdukId = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pilih Produk',
                filled: true,
                fillColor: Colors.green[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            TextField(
              controller: _jumlahController,
              decoration: InputDecoration(labelText: 'Jumlah Terjual'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _tanggalController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Tanggal Penjualan'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  _tanggalController.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(picked);
                }
              },
            ),
            ElevatedButton(onPressed: _simpanPenjualan, child: Text('Simpan')),
          ],
        ),
      ),
    );
  }
}
