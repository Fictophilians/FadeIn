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
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/HomeHeader.dart';
import 'package:fadein_app/widgets/PromoBanner.dart';
import 'package:fadein_app/widgets/ServiceCard.dart';
import 'package:flutter/material.dart';

/// Beranda customer — `docs/DESIGN.md` 7 nomor 4.
///
/// Susunan: header sapaan → kartu promo → daftar layanan horizontal →
/// daftar barber → tombol booking. Empat state tetap ada: loading, error,
/// kosong, dan sukses.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Service> services = [];
  List<Barber> barbers = [];

  /// Booking aktif terdekat, bila ada. Hanya satu yang ditampilkan.
  Booking? upcoming;

  String namaUser = '';

  bool isLoading = true;
  String? error;

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
      final user = await Apiservice.getUser();
      final hasil = await Future.wait([
        Apiservice.get('/services'),
        Apiservice.get('/barbers'),
        Apiservice.get('/bookings'),
      ]);

      if (!mounted) return;

      final daftarBooking = (hasil[2] as List)
          .map((e) => Booking.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((b) => b.status.canCancel)
          .toList();

      setState(() {
        namaUser = '${user?['name'] ?? ''}'.split(' ').first;
        services = (hasil[0] as List)
            .map((e) => Service.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        barbers = (hasil[1] as List)
            .map((e) => Barber.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        upcoming = daftarBooking.isEmpty ? null : daftarBooking.first;
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

  void keBooking() {
    if (services.isEmpty || barbers.isEmpty) {
      Pesan.gagal(context, 'Data layanan atau barber masih kosong!');
      return;
    }
    Navigator.pushNamed(context, '/booking');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenH),
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
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.md,
              AppSpacing.screenH,
              AppSpacing.lg,
            ),
            child: HomeHeader(
              name: namaUser.isEmpty ? 'Kak' : namaUser,
              onBellTap: () => Pesan.sukses(context, 'Belum ada notifikasi.'),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: PromoBanner(
              title: 'Potongan rapi, tanpa antre',
              subtitle: 'Pilih jadwal sendiri dalam hitungan detik.',
              actionLabel: 'Booking',
              onAction: keBooking,
            ),
          ),

          // booking aktif terdekat
          if (upcoming != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
              ),
              child: _KartuUpcoming(
                booking: upcoming!,
                onTap: () => Navigator.pushNamed(context, '/my-bookings'),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          _JudulSection(judul: 'LAYANAN'),
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
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH,
                ),
                itemCount: services.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.cardGap),
                itemBuilder: (_, i) {
                  final service = services[i];
                  return ServiceCard(
                    compact: true,
                    name: service.name,
                    price: formatRupiah(service.price),
                    duration: service.duration,
                    onTap: keBooking,
                  );
                },
              ),
            ),

          const SizedBox(height: AppSpacing.xl),
          _JudulSection(judul: 'BARBER'),
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
            for (final barber in barbers)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.cardGap,
                ),
                child: BarberCard(
                  name: barber.name,
                  description: barber.description,
                  photoUrl: barber.photo,
                  onSelect: keBooking,
                ),
              ),

          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: FadeInButton(
              label: 'Booking Sekarang',
              icon: Icons.content_cut_rounded,
              onPressed: keBooking,
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul section dengan garis pendek gold di kiri.
class _JudulSection extends StatelessWidget {
  const _JudulSection({required this.judul});

  final String judul;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(judul, style: AppTextTheme.section),
        ],
      ),
    );
  }
}

/// Baris ringkas booking aktif: jam + layanan + barber.
class _KartuUpcoming extends StatelessWidget {
  const _KartuUpcoming({required this.booking, required this.onTap});

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
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: AppColors.ink,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      style: AppTextTheme.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                booking.bookingTime,
                style: AppTextTheme.label.copyWith(color: AppColors.gold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
