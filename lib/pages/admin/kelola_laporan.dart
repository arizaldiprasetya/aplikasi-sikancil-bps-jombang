import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'tanggapi_laporan.dart';

class KelolaLaporanPage extends StatefulWidget {
  const KelolaLaporanPage({super.key});

  @override
  State<KelolaLaporanPage> createState() => _KelolaLaporanPageState();
}

class _KelolaLaporanPageState extends State<KelolaLaporanPage> {
  String searchQuery = '';
  String selectedKategori = 'Semua';
  String selectedStatus = 'Semua';
  String selectedPJ = 'Semua';
  DateTime? selectedDate;

  final List<String> kategoriList = ['Semua', 'Keamanan', 'Kebersihan', 'Kerusakan Barang IT', 'Kerusakan Barang Non-IT', 'Lainnya'];
  final List<String> statusList = ['Semua', 'Menunggu Diproses', 'Selesai'];
  final List<String> pjList = ['Semua', 'Alim Sholehuddin, S.Si, M.E', 'Riska Andriani, S.ST', 'Mitha Ramadhani Pratiwi, A.Md'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Laporan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1B9CFC),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('laporan')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Terjadi kesalahan"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada laporan"));
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final namaPelapor = data['namaPelapor'].toString().toLowerCase();
                  final judulLaporan = data['judulLaporan'].toString().toLowerCase();
                  final kategoriLaporan = data['kategoriLaporan'].toString();
                  final statusLaporan = data['statusLaporan'] ?? 'Menunggu Diproses';
                  final tanggalLaporan = (data['tanggalLaporan'] as Timestamp).toDate();
                  final pj = data['penanggungJawab'] ?? '';

                  bool matchesSearch = namaPelapor.contains(searchQuery.toLowerCase()) ||
                      judulLaporan.contains(searchQuery.toLowerCase());
                  bool matchesKategori =
                      (selectedKategori == 'Semua' || selectedKategori == kategoriLaporan);
                  bool matchesStatus =
                      (selectedStatus == 'Semua' || selectedStatus == statusLaporan);
                  bool matchesPJ =
                      (selectedPJ == 'Semua' || selectedPJ == pj);
                  bool matchesDate = (selectedDate == null ||
                      (tanggalLaporan.year == selectedDate!.year &&
                          tanggalLaporan.month == selectedDate!.month &&
                          tanggalLaporan.day == selectedDate!.day));

                  return matchesSearch && matchesKategori && matchesStatus && matchesPJ && matchesDate;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("Tidak ada data laporan pengaduan"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final laporan = filteredDocs[index];
                    final data = laporan.data() as Map<String, dynamic>;
                    final status = data['statusLaporan'] ?? 'Menunggu Diproses';

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    data['namaPelapor'],
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildStatusBadge(status),
                              ],
                            ),
                            const Divider(height: 20, thickness: 1),
                            _simpleRow(Icons.assignment, 'Judul', data['judulLaporan']),
                            _simpleRow(Icons.category, 'Kategori', data['kategoriLaporan']),
                            _simpleRow(Icons.person_outline, 'Penanggung Jawab',
                                data['penanggungJawab'] ?? '-'),
                            _simpleRow(
                              Icons.calendar_today,
                              'Tanggal Laporan',
                              DateFormat('dd-MM-yyyy')
                                  .format((data['tanggalLaporan'] as Timestamp).toDate()),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TanggapiLaporanPage(
                                        laporanId: laporan.id,
                                        laporanData: data,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B9CFC),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                label: const Text(
                                  "Tanggapi",
                                  style: TextStyle(fontSize: 13, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFF7F7F7),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Cari berdasarkan nama/judul...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Kategori
              Flexible(
                child: DropdownButtonFormField<String>(
                  value: selectedKategori,
                  isExpanded: true,
                  items: kategoriList.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedKategori = val!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status
              Flexible(
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  items: statusList.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedStatus = val!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Penanggung Jawab
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPJ,
                  isExpanded: true,
                  items: pjList.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedPJ = val!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Penanggung Jawab",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.date_range, color: Colors.white),
                  label: Text(
                    selectedDate == null
                        ? "Filter Berdasarkan Tanggal"
                        : DateFormat('dd-MM-yyyy').format(selectedDate!),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B9CFC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    selectedDate = null;
                    selectedKategori = 'Semua';
                    selectedStatus = 'Semua';
                    selectedPJ = 'Semua';
                    searchQuery = '';
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _simpleRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    IconData icon;
    String text;

    if (status == "Selesai") {
      bgColor = Colors.green;
      icon = Icons.check_circle;
      text = "Selesai";
    } else {
      bgColor = Colors.red;
      icon = Icons.pending_actions;
      text = "Menunggu Diproses";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: bgColor, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(color: bgColor, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
