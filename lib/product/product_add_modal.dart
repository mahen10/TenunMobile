import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AddProductModal extends StatefulWidget {
  final VoidCallback onSuccess;

  const AddProductModal({required this.onSuccess, super.key});

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  String namaProduk = '', kategori = '', harga = '', stok = '', deskripsi = '';
  File? foto;

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _simpanProduk() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      _showAlert('Token tidak ditemukan!');
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Config.apiUrl}/api/produk'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['nama_produk'] = namaProduk;
    request.fields['kategori'] = kategori;
    request.fields['harga_jual'] = harga;
    request.fields['stok'] = stok;
    request.fields['deskripsi'] = deskripsi;
    if (foto != null) {
      request.files.add(await http.MultipartFile.fromPath('gambar', foto!.path));
    }

    final response = await request.send();
    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.pop(context);
      widget.onSuccess();
      _showAlert('Produk berhasil ditambahkan!');
    } else {
      _showAlert('Gagal menambahkan produk.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Produk'),
          backgroundColor: const Color(0xFFD7B44C),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Nama Produk'),
                      onChanged: (val) => namaProduk = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      onChanged: (val) => kategori = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Harga Jual'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => harga = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Stok'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => stok = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                      onChanged: (val) => deskripsi = val,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Pilih Foto'),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setModalState(() => foto = File(picked.path));
                        }
                      },
                    ),
                    if (foto != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.file(foto!, height: 100),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD7B44C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _simpanProduk,
                      child: const Text('Simpan Produk'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
