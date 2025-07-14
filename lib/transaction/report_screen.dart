import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../service/config.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  double totalPenjualan = 0;
  double totalPembelian = 0;
  bool isLoading = false;

  Future<void> _fetchReport() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('Token tidak ditemukan');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}/api/laporan-bulanan?bulan=$selectedMonth'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalPenjualan = double.tryParse(data['total_penjualan'].toString()) ?? 0;
          totalPembelian = double.tryParse(data['total_pembelian'].toString()) ?? 0;
        });
      } else {
        print('Gagal ambil data laporan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      "Total Penjualan": totalPenjualan,
      "Total Pembelian": totalPembelian,
    };

    return Scaffold(
      backgroundColor: const Color.fromRGBO(252, 211, 77, 1),
      body: Column(
        children: [
          // HEADER SECTION
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(252, 211, 77, 1),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 255, 255, 255)),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 16),
                Text(
                  'Laporan Bulanan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 250, 249, 249),
                  ),
                ),
              ],
            ),
          ),

          // BODY
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    
                    // PICK MONTH & YEAR (PAKE MONTH PICKER DIALOG)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.green[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Pilih Bulan",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showMonthPicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                String newMonth = DateFormat('yyyy-MM').format(picked);
                                setState(() {
                                  selectedMonth = newMonth;
                                });
                                await _fetchReport();
                              }
                            },
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.green[700],
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // PIE CHART
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200]!,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                            )
                          : Column(
                              children: [
                                PieChart(
                                  dataMap: dataMap,
                                  chartRadius: MediaQuery.of(context).size.width / 2.5,
                                  colorList: [Colors.green[400]!, Colors.red[400]!],
                                  chartType: ChartType.ring,
                                  ringStrokeWidth: 40,
                                  legendOptions: LegendOptions(
                                    legendPosition: LegendPosition.bottom,
                                    showLegends: true,
                                    legendTextStyle: GoogleFonts.poppins(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  chartValuesOptions: ChartValuesOptions(
                                    showChartValuesInPercentage: true,
                                    showChartValues: true,
                                    showChartValuesOutside: false,
                                    chartValueStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: 30),

                    // TOTAL PEMBELIAN & PENJUALAN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[200]!,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total Penjualan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Rp ${NumberFormat("#,##0", "id_ID").format(totalPenjualan)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[200]!,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total Pembelian',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Rp ${NumberFormat("#,##0", "id_ID").format(totalPembelian)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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