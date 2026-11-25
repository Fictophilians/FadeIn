import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/models/BookingStatus.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/BookingCard.dart';
import 'package:fadein_app/widgets/ConfirmDialog.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:flutter/material.dart';

/// Tab Pesanan — `docs/DESIGN.md` 7 nomor 5.
///
/// Daftar booking milik customer dengan filter status. Batal hanya muncul
/// untuk `pending`/`confirmed`, lewat [ConfirmDialog], lalu daftar disegarkan
/// dari server supaya status yang tampil selalu yang tersimpan.
class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => MyBookingPageState();
}

class MyBookingPageState extends State<MyBookingPage> {
  /// Filter yang sedang aktif; `null` = Semua.
  BookingStatus? filter;

  List<Booking> bookings = [];
  bool isLoading = true;
  String? error;

  /// Dipanggil tab lain lewat `GlobalKey` setelah booking baru dibuat.
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

  @override
  void initState() {
    super.initState();
    muatData();
  }

  /// Booking yang lolos filter aktif.
  List<Booking> get tampil {
    if (filter == null) return bookings;
    return bookings.where((b) => b.status == filter).toList();
  }

  Future<void> batalkan(Booking booking) async {
    final yakin = await ConfirmDialog.tampilkan(
      context,
      title: 'Batalkan booking?',
      message: 'Jadwal ${booking.serviceName} pada '
          '${booking.bookingDate} ${booking.bookingTime} akan dibatalkan.',
      confirmLabel: 'Ya, batalkan',
    );

    if (!yakin || !mounted) return;

    try {
      await Apiservice.patch('/bookings/${booking.id}/cancel', {});

      if (!mounted) return;

      Pesan.sukses(context, 'Booking berhasil dibatalkan!');
      await muatData();
    } on ApiException catch (e) {
      if (!mounted) return;
      Pesan.gagal(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Pesan.gagal(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('PESANAN')),
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
          title: 'Gagal memuat pesanan',
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
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Belum ada pesanan',
            message: 'Booking yang kamu buat akan muncul di sini.',
            actionLabel: 'Booking sekarang',
            onAction: () => Navigator.pushNamed(context, '/booking'),
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
        return BookingCard(
          booking: booking,
          onCancel: booking.status.canCancel
              ? () => batalkan(booking)
              : null,
        );
      },
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
