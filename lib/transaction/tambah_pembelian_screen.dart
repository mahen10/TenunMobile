import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tenunapp/service/config.dart';

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
                  _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
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
