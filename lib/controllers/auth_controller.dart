import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikancil/routes/app_routes_named.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final uid = userCredential.user!.uid;
      
      final doc = await _firestore.collection('users').doc(uid).get();

      final role = doc.data()?['role'];

      if (role == 'admin') {
        Get.offAllNamed(AppRoutesNamed.adminPage);
      } else {
        Get.offAllNamed(AppRoutesNamed.berandaPage);
      }

      Get.snackbar(
        "Sukses",
        "Login berhasil",
        backgroundColor: const Color(0xFF1B9CFC),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          errorMessage = 'Email atau Password yang dimasukkan salah.';
          break;
        case 'invalid-email':
          errorMessage = 'Email tidak sesuai format.';
          break;
        default:
          errorMessage = e.message ?? 'Terjadi kesalahan saat login';
      }

      Get.snackbar(
        'Login Gagal',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar(
        "Sukses",
        "Email reset password telah dikirim ke $email",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed(AppRoutesNamed.loginPage);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Gagal',
        e.message ?? 'Terjadi kesalahan saat mengirim email reset password',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
