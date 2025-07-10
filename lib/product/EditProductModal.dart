import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class EditProductModal extends StatefulWidget {
  final Map<String, dynamic> produk;
  final Function onSuccess;

  const EditProductModal({
    Key? key,
    required this.produk,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _EditProductModalState createState() => _EditProductModalState();
}

class _EditProductModalState extends State<EditProductModal> {
  late TextEditingController namaProdukController;
  late TextEditingController kategoriController;
  late TextEditingController hargaController;
  late TextEditingController stokController;
  late TextEditingController deskripsiController;
  File? foto;

  @override
  void initState() {
    super.initState();
    namaProdukController = TextEditingController(text: widget.produk['nama_produk'] ?? '');
    kategoriController = TextEditingController(text: widget.produk['kategori'] ?? '');
    hargaController = TextEditingController(text: widget.produk['harga_jual'].toString());
    stokController = TextEditingController(text: widget.produk['stok'].toString());
    deskripsiController = TextEditingController(text: widget.produk['deskripsi'] ?? '');
  }

  @override
  void dispose() {
    namaProdukController.dispose();
    kategoriController.dispose();
    hargaController.dispose();
    stokController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

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

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      _showAlert('Token tidak ditemukan!');
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Config.apiUrl}/api/produk/${widget.produk['id']}?_method=PUT'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['nama_produk'] = namaProdukController.text;
    request.fields['kategori'] = kategoriController.text;
    request.fields['harga_jual'] = hargaController.text;
    request.fields['stok'] = stokController.text;
    request.fields['deskripsi'] = deskripsiController.text;

    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar',
          foto!.path,
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pop(context);
      widget.onSuccess();
      _showAlert('Produk berhasil diupdate!');
    } else {
      _showAlert('Gagal update produk.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Produk'),
          backgroundColor: const Color(0xFFD7B44C),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                  controller: namaProdukController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  controller: kategoriController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Harga Jual'),
                  keyboardType: TextInputType.number,
                  controller: hargaController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                  controller: stokController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                  controller: deskripsiController,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Pilih Foto (Opsional)'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      setState(() => foto = File(picked.path));
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
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD7B44C),
                  ),
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
