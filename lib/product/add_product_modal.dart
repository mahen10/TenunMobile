
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../service/config.dart';

Future<void> showTambahProdukModal(BuildContext context, VoidCallback onProductAdded) async {
  String namaProduk = '', kategori = '', harga = '', stok = '', deskripsi = '';
  File? foto;

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Tambah Produk'),
            backgroundColor: Color(0xFFD7B44C),
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: 'Nama Produk'),
                        onChanged: (val) => namaProduk = val,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Kategori'),
                        onChanged: (val) => kategori = val,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Harga Jual'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => harga = val,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Stok'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => stok = val,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Deskripsi'),
                        maxLines: 3,
                        onChanged: (val) => deskripsi = val,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Pilih Foto'),
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
                          padding: EdgeInsets.all(8),
                          child: Image.file(foto!, height: 100),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD7B44C),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('auth_token');
                          if (token == null) {
                            Navigator.pop(context);
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
                            onProductAdded();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Simpan Produk'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
