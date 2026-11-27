import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Tombol teks kecil untuk aksi per baris (Edit / Hapus).
///
/// Tinggi 44 supaya tetap nyaman disentuh; dipakai tab Barber dan Layanan.
class AksiKecil extends StatelessWidget {
  const AksiKecil({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final warna = danger ? AppColors.danger : AppColors.ink;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: warna),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextTheme.caption.copyWith(
                  color: warna,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}