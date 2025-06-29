import 'package:get/route_manager.dart';
import 'package:sikancil/pages/admin/beranda_admin.dart';
import 'package:sikancil/pages/admin/dashboard.dart';
import 'package:sikancil/pages/admin/export_data.dart';
import 'package:sikancil/pages/admin/ganti_password_admin.dart';
import 'package:sikancil/pages/admin/kelola_laporan.dart';
import 'package:sikancil/pages/auth/login_page.dart';
import 'package:sikancil/pages/auth/lupa_password.dart';
import 'package:sikancil/pages/auth/register_page.dart';
import 'package:sikancil/pages/get_started.dart';
import 'package:sikancil/pages/splash_screen.dart';
import 'package:sikancil/pages/user/beranda_page.dart';
import 'package:sikancil/pages/user/ganti_password.dart';
import 'package:sikancil/pages/user/laporan/buat_laporan.dart';
import 'package:sikancil/pages/user/laporan/riwayat_laporan.dart';
import 'package:sikancil/routes/app_routes_named.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: AppRoutesNamed.splashScreen, page: () => SplashScreen()),
    GetPage(name: AppRoutesNamed.getStarted, page: () => GetStarted()),
    GetPage(name: AppRoutesNamed.loginPage, page: () => LoginPage()),
    GetPage(name: AppRoutesNamed.registerPage, page: () => RegisterPage()),
    GetPage(name: AppRoutesNamed.berandaPage, page: () => BerandaPage()),
    GetPage(name: AppRoutesNamed.buatLaporan, page: () => BuatLaporanPage()),
    GetPage(name: AppRoutesNamed.riwayatLaporan, page: () => RiwayatLaporanPage()),
    GetPage(name: AppRoutesNamed.adminPage, page: () => BerandaAdminPage()),
    GetPage(name: AppRoutesNamed.adminDashboard, page: () => DashboardPage()),
    GetPage(name: AppRoutesNamed.kelolaLaporan, page: () => KelolaLaporanPage()),
    GetPage(name: AppRoutesNamed.exportData, page: () => ExportDataPage()),
    GetPage(name: AppRoutesNamed.gantiPassword, page: () => GantiPasswordPage()),
    GetPage(name: AppRoutesNamed.gantiPasswordAdmin, page: () => GantiPasswordAdminPage()),
    GetPage(name: AppRoutesNamed.lupaPassword, page: () => LupaPasswordPage()),
  ];
}