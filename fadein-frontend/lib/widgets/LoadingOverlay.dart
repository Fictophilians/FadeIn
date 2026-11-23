import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Scrim + kartu "Memproses..." — `docs/DESIGN.md` 5.9.
///
/// Dipakai hanya untuk aksi yang memblokir layar (simpan, unggah, batalkan).
/// Pemuatan daftar cukup `CircularProgressIndicator` di tengah layar.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message = 'Memproses...'});

  final String message;

  /// Menampilkan overlay tanpa memindahkan layar; tutup dengan `Navigator.pop`.
  static Future<void> tampilkan(
    BuildContext context, {
    String message = 'Memproses...',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.scrim,
      builder: (_) => PopScope(
        canPop: false,
        child: LoadingOverlay(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTextTheme.body),
          ],
        ),
      ),
    );
  }
}