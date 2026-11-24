import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/FadeInTextField.dart';
import 'package:fadein_app/widgets/HeroHeader.dart';
import 'package:flutter/material.dart';

/// Layar daftar akun — `docs/DESIGN.md` 7 nomor 3.
///
/// Registrasi selalu menghasilkan role `customer`; tidak ada pilihan peran
/// di form (backend yang menetapkan). Susunan layar mengikuti LoginPage:
/// blok gelap pendek di atas, sheet putih berisi form.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  /// Validasi lokal; mengembalikan pesan error pertama atau `null`.
  String? validasi({
    required String nama,
    required String email,
    required String password,
    required String konfirmasi,
  }) {
    if (nama.trim().length < 3) return 'Nama minimal 3 karakter!';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Format email tidak valid!';
    }
    if (password.length < 6) return 'Password minimal 6 karakter!';
    if (password != konfirmasi) return 'Konfirmasi password tidak cocok!';
    return null;
  }

  Future<void> daftar() async {
    final nama = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final konfirmasi = confirmController.text;

    final salah = validasi(
      nama: nama,
      email: email,
      password: password,
      konfirmasi: konfirmasi,
    );

    if (salah != null) {
      Pesan.gagal(context, salah);
      return;
    }

    setState(() => isLoading = true);

    try {
      await Apiservice.post('/auth/register', {
        'name': nama,
        'email': email,
        'password': password,
      });

      if (!mounted) return;

      Pesan.sukses(context, 'Registrasi berhasil, silakan login!');
      Navigator.pushReplacementNamed(context, '/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      // 409 = email sudah terdaftar, pesannya sudah jelas dari server
      Pesan.gagal(context, e.message);
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
              height: 200,
              onBack: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUAT AKUN',
                    style: AppTextTheme.display.copyWith(
                      fontSize: 30,
                      color: AppColors.onDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Satu menit, lalu bisa booking.',
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
                    FadeInTextField(
                      controller: nameController,
                      label: 'Nama lengkap',
                      hint: 'Mis. Budi Santoso',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: AppSpacing.fieldGap),
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
                    const SizedBox(height: AppSpacing.fieldGap),
                    FadeInTextField(
                      controller: confirmController,
                      label: 'Ulangi password',
                      obscure: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeInButton(
                      label: 'Daftar',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : daftar,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah punya akun?', style: AppTextTheme.caption),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink,
                            textStyle: AppTextTheme.label,
                          ),
                          child: const Text('Masuk'),
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
