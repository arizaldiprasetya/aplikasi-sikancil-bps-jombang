import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrafikBarUser extends StatefulWidget {
  const GrafikBarUser({super.key});

  @override
  State<GrafikBarUser> createState() => _GrafikBarUserState();
}

class _GrafikBarUserState extends State<GrafikBarUser> {
  Map<String, int> userLaporanMap = {};

  @override
  void initState() {
    super.initState();
    fetchUserLaporan();
  }

  Future<void> fetchUserLaporan() async {
    final snapshot = await FirebaseFirestore.instance.collection('laporan').get();
    Map<String, int> tempMap = {};

    for (var doc in snapshot.docs) {
      String nama = doc['namaPelapor'] ?? 'Tanpa Nama';
      tempMap.update(nama, (value) => value + 1, ifAbsent: () => 1);
    }

    // Sort descending berdasarkan jumlah laporan
    var sortedEntries = tempMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      userLaporanMap = Map.fromEntries(sortedEntries);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userList = userLaporanMap.entries.toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Leaderboard Pelapor Dengan Jumlah Laporan Terbanyak",
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            userList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        barGroups: userList.asMap().entries.map((entry) {
                          int index = entry.key;
                          var user = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: user.value.toDouble(),
                                color: Colors.deepPurpleAccent,
                                width: 20,
                                borderRadius: BorderRadius.circular(6),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: userList.first.value.toDouble() + 1,
                                  color: Colors.grey[200],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < userList.length) {
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: Text(
                                      userList[index].key.length > 8
                                          ? '${userList[index].key.substring(0, 8)}...'
                                          : userList[index].key,
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
            // Legend bisa ditambah jika pelapor dibedakan warna
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "*Menampilkan nama pelapor dengan laporan terbanyak",
                style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
