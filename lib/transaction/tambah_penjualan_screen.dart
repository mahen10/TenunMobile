import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
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

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
      _showSnackBar('Harap lengkapi semua data');
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
      _showSnackBar('Penjualan berhasil disimpan!');
    } else {
      _showSnackBar('Gagal menyimpan penjualan.', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Penjualan',
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
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFD7B44C)),
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // Pilih Produk
                  Text(
                    'Pilih Produk',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DropdownButtonFormField<int>(
                      value: selectedProdukId,
                      items:
                          produkList.map((produk) {
                            return DropdownMenuItem<int>(
                              value: produk['id'],
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      produk['nama_produk'],
                                      style: GoogleFonts.poppins(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          produk['stok'] > 0
                                              ? Colors.green[100]
                                              : Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Stok: ${produk['stok']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            produk['stok'] > 0
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      selectedItemBuilder: (BuildContext context) {
                        return produkList.map((produk) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              produk['nama_produk'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      onChanged: (value) {
                        setState(() {
                          selectedProdukId = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        hintText: 'Pilih Produk',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Jumlah Terjual
                  Text(
                    'Jumlah Terjual',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        hintText: 'Masukkan jumlah terjual',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tanggal Penjualan
                  Text(
                    'Tanggal Penjualan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _tanggalController,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        hintText: 'Pilih tanggal penjualan',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                      ),
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
                  ),
                  const SizedBox(height: 40),

                  // Simpan Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD7B44C), Color(0xFFE8C55A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _simpanPenjualan,
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
