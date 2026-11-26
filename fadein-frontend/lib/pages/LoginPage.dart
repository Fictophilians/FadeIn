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
      // Stack (bukan SingleChildScrollView luar): sheet dijangkar ke tepi
      // bawah layar lewat `bottom: 0`, jadi tidak ada pita ivory kosong di
      // bawah form. Yang bergulir hanya isi sheet.
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: LoginPage.heroTinggi,
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
                  // Jarak caption ke sheet: sheet menimpa 28 di tepi bawah
                  // foto, jadi caption dinaikkan dulu supaya tidak tertutup.
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          Positioned(
            top: LoginPage.heroTinggi - AppRadius.sheetLg,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheetLg),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, batas) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.xl,
                    AppSpacing.screenH,
                    AppSpacing.xxl,
                  ),
                  // ConstrainedBox + Center: isi diletakkan di tengah tinggi
                  // sheet saat ruang cukup; saat layar pendek isi melebihi
                  // batas dan tetap bisa digulir.
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: batas.maxHeight -
                          AppSpacing.xl -
                          AppSpacing.xxl,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Selamat datang kembali',
                            style: AppTextTheme.display.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Masuk untuk melanjutkan booking.',
                            style: AppTextTheme.caption,
                          ),
                          const SizedBox(height: AppSpacing.xxl),

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
                                    : () => Navigator.pushNamed(
                                        context,
                                        '/register',
                                      ),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
