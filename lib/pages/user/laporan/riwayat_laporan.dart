import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sikancil/pages/user/laporan/detail_riwayat.dart';

class RiwayatLaporanPage extends StatefulWidget {
  @override
  _RiwayatLaporanPageState createState() => _RiwayatLaporanPageState();
}

class _RiwayatLaporanPageState extends State<RiwayatLaporanPage> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Riwayat Laporan'),
        backgroundColor: Color(0xFF1B9CFC),
      ),
      body: userId.isEmpty
          ? Center(child: Text('User belum login'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('laporan')
                  .where('userId', isEqualTo: userId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Belum ada laporan'));
                }

                final laporanList = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: laporanList.length,
                  itemBuilder: (context, index) {
                    final laporanDoc = laporanList[index];
                    final laporan = laporanDoc.data() as Map<String, dynamic>;

                    final Timestamp tanggalTimestamp = laporan['tanggalLaporan'];
                    final DateTime dateTime = tanggalTimestamp.toDate();
                    final String tanggalFormatted =
                        DateFormat('dd-MM-yyyy').format(dateTime);
                    final String jamFormatted =
                        DateFormat('HH:mm').format(dateTime);
                    final String waktuLengkap = '$tanggalFormatted, $jamFormatted WIB';

                    final String status = laporan['statusLaporan'] ?? 'Menunggu Diproses';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailRiwayatLaporanPage(
                              laporanId: laporanDoc.id,
                              laporanData: laporan,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                laporan['judulLaporan'] ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  SizedBox(width: 6),
                                  Text(
                                    waktuLengkap,
                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.category, size: 16, color: Colors.grey),
                                  SizedBox(width: 6),
                                  Text(
                                    laporan['kategoriLaporan'] ?? '-',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildStatusIcon(status),
                                  SizedBox(width: 6),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: status == 'Selesai' ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              if (status == 'Menunggu Diproses') ...[
                                SizedBox(height: 12),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _confirmHapusLaporan(
                                      context,
                                      laporanDoc.id,
                                    ),
                                    icon: Icon(Icons.delete, color: Colors.white),
                                    label: Text(
                                      "Hapus Laporan",
                                      style: TextStyle(fontSize: 11, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 4,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildStatusIcon(String status) {
    if (status == 'Selesai') {
      return Icon(Icons.check_circle, color: Colors.green, size: 18);
    } else {
      return Icon(Icons.hourglass_empty, color: Colors.orange, size: 18);
    }
  }

  void _confirmHapusLaporan(BuildContext context, String laporanId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah kamu yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FirebaseFirestore.instance
                  .collection('laporan')
                  .doc(laporanId)
                  .delete();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Laporan berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
