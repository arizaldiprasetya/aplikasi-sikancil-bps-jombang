import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'akun_page.dart';
import 'package:sikancil/routes/app_routes_named.dart';

class BerandaPage extends StatefulWidget {
  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    // FeedPage(),
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.article),
          //   label: 'Feed',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
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
              'Beranda',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hello, ${user?.email ?? 'Pengguna'}',
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
                        // ignore: deprecated_member_use
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
                              'Selamat Datang di\nAplikasi SIKANCIL',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MenuItem(
                  iconPath: 'assets/icons/laporan.png',
                  label: 'Buat Laporan',
                  onTap: () {
                    Get.toNamed(AppRoutesNamed.buatLaporan);
                  },
                ),
                _MenuItem(
                  iconPath: 'assets/icons/riwayat_laporan.png',
                  label: 'Riwayat Laporan',
                  onTap: () {
                    Get.toNamed(AppRoutesNamed.riwayatLaporan);
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Alur Laporan Pengaduan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AlurItem(
                  iconPath: 'assets/icons/pencil.png',
                  title: 'Tulis Laporan',
                  description: 'Laporkan keluhan Anda\ndengan jelas dan lengkap',
                ),
                _AlurItem(
                  iconPath: 'assets/icons/chat.png',
                  title: 'Tunggu Diproses',
                  description:
                      'Dalam 1x24 jam kerja,\nadmin akan menindaklanjuti',
                ),
                _AlurItem(
                  iconPath: 'assets/icons/check.png',
                  title: 'Selesai',
                  description:
                      'Laporan Anda akan\nditindaklanjuti hingga selesai',
                ),
              ],
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

class _AlurItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;

  const _AlurItem({
    required this.iconPath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF9AECDB),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(iconPath),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
