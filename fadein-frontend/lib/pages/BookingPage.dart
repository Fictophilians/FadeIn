import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Barber.dart';
import 'package:fadein_app/models/Service.dart';
import 'package:fadein_app/models/Slot.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/BarberCard.dart';
import 'package:fadein_app/widgets/BarisInfo.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/SectionTitle.dart';
import 'package:fadein_app/widgets/ServiceCard.dart';
import 'package:fadein_app/widgets/SlotChip.dart';
import 'package:flutter/material.dart';

/// Form booking lima langkah — `docs/DESIGN.md` 7 nomor 7.
///
/// ```
/// Layanan → Barber → Tanggal → Jam → Ringkasan
/// ```
///
/// Semua pilihan disimpan di [State] layar ini, jadi mundur ke langkah
/// sebelumnya tidak menghapus apa pun. Slot baru diambil saat langkah jam
/// dibuka, dan diambil ulang setiap `409` (slot sudah dipesan orang lain).
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  /// Jumlah langkah. Indeks terakhir = ringkasan.
  static const jumlahLangkah = 5;

  /// Batas hari ke depan yang boleh dipilih.
  static const batasHari = 30;

  /// Aturan slot, dipisah dari state supaya bisa diuji tanpa menunggu jam asli.
  ///
  /// Slot masa depan selalu boleh; slot hari ini hanya boleh bila jamnya
  /// masih di depan. Tanggal `null` (belum dipilih) berarti belum boleh.
  @visibleForTesting
  static bool slotBolehDipakai({
    required bool tersedia,
    required String? tanggal,
    required String hariIni,
    required String jam,
    required String jamSekarang,
  }) {
    if (!tersedia || tanggal == null) return false;
    if (tanggal != hariIni) return true;

    return jam.compareTo(jamSekarang) > 0;
  }

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int langkah = 0;

  List<Service> services = [];
  List<Barber> barbers = [];
  List<Slot> slots = [];

  Service? pilihanLayanan;
  Barber? pilihanBarber;
  DateTime? pilihanTanggal;
  String? pilihanJam;

  bool isLoading = true;
  bool isLoadingSlot = false;
  bool isMenyimpan = false;
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

  // ---------- tanggal ----------

  /// Daftar tanggal yang bisa dipilih: hari ini sampai [batasHari] ke depan.
  List<DateTime> get daftarTanggal {
    final hariIni = _tanggalHariIni();
    return List.generate(
      BookingPage.batasHari + 1,
      (i) => hariIni.add(Duration(days: i)),
    );
  }

  /// Tanggal hari ini menurut WIB, tanpa komponen jam.
  static DateTime _tanggalHariIni() {
    final hariIni = tanggalHariIniWib().split('-');
    return DateTime(
      int.parse(hariIni[0]),
      int.parse(hariIni[1]),
      int.parse(hariIni[2]),
    );
  }

  static String _keStringTanggal(DateTime t) {
    final b = t.toIso8601String().substring(0, 10).split('-');
    return '${b[0]}-${b[1]}-${b[2]}';
  }

  static String _namaHariSingkat(BahasaData t, DateTime tanggal) {
    return t.hariSingkat[tanggal.weekday - 1];
  }

  // ---------- slot ----------

  Future<void> muatSlot() async {
    if (pilihanBarber == null || pilihanTanggal == null) return;

    setState(() {
      isLoadingSlot = true;
      pilihanJam = null;
    });

    try {
      final data = await Apiservice.get(
        '/bookings/slots?barber_id=${pilihanBarber!.id}'
        '&date=${_keStringTanggal(pilihanTanggal!)}',
      );

      if (!mounted) return;

      final daftar = (data['slots'] as List)
          .map((e) => Slot.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      setState(() {
        slots = daftar;
        isLoadingSlot = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      // daftar lama dibuang: kalau tidak, jam dari tanggal sebelumnya tetap
      // bisa dipilih walaupun pengambilan slot untuk tanggal ini gagal
      setState(() {
        slots = [];
        isLoadingSlot = false;
      });
      Pesan.gagal(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        slots = [];
        isLoadingSlot = false;
      });
      Pesan.gagal(context, '$e');
    }
  }

  /// Slot hari ini yang jamnya sudah lewat tidak boleh dipilih.
  bool _slotBolehDipakai(Slot slot) {
    return BookingPage.slotBolehDipakai(
      tersedia: slot.available,
      tanggal: pilihanTanggal == null
          ? null
          : _keStringTanggal(pilihanTanggal!),
      hariIni: tanggalHariIniWib(),
      jam: slot.time,
      jamSekarang: jamSekarangWib(),
    );
  }

  // ---------- navigasi langkah ----------

  bool get _bolehLanjut {
    switch (langkah) {
      case 0:
        return pilihanLayanan != null;
      case 1:
        return pilihanBarber != null;
      case 2:
        return pilihanTanggal != null;
      case 3:
        return pilihanJam != null;
      default:
        return true;
    }
  }

  void lanjut() {
    if (!_bolehLanjut) return;

    // langkah jam baru dibuka: ambil slot terbaru
    if (langkah == 2) muatSlot();

    setState(() => langkah++);
  }

  void kembali() {
    if (langkah == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => langkah--);
  }

  // ---------- simpan ----------

  Future<void> simpan() async {
    if (isMenyimpan) return;

    setState(() => isMenyimpan = true);

    try {
      await Apiservice.post('/bookings', {
        'barber_id': pilihanBarber!.id,
        'service_id': pilihanLayanan!.id,
        'booking_date': _keStringTanggal(pilihanTanggal!),
        'booking_time': pilihanJam,
      });

      if (!mounted) return;

      final t = context.bahasa;
      final tanggalTeks = formatTanggal(_keStringTanggal(pilihanTanggal!));

      // dialog singkat dulu supaya pengguna sadar booking tersimpan,
      // baru kembali ke tab Pesanan lewat MenuPage
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t.bookingBerhasil),
          content: Text(
            t.bookingBerhasilIsi(
              pilihanLayanan!.name,
              pilihanBarber!.name,
              tanggalTeks,
              formatJam(pilihanJam!),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.lihatPesanan),
            ),
          ],
        ),
      );

      if (!mounted) return;
      // `true` = booking tersimpan; MenuPage yang memindahkan tab
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => isMenyimpan = false);

      // 409 = slot direbut orang lain; kembali ke langkah jam dan segarkan
      if (e.isConflict) {
        Pesan.gagal(context, context.bahasa.jadwalSudahDipesan);
        setState(() => langkah = 3);
        await muatSlot();
      } else {
        Pesan.gagal(context, e.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isMenyimpan = false);
      Pesan.gagal(context, '$e');
    }
  }

  // ---------- tampilan ----------

  @override
  Widget build(BuildContext context) {
    final t = context.bahasa;

    return PopScope(
      // Back sistem mengikuti tombol back di AppBar: mundur satu langkah,
      // dan baru menutup form saat berada di langkah pertama.
      canPop: langkah == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) kembali();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text(t.judulBooking),
          leading: IconButton(
            onPressed: kembali,
            icon: const Icon(Icons.arrow_back),
            tooltip: t.kembali,
          ),
        ),
        body: Column(
          children: [
            _IndikatorLangkah(langkah: langkah),
            Expanded(child: _isi(t)),
            _barisBawah(t),
          ],
        ),
      ),
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
          title: t.gagalMuatData,
          message: error,
          actionLabel: t.coba,
          onAction: muatData,
        ),
      );
    }

    switch (langkah) {
      case 0:
        return _langkahLayanan(t);
      case 1:
        return _langkahBarber(t);
      case 2:
        return _langkahTanggal(t);
      case 3:
        return _langkahJam(t);
      default:
        return _langkahRingkasan(t);
    }
  }

  Widget _langkahLayanan(BahasaData t) {
    if (services.isEmpty) {
      return Center(
        child: EmptyState(
          title: t.belumAdaLayanan,
          message: t.adminBelumLayanan,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xl,
      ),
      itemCount: services.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final service = services[i];
        return ServiceCard(
          name: service.name,
          price: formatRupiah(service.price),
          duration: service.duration,
          selected: pilihanLayanan?.id == service.id,
          onTap: () => setState(() => pilihanLayanan = service),
        );
      },
    );
  }

  Widget _langkahBarber(BahasaData t) {
    if (barbers.isEmpty) {
      return Center(
        child: EmptyState(
          title: t.belumAdaBarber,
          message: t.adminBelumBarber,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xl,
      ),
      itemCount: barbers.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final barber = barbers[i];
        return BarberCard(
          name: barber.name,
          description: barber.description,
          photoUrl: barber.photo,
          selected: pilihanBarber?.id == barber.id,
          onSelect: () => setState(() => pilihanBarber = barber),
        );
      },
    );
  }

  Widget _langkahTanggal(BahasaData t) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.md),
        SectionTitle(title: t.pilihTanggal),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
            ),
            itemCount: BookingPage.batasHari + 1,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (_, i) {
              final tanggal = daftarTanggal[i];
              return _KartuTanggal(
                tanggal: tanggal,
                label: i == 0 ? t.hariIni : _namaHariSingkat(t, tanggal),
                selected: pilihanTanggal == tanggal,
                onTap: () => setState(() {
                  pilihanTanggal = tanggal;
                  pilihanJam = null;
                }),
              );
            },
          ),
        ),
        if (pilihanTanggal != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
            ),
            child: Text(
              '${formatHari(_keStringTanggal(pilihanTanggal!))}, '
              '${formatTanggal(_keStringTanggal(pilihanTanggal!))}',
              style: AppTextTheme.body,
            ),
          ),
        ],
      ],
    );
  }

  Widget _langkahJam(BahasaData t) {
    if (isLoadingSlot) {
      return const Center(child: CircularProgressIndicator());
    }

    if (slots.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.schedule_outlined,
          title: t.jamBelumTersedia,
          message: t.cobaTanggalLain,
          actionLabel: t.muatUlang,
          onAction: muatSlot,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.md),
        SectionTitle(title: t.pilihJam),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Text(
            t.jamTerisiInfo,
            style: AppTextTheme.caption,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final slot in slots)
                SlotChip(
                  time: slot.time,
                  available: _slotBolehDipakai(slot),
                  selected: pilihanJam == slot.time,
                  onTap: () => setState(() => pilihanJam = slot.time),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _langkahRingkasan(BahasaData t) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xl,
      ),
      children: [
        SectionTitle(title: t.ringkasan),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _barisRingkasan(t.layanan, pilihanLayanan?.name ?? '-'),
              const Divider(height: AppSpacing.xl),
              _barisRingkasan(t.barber, pilihanBarber?.name ?? '-'),
              const Divider(height: AppSpacing.xl),
              _barisRingkasan(
                t.tanggal,
                pilihanTanggal == null
                    ? '-'
                    : '${formatHari(_keStringTanggal(pilihanTanggal!))}, '
                        '${formatTanggal(_keStringTanggal(pilihanTanggal!))}',
              ),
              const Divider(height: AppSpacing.xl),
              _barisRingkasan(t.jam, formatJam(pilihanJam ?? '-')),
              const Divider(height: AppSpacing.xl),
              _barisRingkasan(
                t.durasi,
                '${pilihanLayanan?.duration ?? 0} ${t.menit}',
              ),
              const Divider(height: AppSpacing.xl),
              _barisRingkasan(
                t.total,
                formatRupiah(pilihanLayanan?.price ?? 0),
                tebal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _barisRingkasan(String label, String nilai, {bool tebal = false}) {
    return BarisInfo(
      label: label,
      nilai: nilai,
      lebarLabel: 84,
      style: tebal
          ? AppTextTheme.price
          : AppTextTheme.body.copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget _barisBawah(BahasaData t) {
    final terakhir = langkah == BookingPage.jumlahLangkah - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: FadeInButton(
          label: terakhir ? t.konfirmasiBooking : t.lanjut,
          icon: terakhir ? Icons.check : null,
          isLoading: isMenyimpan,
          onPressed: (terakhir ? true : _bolehLanjut) && !isMenyimpan
              ? (terakhir ? simpan : lanjut)
              : null,
        ),
      ),
    );
  }
}

/// Garis progres lima langkah di bawah AppBar.
class _IndikatorLangkah extends StatelessWidget {
  const _IndikatorLangkah({required this.langkah});

  final int langkah;

  @override
  Widget build(BuildContext context) {
    final t = context.bahasa;
    final label = [t.layanan, t.barber, t.tanggal, t.jam, t.ringkasan];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.langkah(langkah + 1, BookingPage.jumlahLangkah),
                style: AppTextTheme.caption.copyWith(
                  fontSize: 10,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label[langkah],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.label.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (var i = 0; i < BookingPage.jumlahLangkah; i++)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(
                      right: i == BookingPage.jumlahLangkah - 1 ? 0 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: i <= langkah ? AppColors.gold : AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Satu tanggal pada strip horizontal.
class _KartuTanggal extends StatelessWidget {
  const _KartuTanggal({
    required this.tanggal,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final DateTime tanggal;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: context.bahasa.tanggalSemantics(label, tanggal.day),
      child: Material(
        color: selected ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: selected ? AppColors.ink : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.caption.copyWith(
                    fontSize: 10,
                    color: selected
                        ? AppColors.onDark.withValues(alpha: 0.75)
                        : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tanggal.day}',
                  style: AppTextTheme.display.copyWith(
                    fontSize: 20,
                    color: selected ? AppColors.onDark : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
