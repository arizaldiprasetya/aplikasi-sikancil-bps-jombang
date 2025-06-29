import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'akun_admin.dart';
import 'package:sikancil/routes/app_routes_named.dart';

class BerandaAdminPage extends StatefulWidget {
  @override
  _BerandaAdminPageState createState() => _BerandaAdminPageState();
}

class _BerandaAdminPageState extends State<BerandaAdminPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeAdminContent(),
    AkunPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF182C61),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class HomeAdminContent extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beranda Admin',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hello, ${user?.email ?? 'admin'}',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/bg_rectangle.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF9AECDB).withOpacity(0.5),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo_bps.png',
                              height: 50,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Selamat Datang di\nHalaman Admin SIKANCIL',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sistem Keluhan dan Cek Infrastruktur Layanan',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'BPS Kabupaten Jombang',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
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
            const SizedBox(height: 30),

            // MENU UTAMA
            Center(
              child: SizedBox(
                width: 300,
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _MenuItem(
                      iconPath: 'assets/icons/dashboard.png',
                      label: 'Dashboard',
                      onTap: () {
                        Get.toNamed(AppRoutesNamed.adminDashboard);
                      },
                    ),
                    _MenuItem(
                      iconPath: 'assets/icons/notebook.png',
                      label: 'Kelola Laporan',
                      onTap: () {
                        Get.toNamed(AppRoutesNamed.kelolaLaporan);
                      },
                    ),
                    _MenuItem(
                      iconPath: 'assets/icons/export.png',
                      label: 'Export Data',
                      onTap: () {
                        Get.toNamed(AppRoutesNamed.exportData);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF9AECDB),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(iconPath),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(),
          ),
        ],
      ),
    );
  }
}
