import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/HomePage.dart';
import 'package:fadein_app/pages/LoginPage.dart';
import 'package:fadein_app/pages/RegisterPage.dart';
import 'package:fadein_app/pages/RuteTerjaga.dart';
import 'package:fadein_app/pages/SplashPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const RuteTerjaga(
              role: 'customer',
              child: HomePage(),
            ),
        // /booking, /my-bookings, /profile menyusul di T12–T15.
        // /admin/* menyusul di T16–T18.
      },
      // route belum terdaftar jangan sampai membuat layar mati
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }
}