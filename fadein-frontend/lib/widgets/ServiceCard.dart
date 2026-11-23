import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Baris layanan pada Home Customer — `docs/DESIGN.md` 5.3.
///
/// ```
/// Haircut + Wash                    Rp50.000
/// 45 menit                                  ›
/// ```
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.name,
    required this.price,
    required this.duration,
    this.selected = false,
    this.onTap,
  });

  final String name;

  /// Harga sudah diformat (`Rp50.000`) oleh pemanggil.
  final String price;

  /// Durasi dalam menit.
  final int duration;

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        splashColor: AppColors.gold.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextTheme.label.copyWith(fontSize: 16)),
                    const SizedBox(height: AppSpacing.labelGap),
                    Text('$duration menit', style: AppTextTheme.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(price, style: AppTextTheme.price),
              const SizedBox(width: AppSpacing.xxs),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}