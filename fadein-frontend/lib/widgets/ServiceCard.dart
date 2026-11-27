import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Kartu layanan — `docs/DESIGN.md` 5.3.
///
/// Dua bentuk:
///
/// ```
/// tile: false (default)          tile: true
/// ┌──────────────────────────┐   ┌──────────────┐
/// │ Haircut + Wash  Rp50.000 │   │ 01     45mnt │
/// │ 45 menit            ›    │   │ Haircut      │
/// └──────────────────────────┘   │ Rp50.000     │
///                                └──────────────┘
/// ```
///
/// Tabel `services` tidak punya kolom foto, jadi tidak ada sampul gambar dan
/// tidak ada gradien pengganti. Nomor urut Oswald + harga besar sudah cukup
/// memberi bobot visual.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.name,
    required this.price,
    required this.duration,
    this.number,
    this.selected = false,
    this.onTap,
    this.tile = false,
  });

  final String name;

  /// Harga sudah diformat (`Rp50.000`) oleh pemanggil.
  final String price;

  /// Durasi dalam menit.
  final int duration;

  /// Nomor urut dua digit (`01`). Hanya dipakai bentuk [tile].
  final String? number;

  final bool selected;
  final VoidCallback? onTap;

  /// `true` = kartu tegak untuk grid beranda.
  final bool tile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
          child: tile ? _isiTile() : _isiBaris(),
        ),
      ),
    );
  }

  Widget _isiBaris() {
    return Row(
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
    );
  }

  Widget _isiTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (number != null)
              Text(
                number!,
                style: AppTextTheme.display.copyWith(
                  fontSize: 18,
                  color: AppColors.gold,
                ),
              ),
            const Spacer(),
            Text('$duration mnt', style: AppTextTheme.caption),
          ],
        ),
        const Spacer(),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextTheme.label.copyWith(fontSize: 15, height: 1.25),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(price, style: AppTextTheme.display.copyWith(fontSize: 20)),
      ],
    );
  }
}
