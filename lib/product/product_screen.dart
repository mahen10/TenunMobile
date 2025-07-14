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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduk(int id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Konfirmasi Hapus',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Content
                  Text(
                    'Apakah Anda yakin ingin menghapus produk ini? Tindakan ini tidak dapat dibatalkan.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      // Batal Button
                      Expanded(
                        child: Container(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Hapus Button
                      Expanded(
                        child: Container(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token = prefs.getString('auth_token');
                              if (token == null) {
                                _showSnackBar('Token tidak ditemukan!');
                                return;
                              }

                              final response = await http.delete(
                                Uri.parse('${Config.apiUrl}/api/produk/$id'),
                                headers: {'Authorization': 'Bearer $token'},
                              );

                              if (response.statusCode == 200) {
                                _fetchProduk();
                                _showSnackBar(
                                  'Berhasil hapus produk.',
                                  backgroundColor: Colors.red,
                                );
                              } else {
                                _showSnackBar(
                                  'Gagal hapus produk.',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Hapus',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produk',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: const Color(0xFFD7B44C),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFD7B44C),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan icon produk
                    const SizedBox(height: 20),

                    // Search bar dan tombol tambah
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Cari Produk',
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                              ),
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextButton(
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
                            child: Text(
                              'Cari',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tombol tambah produk
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AddProductModal(onSuccess: _fetchProduk),
                          );
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Tambah Produk',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DD0E1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Label Produk Tenun
                    Text(
                      'Produk Tenun',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List produk
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchProduk,
                        child:
                            produkTenun.isEmpty
                                ? ListView(
                                  children: [
                                    const SizedBox(height: 100),
                                    Center(
                                      child: Text(
                                        'Belum ada produk',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : ListView.builder(
                                  itemCount: produkTenun.length,
                                  itemBuilder: (context, index) {
                                    final p = produkTenun[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        children: [
                                          // Gambar produk
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey[200],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child:
                                                  p['gambar'] != null
                                                      ? Image.network(
                                                        '${Config.apiUrl}/storage/${p['gambar']}',
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                          );
                                                        },
                                                      )
                                                      : const Icon(
                                                        Icons.image,
                                                        color: Colors.grey,
                                                      ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          // Detail produk
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p['nama_produk'] ??
                                                      'Nama Produk',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Kategori: ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                    ),
                                                    Text(
                                                      p['kategori'] ?? 'Umum',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                              0xFF4DD0E1,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Stok: ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                    ),
                                                    Text(
                                                      '${p['stok'] ?? 0}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Harga dan tombol aksi
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                numberFormat.format(
                                                  double.tryParse(
                                                        p['harga_jual']
                                                                ?.toString() ??
                                                            '0',
                                                      ) ??
                                                      0,
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Tombol detail
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (_) => Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      20,
                                                                    ),
                                                              ),
                                                              elevation: 10,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: Container(
                                                                constraints:
                                                                    BoxConstraints(
                                                                      maxWidth:
                                                                          400,
                                                                      maxHeight:
                                                                          500,
                                                                    ),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    // Header dengan gradient
                                                                    Container(
                                                                      width:
                                                                          double
                                                                              .infinity,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            20,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        color: const Color.fromRGBO(
                                                                          252,
                                                                          211,
                                                                          77,
                                                                          1,
                                                                        ),
                                                                        borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                            20,
                                                                          ),
                                                                          topRight: Radius.circular(
                                                                            20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.info_outline,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                28,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Expanded(
                                                                            child: Text(
                                                                              'Detail Produk',
                                                                              style: GoogleFonts.poppins(
                                                                                fontSize:
                                                                                    20,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                                color: const Color.fromARGB(
                                                                                  255,
                                                                                  255,
                                                                                  255,
                                                                                  255,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    // Content
                                                                    Flexible(
                                                                      child: Padding(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                              20,
                                                                            ),
                                                                        child: Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            // Kategori Card
                                                                            _buildInfoCard(
                                                                              icon:
                                                                                  Icons.category_outlined,
                                                                              title:
                                                                                  'Kategori',
                                                                              value:
                                                                                  p['kategori'] ??
                                                                                  '-',
                                                                              color:
                                                                                  Colors.blue,
                                                                            ),

                                                                            SizedBox(
                                                                              height:
                                                                                  16,
                                                                            ),

                                                                            // Stok Card
                                                                            _buildInfoCard(
                                                                              icon:
                                                                                  Icons.inventory_outlined,
                                                                              title:
                                                                                  'Stok',
                                                                              value:
                                                                                  '${p['stok'] ?? 0}',
                                                                              color:
                                                                                  (p['stok'] ??
                                                                                              0) >
                                                                                          0
                                                                                      ? Colors.green
                                                                                      : Colors.red,
                                                                            ),

                                                                            SizedBox(
                                                                              height:
                                                                                  16,
                                                                            ),

                                                                            // Deskripsi Card
                                                                            Container(
                                                                              width:
                                                                                  double.infinity,
                                                                              padding: EdgeInsets.all(
                                                                                16,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color:
                                                                                    Colors.grey[50],
                                                                                borderRadius: BorderRadius.circular(
                                                                                  12,
                                                                                ),
                                                                                border: Border.all(
                                                                                  color:
                                                                                      Colors.grey[200]!,
                                                                                  width:
                                                                                      1,
                                                                                ),
                                                                              ),
                                                                              child: Column(
                                                                                crossAxisAlignment:
                                                                                    CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.description_outlined,
                                                                                        color:
                                                                                            Colors.orange,
                                                                                        size:
                                                                                            20,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width:
                                                                                            8,
                                                                                      ),
                                                                                      Text(
                                                                                        'Deskripsi',
                                                                                        style: GoogleFonts.poppins(
                                                                                          fontSize:
                                                                                              14,
                                                                                          fontWeight:
                                                                                              FontWeight.w600,
                                                                                          color:
                                                                                              Colors.grey[700],
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height:
                                                                                        8,
                                                                                  ),
                                                                                  Text(
                                                                                    p['deskripsi'] ??
                                                                                        'Tidak ada deskripsi',
                                                                                    style: GoogleFonts.poppins(
                                                                                      fontSize:
                                                                                          14,
                                                                                      color:
                                                                                          Colors.grey[600],
                                                                                      height:
                                                                                          1.5,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    // Action buttons
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.fromLTRB(
                                                                            20,
                                                                            0,
                                                                            20,
                                                                            20,
                                                                          ),
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          TextButton(
                                                                            onPressed:
                                                                                () => Navigator.pop(
                                                                                  context,
                                                                                ),
                                                                            style: TextButton.styleFrom(
                                                                              padding: EdgeInsets.symmetric(
                                                                                horizontal:
                                                                                    24,
                                                                                vertical:
                                                                                    12,
                                                                              ),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  8,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            child: Text(
                                                                              'Tutup',
                                                                              style: GoogleFonts.poppins(
                                                                                fontSize:
                                                                                    14,
                                                                                fontWeight:
                                                                                    FontWeight.w500,
                                                                                color:
                                                                                    Colors.grey[600],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed:
                                                                                () => Navigator.pop(
                                                                                  context,
                                                                                ),
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: Color(
                                                                                0xFFD7B44C,
                                                                              ),
                                                                              foregroundColor:
                                                                                  Colors.white,
                                                                              padding: EdgeInsets.symmetric(
                                                                                horizontal:
                                                                                    24,
                                                                                vertical:
                                                                                    12,
                                                                              ),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  8,
                                                                                ),
                                                                              ),
                                                                              elevation:
                                                                                  2,
                                                                            ),
                                                                            child: Text(
                                                                              'OK',
                                                                              style: GoogleFonts.poppins(
                                                                                fontSize:
                                                                                    14,
                                                                                fontWeight:
                                                                                    FontWeight.w500,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF66BB6A,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.visibility,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),

                                                  // Tombol edit
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (
                                                              _,
                                                            ) => EditProductModal(
                                                              produk: p,
                                                              onSuccess:
                                                                  _fetchProduk,
                                                            ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF66BB6A,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),

                                                  // Tombol hapus
                                                  GestureDetector(
                                                    onTap:
                                                        () =>
                                                            _confirmDeleteProduk(
                                                              p['id'],
                                                            ),
                                                    child: Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF66BB6A,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
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
