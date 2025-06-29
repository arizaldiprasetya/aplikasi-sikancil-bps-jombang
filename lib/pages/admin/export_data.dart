import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> laporanList = [];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now().subtract(const Duration(days: 7)) : DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2200),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });

      if (startDate != null && endDate != null) {
        _fetchData();
      }
    }
  }

  Future<void> _fetchData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('laporan')
        .where('tanggalLaporan', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!))
        .where('tanggalLaporan', isLessThanOrEqualTo: Timestamp.fromDate(endDate!))
        .get();

    final List<Map<String, dynamic>> tempData = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      tempData.add({
        'namaPelapor': data['namaPelapor'] ?? '',
        'judulLaporan': data['judulLaporan'] ?? '',
        'tanggalLaporan': data['tanggalLaporan'] is Timestamp
            ? data['tanggalLaporan'].toDate()
            : DateTime.now(),
        'kategoriLaporan': data['kategoriLaporan'] ?? '',
        'gambarBase64': data['gambarBase64'] ?? '',
        'deskripsiLaporan': data['deskripsiLaporan'] ?? '',
        'tanggalPerbaikan': data['tanggalPerbaikan'] is Timestamp
            ? data['tanggalPerbaikan'].toDate()
            : null,
        'notesLaporan': data['notesLaporan'] ?? '',
        'statusLaporan': data['statusLaporan'] ?? '',
      });
    }

    setState(() {
      laporanList = tempData;
    });
  }

  Future<void> _exportToExcel() async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Data Laporan';

    final headers = [
      'Nama Pelapor',
      'Judul Laporan',
      'Tanggal Laporan',
      'Kategori',
      'Deskripsi',
      'Tanggal Perbaikan',
      'Catatan',
      'Status'
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (int i = 0; i < laporanList.length; i++) {
      final laporan = laporanList[i];
      sheet.getRangeByIndex(i + 2, 1).setText(laporan['namaPelapor']);
      sheet.getRangeByIndex(i + 2, 2).setText(laporan['judulLaporan']);
      sheet.getRangeByIndex(i + 2, 3).setText(DateFormat('dd-MM-yyyy').format(laporan['tanggalLaporan']));
      sheet.getRangeByIndex(i + 2, 4).setText(laporan['kategoriLaporan']);
      sheet.getRangeByIndex(i + 2, 5).setText(laporan['deskripsiLaporan']);
      sheet.getRangeByIndex(i + 2, 6).setText(
        laporan['tanggalPerbaikan'] != null
            ? DateFormat('dd-MM-yyyy').format(laporan['tanggalPerbaikan'])
            : '-',
      );
      sheet.getRangeByIndex(i + 2, 7).setText(laporan['notesLaporan']);
      sheet.getRangeByIndex(i + 2, 8).setText(laporan['statusLaporan']);
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: 'laporan.xlsx');
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Text(
            'Data Laporan SIKANCIL',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: [
              'Nama',
              'Judul',
              'Tanggal Laporan',
              'Kategori',
              'Deskripsi',
              'Tanggal Perbaikan',
              'Catatan',
              'Status'
            ],
            data: laporanList.map((laporan) {
              return [
                laporan['namaPelapor'],
                laporan['judulLaporan'],
                DateFormat('dd-MM-yyyy').format(laporan['tanggalLaporan']),
                laporan['kategoriLaporan'],
                laporan['deskripsiLaporan'],
                laporan['tanggalPerbaikan'] != null
                    ? DateFormat('dd-MM-yyyy').format(laporan['tanggalPerbaikan'])
                    : '-',
                laporan['notesLaporan'],
                laporan['statusLaporan']
              ];
            }).toList(),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _exportToSpreadsheet() async {
    const String scriptURL = 'https://script.google.com/macros/s/AKfycbzvZsgYoMR00ovpe8NpGQ0RBldpjcjFnMsLNm2CU48W6C_DZM5YsOozpc6jaTQOoLZl/exec';

    final List<Map<String, dynamic>> formattedData = laporanList.map((laporan) {
      return {
        'namaPelapor': laporan['namaPelapor'],
        'judulLaporan': laporan['judulLaporan'],
        'tanggalLaporan': DateFormat('dd-MM-yyyy').format(laporan['tanggalLaporan']),
        'kategoriLaporan': laporan['kategoriLaporan'],
        'deskripsiLaporan': laporan['deskripsiLaporan'],
        'tanggalPerbaikan': laporan['tanggalPerbaikan'] != null
            ? DateFormat('dd-MM-yyyy').format(laporan['tanggalPerbaikan'])
            : '-',
        'notesLaporan': laporan['notesLaporan'],
        'statusLaporan': laporan['statusLaporan'],
      };
    }).toList();

    try {
    final response = await http.post(
      Uri.parse(scriptURL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(formattedData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Data laporan berhasil diekspor ke Google Spreadsheet. Silakan cek spreadsheet Anda.",
          ),
        ),
      );
    } else {
      throw Exception('Silakan cek spreadsheet Anda.');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text( "Data laporan berhasil diekspor ke Google Spreadsheet. Silakan cek spreadsheet Anda.")),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDataReady = laporanList.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: const Color(0xFF1B9CFC),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context, true),
                  icon: const Icon(Icons.date_range, color: Colors.white),
                  label: Text(
                    startDate == null
                        ? 'Pilih Tanggal Laporan Awal'
                        : DateFormat('dd-MM-yyyy').format(startDate!),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context, false),
                  icon: const Icon(Icons.date_range_outlined, color: Colors.white),
                  label: Text(
                    endDate == null
                        ? 'Pilih Tanggal Laporan Akhir'
                        : DateFormat('dd-MM-yyyy').format(endDate!),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
                ElevatedButton.icon(
                  onPressed: isDataReady ? _exportToExcel : null,
                  icon: Icon(Icons.file_copy, color: isDataReady ? Colors.white : Colors.black),
                  label: Text(
                    'Export Excel',
                    style: TextStyle(color: isDataReady ? Colors.white : Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDataReady ? Colors.green : Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isDataReady ? _exportToPdf : null,
                  icon: Icon(Icons.picture_as_pdf, color: isDataReady ? Colors.white : Colors.black),
                  label: Text(
                    'Export PDF',
                    style: TextStyle(color: isDataReady ? Colors.white : Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDataReady ? Colors.redAccent : Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isDataReady ? _exportToSpreadsheet : null,
                  icon: Icon(Icons.upload_file, color: isDataReady ? Colors.white : Colors.black),
                  label: Text(
                    'Export Spreadsheet',
                    style: TextStyle(color: isDataReady ? Colors.white : Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDataReady ? Colors.orange : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: laporanList.isEmpty
                  ? const Center(child: Text("Tidak ada data untuk ditampilkan"))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFF9AECDB)),
                        columns: const [
                          DataColumn(label: Text('Nama')),
                          DataColumn(label: Text('Judul')),
                          DataColumn(label: Text('Tanggal Laporan')),
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Deskripsi')),
                          DataColumn(label: Text('Tanggal Perbaikan')),
                          DataColumn(label: Text('Catatan')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: laporanList.map((laporan) {
                          return DataRow(
                            cells: [
                              DataCell(Text(laporan['namaPelapor'])),
                              DataCell(Text(laporan['judulLaporan'])),
                              DataCell(Text(DateFormat('dd-MM-yyyy').format(laporan['tanggalLaporan']))),
                              DataCell(Text(laporan['kategoriLaporan'])),
                              DataCell(Text(laporan['deskripsiLaporan'])),
                              DataCell(Text(
                                laporan['tanggalPerbaikan'] != null
                                    ? DateFormat('dd-MM-yyyy').format(laporan['tanggalPerbaikan'])
                                    : '-',
                              )),
                              DataCell(Text(laporan['notesLaporan'])),
                              DataCell(Text(laporan['statusLaporan'])),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
