import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart'; // Pastikan path sesuai

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
      "Penjualan": totalPenjualan,
      "Pembelian": totalPembelian,
    };

    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: Column(
        children: [
          // HEADER
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
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 16),
                Text(
                  'Laporan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                    // PICK BULAN & TAHUN (PAKE DATE PICKER)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Bulan: ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              helpText: 'Pilih Bulan & Tahun',
                            );

                            if (picked != null) {
                              String newMonth = DateFormat('yyyy-MM').format(picked);
                              setState(() {
                                selectedMonth = newMonth;
                              });
                              await _fetchReport();
                            }
                          },
                          child: Text(selectedMonth),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // PIE CHART
                    isLoading
                        ? CircularProgressIndicator()
                        : PieChart(
                            dataMap: dataMap,
                            chartRadius: MediaQuery.of(context).size.width / 2.2,
                            colorList: [Colors.green, Colors.blue],
                            chartType: ChartType.disc,
                            ringStrokeWidth: 32,
                            legendOptions: LegendOptions(
                              legendPosition: LegendPosition.bottom,
                              showLegends: true,
                              legendTextStyle: GoogleFonts.poppins(),
                            ),
                            chartValuesOptions: ChartValuesOptions(
                              showChartValuesInPercentage: true,
                              showChartValues: true,
                            ),
                          ),
                    SizedBox(height: 30),

                    // TOTAL PEMBELIAN & PENJUALAN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total Penjualan',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Rp ${NumberFormat("#,##0", "id_ID").format(totalPenjualan)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total Pembelian',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Rp ${NumberFormat("#,##0", "id_ID").format(totalPembelian)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.green,
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
