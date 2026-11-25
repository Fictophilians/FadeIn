import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/models/BookingStatus.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/ConfirmDialog.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/StatusBadge.dart';
import 'package:flutter/material.dart';

/// Tab Booking untuk admin — `docs/DESIGN.md` 7 nomor 10.
///
/// Menampilkan seluruh booking. Aksi mengikuti status:
///
/// ```
/// pending   → Konfirmasi · Batalkan
/// confirmed → Selesai    · Batalkan
/// completed / cancelled → tidak ada aksi
/// ```
class AdminBookingPage extends StatefulWidget {
  const AdminBookingPage({super.key});

  @override
  State<AdminBookingPage> createState() => AdminBookingPageState();
}

class AdminBookingPageState extends State<AdminBookingPage> {
  List<Booking> bookings = [];
  BookingStatus? filter;
  bool isLoading = true;
  String? error;

  /// Id booking yang sedang diproses, supaya tombolnya tidak bisa ditekan dua kali.
  int? idDiproses;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await Apiservice.get('/bookings');

      if (!mounted) return;

      setState(() {
        bookings = (data as List)
            .map((e) => Booking.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '$e';
        isLoading = false;
      });
    }
  }

  List<Booking> get tampil {
    if (filter == null) return bookings;
    return bookings.where((b) => b.status == filter).toList();
  }

  Future<void> ubahStatus(Booking booking, BookingStatus tujuan) async {
    if (idDiproses != null) return;

    setState(() => idDiproses = booking.id);

    try {
      await Apiservice.patch('/bookings/${booking.id}/status', {
        'status': tujuan.value,
      });

      if (!mounted) return;

      Pesan.sukses(context, 'Status diubah menjadi ${tujuan.label}.');
      setState(() => idDiproses = null);
      await muatData();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => idDiproses = null);
      Pesan.gagal(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => idDiproses = null);
      Pesan.gagal(context, '$e');
    }
  }

  Future<void> batalkan(Booking booking) async {
    if (idDiproses != null) return;

    final yakin = await ConfirmDialog.tampilkan(
      context,
      title: 'Batalkan booking?',
      message: 'Booking ${booking.customerName} pada '
          '${formatTanggal(booking.bookingDate)} ${formatJam(booking.bookingTime)} '
          'akan dibatalkan.',
      confirmLabel: 'Ya, batalkan',
    );

    if (!yakin || !mounted) return;

    setState(() => idDiproses = booking.id);

    try {
      await Apiservice.patch('/bookings/${booking.id}/cancel', {});

      if (!mounted) return;

      Pesan.sukses(context, 'Booking berhasil dibatalkan!');
      setState(() => idDiproses = null);
      await muatData();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => idDiproses = null);
      Pesan.gagal(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => idDiproses = null);
      Pesan.gagal(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('BOOKING')),
      body: _isi(),
    );
  }

  Widget _isi() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Gagal memuat booking',
          message: error,
          actionLabel: 'Coba lagi',
          onAction: muatData,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: muatData,
      child: Column(
        children: [
          _BarisFilter(
            aktif: filter,
            onPilih: (f) => setState(() => filter = f),
          ),
          Expanded(child: _daftar()),
        ],
      ),
    );
  }

  Widget _daftar() {
    if (bookings.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          const EmptyState(
            icon: Icons.event_busy_outlined,
            title: 'Belum ada booking',
            message: 'Booking dari customer akan muncul di sini.',
          ),
        ],
      );
    }

    final daftar = tampil;

    if (daftar.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          EmptyState(
            icon: Icons.filter_alt_off_outlined,
            title: 'Tidak ada di filter ini',
            message: 'Coba pilih status lain.',
            actionLabel: 'Tampilkan semua',
            onAction: () => setState(() => filter = null),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xs,
        AppSpacing.screenH,
        AppSpacing.xl,
      ),
      itemCount: daftar.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (_, i) {
        final booking = daftar[i];
        return _KartuBookingAdmin(
          booking: booking,
          diproses: idDiproses == booking.id,
          onStatus: (s) => ubahStatus(booking, s),
          onBatal: () => batalkan(booking),
        );
      },
    );
  }
}

/// Kartu booking versi admin: menampilkan nama customer dan tombol status.
class _KartuBookingAdmin extends StatelessWidget {
  const _KartuBookingAdmin({
    required this.booking,
    required this.diproses,
    required this.onStatus,
    required this.onBatal,
  });

  final Booking booking;
  final bool diproses;
  final ValueChanged<BookingStatus> onStatus;
  final VoidCallback onBatal;

  @override
  Widget build(BuildContext context) {
    final status = booking.status;

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
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(formatJam(booking.bookingTime), style: AppTextTheme.body),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _baris('Customer', booking.customerName),
          const SizedBox(height: AppSpacing.xxs),
          _baris('Barber', booking.barberName),
          const SizedBox(height: AppSpacing.xxs),
          _baris('Layanan', booking.serviceName),
          const SizedBox(height: AppSpacing.sm),
          Text(formatRupiah(booking.price), style: AppTextTheme.price),
          if (status.isActive) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (status == BookingStatus.pending)
                  Expanded(
                    child: _TombolKecil(
                      label: 'Konfirmasi',
                      icon: Icons.check_circle_outline,
                      disabled: diproses,
                      onTap: () => onStatus(BookingStatus.confirmed),
                    ),
                  ),
                if (status == BookingStatus.confirmed)
                  Expanded(
                    child: _TombolKecil(
                      label: 'Selesai',
                      icon: Icons.task_alt,
                      disabled: diproses,
                      onTap: () => onStatus(BookingStatus.completed),
                    ),
                  ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _TombolKecil(
                    label: 'Batalkan',
                    icon: Icons.close,
                    danger: true,
                    disabled: diproses,
                    onTap: onBatal,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _baris(String label, String nilai) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(label, style: AppTextTheme.caption),
        ),
        Expanded(
          child: Text(nilai, style: AppTextTheme.body),
        ),
      ],
    );
  }
}

/// Tombol aksi kecil berbingkai di dalam kartu.
class _TombolKecil extends StatelessWidget {
  const _TombolKecil({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
    this.disabled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final warna = danger ? AppColors.danger : AppColors.ink;

    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: disabled ? null : onTap,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: warna.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: warna),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTheme.caption.copyWith(
                        color: warna,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Deretan chip filter status.
class _BarisFilter extends StatelessWidget {
  const _BarisFilter({required this.aktif, required this.onPilih});

  final BookingStatus? aktif;
  final ValueChanged<BookingStatus?> onPilih;

  static const _label = {
    null: 'Semua',
    BookingStatus.pending: 'Pending',
    BookingStatus.confirmed: 'Confirmed',
    BookingStatus.completed: 'Completed',
    BookingStatus.cancelled: 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm,
        ),
        children: [
          for (final entry in _label.entries)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _Chip(
                label: entry.value,
                selected: aktif == entry.key,
                onTap: () => onPilih(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
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
    );
  }
}
