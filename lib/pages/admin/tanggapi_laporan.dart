import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'kelola_laporan.dart';

class TanggapiLaporanPage extends StatefulWidget {
  final String laporanId;
  final Map<String, dynamic> laporanData;

  const TanggapiLaporanPage({
    super.key,
    required this.laporanId,
    required this.laporanData,
  });

  @override
  State<TanggapiLaporanPage> createState() => _TanggapiLaporanPageState();
}

class _TanggapiLaporanPageState extends State<TanggapiLaporanPage> {
  late TextEditingController notesController;
  late TextEditingController tanggalPerbaikanController;
  late String selectedStatus;
  Uint8List? imageBytes;
  DateTime? selectedTanggalPerbaikan;

  @override
  void initState() {
    super.initState();
    notesController = TextEditingController(text: widget.laporanData['notesLaporan'] ?? '');
    selectedStatus = widget.laporanData['statusLaporan'] ?? 'Menunggu Diproses';

    if (widget.laporanData['tanggalPerbaikan'] != null &&
        widget.laporanData['tanggalPerbaikan'].toString().isNotEmpty) {
      Timestamp ts = widget.laporanData['tanggalPerbaikan'];
      selectedTanggalPerbaikan = ts.toDate();
    }

    tanggalPerbaikanController = TextEditingController(
      text: selectedTanggalPerbaikan != null
          ? DateFormat('dd-MM-yyyy HH:mm').format(selectedTanggalPerbaikan!) + ' WIB'
          : '',
    );

    final gambarBase64 = widget.laporanData['gambarBase64'];
    if (gambarBase64 != null && gambarBase64.isNotEmpty) {
      imageBytes = base64Decode(gambarBase64);
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    tanggalPerbaikanController.dispose();
    super.dispose();
  }

  Future<void> _selectTanggalPerbaikan() async {
    DateTime now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedTanggalPerbaikan ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2200),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedTanggalPerbaikan ?? now),
      );

      if (pickedTime != null) {
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          selectedTanggalPerbaikan = combined;
          tanggalPerbaikanController.text =
              DateFormat('dd-MM-yyyy HH:mm').format(combined) + ' WIB';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tanggapi Laporan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B9CFC),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBytes != null)
              Container(
                constraints: const BoxConstraints(maxHeight: 300, minHeight: 100),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(imageBytes!, fit: BoxFit.contain),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),

            const SizedBox(height: 12),
            _infoRow(Icons.person, "Nama Pelapor", widget.laporanData['namaPelapor']),
            _infoRow(Icons.title, "Judul Laporan", widget.laporanData['judulLaporan']),
            _infoRow(Icons.category, "Kategori Laporan", widget.laporanData['kategoriLaporan']),
            _infoRow(Icons.description, "Deskripsi Laporan", widget.laporanData['deskripsiLaporan']),
            _infoRow(
              Icons.date_range,
              "Tanggal dan Waktu Laporan",
              DateFormat('dd-MM-yyyy, HH:mm').format(
                    (widget.laporanData['tanggalLaporan'] as Timestamp).toDate(),
                  ) +
                  ' WIB',
            ),

            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: ['Menunggu Diproses', 'Selesai'].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Status Laporan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() => selectedStatus = value!);
              },
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: tanggalPerbaikanController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Tanggal dan Waktu Perbaikan',
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onTap: _selectTanggalPerbaikan,
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan / Tanggapan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Pastikan Anda telah memberikan catatan, mengisi tanggal perbaikan dan memperbarui status menjadi 'Selesai' jika laporan telah ditangani.",
                      style: TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final notesText = notesController.text.trim();

                if (notesText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Catatan wajib diisi sebelum menyimpan perubahan."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (selectedStatus == 'Selesai' && selectedTanggalPerbaikan == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tanggal Perbaikan wajib diisi sebelum menyimpan perubahan."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final Map<String, dynamic> updateData = {
                  'statusLaporan': selectedStatus,
                  'notesLaporan': notesText,
                };

                if (selectedTanggalPerbaikan != null) {
                  updateData['tanggalPerbaikan'] = Timestamp.fromDate(selectedTanggalPerbaikan!);
                }

                await FirebaseFirestore.instance
                    .collection('laporan')
                    .doc(widget.laporanId)
                    .update(updateData);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Laporan berhasil diperbarui."),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const KelolaLaporanPage()),
                );
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Simpan Perubahan',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B9CFC),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          )
        ],
      ),
    );
  }
}
