import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Kartu barber — `docs/DESIGN.md` 5.4.
///
/// Foto bundar 64 dengan border `goldSoft` saat terpilih, nama Inter 600 / 16,
/// deskripsi maksimal 2 baris, dan tombol Ghost "Pilih".
class BarberCard extends StatelessWidget {
  const BarberCard({
    super.key,
    required this.name,
    this.description,
    this.photoUrl,
    this.selected = false,
    this.onSelect,
  });

  final String name;
  final String? description;

  /// URL foto dari Cloudinary. `null` → pakai `avatar_default.png`.
  final String? photoUrl;

  final bool selected;
  final VoidCallback? onSelect;

  static const _fallback = 'assets/images/avatar_default.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: selected ? AppColors.gold : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.goldSoft,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                photoUrl ?? _fallback,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  _fallback,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextTheme.label.copyWith(fontSize: 16)),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTheme.caption,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (!selected)
            TextButton(
              onPressed: onSelect,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                textStyle: AppTextTheme.label,
              ),
              child: const Text('Pilih'),
            )
          else
            const Icon(Icons.check_circle, color: AppColors.gold, size: 24),
        ],
      ),
    );
  }
}