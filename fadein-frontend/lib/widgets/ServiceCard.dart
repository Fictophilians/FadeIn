import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Baris layanan pada Home Customer — `docs/DESIGN.md` 5.3.
///
/// Dua bentuk:
///
/// ```
/// compact: false (default)          compact: true
/// ┌──────────────────────────┐      ┌────────────┐
/// │ Haircut + Wash  Rp50.000 │      │  Rp50.000  │  ← sampul gradien
/// │ 45 menit            ›    │      │ Haircut    │
/// └──────────────────────────┘      │ 45 menit   │
///                                   └────────────┘
/// ```
///
/// Tabel `services` tidak punya kolom foto, jadi sampulnya gradien
/// `goldSoft` dengan harga besar — bukan gambar.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.name,
    required this.price,
    required this.duration,
    this.selected = false,
    this.onTap,
    this.compact = false,
  });

  final String name;

  /// Harga sudah diformat (`Rp50.000`) oleh pemanggil.
  final String price;

  /// Durasi dalam menit.
  final int duration;

  final bool selected;
  final VoidCallback? onTap;

  /// `true` = kartu tegak untuk daftar horizontal di beranda.
  final bool compact;

  static const double _lebarCompact = 168;

  @override
  Widget build(BuildContext context) {
    final isi = compact ? _isiTegak() : _isiBaris();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.gold.withValues(alpha: 0.12),
        child: Container(
          width: compact ? _lebarCompact : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: isi,
        ),
      ),
    );
  }

  Widget _isiBaris() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
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
    );
  }

  Widget _isiTegak() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // sampul: harga besar sebagai elemen visual pengganti foto
        Container(
          height: 84,
          alignment: Alignment.center,
          decoration: const BoxDecoration(gradient: AppGradient.cardCover),
          child: Text(
            price,
            style: AppTextTheme.display.copyWith(
              fontSize: 24,
              color: AppColors.ink,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextTheme.label.copyWith(fontSize: 14, height: 1.25),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 13,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text('$duration menit', style: AppTextTheme.caption),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
