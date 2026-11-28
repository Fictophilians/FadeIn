import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:flutter/material.dart';

/// Pil bahasa `ID | EN` — dua sisi, sisi aktif berlatar gold.
///
/// Cukup satu widget untuk dua tempat: header beranda customer (latar `ink`,
/// pakai [gelap] `true`) dan AppBar admin (latar terang, bawaan).
class TombolBahasa extends StatelessWidget {
  const TombolBahasa({super.key, this.gelap = false});

  /// `true` bila dipasang di atas latar gelap.
  final bool gelap;

  @override
  Widget build(BuildContext context) {
    final aktif = context.bahasa.bahasa;
    final warnaPasif = gelap ? AppColors.onDark : AppColors.muted;

    return Semantics(
      button: true,
      label: aktif == Bahasa.id ? 'Switch to English' : 'Ganti ke Indonesia',
      child: Material(
        color: gelap
            ? AppColors.onDark.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final b in Bahasa.values)
              InkWell(
                onTap: () => gantiBahasa(b),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  color: b == aktif ? AppColors.gold : Colors.transparent,
                  child: Text(
                    b.kode,
                    style: AppTextTheme.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: b == aktif ? AppColors.ink : warnaPasif,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
