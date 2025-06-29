import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sikancil/routes/app_routes_named.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final joinedAt = formatDate(user?.metadata.creationTime);
    final lastLogin = formatDate(user?.metadata.lastSignInTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B9CFC),
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              color: const Color(0xFF9AECDB),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/icons/default_profile.png'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'Admin',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ProfileTile(
                    icon: Icons.calendar_today,
                    title: "Bergabung Pada",
                    subtitle: joinedAt,
                  ),
                  const Divider(),
                  ProfileTile(
                    icon: Icons.access_time,
                    title: "Terakhir Login",
                    subtitle: lastLogin,
                  ),
                  const Divider(),
                  ProfileTile(
                    icon: Icons.location_on,
                    title: "Lokasi",
                    subtitle: "BPS Kabupaten Jombang",
                  ),
                  const Divider(),
                  ProfileTile(
                    icon: Icons.info,
                    title: "Tentang Saya",
                    subtitle: "Admin SIKANCIL BPS Jombang.",
                  ),
                  const Divider(),
                  ProfileTile(
                    icon: Icons.lock,
                    title: "Ganti Password",
                    subtitle: "Perbarui kata sandi Anda",
                    onTap: () {
                      Get.toNamed(AppRoutesNamed.gantiPasswordAdmin);
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Get.offAllNamed(AppRoutesNamed.loginPage);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Keluar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF9AECDB),
        child: Icon(icon, color: const Color(0xFF182C61)),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
