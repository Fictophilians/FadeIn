import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/service/api.dart';
import 'package:flutter/material.dart';

/// Layar pembuka: membaca sesi tersimpan lalu mengarahkan ke layar yang tepat.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// Aturan tujuan berdasarkan sesi (task.md T6).
  ///
  /// Dipisah sebagai fungsi murni supaya bisa diuji tanpa secure storage.
  static String ruteUntuk({String? token, String? role}) {
    if (token == null || token.isEmpty) return '/login';
    return role == 'admin' ? '/admin/barbers' : '/home';
  }

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _arahkan();
  }

  Future<void> _arahkan() async {
    final token = await Apiservice.getToken();
    final user = await Apiservice.getUser();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      SplashPage.ruteUntuk(
        token: token,
        role: user?['role']?.toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkSoft,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/splash_logo.png',
              width: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'FADEIN',
              style: AppTextTheme.display.copyWith(color: AppColors.onDark),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}