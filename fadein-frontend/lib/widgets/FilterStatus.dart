import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/BookingStatus.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:flutter/material.dart';

/// Deretan chip filter status booking.
///
/// `null` = Semua. Dipakai tab Pesanan (customer) dan tab Booking (admin).
/// Label diambil dari [BookingStatus.label] supaya bahasanya sama dengan
/// [StatusBadge] di dalam kartu.
class FilterStatus extends StatelessWidget {
  const FilterStatus({super.key, required this.aktif, required this.onPilih});

  final BookingStatus? aktif;
  final ValueChanged<BookingStatus?> onPilih;

  @override
  Widget build(BuildContext context) {
    final t = context.bahasa;

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm,
        ),
        children: [
          _Chip(
            label: t.semua,
            selected: aktif == null,
            onTap: () => onPilih(null),
          ),
          for (final status in BookingStatus.values)
            _Chip(
              label: t.status(status),
              selected: aktif == status,
              onTap: () => onPilih(status),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: selected ? AppColors.ink : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: AppTextTheme.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.onDark : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}