import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Barber.dart';
import 'package:fadein_app/models/Service.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/BarberCard.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/ServiceCard.dart';
import 'package:flutter/material.dart';

/// Beranda customer — `docs/DESIGN.md` 7 nomor 4.
///
/// Mengambil layanan dan barber sekaligus, lalu menampilkan empat state:
/// loading, error + coba lagi, kosong, dan sukses.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Service> services = [];
  List<Barber> barbers = [];

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
      // dua request sekaligus supaya beranda cepat terbuka
      final hasil = await Future.wait([
        Apiservice.get('/services'),
        Apiservice.get('/barbers'),
      ]);

      if (!mounted) return;

      setState(() {
        services = (hasil[0] as List)
            .map((e) => Service.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        barbers = (hasil[1] as List)
            .map((e) => Barber.fromJson(Map<String, dynamic>.from(e as Map)))
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Gagal memuat data',
          message: error,
          actionLabel: 'Coba lagi',
          onAction: muatData,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: muatData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.lg,
          AppSpacing.screenH,
          AppSpacing.xxl,
        ),
        children: [
          Text('LAYANAN', style: AppTextTheme.section),
          const SizedBox(height: AppSpacing.sm),
          if (services.isEmpty)
            const EmptyState(
              title: 'Belum ada layanan',
              message: 'Admin belum menambahkan layanan.',
            )
          else
            for (final service in services)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                child: ServiceCard(
                  name: service.name,
                  price: formatRupiah(service.price),
                  duration: service.duration,
                ),
              ),

          const SizedBox(height: AppSpacing.lg),
          Text('BARBER', style: AppTextTheme.section),
          const SizedBox(height: AppSpacing.sm),
          if (barbers.isEmpty)
            const EmptyState(
              title: 'Belum ada barber',
              message: 'Admin belum menambahkan barber.',
            )
          else
            for (final barber in barbers)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                child: BarberCard(
                  name: barber.name,
                  description: barber.description,
                  photoUrl: barber.photo,
                ),
              ),

          const SizedBox(height: AppSpacing.lg),
          FadeInButton(
            label: 'Booking Sekarang',
            onPressed: () {
              if (services.isEmpty || barbers.isEmpty) {
                Pesan.gagal(context, 'Data layanan atau barber masih kosong!');
                return;
              }
              Navigator.pushNamed(context, '/booking');
            },
          ),
        ],
      ),
    );
  }
}