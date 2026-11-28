import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/utils/statistik.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/SectionTitle.dart';
import 'package:fadein_app/widgets/StatCard.dart';
import 'package:flutter/material.dart';

/// Tab Beranda untuk admin — ringkasan angka dari data yang sudah ada.
///
/// Tidak ada endpoint baru: seluruh angka dihitung dari `GET /bookings`
/// (yang sudah membawa `price`, `status`, `booking_date`, `service_name`)
/// dan `GET /barbers` untuk menghitung kapasitas slot.
///
/// Rumusnya ada di `lib/utils/statistik.dart` supaya bisa diuji terpisah.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => AdminHomePageState();
}

class AdminHomePageState extends State<AdminHomePage> {
  Statistik? statistik;
  bool isLoading = true;
  bool _pernahMuat = false;
  String? error;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    // Spinner penuh hanya pada muat pertama atau setelah gagal; refresh
    // mempertahankan angka lama supaya layar tidak berkedip kosong.
    final tampilkanSpinner = !_pernahMuat || error != null;

    setState(() {
      if (tampilkanSpinner) isLoading = true;
      error = null;
    });

    try {
      // Dua request berjalan bersamaan: total waktu tunggu mengikuti yang
      // paling lambat, bukan jumlah keduanya.
      final hasil = await Future.wait([
        Apiservice.get('/bookings'),
        Apiservice.get('/barbers'),
      ]);

      if (!mounted) return;

      final daftarBooking = (hasil[0] as List)
          .map((e) => Booking.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final daftarBarber = hasil[1] as List;

      setState(() {
        statistik = Statistik.hitung(
          daftarBooking,
          jumlahBarber: daftarBarber.length,
          hariIni: tanggalHariIniWib(),
        );
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('DASHBOARD')),
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
          title: 'Gagal memuat ringkasan',
          message: error,
          actionLabel: 'Coba lagi',
          onAction: muatData,
        ),
      );
    }

    final s = statistik;
    if (s == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final bulan = formatBulanTahun(tanggalHariIniWib().substring(0, 7));

    return RefreshIndicator(
      onRefresh: muatData,
      child: ListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.xxl,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: Text(
              'Ringkasan $bulan',
              style: AppTextTheme.caption,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ——— Empat angka utama, dua per baris ———
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Pendapatan bulan ini',
                      value: formatRupiah(s.pendapatanBulanIni),
                      sub: '${s.hariAktif} hari ada transaksi',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.cardGap),
                  Expanded(
                    child: StatCard(
                      label: 'Rata-rata per hari',
                      value: formatRupiah(s.rataRataPerHari),
                      sub: 'pendapatan ÷ hari aktif',
                      icon: Icons.show_chart,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Booking bulan ini',
                      value: '${s.bookingBulanIni}',
                      sub: 'semua status',
                      icon: Icons.event_note_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.cardGap),
                  Expanded(
                    child: StatCard(
                      label: 'Okupansi hari ini',
                      value: '${s.okupansiPersen.toStringAsFixed(0)}%',
                      sub: '${s.slotTerisiHariIni} dari '
                          '${s.totalSlotHariIni} slot',
                      icon: Icons.pie_chart_outline,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ——— Modus layanan ———
          const SectionTitle(title: 'LAYANAN TERPOPULER'),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: _KartuLayananTerpopuler(statistik: s),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ——— Persentase perubahan ———
          const SectionTitle(title: 'TREN PENDAPATAN'),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: _KartuPertumbuhan(statistik: s),
          ),
        ],
      ),
    );
  }
}

/// Layanan paling sering dipesan beserta porsinya dari seluruh booking
/// bulan ini. Bar progres memakai nilai yang sama dengan angkanya.
class _KartuLayananTerpopuler extends StatelessWidget {
  const _KartuLayananTerpopuler({required this.statistik});

  final Statistik statistik;

  @override
  Widget build(BuildContext context) {
    final nama = statistik.layananTerpopuler;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: nama == null
          ? Text(
              'Belum ada booking aktif bulan ini.',
              style: AppTextTheme.caption,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTheme.label,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${statistik.persenLayananTerpopuler.toStringAsFixed(0)}%',
                      style: AppTextTheme.price.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${statistik.jumlahLayananTerpopuler} dari '
                  '${statistik.bookingDihitung} booking',
                  style: AppTextTheme.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  label: 'Porsi layanan terpopuler',
                  value:
                      '${statistik.persenLayananTerpopuler.toStringAsFixed(0)}%',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: statistik.persenLayananTerpopuler / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Persentase perubahan pendapatan dibanding bulan lalu.
///
/// Kalau bulan lalu belum ada pendapatan, pembandingnya tidak ada sehingga
/// layar menampilkan tanda pisah — bukan angka nol yang menyesatkan.
class _KartuPertumbuhan extends StatelessWidget {
  const _KartuPertumbuhan({required this.statistik});

  final Statistik statistik;

  @override
  Widget build(BuildContext context) {
    final tumbuh = statistik.pertumbuhan;

    final (IconData ikon, Color warna, String nilai, String keterangan) =
        switch (tumbuh) {
      null => (
        Icons.remove,
        AppColors.muted,
        '—',
        'belum ada data bulan lalu',
      ),
      > 0 => (
        Icons.trending_up,
        AppColors.success,
        '+${tumbuh.toStringAsFixed(1)}%',
        'dari ${formatRupiah(statistik.pendapatanBulanLalu)} bulan lalu',
      ),
      < 0 => (
        Icons.trending_down,
        AppColors.danger,
        '${tumbuh.toStringAsFixed(1)}%',
        'dari ${formatRupiah(statistik.pendapatanBulanLalu)} bulan lalu',
      ),
      _ => (
        Icons.trending_flat,
        AppColors.muted,
        '0%',
        'sama dengan bulan lalu',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Icon(ikon, size: 20, color: warna),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nilai,
                  style: AppTextTheme.section.copyWith(
                    fontSize: 20,
                    color: warna,
                  ),
                ),
                Text(
                  keterangan,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
