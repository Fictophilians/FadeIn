import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/HeroHeader.dart';
import 'package:flutter/material.dart';

/// Layar pembuka: memperkenalkan aplikasi lalu menunggu pengguna menekan
/// "Mulai".
///
/// Tidak ada pengalihan otomatis — pengguna yang menentukan kapan masuk.
/// Sesi tersimpan baru dibaca saat tombol ditekan, jadi layar ini tidak
/// bergantung pada storage untuk tampil.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// Aturan tujuan berdasarkan sesi (task.md T6).
  ///
  /// Dipisah sebagai fungsi murni supaya bisa diuji tanpa secure storage.
  static String ruteUntuk({String? token, String? role}) {
    if (token == null || token.isEmpty) return '/login';
    return role == 'admin' ? '/admin' : '/home';
  }

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isLoading = false;

  Future<void> mulai() async {
    setState(() => isLoading = true);

    final token = await Apiservice.getToken();
    final user = await Apiservice.getUser();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      SplashPage.ruteUntuk(token: token, role: user?['role']?.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: HeroHeader(
        height: double.infinity,
        scrim: AppColors.splashScrim,
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
              style: AppTextTheme.display.copyWith(
                fontSize: 30,
                height: 1.2,
                color: AppColors.onDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pilih barber, pilih jam, datang tanpa menunggu.',
              style: AppTextTheme.body.copyWith(
                color: AppColors.onDark.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FadeInButton(
              label: 'Mulai',
              icon: Icons.arrow_forward,
              isLoading: isLoading,
              onPressed: isLoading ? null : mulai,
            ),
          ],
        ),
      ),
    );
  }
}
