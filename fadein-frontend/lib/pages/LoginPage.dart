import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/RuteTerjaga.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/FadeInTextField.dart';
import 'package:flutter/material.dart';

/// Layar login — `docs/DESIGN.md` 7 nomor 2.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical: AppSpacing.xxl,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Image.asset(
                  'assets/images/logo_mark.png',
                  height: 96,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'MASUK',
                  textAlign: TextAlign.center,
                  style: AppTextTheme.display,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Booking barbershop tanpa antre.',
                  textAlign: TextAlign.center,
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
                const SizedBox(height: AppSpacing.md),
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
      ),
    );
  }
}