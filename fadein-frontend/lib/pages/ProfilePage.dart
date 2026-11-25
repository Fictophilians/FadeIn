import 'dart:typed_data';

import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/User.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/ConfirmDialog.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Tab Profil — `docs/DESIGN.md` 7 nomor 6.
///
/// Data akun diambil dari `GET /users/profile` (bukan dari cache login) supaya
/// foto yang baru diunggah langsung terlihat. Unggah memakai
/// `PUT /users/photo` dengan field multipart bernama `photo`.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  /// Batas ukuran file yang diterima backend (5 MB di multer).
  static const batasUkuran = 5 * 1024 * 1024;

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  User? user;
  bool isLoading = true;
  bool isMengunggah = false;
  String? error;

  Future<void> muatData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await Apiservice.get('/users/profile');

      if (!mounted) return;

      setState(() {
        user = User.fromJson(Map<String, dynamic>.from(data as Map));
        isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '$e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> gantiFoto() async {
    final picker = ImagePicker();
    final berkas = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );

    if (berkas == null) return;

    final bytes = await berkas.readAsBytes();

    if (!mounted) return;

    if (bytes.length > ProfilePage.batasUkuran) {
      Pesan.gagal(context, 'Ukuran foto maksimal 5 MB.');
      return;
    }

    setState(() => isMengunggah = true);

    try {
      final data = await Apiservice.upload(
        '/users/photo',
        Uint8List.fromList(bytes),
        filename: berkas.name,
        mimeType: berkas.mimeType ?? 'image/jpeg',
      );

      if (!mounted) return;

      final url = '${(data as Map)['photo'] ?? ''}';

      setState(() {
        user = User(
          id: user!.id,
          name: user!.name,
          email: user!.email,
          role: user!.role,
          photo: url,
        );
        isMengunggah = false;
      });

      // cache sesi ikut diperbarui supaya beranda memakai foto baru
      await Apiservice.saveUser(user!.toJson());

      if (!mounted) return;
      Pesan.sukses(context, 'Foto profil berhasil diperbarui!');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => isMengunggah = false);
      Pesan.gagal(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => isMengunggah = false);
      Pesan.gagal(context, '$e');
    }
  }

  Future<void> keluar() async {
    final yakin = await ConfirmDialog.tampilkan(
      context,
      title: 'Keluar dari akun?',
      message: 'Kamu perlu login lagi untuk melihat pesanan.',
      confirmLabel: 'Ya, keluar',
    );

    if (!yakin || !mounted) return;

    await Apiservice.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('PROFIL')),
      body: _isi(),
    );
  }

  Widget _isi() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Gagal memuat profil',
          message: error,
          actionLabel: 'Coba lagi',
          onAction: muatData,
        ),
      );
    }

    final data = user!;

    return RefreshIndicator(
      onRefresh: muatData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.xl,
          AppSpacing.screenH,
          AppSpacing.xxl,
        ),
        children: [
          Center(
            child: _Avatar(
              photoUrl: data.photo,
              isLoading: isMengunggah,
              onTap: isMengunggah ? null : gantiFoto,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.name,
            textAlign: TextAlign.center,
            style: AppTextTheme.display.copyWith(fontSize: 24),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            data.email,
            textAlign: TextAlign.center,
            style: AppTextTheme.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(child: _BadgePeran(role: data.role)),
          const SizedBox(height: AppSpacing.xxl),
          FadeInButton(
            label: 'Ganti foto',
            icon: Icons.photo_camera_outlined,
            variant: FadeInButtonVariant.ghost,
            isLoading: isMengunggah,
            onPressed: isMengunggah ? null : gantiFoto,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          _barisInfo('Nama', data.name),
          const SizedBox(height: AppSpacing.md),
          _barisInfo('Email', data.email),
          const SizedBox(height: AppSpacing.md),
          _barisInfo('Peran', data.role.label),
          const SizedBox(height: AppSpacing.xxl),
          FadeInButton(
            label: 'Keluar',
            variant: FadeInButtonVariant.danger,
            icon: Icons.logout,
            onPressed: keluar,
          ),
        ],
      ),
    );
  }

  Widget _barisInfo(String label, String nilai) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: AppTextTheme.caption),
        ),
        Expanded(
          child: Text(
            nilai,
            style: AppTextTheme.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

/// Avatar bundar 96 dengan cincin gold dan tombol kamera kecil.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photoUrl,
    required this.isLoading,
    required this.onTap,
  });

  final String? photoUrl;
  final bool isLoading;
  final VoidCallback? onTap;

  static const _fallback = 'assets/images/avatar_default.png';

  Widget _foto() {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return Image.asset(_fallback, width: 96, height: 96, fit: BoxFit.cover);
    }
    return Image.network(
      photoUrl!,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          Image.asset(_fallback, width: 96, height: 96, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Foto profil, ketuk untuk mengganti',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: ClipOval(child: _foto()),
            ),
            if (isLoading)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onDark,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: AppColors.onDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge peran: gold untuk admin, netral untuk customer.
class _BadgePeran extends StatelessWidget {
  const _BadgePeran({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final admin = role == UserRole.admin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: admin ? AppColors.goldSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: admin ? AppColors.gold : AppColors.border),
      ),
      child: Text(
        role.label,
        style: AppTextTheme.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
