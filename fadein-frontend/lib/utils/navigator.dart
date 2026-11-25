import 'package:flutter/material.dart';

/// Navigator global aplikasi.
///
/// Dipakai lapisan jaringan untuk memaksa kembali ke `/login` saat token
/// kedaluwarsa, tanpa perlu `BuildContext` dari layar yang sedang terbuka.
final navigatorKey = GlobalKey<NavigatorState>();
