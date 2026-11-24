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
/// Susunan: blok gelap di atas berisi judul besar, lalu sheet putih yang
/// naik dari bawah memuat form. Pola ini sama untuk register.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroHeader(
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEMUKAN\nGAYA KAMU',
                    style: AppTextTheme.display.copyWith(
                      fontSize: 34,
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
            Transform.translate(
              offset: const Offset(0, -AppRadius.sheetLg),
              child: Container(
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
                    const SizedBox(height: AppSpacing.lg),

                    FadeInButton(
                      label: 'Masuk',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : login,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // pemisah visual; tombol sosial hanya tampilan, belum aktif
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            'atau lanjut dengan',
                            style: AppTextTheme.caption,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Row(
                      children: [
                        Expanded(
                          child: _TombolSosial(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _TombolSosial(
                            icon: Icons.apple,
                            label: 'Apple',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun?', style: AppTextTheme.caption),
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

/// Tombol sosial nonaktif — hanya untuk kelengkapan visual.
///
/// Login sosial belum ada di backend, jadi tombol sengaja tidak melakukan
/// apa pun dan tidak bisa ditekan.
class _TombolSosial extends StatelessWidget {
  const _TombolSosial({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: AppColors.muted),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextTheme.label.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}
