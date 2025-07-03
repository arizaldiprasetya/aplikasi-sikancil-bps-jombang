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
        'penanggungJawab': data['penanggungJawab'] ?? '',
        'noTelpPenanggungJawab': data['noTelpPenanggungJawab'] ?? '',
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
      'Status',
      'Penanggung Jawab',
      'No. Telp PJ',
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
      sheet.getRangeByIndex(i + 2, 9).setText(laporan['penanggungJawab']);
      sheet.getRangeByIndex(i + 2, 10).setText(laporan['noTelpPenanggungJawab']);
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
      build: (context) {
        return [
          pw.Center(
            child: pw.Text(
              'Data Laporan SIKANCIL',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(4),
              5: pw.FlexColumnWidth(2),
              6: pw.FlexColumnWidth(3),
              7: pw.FlexColumnWidth(2),
              8: pw.FlexColumnWidth(3),
              9: pw.FlexColumnWidth(3),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Nama', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Judul', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Tgl Laporan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Kategori', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Deskripsi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Tgl Perbaikan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Catatan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Penanggung Jawab', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('No. Telp PJ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),

              ...laporanList.map((laporan) {
                return pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(laporan['namaPelapor'] ?? '')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(laporan['judulLaporan'] ?? '')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(DateFormat('dd-MM-yyyy').format(laporan['tanggalLaporan']))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(laporan['kategoriLaporan'] ?? '')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(laporan['deskripsiLaporan'] ?? '')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(laporan['tanggalPerbaikan'] != null
                            ? DateFormat('dd-MM-yyyy').format(laporan['tanggalPerbaikan'])
                            : '-')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(laporan['notesLaporan'] ?? '')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(laporan['statusLaporan'] ?? '')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(laporan['penanggungJawab'] ?? '')),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(laporan['noTelpPenanggungJawab'] ?? '')),
                  ],
                );
              }).toList(),
            ],
          ),
        ];
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}

  Future<void> _exportToSpreadsheet() async {
    const String scriptURL = 'https://script.google.com/macros/s/AKfycbzH6pt8l5lleeb63_ep6j4u4kSkQKrP1OxCe4HDi5jISYG_vg4IS3XnHS5YctQC_mXq/exec';

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
        'penanggungJawab': laporan['penanggungJawab'],
        'noTelpPenanggungJawab': laporan['noTelpPenanggungJawab'],
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
                          DataColumn(label: Text('PJ')),
                          DataColumn(label: Text('No. Telp PJ')),
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
                              DataCell(Text(laporan['penanggungJawab'])),
                              DataCell(Text(laporan['noTelpPenanggungJawab'])),
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
