import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sikancil/controllers/auth_controller.dart';
import 'package:sikancil/pages/custom_textfield.dart';
import 'package:sikancil/routes/app_routes_named.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  final AuthController authController = Get.put(AuthController());

  void _login() {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      authController.login(email, password); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/images/logo_bps.png", height: 75, width: 75),
                            const SizedBox(width: 12),
                            Text(
                              "SIKANCIL BPS JOMBANG",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Selamat datang\nKembali",
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
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Email wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Color(0xffC0C0C0)),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Password wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "Belum punya akun?",
                            style: GoogleFonts.poppins(color: Colors.black),
                          ),
                          const SizedBox(width: 3),
                          TextButton(
                              style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, 
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Get.toNamed(AppRoutesNamed.registerPage);
                            },
                            child: Text(
                              "Daftar",
                              style: GoogleFonts.poppins(
                                  color: Color.fromARGB(255, 255, 72, 0)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B9CFC),
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Masuk",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutesNamed.lupaPassword);
                          },
                          child: Text(
                            "Lupa Password?",
                            style: GoogleFonts.poppins(
                              color: Color.fromARGB(255, 255, 72, 0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
