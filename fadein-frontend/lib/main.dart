import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'dev/theme_preview_page.dart';

void main() {
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
      // Sementara: halaman pratinjau tema. Diganti Splash pada T6.
      home: const ThemePreviewPage(),
    );
  }
}
