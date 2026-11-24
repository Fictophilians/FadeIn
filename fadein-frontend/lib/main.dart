import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/LoginPage.dart';
import 'package:fadein_app/pages/MenuPage.dart';
import 'package:fadein_app/pages/RegisterPage.dart';
import 'package:fadein_app/pages/RuteTerjaga.dart';
import 'package:fadein_app/pages/SplashPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        '/home': (_) => const RuteTerjaga(
              role: 'customer',
              child: MenuPage(),
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
