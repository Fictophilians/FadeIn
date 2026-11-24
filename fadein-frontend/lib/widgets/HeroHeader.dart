import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Header gelap di atas layar, dipakai login dan splash.
///
/// Tanpa foto: blok `inkSoft` → `ink` dengan aksen gold. Ini pilihan sadar
/// supaya tidak perlu aset foto berlisensi dan tetap cepat dimuat.
///
/// ```dart
/// HeroHeader(
///   height: 320,
///   child: Text('Discover Your\nSignature Style', style: ...),
/// )
/// ```
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    this.height = 320,
    this.child,
    this.onBack,
    this.roundedBottom = false,
  });

  final double height;

  /// Isi yang diletakkan di bagian bawah, di atas gradien.
  final Widget? child;

  /// Bila diisi, tombol bulat kembali muncul di kiri atas.
  final VoidCallback? onBack;

  /// `true` = sudut bawah membulat.
  final bool roundedBottom;

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
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradient.promo),
          child: Stack(
            children: [
              // garis gold tipis sebagai aksen, bukan hiasan berlebih
              Positioned(
                left: AppSpacing.screenH,
                right: AppSpacing.screenH,
                bottom: 0,
                child: Container(height: 3, color: AppColors.gold),
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
