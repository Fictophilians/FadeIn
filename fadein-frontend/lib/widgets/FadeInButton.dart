import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Varian tombol sesuai `docs/DESIGN.md` 5.1.
enum FadeInButtonVariant { primary, secondary, ghost, danger }

/// Tombol utama aplikasi.
///
/// Tinggi 48, radius 12, padding horizontal 20, dan tiga state:
/// normal, loading (spinner, tidak bisa ditekan), disabled (opacity 0.4).
class FadeInButton extends StatelessWidget {
  const FadeInButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = FadeInButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final FadeInButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  /// Tombol tidak bisa ditekan saat loading atau `onPressed` kosong.
  bool get _nonaktif => isLoading || onPressed == null;

  Color get _latar {
    switch (variant) {
      case FadeInButtonVariant.primary:
        return AppColors.ink;
      case FadeInButtonVariant.secondary:
        return AppColors.gold;
      case FadeInButtonVariant.ghost:
        return AppColors.transparent;
      case FadeInButtonVariant.danger:
        return AppColors.danger;
    }
  }

  Color get _teks {
    switch (variant) {
      case FadeInButtonVariant.primary:
      case FadeInButtonVariant.danger:
        return AppColors.onDark;
      case FadeInButtonVariant.secondary:
      case FadeInButtonVariant.ghost:
        return AppColors.ink;
    }
  }

  BorderSide get _border {
    if (variant != FadeInButtonVariant.ghost) return BorderSide.none;
    return const BorderSide(color: AppColors.border);
  }

  @override
  Widget build(BuildContext context) {
    final tombol = Opacity(
      opacity: (onPressed == null && !isLoading) ? 0.4 : 1,
      child: SizedBox(
        height: 48,
        width: expanded ? double.infinity : null,
        child: TextButton(
          onPressed: _nonaktif ? null : onPressed,
          style: TextButton.styleFrom(
            backgroundColor: _latar,
            foregroundColor: _teks,
            disabledBackgroundColor: _latar,
            disabledForegroundColor: _teks,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
              side: _border,
            ),
            textStyle: AppTextTheme.label.copyWith(color: _teks),
          ),
          child: isLoading ? const _Spinner() : _isi(),
        ),
      ),
    );

    return tombol;
  }

  Widget _isi() {
    if (icon == null) {
      return Text(label, style: AppTextTheme.label.copyWith(color: _teks));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: _teks),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextTheme.label.copyWith(color: _teks)),
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onDark),
    );
  }
}