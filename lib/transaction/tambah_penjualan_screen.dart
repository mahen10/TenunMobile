import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tenunapp/service/config.dart';

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Harap lengkapi semua data')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Penjualan berhasil disimpan!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan penjualan.')));
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
              items: produkList.map((produk) {
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
                  _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
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
