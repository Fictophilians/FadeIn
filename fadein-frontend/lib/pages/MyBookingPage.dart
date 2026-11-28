import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/models/BookingStatus.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/BookingCard.dart';
import 'package:fadein_app/widgets/ConfirmDialog.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/FilterStatus.dart';
import 'package:flutter/material.dart';

/// Tab Pesanan — `docs/DESIGN.md` 7 nomor 5.
///
/// Daftar booking milik customer dengan filter status. Batal hanya muncul
/// untuk `pending`/`confirmed`, lewat [ConfirmDialog], lalu daftar disegarkan
/// dari server supaya status yang tampil selalu yang tersimpan.
class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key, this.onBuatBooking});

  /// Dipanggil tombol "Booking sekarang" pada daftar kosong. `MenuPage` bisa
  /// mengarahkannya ke tab Beranda, sedangkan pemakaian mandiri cukup push
  /// route `/booking`.
  final Future<bool?> Function()? onBuatBooking;

  @override
  State<MyBookingPage> createState() => MyBookingPageState();
}

class MyBookingPageState extends State<MyBookingPage> {
  /// Filter yang sedang aktif; `null` = Semua.
  BookingStatus? filter;

  List<Booking> bookings = [];
  bool isLoading = true;
  bool _pernahMuat = false;
  String? error;

  /// Dipanggil tab lain lewat `GlobalKey` setelah booking baru dibuat.
  Future<void> muatData() async {
    // Spinner penuh hanya pada muat pertama atau setelah gagal; refresh
    // mempertahankan daftar lama supaya layar tidak berkedip kosong.
    final tampilkanSpinner = !_pernahMuat || error != null;

    setState(() {
      if (tampilkanSpinner) isLoading = true;
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
        _pernahMuat = true;
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

  /// Buka form booking; kalau tersimpan, daftar ini ikut disegarkan.
  Future<void> _buatBooking() async {
    final tersimpan = widget.onBuatBooking != null
        ? await widget.onBuatBooking!()
        : await Navigator.pushNamed(context, '/booking') as bool?;

    if (tersimpan == true && mounted) await muatData();
  }

  Future<void> batalkan(Booking booking) async {
    final t = context.bahasa;
    final yakin = await ConfirmDialog.tampilkan(
      context,
      title: t.batalkanBookingTanya,
      message: t.jadwalAkanDibatalkan(
        booking.serviceName,
        formatTanggal(booking.bookingDate),
        formatJam(booking.bookingTime),
      ),
      confirmLabel: t.yaBatalkan,
      cancelLabel: t.batal,
    );

    if (!yakin || !mounted) return;

    try {
      await Apiservice.patch('/bookings/${booking.id}/cancel', {});

      if (!mounted) return;

      Pesan.sukses(context, t.bookingDibatalkan);
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
    final t = context.bahasa;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(t.judulPesanan)),
      body: _isi(t),
    );
  }

  Widget _isi(BahasaData t) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: t.gagalMuatPesanan,
          message: error,
          actionLabel: t.coba,
          onAction: muatData,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: muatData,
      child: Column(
        children: [
          FilterStatus(
            aktif: filter,
            onPilih: (f) => setState(() => filter = f),
          ),
          Expanded(child: _daftar(t)),
        ],
      ),
    );
  }

  Widget _daftar(BahasaData t) {
    if (bookings.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: t.belumAdaPesanan,
            message: t.pesananAkanMuncul,
            actionLabel: t.bookingSekarang,
            onAction: _buatBooking,
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
            title: t.tidakAdaDiFilter,
            message: t.cobaStatusLain,
            actionLabel: t.tampilkanSemua,
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
