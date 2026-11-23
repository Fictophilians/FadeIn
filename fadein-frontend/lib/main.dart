import 'package:fadein_app/constants/theme.dart';
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
      // Halaman login, home, dan admin didaftarkan pada T8–T11.
      home: const SplashPage(),
    );
  }
}