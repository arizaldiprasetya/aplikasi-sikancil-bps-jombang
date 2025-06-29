import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'riwayat_laporan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: BuatLaporanPage()));
}

class BuatLaporanPage extends StatefulWidget {
  @override
  _BuatLaporanPageState createState() => _BuatLaporanPageState();
}

class _BuatLaporanPageState extends State<BuatLaporanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tanggalController = TextEditingController(
    text: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()) + ' WIB',
  );
  final _penanggungJawabController = TextEditingController();

  String? _kategoriTerpilih;
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _kategoriList = [
    'Keamanan',
    'Kebersihan',
    'Kerusakan Barang IT',
    'Kerusakan Barang Non-IT',
    'Lainnya',
  ];

  final Map<String, String> _penanggungJawabMap = {
    'Kerusakan Barang IT': 'Riska Andriani, S.ST',
    'Kerusakan Barang Non-IT': 'Mitha Ramadhani Pratiwi, A.Md',
    'Keamanan': 'Alim Sholehuddin, S.Si, M.E',
    'Kebersihan': 'Alim Sholehuddin, S.Si, M.E',
    'Lainnya': 'Alim Sholehuddin, S.Si, M.E',
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.length();

        if (bytes > 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ukuran gambar melebihi 1 MB!')),
          );
        } else {
          setState(() {
            _imageFile = file;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<String?> _convertImageToBase64() async {
    try {
      if (_imageFile == null) return null;
      List<int> imageBytes = await _imageFile!.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      throw Exception("Gagal konversi gambar ke Base64: $e");
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User belum login!");

      String? base64Image = await _convertImageToBase64();
      final tanggalString = _tanggalController.text.replaceAll(' WIB', '');
      final tanggalLaporan = DateFormat('dd-MM-yyyy HH:mm').parse(tanggalString);

      await FirebaseFirestore.instance.collection('laporan').add({
        'userId': user.uid,
        'namaPelapor': _namaController.text.trim(),
        'judulLaporan': _judulController.text.trim(),
        'tanggalLaporan': Timestamp.fromDate(tanggalLaporan),
        'kategoriLaporan': _kategoriTerpilih,
        'penanggungJawab': _penanggungJawabController.text.trim(),
        'deskripsiLaporan': _deskripsiController.text.trim(),
        'gambarBase64': base64Image ?? '',
        'notesLaporan': '',
        'statusLaporan': 'Menunggu Diproses',
        'tanggalPerbaikan': '',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan berhasil dibuat!')),
      );

      _resetForm();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RiwayatLaporanPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _kategoriTerpilih = null;
      _penanggungJawabController.clear();
      _imageFile = null;
      _tanggalController.text =
          DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()) + ' WIB';
    });
  }

  Future<void> _selectTanggal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2200),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        String formatted =
            DateFormat('dd-MM-yyyy HH:mm').format(combined) + ' WIB';

        setState(() {
          _tanggalController.text = formatted;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Buat Laporan'),
            backgroundColor: Color(0xFF1B9CFC),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    'Nama Pelapor',
                    _namaController,
                    hintText: 'Isikan anonim jika ingin tidak diketahui nama Anda!',
                  ),
                  SizedBox(height: 12),
                  _buildTextField('Judul Laporan', _judulController),
                  SizedBox(height: 12),
                  _buildDateField(),
                  SizedBox(height: 12),
                  _buildDropdownField(),
                  SizedBox(height: 12),
                  _buildTextField('Penanggung Jawab Kategori', _penanggungJawabController),
                  SizedBox(height: 12),
                  _buildTextField('Deskripsi Laporan', _deskripsiController, maxLines: 3),
                  SizedBox(height: 16),
                  _buildImageUploadSection(),
                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3CD),
                      border: Border.all(color: Color(0xFFFFEEBA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pastikan gambar yang diunggah tidak melebihi 1 MB untuk menghindari kegagalan saat pengiriman laporan.',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1B9CFC),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _isLoading ? null : _submitForm,
                    icon: Icon(Icons.send),
                    label: Text('Kirim Laporan'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black45,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: label == 'Penanggung Jawab Kategori',
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 10),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: maxLines,
      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _tanggalController,
      decoration: InputDecoration(
        labelText: 'Tanggal dan Waktu Laporan',
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      readOnly: true,
      onTap: _selectTanggal,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _kategoriTerpilih,
      decoration: InputDecoration(
        labelText: 'Kategori Laporan',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _kategoriList.map((kategori) {
        return DropdownMenuItem(value: kategori, child: Text(kategori));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _kategoriTerpilih = value;
          _penanggungJawabController.text =
              _penanggungJawabMap[value!] ?? '';
        });
      },
      validator: (value) => value == null ? 'Pilih kategori' : null,
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Gambar (Max 1 MB)', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_imageFile!, height: 150),
              )
            : Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
              ),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_camera),
              label: Text('Upload Gambar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1B9CFC),
                foregroundColor: Colors.white,
              ),
            ),
            if (_imageFile != null)
              ElevatedButton.icon(
                onPressed: () => setState(() => _imageFile = null),
                icon: Icon(Icons.delete),
                label: Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              )
          ],
        ),
      ],
    );
  }
}
