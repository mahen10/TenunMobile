import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:tenunapp/product/EditProductModal.dart';
import 'package:tenunapp/product/product_add_modal.dart';
import '../service/config.dart';


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

  void _confirmDeleteProduk(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
      appBar: AppBar(
          title: Text(
            'Tambah Produk',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFFD7B44C),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      backgroundColor: Colors.yellow[700],
      body: Column(
        children: [
          
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                produkTenun = _allProduk.where((p) {
                                  final nama = (p['nama_produk'] ?? '')
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
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddProductModal(
                                  onSuccess: _fetchProduk,
                                ),
                              );
                            },
                            icon: Icon(Icons.add_circle, size: 18),
                            label: Text('Tambah'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[700],
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
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
                        onRefresh: _fetchProduk,
                        child: produkTenun.isEmpty
                            ? ListView(
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
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: p['gambar'] != null
                                                ? Image.network(
                                                    '${Config.apiUrl}/storage/${p['gambar']}',
                                                    width: 65,
                                                    height: 65,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
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
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p['nama_produk'],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  numberFormat.format(
                                                    double.tryParse(p[
                                                                'harga_jual']
                                                            .toString()) ??
                                                        0,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          AlertDialog(
                                                        title:
                                                            Text('Detail Produk'),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                'Kategori: ${p['kategori'] ?? '-'}'),
                                                            Text(
                                                                'Stok: ${p['stok'] ?? 0}'),
                                                            Text(
                                                                'Deskripsi: ${p['deskripsi'] ?? '-'}'),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child:
                                                                const Text('Tutup'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'Lihat Detail',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: Colors.teal,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        EditProductModal(
                                                      produk: p,
                                                      onSuccess: _fetchProduk,
                                                    ),
                                                  );
                                                },
                                                tooltip: 'Edit',
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 22,
                                                ),
                                                onPressed: () =>
                                                    _confirmDeleteProduk(
                                                        p['id']),
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
