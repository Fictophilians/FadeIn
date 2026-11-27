import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip jam — `docs/DESIGN.md` 5.6.
///
/// Tersedia: `surface`/`ink`/border. Terpilih: `ink`/putih. Terisi: `slotDisabledBg`,
/// teks `muted`, dicoret, tidak bisa ditekan.
class SlotChip extends StatelessWidget {
  const SlotChip({
    super.key,
    required this.time,
    required this.available,
    this.selected = false,
    this.onTap,
  });

  /// Format `HH:mm`.
  final String time;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final aktif = available && !selected;

    final Color bg;
    final Color fg;
    final Color? border;

    if (!available) {
      bg = AppColors.slotDisabledBg;
      fg = AppColors.muted;
      border = null;
    } else if (selected) {
      bg = AppColors.ink;
      fg = AppColors.onDark;
      border = AppColors.ink;
    } else {
      bg = AppColors.surface;
      fg = AppColors.ink;
      border = AppColors.border;
    }

    return Semantics(
      button: aktif,
      selected: selected,
      enabled: available,
      label: available ? 'Jam $time' : 'Jam $time sudah terisi',
      child: SizedBox(
        height: 40,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: available ? onTap : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              constraints: const BoxConstraints(minWidth: 64),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: border == null ? null : Border.all(color: border),
              ),
              child: Text(
                time,
                style: AppTextTheme.label.copyWith(
                  color: fg,
                  decoration: available ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}