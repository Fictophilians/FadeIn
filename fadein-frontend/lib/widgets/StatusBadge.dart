import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/BookingStatus.dart';
import 'package:flutter/material.dart';

/// Chip status booking — `docs/DESIGN.md` 5.5.
///
/// Radius 999, padding 10 x 6, teks 12 weight 600, titik 6 di kiri.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final BookingStatus status;

  Color get _fg {
    switch (status) {
      case BookingStatus.pending:
        return AppStatusColors.pendingFg;
      case BookingStatus.confirmed:
        return AppStatusColors.confirmedFg;
      case BookingStatus.completed:
        return AppStatusColors.completedFg;
      case BookingStatus.cancelled:
        return AppStatusColors.cancelledFg;
    }
  }

  Color get _bg {
    switch (status) {
      case BookingStatus.pending:
        return AppStatusColors.pendingBg;
      case BookingStatus.confirmed:
        return AppStatusColors.confirmedBg;
      case BookingStatus.completed:
        return AppStatusColors.completedBg;
      case BookingStatus.cancelled:
        return AppStatusColors.cancelledBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: AppTextTheme.caption.copyWith(
              color: _fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}