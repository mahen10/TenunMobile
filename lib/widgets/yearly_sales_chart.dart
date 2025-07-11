import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../service/config.dart';
import 'dart:async';

class YearlySalesChart extends StatefulWidget {
  @override
  _YearlySalesChartState createState() => _YearlySalesChartState();
}

class _YearlySalesChartState extends State<YearlySalesChart> {
  int selectedYear = DateTime.now().year;
  List<dynamic> chartData = [];
  bool isLoading = false;
  bool isAutoRefreshEnabled = true;
  Timer? _refreshTimer;
  
  // Durasi auto refresh (dalam detik)
  static const int refreshIntervalSeconds = 30;

  @override
  void initState() {
    super.initState();
    fetchChartData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }

  void _startAutoRefresh() {
    if (isAutoRefreshEnabled) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: refreshIntervalSeconds),
        (timer) {
          if (mounted && isAutoRefreshEnabled) {
            fetchChartData();
          }
        },
      );
    }
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _toggleAutoRefresh() {
    setState(() {
      isAutoRefreshEnabled = !isAutoRefreshEnabled;
    });
    
    if (isAutoRefreshEnabled) {
      _startAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
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
        // ignore: unused_local_variable
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE8DDD4).withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section - more compact
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(251, 192, 45, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penjualan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'Grafik tahunan',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: fetchChartData,
                      icon: Icon(
                        Icons.refresh,
                        color: Color(0xFF8B7355),
                        size: 20,
                      ),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ),
                  SizedBox(width: 8),
                  // Year picker button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(247, 192, 55, 1),
                          Color.fromRGBO(243, 192, 61, 1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 246, 246, 246).withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: _pickYear,
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          SizedBox(width: 6),
                          Text(
                            selectedYear.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: Color(0xFF6B5B47),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Auto refresh status indicator
          if (isAutoRefreshEnabled) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Auto refresh setiap ${refreshIntervalSeconds}s',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 16),

          // Chart section - reduced height
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: Color(0xFFF8F6F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFFE8DDD4).withOpacity(0.5),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(12),
            child: Stack(
              children: [
                // Main chart content
                isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8B7355),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Memuat data...",
                              style: TextStyle(
                                color: Color(0xFF8B7355),
                                fontSize: 12,
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
                                  size: 40,
                                  color: Color(0xFF8B7355).withOpacity(0.5),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Tidak ada data penjualan",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6B5B47),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "untuk tahun ${selectedYear}",
                                  style: TextStyle(
                                    fontSize: 12,
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
                                            )?.toDouble() ??
                                        0.0;
                                    return FlSpot(bulan, total);
                                  }).toList(),
                                  isCurved: true,
                                  color: Color(0xFF8B7355),
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF8B7355), Color(0xFFB8A082)],
                                  ),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 3,
                                        color: Color(0xFF6B5B47),
                                        strokeWidth: 1.5,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  barWidth: 2.5,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Color(0xFFE8DDD4),
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
                                  strokeWidth: 0.5,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        NumberFormat.compactCurrency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(value),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF8B7355),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 24,
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
                                        padding: EdgeInsets.only(top: 4),
                                        child: Text(
                                          month,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF8B7355),
                                            fontWeight: FontWeight.w400,
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
                                  tooltipRoundedRadius: 8,
                                  tooltipPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
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
                                          fontWeight: FontWeight.w400,
                                          fontSize: 11,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                                handleBuiltInTouches: true,
                              ),
                            ),
                          ),
                // Refresh button overlay
                
              ],
            ),
          ),

          // Summary section - more compact
          if (chartData.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8F6F0),
                borderRadius: BorderRadius.circular(10),
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
                      chartData.fold(
                        0.0,
                        (sum, item) =>
                            sum +
                            (num.tryParse(item['total_penjualan'].toString()) ?? 0),
                      ),
                    ),
                    Icons.trending_up,
                  ),
                  Container(width: 1, height: 32, color: Color(0xFFE8DDD4)),
                  _buildSummaryItem(
                    'Rata-rata/Bulan',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(
                      chartData.fold(
                            0.0,
                            (sum, item) =>
                                sum +
                                (num.tryParse(
                                      item['total_penjualan'].toString(),
                                    ) ??
                                    0),
                          ) /
                          (chartData.length > 0 ? chartData.length : 1),
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
        Icon(icon, size: 20, color: Color(0xFF8B7355)),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF8B7355).withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B5B47),
          ),
        ),
      ],
    );
  }
}