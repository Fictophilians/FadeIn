import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/BookingPage.dart';
import 'package:fadein_app/pages/LoginPage.dart';
import 'package:fadein_app/pages/MenuPage.dart';
import 'package:fadein_app/pages/RegisterPage.dart';
import 'package:fadein_app/pages/RuteTerjaga.dart';
import 'package:fadein_app/pages/SplashPage.dart';
import 'package:fadein_app/utils/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Login/Register memakai hero bertinggi tetap; pada landscape sheet form
  // hanya menyisakan beberapa puluh piksel. Kunci portrait agar form tetap
  // terbaca saat HP diputar.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // memuat nama bulan & hari bahasa Indonesia untuk DateFormat
  await initializeDateFormatting('id_ID');

  runApp(const FadeInApp());
}

class FadeInApp extends StatelessWidget {
  const FadeInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FadeIn',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.light,

      // Seluruh teks bawaan Material (date picker, dialog, tombol) ikut
      // berbahasa Indonesia — `docs/DESIGN.md` 12.
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),

        // Beranda customer. Tab Pesanan dan Profil ada di dalam MenuPage,
        // jadi tidak punya route sendiri.
        '/home': (_) => const RuteTerjaga(
              role: 'customer',
              child: MenuPage(),
            ),

        '/booking': (_) => const RuteTerjaga(
              role: 'customer',
              child: BookingPage(),
            ),

        // Beranda admin: tab Barber · Layanan · Booking · Profil.
        '/admin': (_) => const RuteTerjaga(
              role: 'admin',
              child: MenuPage(role: 'admin'),
            ),
      },
      // route belum terdaftar jangan sampai membuat layar mati
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }
}
