import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config.dart';

class YearlySalesChart extends StatefulWidget {
  @override
  _YearlySalesChartState createState() => _YearlySalesChartState();
}

class _YearlySalesChartState extends State<YearlySalesChart> {
  int selectedYear = DateTime.now().year;
  List<dynamic> chartData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
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
        Uri.parse('${Config.apiUrl}/api/grafik-penjualan?tahun=$selectedYear'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          chartData = data;
        });
      } else {
        print('Gagal ambil data grafik: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _pickYear() async {
    final pickedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempYear = selectedYear;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pilih Tahun',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B5B47),
            ),
          ),
          content: Container(
            height: 250,
            width: 100,
            child: YearPicker(
              firstDate: DateTime(2010),
              lastDate: DateTime(DateTime.now().year + 10),
              initialDate: DateTime(selectedYear),
              selectedDate: DateTime(selectedYear),
              onChanged: (dateTime) {
                Navigator.of(context).pop(dateTime.year);
              },
            ),
          ),
        );
      },
    );

    if (pickedYear != null && pickedYear != selectedYear) {
      setState(() {
        selectedYear = pickedYear;
      });
      await fetchChartData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE8DDD4).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Grafik Penjualan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B5B47),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Analisis penjualan Tahunan",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B7355).withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE8DDD4),
                      Color(0xFFD4C4A8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD4C4A8).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _pickYear,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF6B5B47),
                      ),
                      SizedBox(width: 8),
                      Text(
                        selectedYear.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B5B47),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Color(0xFF6B5B47),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Chart section
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Color(0xFFF8F6F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFE8DDD4).withOpacity(0.5),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8B7355),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Memuat data...",
                          style: TextStyle(
                            color: Color(0xFF8B7355),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : chartData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 48,
                              color: Color(0xFF8B7355).withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Tidak ada data penjualan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B5B47),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "untuk tahun ${selectedYear}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8B7355).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData.map((e) {
                                final bulan = (e['bulan'] as int).toDouble();
                                final total = num.tryParse(
                                  e['total_penjualan'].toString(),
                                )?.toDouble() ?? 0.0;
                                return FlSpot(bulan, total);
                              }).toList(),
                              isCurved: true,
                              color: Color(0xFF8B7355),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF8B7355),
                                  Color(0xFFB8A082),
                                ],
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Color(0xFF6B5B47),
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF8B7355).withOpacity(0.3),
                                    Color(0xFF8B7355).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Color(0xFFE8DDD4),
                              width: 1,
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: null,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Color(0xFFE8DDD4).withOpacity(0.5),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    NumberFormat.compactCurrency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(value),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF8B7355),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    '',
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'Mei',
                                    'Jun',
                                    'Jul',
                                    'Agu',
                                    'Sep',
                                    'Okt',
                                    'Nov',
                                    'Des',
                                  ];
                                  String month = '';
                                  if (value.toInt() >= 1 && value.toInt() <= 12) {
                                    month = months[value.toInt()];
                                  }
                                  return Container(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      month,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF8B7355),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          minX: 1,
                          maxX: 12,
                          minY: 0,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Color(0xFF6B5B47),
                              tooltipRoundedRadius: 12,
                              tooltipPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  const months = [
                                    '',
                                    'Januari',
                                    'Februari',
                                    'Maret',
                                    'April',
                                    'Mei',
                                    'Juni',
                                    'Juli',
                                    'Agustus',
                                    'September',
                                    'Oktober',
                                    'November',
                                    'Desember',
                                  ];
                                  final month = months[spot.x.toInt()];
                                  final value = NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(spot.y);
                                  
                                  return LineTooltipItem(
                                    '${month}\n${value}',
                                    TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            handleBuiltInTouches: true,
                          ),
                        ),
                      ),
          ),
          
          // Summary section
          if (chartData.isNotEmpty) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8F6F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFFE8DDD4).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total Penjualan',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(
                      chartData.fold(0.0, (sum, item) => 
                        sum + (num.tryParse(item['total_penjualan'].toString()) ?? 0)
                      ),
                    ),
                    Icons.trending_up,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Color(0xFFE8DDD4),
                  ),
                  _buildSummaryItem(
                    'Rata-rata/Bulan',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(
                      chartData.fold(0.0, (sum, item) => 
                        sum + (num.tryParse(item['total_penjualan'].toString()) ?? 0)
                      ) / (chartData.length > 0 ? chartData.length : 1),
                    ),
                    Icons.analytics,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Color(0xFF8B7355),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF8B7355).withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B5B47),
          ),
        ),
      ],
    );
  }
}