import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailRiwayatLaporanPage extends StatelessWidget {
  final String laporanId;
  final Map<String, dynamic> laporanData;

  const DetailRiwayatLaporanPage({
    Key? key,
    required this.laporanId,
    required this.laporanData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parsing data
    String judulLaporan = laporanData['judulLaporan'] ?? '-';
    String kategoriLaporan = laporanData['kategoriLaporan'] ?? '-';
    String deskripsiLaporan = laporanData['deskripsiLaporan'] ?? '-';
    String notesLaporan = laporanData['notesLaporan'] ?? '';
    String penanggungJawab = laporanData['penanggungJawab'] ?? '-';

    // Format tanggal laporan dengan jam
    String tanggalFormatted = '-';
    final tanggalLaporanRaw = laporanData['tanggalLaporan'];
    if (tanggalLaporanRaw is Timestamp) {
      final date = DateFormat('dd-MM-yyyy').format(tanggalLaporanRaw.toDate());
      final time = DateFormat('HH:mm').format(tanggalLaporanRaw.toDate());
      tanggalFormatted = '$date, $time WIB';
    }

    // Format tanggal perbaikan
    String tanggalPerbaikanText = 'Tanggal dan waktu belum diisi admin.';
    final tanggalPerbaikanRaw = laporanData['tanggalPerbaikan'];
    if (tanggalPerbaikanRaw is Timestamp) {
      final date = DateFormat('dd-MM-yyyy').format(tanggalPerbaikanRaw.toDate());
      final time = DateFormat('HH:mm').format(tanggalPerbaikanRaw.toDate());
      tanggalPerbaikanText = '$date, pukul $time WIB';
    }

    // Gambar laporan
    Uint8List? imageBytes;
    if (laporanData['gambarBase64'] != null &&
        laporanData['gambarBase64'].toString().isNotEmpty) {
      try {
        imageBytes = base64Decode(laporanData['gambarBase64']);
      } catch (e) {
        // Jika decoding gagal, biarkan imageBytes tetap null
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: const Color(0xFF1B9CFC),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gambar
                if (imageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        maxWidth: double.infinity,
                      ),
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[600]),
                  ),

                const SizedBox(height: 20),

                // Judul
                Text(
                  judulLaporan,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Tanggal
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      tanggalFormatted,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kategori
                Row(
                  children: [
                    const Icon(Icons.category, color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      kategoriLaporan,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Penanggung Jawab
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person_outline, color: Colors.blueGrey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PJ: $penanggungJawab',
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Divider(thickness: 1, color: Colors.grey[300]),

                // Deskripsi
                const Text(
                  'Deskripsi Laporan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  deskripsiLaporan,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Tanggal Perbaikan
                const Text(
                  'Tanggal dan Waktu Perbaikan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tanggalPerbaikanText,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 20),

                // Catatan Admin
                const Text(
                  'Catatan / Tanggapan Admin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notesLaporan.isNotEmpty
                        ? notesLaporan
                        : 'Belum ada tanggapan dari admin.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 30),

                // Info tambahan
                if (notesLaporan.trim().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Jika masih ada keluhan lain, silakan buat laporan baru dengan detail tambahan.',
                            style: TextStyle(fontSize: 16, color: Colors.orange[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
