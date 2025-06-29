import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class GrafikLineTanggal extends StatefulWidget {
  const GrafikLineTanggal({super.key});

  @override
  State<GrafikLineTanggal> createState() => _GrafikLineTanggalState();
}

class _GrafikLineTanggalState extends State<GrafikLineTanggal> {
  Map<String, int> laporanPerTanggal = {};
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchLaporan();
  }

  Future<void> fetchLaporan() async {
    final snapshot = await FirebaseFirestore.instance.collection('laporan').get();
    Map<String, int> tempData = {};

    for (var doc in snapshot.docs) {
      var data = doc.data();
      Timestamp ts = data['tanggalLaporan'];
      DateTime date = ts.toDate();
      String formattedDate = DateFormat('dd-MM-yyyy').format(date); // Format readable
      tempData.update(formattedDate, (value) => value + 1, ifAbsent: () => 1);
    }

    setState(() {
      laporanPerTanggal = tempData;
    });
  }

  Future<void> pilihTanggal() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd-MM-yyyy');

    final filteredData = laporanPerTanggal.entries.where((entry) {
      if (startDate != null && endDate != null) {
        final entryDate = dateFormatter.parse(entry.key);
        return entryDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            entryDate.isBefore(endDate!.add(const Duration(days: 1)));
      }
      return true;
    }).toList()
      ..sort((a, b) => dateFormatter.parse(a.key).compareTo(dateFormatter.parse(b.key)));

    List<FlSpot> spots = filteredData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();

    double chartWidth = max(MediaQuery.of(context).size.width, filteredData.length * 100);
    double maxY = 1;

    if (spots.isNotEmpty) {
      double maxValue = spots.map((e) => e.y).reduce(max);
      maxY = maxValue + 1;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Grafik Jumlah Laporan Berdasarkan Tanggal",
                  style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: pilihTanggal,
                  icon: const Icon(Icons.filter_alt_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (filteredData.length - 1).toDouble(),
                      minY: 0,
                      maxY: maxY,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                            interval: filteredData.length > 10 ? (filteredData.length / 10).floorToDouble() : 1,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < filteredData.length) {
                                String formatted = filteredData[index].key;
                                return Transform.rotate(
                                  angle: -0.5,
                                  child: SizedBox(
                                    width: 90,
                                    child: Text(formatted, style: const TextStyle(fontSize: 7), textAlign: TextAlign.center),
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
                            reservedSize: 40,
                            interval: 1,
                            getTitlesWidget: (value, _) => Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.purple,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "*Sumbu Y = jumlah total laporan",
                style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GrafikBarKategori extends StatefulWidget {
  const GrafikBarKategori({super.key});

  @override
  State<GrafikBarKategori> createState() => _GrafikBarKategoriState();
}

class _GrafikBarKategoriState extends State<GrafikBarKategori> {
  final Map<String, int> kategoriMap = {
    'Kebersihan': 0,
    'Keamanan': 0,
    'Kerusakan Barang IT': 0,
    'Kerusakan Barang Non-IT': 0,
    'Lainnya': 0,
  };

  final Map<String, Color> kategoriColors = {
    'Kebersihan': Colors.purple,
    'Keamanan': Colors.teal,
    'Kerusakan Barang IT': Colors.indigo,
    'Kerusakan Barang Non-IT': Colors.deepOrange,
    'Lainnya': Colors.brown,
  };

  @override
  void initState() {
    super.initState();
    fetchKategoriData();
  }

  Future<void> fetchKategoriData() async {
    final snapshot = await FirebaseFirestore.instance.collection('laporan').get();

    for (var doc in snapshot.docs) {
      String kategori = doc['kategoriLaporan'] ?? 'Lainnya';
      kategoriMap.update(kategori, (value) => value + 1, ifAbsent: () => 1);
    }

    setState(() {});
  }

  Widget _buildLegendBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final kategoriList = kategoriMap.entries.toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Grafik Jumlah Laporan Berdasarkan Kategori",
              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: kategoriList.asMap().entries.map((entry) {
                    int index = entry.key;
                    var kategori = entry.value;
                    Color barColor = kategoriColors[kategori.key] ?? Colors.grey;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: kategori.value.toDouble(),
                          color: barColor,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < kategoriList.length) {
                            return Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                kategoriList[value.toInt()].key,
                                style: const TextStyle(fontSize: 8),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 1),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: kategoriList.map((entry) {
                Color color = kategoriColors[entry.key] ?? Colors.grey;
                return _buildLegendBox(color, entry.key);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
