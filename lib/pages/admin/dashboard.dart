import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'grafik.dart'; 
import 'grafik_tambahan.dart';
import 'grafik_user.dart'; 
import 'grafik_trend.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalLaporan = 0;
  int menungguDiproses = 0;
  int selesai = 0;

  @override
  void initState() {
    super.initState();
    fetchLaporanCount();
  }

  Future<void> fetchLaporanCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('laporan').get();
    int total = snapshot.docs.length;
    int menunggu = 0;
    int selesaiCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['statusLaporan'] ?? 'Menunggu Diproses';

      if (status == 'Selesai') {
        selesaiCount++;
      } else {
        menunggu++;
      }
    }

    setState(() {
      totalLaporan = total;
      menungguDiproses = menunggu;
      selesai = selesaiCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1B9CFC),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchLaporanCount,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 20),
              GrafikRingkasan(
                menungguDiproses: menungguDiproses,
                selesai: selesai,
              ),
              const SizedBox(height: 20),
              GrafikBar(
                menungguDiproses: menungguDiproses,
                selesai: selesai,
              ),
              const SizedBox(height: 20),
              const GrafikLineTanggal(), 
              const SizedBox(height: 20),
              const GrafikBarKategori(),
              const SizedBox(height: 20),
              const GrafikBarUser(),
              const SizedBox(height: 20),
              const GrafikTrendPenanganan(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildCard('Total', totalLaporan, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _buildCard('Menunggu', menungguDiproses, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _buildCard('Selesai', selesai, Colors.green)),
      ],
    );
  }

  Widget _buildCard(String title, int count, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.15),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 14, color: color),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 28, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
