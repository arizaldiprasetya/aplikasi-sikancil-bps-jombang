import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class GrafikRingkasan extends StatelessWidget {
  final int menungguDiproses;
  final int selesai;

  const GrafikRingkasan({super.key, required this.menungguDiproses, required this.selesai});

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      title: "Ringkasan Status Laporan",
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.orange,
              value: menungguDiproses.toDouble(),
              title: '$menungguDiproses',
              radius: 50,
              titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: selesai.toDouble(),
              title: '$selesai',
              radius: 50,
              titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      legends: [
        _buildLegendBox(Colors.orange, 'Menunggu'),
      const SizedBox(width: 8),
        _buildLegendBox(Colors.green, 'Selesai'),
      ],
    );
  }

  Widget _buildLegendBox(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.poppins()),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child, List<Widget>? legends}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: child),
            if (legends != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: legends,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class GrafikBar extends StatelessWidget {
  final int menungguDiproses;
  final int selesai;

  const GrafikBar({super.key, required this.menungguDiproses, required this.selesai});

  @override
  Widget build(BuildContext context) {
    double maxData = [menungguDiproses.toDouble(), selesai.toDouble()].reduce((a, b) => a > b ? a : b);
    double interval = (maxData <= 5) ? 1 : (maxData <= 20) ? 2 : (maxData <= 50) ? 5 : 10;
    double maxY = maxData + interval;

    return _buildCard(
      title: "Grafik Jumlah Laporan Berdasarkan Status",
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: menungguDiproses.toDouble(), color: Colors.orange, width: 30)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: selesai.toDouble(), color: Colors.green, width: 30)]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("Menunggu", style: TextStyle(fontSize: 12));
                    case 1:
                      return const Text("Selesai", style: TextStyle(fontSize: 12));
                    default:
                      return const Text("");
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: interval)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
      legends: [
        _buildLegendBox(Colors.orange, 'Menunggu'),
        const SizedBox(width: 8),
        _buildLegendBox(Colors.green, 'Selesai'),
      ],
    );
  }

  Widget _buildLegendBox(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.poppins()),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child, List<Widget>? legends}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(height: 250, child: child),
            if (legends != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: legends,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
