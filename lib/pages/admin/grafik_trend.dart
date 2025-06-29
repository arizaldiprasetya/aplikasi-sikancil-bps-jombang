import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class GrafikTrendPenanganan extends StatefulWidget {
  const GrafikTrendPenanganan({super.key});

  @override
  State<GrafikTrendPenanganan> createState() => _GrafikTrendPenangananState();
}

class _GrafikTrendPenangananState extends State<GrafikTrendPenanganan> {
  Map<String, List<double>> durasiPerMinggu = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrendData();
  }

  Future<void> fetchTrendData() async {
    final snapshot = await FirebaseFirestore.instance.collection('laporan').get();
    Map<String, List<double>> tempMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final tanggalLaporanRaw = data['tanggalLaporan'];
      if (tanggalLaporanRaw == null || tanggalLaporanRaw is! Timestamp) continue;
      final tanggalLaporan = tanggalLaporanRaw.toDate();

      final tanggalPerbaikanRaw = data['tanggalPerbaikan'];
      if (tanggalPerbaikanRaw == null) continue;

      DateTime? tanggalPerbaikan;

      if (tanggalPerbaikanRaw is Timestamp) {
        tanggalPerbaikan = tanggalPerbaikanRaw.toDate();
      } else if (tanggalPerbaikanRaw is String && tanggalPerbaikanRaw.trim().isNotEmpty) {
        try {
          tanggalPerbaikan = DateFormat("MMMM d, yyyy 'at' h:mm:ss a", 'en_US').parse(tanggalPerbaikanRaw);
        } catch (e) {
          debugPrint('Gagal parsing tanggalPerbaikan: $e');
        }
      }

      if (tanggalPerbaikan != null) {
        double durasi = tanggalPerbaikan.difference(tanggalLaporan).inHours / 24;

        final weekKey = _getWeekKey(tanggalLaporan);
        if (weekKey != "Unknown") {
          tempMap.putIfAbsent(weekKey, () => []);
          tempMap[weekKey]!.add(durasi);
        }
      }
    }

    setState(() {
      durasiPerMinggu = tempMap;
      isLoading = false;
    });
  }

  String _getWeekKey(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - 1;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
    final diff = date.difference(firstMonday).inDays;
    final weekNumber = (diff / 7).floor() + 1;
    return "${date.year}-M$weekNumber";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final sortedKeys = durasiPerMinggu.keys.toList()..sort();
    final avgDurasi = sortedKeys.map((key) {
      final list = durasiPerMinggu[key]!;
      return list.reduce((a, b) => a + b) / list.length;
    }).toList();

    List<FlSpot> spots = avgDurasi.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    double chartWidth = max(MediaQuery.of(context).size.width, sortedKeys.length * 100);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trend Rata-rata Waktu Penanganan Laporan (per Minggu)",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 360,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: 0,
                      lineTouchData: LineTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          axisNameSize: 16,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < sortedKeys.length) {
                                return Transform.rotate(
                                  angle: -0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      sortedKeys[index],
                                      style: const TextStyle(fontSize: 8),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) {
                              return Text(
                                "${value.toStringAsFixed(0)} hari",
                                style: const TextStyle(fontSize: 8),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (_, __) => const SizedBox.shrink(),
                            reservedSize: 16,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.teal.shade700,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      extraLinesData: ExtraLinesData(horizontalLines: [
                        HorizontalLine(
                          y: 0,
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "*Sumbu Y = rata-rata durasi penanganan (hari)",
                style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
