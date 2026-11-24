import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/RuteTerjaga.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/FadeInTextField.dart';
import 'package:fadein_app/widgets/HeroHeader.dart';
import 'package:flutter/material.dart';

/// Layar login — `docs/DESIGN.md` 7 nomor 2.
///
/// Foto hero di atas, lalu sheet putih yang menimpa tepi bawahnya sejauh
/// [AppRadius.sheetLg]. Susunan ini dipakai juga oleh [RegisterPage].
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  /// Tinggi foto hero.
  static const heroTinggi = 320.0;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Pesan.gagal(context, 'Email dan password wajib diisi!');
      return;
    }

    if (!email.contains('@')) {
      Pesan.gagal(context, 'Format email tidak valid!');
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await Apiservice.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final token = '${data['token'] ?? ''}';
      final user = Map<String, dynamic>.from(data['user'] as Map);

      await Apiservice.saveToken(token);
      await Apiservice.saveUser(user);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        RuteTerjaga.beranda(user['role']?.toString()),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Pesan.gagal(
        context,
        e.isUnauthorized ? 'Email atau password salah' : e.message,
      );
    } catch (e) {
      if (!mounted) return;
      Pesan.gagal(context, '$e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        // Stack: foto hero di belakang, sheet didorong turun supaya tepi
        // atasnya menimpa foto. Tidak ada ruang mati di bawah seperti pola
        // `Transform.translate` (parent tidak ikut menyusut).
        child: Stack(
          children: [
            SizedBox(
              height: LoginPage.heroTinggi,
              width: double.infinity,
              child: HeroHeader(
                height: LoginPage.heroTinggi,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TEMUKAN GAYA KAMU',
                      style: AppTextTheme.display.copyWith(
                        fontSize: 28,
                        height: 1.1,
                        color: AppColors.onDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Booking barbershop tanpa antre.',
                      style: AppTextTheme.caption.copyWith(
                        color: AppColors.onDark.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                top: LoginPage.heroTinggi - AppRadius.sheetLg,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.xl,
                  AppSpacing.screenH,
                  AppSpacing.xxl,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sheetLg),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Selamat datang kembali', style: AppTextTheme.section),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Masuk untuk melanjutkan booking.',
                      style: AppTextTheme.caption,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    FadeInTextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'nama@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                    ),
                    const SizedBox(height: AppSpacing.fieldGap),
                    FadeInTextField(
                      controller: passwordController,
                      label: 'Password',
                      obscure: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    FadeInButton(
                      label: 'Masuk',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : login,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Belum punya akun?',
                            style: AppTextTheme.caption,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pushNamed(context, '/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            textStyle: AppTextTheme.label,
                          ),
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
