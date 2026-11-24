import 'dart:async';

import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/widgets/HeroHeader.dart';
import 'package:flutter/material.dart';

/// Layar pembuka: membaca sesi tersimpan lalu mengarahkan ke layar yang tepat.
///
/// Foto barbershop menjadi latar dengan tirai pekat, logo di tengah. Ada
/// durasi minimum supaya layar tidak berkedip saat storage cepat menjawab.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// Aturan tujuan berdasarkan sesi (task.md T6).
  ///
  /// Dipisah sebagai fungsi murni supaya bisa diuji tanpa secure storage.
  static String ruteUntuk({String? token, String? role}) {
    if (token == null || token.isEmpty) return '/login';
    return role == 'admin' ? '/admin/barbers' : '/home';
  }

  /// Lama minimum splash tampil (ms).
  static const durasiMinimum = Duration(milliseconds: 1100);

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
    final mulai = DateTime.now();

    final token = await Apiservice.getToken();
    final user = await Apiservice.getUser();

    // sisa waktu supaya splash tidak sekadar berkedip
    final sisa = SplashPage.durasiMinimum - DateTime.now().difference(mulai);
    if (sisa > Duration.zero) await Future<void>.delayed(sisa);

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
      backgroundColor: AppColors.ink,
      body: HeroHeader(
        height: double.infinity,
        fadeToInk: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_white.png',
              width: 132,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(width: 56, height: 3, color: AppColors.gold),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Booking barbershop\ntanpa antre.',
              style: AppTextTheme.body.copyWith(
                color: AppColors.onDark.withValues(alpha: 0.8),
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(
              width: 20,
              height: 20,
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
