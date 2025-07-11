import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tenunapp/service/config.dart';
import 'package:tenunapp/transaction/tambah_pembelian_screen.dart';
import 'package:tenunapp/transaction/tambah_penjualan_screen.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool isPembelian = true;
  List<dynamic> _pembelian = [];
  List<dynamic> _penjualan = [];
  List<dynamic> produkList = [];
  String selectedMonth = 'Semua';

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
        http.get(Uri.parse('${Config.apiUrl}/api/pembelian-bahan'),
            headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('${Config.apiUrl}/api/penjualan'),
            headers: {'Authorization': 'Bearer $token'}),
        http.get(Uri.parse('${Config.apiUrl}/api/produk'),
            headers: {'Authorization': 'Bearer $token'}),
      ]);

      setState(() {
        _pembelian = responses[0].statusCode == 200 ? json.decode(responses[0].body) : [];
        _penjualan = responses[1].statusCode == 200 ? json.decode(responses[1].body) : [];
        produkList = responses[2].statusCode == 200 ? json.decode(responses[2].body) : [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isPembelian
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

  List<String> _getMonthOptions() {
    Set<String> months = {'Semua'};
    
    List<dynamic> currentData = isPembelian ? _pembelian : _penjualan;
    String dateField = isPembelian ? 'tanggal_pembelian' : 'tanggal_penjualan';
    
    for (var item in currentData) {
      if (item[dateField] != null) {
        try {
          DateTime date = DateTime.parse(item[dateField]);
          String monthYear = '${_getMonthName(date.month)} ${date.year}';
          months.add(monthYear);
        } catch (e) {
          // Skip invalid dates
        }
      }
    }
    
    List<String> sortedMonths = months.toList();
    sortedMonths.sort((a, b) {
      if (a == 'Semua') return -1;
      if (b == 'Semua') return 1;
      return b.compareTo(a); // Newest first
    });
    
    return sortedMonths;
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  List<dynamic> _getFilteredData() {
    List<dynamic> currentData = isPembelian ? _pembelian : _penjualan;
    
    if (selectedMonth == 'Semua') {
      return currentData;
    }
    
    String dateField = isPembelian ? 'tanggal_pembelian' : 'tanggal_penjualan';
    
    return currentData.where((item) {
      if (item[dateField] != null) {
        try {
          DateTime date = DateTime.parse(item[dateField]);
          String monthYear = '${_getMonthName(date.month)} ${date.year}';
          return monthYear == selectedMonth;
        } catch (e) {
          return false;
        }
      }
      return false;
    }).toList();
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: selectedMonth,
        items: _getMonthOptions().map((String month) {
          return DropdownMenuItem<String>(
            value: month,
            child: Text(
              month,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedMonth = newValue ?? 'Semua';
          });
        },
        underline: Container(),
        icon: Icon(Icons.keyboard_arrow_down, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7B44C),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text(
                  'Transaksi',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Tab Bar dan Filter
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Tab Switcher
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPembelian = true;
                                      selectedMonth = 'Semua';
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isPembelian ? Colors.black : Colors.transparent,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      "Pembelian",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: isPembelian ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPembelian = false;
                                      selectedMonth = 'Semua';
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isPembelian ? Colors.black : Colors.transparent,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      "Penjualan",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: !isPembelian ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Add Button dan Filter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Add Button
                            GestureDetector(
                              onTap: _navigateToAddTransaction,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4DD0E1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      isPembelian ? 'Pembelian' : 'Penjualan',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Month Filter
                            _buildMonthDropdown(),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        
                      
                      ],
                    ),
                  ),
                  
                  // Section Title
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isPembelian ? 'Pembelian Bahan' : 'Penjualan Produk',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Transaction List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _getFilteredData().length,
                      itemBuilder: (context, index) {
                        final data = _getFilteredData()[index];
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Product Image/Icon
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _getRandomColor(index),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isPembelian ? Icons.shopping_bag : Icons.sell,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                
                                SizedBox(width: 16),
                                
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPembelian
                                            ? data['nama_bahan']
                                            : _getNamaProduk(data['produk_id']),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        isPembelian
                                            ? 'Jumlah: ${data['jumlah']}'
                                            : 'Jumlah: ${data['jumlah_terjual']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        isPembelian
                                            ? 'Total: Rp ${data['harga_total']}'
                                            : 'Total: Rp ${data['total_harga']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4DD0E1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Date
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatDate(data[isPembelian ? 'tanggal_pembelian' : 'tanggal_penjualan']),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF81C784),
                                        shape: BoxShape.circle,
                                      ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getRandomColor(int index) {
    List<Color> colors = [
      Color(0xFFE91E63), // Pink
      Color(0xFF2196F3), // Blue
      Color(0xFF4CAF50), // Green
      Color(0xFFFF9800), // Orange
      Color(0xFF9C27B0), // Purple
      Color(0xFF00BCD4), // Cyan
    ];
    return colors[index % colors.length];
  }
}