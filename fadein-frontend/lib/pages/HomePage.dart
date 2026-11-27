import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Barber.dart';
import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/models/Service.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/BarberCard.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/HomeHeader.dart';
import 'package:fadein_app/widgets/SectionTitle.dart';
import 'package:fadein_app/widgets/ServiceCard.dart';
import 'package:flutter/material.dart';

/// Beranda customer — `docs/DESIGN.md` 7 nomor 4.
///
/// Susunan: blok gelap (sapaan + judul) → kartu jadwal berikutnya yang
/// menumpuk tepi bawah blok → grid layanan → rail barber.
///
/// Hanya memuat `/services` dan `/barbers`. Booking terdekat dimuat terpisah
/// dan kegagalannya tidak menjatuhkan seluruh beranda.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onBuatBooking, this.onBukaPesanan});

  /// Membuka form booking. `MenuPage` mengisinya supaya setelah tersimpan
  /// tab langsung pindah ke Pesanan tanpa menumpuk layar baru.
  final Future<bool?> Function()? onBuatBooking;

  /// Dipanggil saat kartu jadwal ditekan. `MenuPage` mengisinya dengan
  /// perpindahan ke tab Pesanan supaya tidak menumpuk layar baru.
  final VoidCallback? onBukaPesanan;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Service> services = [];
  List<Barber> barbers = [];
  Booking? upcoming;
  String namaUser = '';
  String? fotoUser;

  bool isLoading = true;
  bool _pernahMuat = false;
  String? error;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    // Spinner penuh hanya pada muat pertama atau setelah gagal. Refresh
    // (pull-to-refresh / kembali ke tab) mempertahankan isi layar supaya
    // tidak berkedip kosong.
    final tampilkanSpinner = !_pernahMuat || error != null;

    setState(() {
      if (tampilkanSpinner) isLoading = true;
      error = null;
    });

    try {
      final user = await Apiservice.getUser();
      final hasil = await Future.wait([
        Apiservice.get('/services'),
        Apiservice.get('/barbers'),
      ]);

      if (!mounted) return;

      setState(() {
        namaUser = '${user?['name'] ?? ''}'.split(' ').first;
        fotoUser = user?['photo'] as String?;
        services = (hasil[0] as List)
            .map((e) => Service.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        barbers = (hasil[1] as List)
            .map((e) => Barber.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        isLoading = false;
        _pernahMuat = true;
      });

      _muatBookingTerdekat();
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

  /// Booking aktif terdekat. Gagal di sini tidak boleh menjatuhkan beranda.
  Future<void> _muatBookingTerdekat() async {
    try {
      final data = await Apiservice.get('/bookings');
      final daftar = (data as List)
          .map((e) => Booking.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((b) => b.status.canCancel)
          .toList();

      // backend mengurutkan terbaru dulu, jadi yang paling dekat harus dicari
      // manual. Booking yang tanggalnya sudah lewat tidak ditampilkan.
      final hariIni = tanggalHariIniWib();
      final jamSekarang = jamSekarangWib();
      Booking? terdekat;
      for (final booking in daftar) {
        if (booking.bookingDate.compareTo(hariIni) < 0) continue;
        // jadwal hari ini yang jamnya sudah lewat bukan "jadwal berikutnya"
        if (booking.bookingDate == hariIni &&
            booking.bookingTime.compareTo(jamSekarang) <= 0) {
          continue;
        }
        if (terdekat == null || _lebihDulu(booking, terdekat)) {
          terdekat = booking;
        }
      }

      if (!mounted) return;
      setState(() => upcoming = terdekat);
    } catch (_) {
      // diamkan: kartu jadwal hanya pelengkap
    }
  }

  /// `true` bila [a] jatuh sebelum [b].
  static bool _lebihDulu(Booking a, Booking b) {
    final tanggal = a.bookingDate.compareTo(b.bookingDate);
    if (tanggal != 0) return tanggal < 0;
    return a.bookingTime.compareTo(b.bookingTime) < 0;
  }

  void keBooking() {
    if (services.isEmpty || barbers.isEmpty) {
      Pesan.gagal(context, 'Data layanan atau barber masih kosong!');
      return;
    }

    if (widget.onBuatBooking != null) {
      widget.onBuatBooking!();
    } else {
      Navigator.pushNamed(context, '/booking');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return SafeArea(
        child: Center(
          child: EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Gagal memuat data',
            message: error,
            actionLabel: 'Coba lagi',
            onAction: muatData,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: muatData,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _BlokAtas(
            nama: namaUser.isEmpty ? 'Kak' : namaUser,
            foto: fotoUser,
            upcoming: upcoming,
            onBellTap: () => Pesan.sukses(context, 'Belum ada notifikasi.'),
            onUpcomingTap: () => widget.onBukaPesanan?.call(),
          ),

          const SizedBox(height: AppSpacing.xl),
          const SectionTitle(title: 'LAYANAN'),
          const SizedBox(height: AppSpacing.sm),

          if (services.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              child: EmptyState(
                title: 'Belum ada layanan',
                message: 'Admin belum menambahkan layanan.',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: services.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.cardGap,
                  mainAxisSpacing: AppSpacing.cardGap,
                  mainAxisExtent: 148,
                ),
                itemBuilder: (_, i) {
                  final service = services[i];
                  return ServiceCard(
                    tile: true,
                    number: '${i + 1}'.padLeft(2, '0'),
                    name: service.name,
                    price: formatRupiah(service.price),
                    duration: service.duration,
                    onTap: keBooking,
                  );
                },
              ),
            ),

          const SizedBox(height: AppSpacing.xl),
          const SectionTitle(title: 'BARBER'),
          const SizedBox(height: AppSpacing.sm),

          if (barbers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              child: EmptyState(
                title: 'Belum ada barber',
                message: 'Admin belum menambahkan barber.',
              ),
            )
          else
            SizedBox(
              height: BarberCard.tinggiPotret,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH,
                ),
                itemCount: barbers.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.cardGap),
                itemBuilder: (_, i) {
                  final barber = barbers[i];
                  return BarberCard(
                    portrait: true,
                    name: barber.name,
                    description: barber.description,
                    photoUrl: barber.photo,
                    // hanya pajangan: pemilihan barber terjadi di form booking
                    onSelect: null,
                  );
                },
              ),
            ),

          // ruang untuk FAB "Buat Booking" supaya kartu terakhir tidak tertutup
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

/// Blok gelap dengan kartu jadwal di dalamnya, tepat di bawah garis gold.
class _BlokAtas extends StatelessWidget {
  const _BlokAtas({
    required this.nama,
    required this.foto,
    required this.upcoming,
    required this.onBellTap,
    required this.onUpcomingTap,
  });

  final String nama;
  final String? foto;
  final Booking? upcoming;
  final VoidCallback onBellTap;
  final VoidCallback onUpcomingTap;

  @override
  Widget build(BuildContext context) {
    return HomeHeader(
      name: nama,
      photoUrl: foto,
      onBellTap: onBellTap,
      child: upcoming == null
          ? null
          : _KartuJadwal(booking: upcoming!, onTap: onUpcomingTap),
    );
  }
}

/// Baris jadwal berikutnya: label, layanan, tanggal, jam besar.
class _KartuJadwal extends StatelessWidget {
  const _KartuJadwal({required this.booking, required this.onTap});

  final Booking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // strip gold: penanda "ini jadwal aktif"
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.card),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'JADWAL BERIKUTNYA',
                        style: AppTextTheme.caption.copyWith(
                          fontSize: 10,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTheme.label.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatTanggal(booking.bookingDate)} · '
                        '${booking.barberName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTheme.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Text(
                  formatJam(booking.bookingTime),
                  style: AppTextTheme.display.copyWith(fontSize: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
