import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'config.dart';

class ProdukPage extends StatefulWidget {
  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final _searchController = TextEditingController();
  List<dynamic> produkTenun = [];
  List<dynamic> _allProduk = [];
  final numberFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  Future<void> _fetchProduk() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      print('Token tidak ditemukan');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/produk'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _allProduk = data;
          produkTenun = data;
          _searchController.clear();
        });
      } else {
        print('Gagal ambil produk: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetch produk: $e');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  void _showTambahProdukModal() {
    String namaProduk = '',
        kategori = '',
        harga = '',
        stok = '',
        deskripsi = '';
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
                            final picked = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
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
                              request.files.add(
                                await http.MultipartFile.fromPath(
                                  'gambar',
                                  foto!.path,
                                ),
                              );
                            }

                            final response = await request.send();
                            if (response.statusCode == 201 ||
                                response.statusCode == 200) {
                              Navigator.pop(context);
                              _fetchProduk();
                              _showAlert('Produk berhasil ditambahkan!');
                            } else {
                              _showAlert('Gagal menambahkan produk.');
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

void _showEditProdukModal(Map<String, dynamic> produk) {
  final namaProdukController = TextEditingController(text: produk['nama_produk'] ?? '');
  final kategoriController = TextEditingController(text: produk['kategori'] ?? '');
  final hargaController = TextEditingController(text: produk['harga_jual'].toString());
  final stokController = TextEditingController(text: produk['stok'].toString());
  final deskripsiController = TextEditingController(text: produk['deskripsi'] ?? '');
  File? foto;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Edit Produk'),
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
                        controller: namaProdukController,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Kategori'),
                        controller: kategoriController,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Harga Jual'),
                        keyboardType: TextInputType.number,
                        controller: hargaController,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Stok'),
                        keyboardType: TextInputType.number,
                        controller: stokController,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Deskripsi'),
                        maxLines: 3,
                        controller: deskripsiController,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Pilih Foto (Opsional)'),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
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
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('auth_token');
                          if (token == null) {
                            _showAlert('Token tidak ditemukan!');
                            return;
                          }

                          var request = http.MultipartRequest(
                            'POST',
                            Uri.parse('${Config.apiUrl}/api/produk/${produk['id']}?_method=PUT'),
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
                            _fetchProduk();
                            _showAlert('Produk berhasil diupdate!');
                          } else {
                            _showAlert('Gagal update produk.');
                          }
                        },
                        child: Text('Simpan Perubahan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD7B44C),
                        ),
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



  void _confirmDeleteProduk(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Konfirmasi Hapus'),
            content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('auth_token');
                  if (token == null) {
                    _showAlert('Token tidak ditemukan!');
                    return;
                  }

                  final response = await http.delete(
                    Uri.parse('${Config.apiUrl}/api/produk/$id'),
                    headers: {'Authorization': 'Bearer $token'},
                  );

                  if (response.statusCode == 200) {
                    _fetchProduk();
                    _showAlert('Produk berhasil dihapus!');
                  } else {
                    _showAlert('Gagal hapus produk.');
                  }
                },
                child: Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.yellow[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.black),
                SizedBox(width: 16),
                Text(
                  'Produk Tenun',
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
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari Produk',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              String keyword =
                                  _searchController.text.toLowerCase();
                              setState(() {
                                produkTenun =
                                    _allProduk.where((p) {
                                      final nama =
                                          (p['nama_produk'] ?? '')
                                              .toString()
                                              .toLowerCase();
                                      return nama.contains(keyword);
                                    }).toList();
                              });
                            },
                            child: Text('Cari'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _showTambahProdukModal,
                            icon: Icon(Icons.add_circle, size: 18),
                            label: Text('Tambah'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[700],
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchProduk, // Auto Refresh
                        child:
                            produkTenun.isEmpty
                                ? ListView(
                                  // Supaya tetap bisa tarik walau kosong
                                  children: [
                                    SizedBox(height: 100),
                                    Center(child: Text('Belum ada produk')),
                                  ],
                                )
                                : ListView.builder(
                                  itemCount: produkTenun.length,
                                  itemBuilder: (context, index) {
                                    final p = produkTenun[index];
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Gambar Produk
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child:
                                                  p['gambar'] != null
                                                      ? Image.network(
                                                        '${Config.apiUrl}/storage/${p['gambar']}',
                                                        width: 65,
                                                        height: 65,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Icon(
                                                            Icons.broken_image,
                                                            size: 65,
                                                          );
                                                        },
                                                      )
                                                      : Icon(
                                                        Icons.image,
                                                        size: 65,
                                                      ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Info Produk
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p['nama_produk'],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    numberFormat.format(
                                                      double.tryParse(
                                                            p['harga_jual']
                                                                .toString(),
                                                          ) ??
                                                          0,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (_) => AlertDialog(
                                                              title: Text(
                                                                'Detail Produk',
                                                              ),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Kategori: ${p['kategori'] ?? '-'}',
                                                                  ),
                                                                  Text(
                                                                    'Stok: ${p['stok'] ?? 0}',
                                                                  ),
                                                                  Text(
                                                                    'Deskripsi: ${p['deskripsi'] ?? '-'}',
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  child:
                                                                      const Text(
                                                                        'Tutup',
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                      );
                                                    },
                                                    child: Text(
                                                      'Lihat Detail',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            color: Colors.teal,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Tombol Edit & Hapus
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                    size: 22,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _showEditProdukModal(
                                                            p,
                                                          ),
                                                  tooltip: 'Edit',
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 22,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _confirmDeleteProduk(
                                                            p['id'],
                                                          ),
                                                  tooltip: 'Hapus',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
