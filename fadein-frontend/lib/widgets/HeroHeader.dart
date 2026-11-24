import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Header foto penuh dengan tirai gelap di bagian bawah.
///
/// Dipakai layar login, register, dan splash. Foto menutup seluruh area
/// (`BoxFit.cover`, fokus atas supaya wajah tidak terpotong), lalu gradien
/// `AppGradient.heroOverlay` memastikan teks putih tetap terbaca.
///
/// ```dart
/// HeroHeader(
///   image: 'assets/images/hero_barber.jpg',
///   height: 340,
///   child: Text('TEMUKAN GAYA KAMU', style: ...),
/// )
/// ```
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    this.image = 'assets/images/hero_barber.jpg',
    this.height = 320,
    this.child,
    this.onBack,
    this.roundedBottom = false,
    this.fadeToInk = false,
  });

  /// Path aset (`assets/...`). `null` = blok gelap tanpa foto.
  final String? image;

  final double height;

  /// Isi yang diletakkan di bagian bawah foto, di atas gradien.
  final Widget? child;

  /// Bila diisi, tombol bulat kembali muncul di kiri atas.
  final VoidCallback? onBack;

  /// `true` = sudut bawah membulat.
  final bool roundedBottom;

  /// `true` = latar belakang jadi `ink` polos (dipakai saat foto gagal).
  final bool fadeToInk;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: roundedBottom
          ? const BorderRadius.vertical(
              bottom: Radius.circular(AppRadius.xl),
            )
          : BorderRadius.zero,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.asset(
                image!,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: AppColors.inkSoft),
              )
            else
              const ColoredBox(color: AppColors.inkSoft),

            if (fadeToInk)
              // splash: tirai rata supaya logo jadi fokus, foto tetap terasa
              const DecoratedBox(
                decoration: BoxDecoration(color: AppColors.splashScrim),
              )
            else
              // hero: gelap bertingkat, judul terbaca di bawah
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradient.heroOverlay),
              ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.md,
                  AppSpacing.screenH,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onBack != null) _TombolKembali(onTap: onBack!),
                    const Spacer(),
                    ?child,
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

/// Tombol bulat putih transparan di pojok kiri atas.
class _TombolKembali extends StatelessWidget {
  const _TombolKembali({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onDark.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back, color: AppColors.onDark, size: 22),
        ),
      ),
    );
  }
}
