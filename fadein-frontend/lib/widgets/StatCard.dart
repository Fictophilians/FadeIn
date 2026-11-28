import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Satu kotak angka di dashboard admin.
///
/// Dipakai berpasangan lewat [Row] + [Expanded], bukan [GridView], supaya
/// tinggi kartu mengikuti isi. Nilai rupiah yang panjang diperkecil sendiri
/// oleh [FittedBox] alih-alih meluber keluar kotak.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.icon,
    this.accent = AppColors.ink,
  });

  /// Keterangan kecil di atas angka, mis. "PENDAPATAN BULAN INI".
  final String label;

  /// Angka utama yang sudah diformat, mis. `Rp1.250.000`.
  final String value;

  /// Keterangan tambahan di bawah angka, mis. "dari 6 hari aktif".
  final String? sub;

  final IconData? icon;

  /// Warna angka. Default `ink`; dipakai `success`/`danger` untuk tren.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                // Tinggi dikunci dua baris supaya angka pada kartu sebelah
                // tetap sejajar walau labelnya hanya satu baris.
                child: SizedBox(
                  height: 30,
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTheme.caption.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.xxs),
                Icon(icon, size: 16, color: AppColors.muted),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextTheme.section.copyWith(
                fontSize: 22,
                color: accent,
                letterSpacing: 0,
              ),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              sub!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.caption.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
