import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GantiPasswordPage extends StatefulWidget {
  const GantiPasswordPage({super.key});

  @override
  State<GantiPasswordPage> createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email!, password: _oldPasswordController.text);

    try {
      // Re-authenticate user
      await user.reauthenticateWithCredential(cred);

      // Cek konfirmasi password baru
      if (_newPasswordController.text != _confirmPasswordController.text) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar("Error", "Password baru dan konfirmasi tidak sama",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Update password
      await user.updatePassword(_newPasswordController.text);
      await FirebaseAuth.instance.signOut();

      setState(() {
        _isLoading = false;
      });

      Get.snackbar("Sukses", "Password berhasil diganti. Silakan login ulang.",
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed('/login'); // pastikan route loginPage sesuai di project anda

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.code == 'wrong-password') {
        Get.snackbar("Error", "Password lama salah",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar("Error", e.message ?? "Terjadi kesalahan",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B9CFC),
        title: Text('Ganti Password',
            style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildPasswordField("Password Lama", _oldPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("Password Baru", _newPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("Konfirmasi Password Baru", _confirmPasswordController),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B9CFC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Simpan Perubahan",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: const Color(0xFFF1F2F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.lock),
      ),
    );
  }
}
