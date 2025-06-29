import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sikancil/pages/custom_textfield.dart';
import 'package:sikancil/routes/app_routes_named.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validasi email dengan regex
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }

    const pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@+[a-zA-Z0-9]+\.[a-zA-Z]+";
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfirmasi password tidak sama')),
        );
        return;
      }

      try {
        // Register akun ke Firebase Auth
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final uid = userCredential.user!.uid;

        // Simpan data ke Firestore (koleksi users)
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'role': 'user', // default role user
          'created_at': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil')),
        );

        Get.offNamed(AppRoutesNamed.loginPage);
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email sudah terdaftar. Silakan gunakan email lain.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Format email tidak valid.';
        } else {
          errorMessage = e.message ?? 'Terjadi kesalahan saat registrasi.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $errorMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/logo_bps.png",
                        height: 75, width: 75),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        "SIKANCIL BPS JOMBANG",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Selamat datang\nSilahkan Mendaftar",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextFormField(
                  label: "Email",
                  controller: emailController,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) => value == null || value.length < 6
                      ? 'Password minimal 6 karakter'
                      : null,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Color(0xffC0C0C0)),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Konfirmasi password wajib diisi'
                      : null,
                  decoration: InputDecoration(
                    labelText: "Konfirmasi Password",
                    labelStyle: const TextStyle(color: Color(0xffC0C0C0)),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Sudah punya akun?",
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                    const SizedBox(width: 3),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Get.offNamed(AppRoutesNamed.loginPage);
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 255, 72, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF182C61),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Daftar",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
