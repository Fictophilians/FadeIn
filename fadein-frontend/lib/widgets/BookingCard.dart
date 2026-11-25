import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/widgets/BarisInfo.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/StatusBadge.dart';
import 'package:flutter/material.dart';

/// Kartu booking — `docs/DESIGN.md` 5.7.
///
/// Booking `pending`/`confirmed` menampilkan tombol Ghost "Batalkan";
/// `completed` dan `cancelled` tidak menampilkan aksi.
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
  });

  final Booking booking;

  /// `null` → tombol batal tidak ditampilkan.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final bisaBatal = onCancel != null && booking.status.canCancel;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatHari(booking.bookingDate)}, '
                  '${formatTanggal(booking.bookingDate)}',
                  style: AppTextTheme.label.copyWith(fontSize: 16),
                ),
              ),
              StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(formatJam(booking.bookingTime), style: AppTextTheme.body),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          BarisInfo(label: 'Barber', nilai: booking.barberName),
          const SizedBox(height: AppSpacing.xxs),
          BarisInfo(label: 'Layanan', nilai: booking.serviceName),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatRupiah(booking.price),
                  style: AppTextTheme.price,
                ),
              ),
              if (bisaBatal)
                FadeInButton(
                  label: 'Batalkan',
                  variant: FadeInButtonVariant.ghost,
                  expanded: false,
                  onPressed: onCancel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}