import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Header foto penuh dengan tirai gelap bertingkat.
///
/// Dipakai layar login, register, dan splash. Foto menutup seluruh area
/// (`BoxFit.cover`, fokus tengah supaya subjek tidak terpotong), lalu
/// [AppGradient.heroOverlay] memastikan teks putih tetap terbaca.
///
/// Foto bawaan landscape 1400×933. Untuk splash yang butuh tirai rata,
/// kirim [scrim] eksplisit alih-alih menambah cabang di dalam widget ini.
///
/// ```dart
/// HeroHeader(
///   image: 'assets/images/hero_login.jpg',
///   height: 320,
///   child: Text('TEMUKAN GAYA KAMU', style: ...),
/// )
/// ```
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    this.image = 'assets/images/hero_login.jpg',
    this.height = 320,
    this.child,
    this.onBack,
    this.roundedBottom = false,
    this.scrim,
    this.paddingBottom = AppSpacing.xxl,
  });

  /// Path aset (`assets/...`). `null` = blok gelap tanpa foto.
  final String? image;

  final double height;

  /// Isi di bagian bawah foto, di atas gradien.
  final Widget? child;

  /// Bila diisi, tombol bulat kembali muncul di kiri atas.
  final VoidCallback? onBack;

  /// `true` = sudut bawah membulat.
  final bool roundedBottom;

  /// Tirai pengganti gradien. `null` → `AppGradient.heroOverlay`.
  final Color? scrim;

  /// Jarak [child] ke tepi bawah foto.
  ///
  /// [child] dipaku ke dasar lewat `Spacer`, jadi menambah nilai ini
  /// mengangkat seluruh isi hero tanpa mengubah tinggi fotonya. Layar yang
  /// juga memperbesar [height] harus menaikkan nilai ini sebesar selisihnya
  /// supaya teks tidak ikut turun.
  final double paddingBottom;

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
                alignment: Alignment.center,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: AppColors.inkSoft),
              )
            else
              const ColoredBox(color: AppColors.inkSoft),

            if (scrim != null)
              DecoratedBox(decoration: BoxDecoration(color: scrim))
            else
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradient.heroOverlay),
              ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.md,
                  AppSpacing.screenH,
                  paddingBottom,
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
