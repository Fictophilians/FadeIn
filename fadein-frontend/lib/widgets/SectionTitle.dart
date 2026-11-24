import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Judul bagian beranda: teks Oswald uppercase dengan garis gold di kiri.
///
/// Satu tempat saja supaya semua section punya bentuk yang sama.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action});

  final String title;

  /// Aksi kecil di kanan, mis. "Lihat semua".
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(title, style: AppTextTheme.section)),
          ?action,
        ],
      ),
    );
  }
}
