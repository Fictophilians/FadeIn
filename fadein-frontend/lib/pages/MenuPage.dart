import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/AdminBarberPage.dart';
import 'package:fadein_app/pages/AdminBookingPage.dart';
import 'package:fadein_app/pages/AdminHomePage.dart';
import 'package:fadein_app/pages/AdminServicePage.dart';
import 'package:fadein_app/pages/HomePage.dart';
import 'package:fadein_app/pages/MyBookingPage.dart';
import 'package:fadein_app/pages/ProfilePage.dart';
import 'package:fadein_app/models/User.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:flutter/material.dart';

/// Kerangka utama aplikasi — `docs/DESIGN.md` 6.
///
/// Pola sama seperti `MenuPage` pada proyek GameHaven: satu daftar [pages],
/// satu [currentIndex], dan `IndexedStack` supaya tiap tab tidak dibangun
/// ulang (data tidak di-fetch ulang setiap pindah tab).
///
/// Satu kelas untuk dua peran:
///
/// ```
/// customer : Beranda · Pesanan · Profil
/// admin    : Beranda · Barber · Layanan · Booking · Profil
/// ```
class MenuPage extends StatefulWidget {
  const MenuPage({super.key, this.role = 'customer'});

  /// `customer` atau `admin`.
  final String role;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int currentIndex = 0;

  /// `IndexedStack` tidak membangun ulang tab, jadi tab yang datanya bisa
  /// berubah di tempat lain perlu disegarkan lewat kunci ini.
  final _kunciBeranda = GlobalKey<HomePageState>();
  final _kunciPesanan = GlobalKey<MyBookingPageState>();
  final _kunciBookingAdmin = GlobalKey<AdminBookingPageState>();
  final _kunciBerandaAdmin = GlobalKey<AdminHomePageState>();

  bool get _admin => widget.role == UserRole.admin.value;

  static const _ikonCustomer = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.person_outline,
  ];
  static const _ikonCustomerAktif = [
    Icons.home_rounded,
    Icons.receipt_long_rounded,
    Icons.person_rounded,
  ];

  static const _ikonAdmin = [
    Icons.home_outlined,
    Icons.content_cut_outlined,
    Icons.design_services_outlined,
    Icons.event_note_outlined,
    Icons.person_outline,
  ];
  static const _ikonAdminAktif = [
    Icons.home_rounded,
    Icons.content_cut,
    Icons.design_services,
    Icons.event_note_rounded,
    Icons.person_rounded,
  ];

  late final List<Widget> pages = _admin
      ? [
          AdminHomePage(key: _kunciBerandaAdmin),
          const AdminBarberPage(),
          const AdminServicePage(),
          AdminBookingPage(key: _kunciBookingAdmin),
          const ProfilePage(),
        ]
      : [
          HomePage(
            key: _kunciBeranda,
            onBuatBooking: bukaBooking,
            onBukaPesanan: () => _pilih(1),
          ),
          MyBookingPage(key: _kunciPesanan, onBuatBooking: bukaBooking),
          const ProfilePage(),
        ];

  /// Label diambil dari bahasa aktif; sengaja bukan `const` lagi.
  List<String> _label(BuildContext context) {
    final t = context.bahasa;
    return _admin
        ? [t.beranda, t.barber, t.layanan, t.booking, t.profil]
        : [t.beranda, t.pesanan, t.profil];
  }

  List<IconData> get _ikon => _admin ? _ikonAdmin : _ikonCustomer;
  List<IconData> get _ikonAktif =>
      _admin ? _ikonAdminAktif : _ikonCustomerAktif;

  void _pilih(int i) {
    setState(() => currentIndex = i);

    // muat ulang data tab yang butuh data segar; Beranda ikut disegarkan
    // supaya foto profil dan jadwal terdekat tidak basi setelah aksi di tab lain
    if (_admin && i == 0) _kunciBerandaAdmin.currentState?.muatData();
    if (_admin && i == 3) _kunciBookingAdmin.currentState?.muatData();
    if (!_admin && i == 0) _kunciBeranda.currentState?.muatData();
    if (!_admin && i == 1) _kunciPesanan.currentState?.muatData();
  }

  /// Satu pintu masuk form booking untuk customer.
  ///
  /// Setelah tersimpan, tab Pesanan langsung dibuka; tanpa itu pengguna
  /// mendarat kembali di beranda tanpa bukti bookingnya tercatat.
  Future<bool?> bukaBooking() async {
    if (!mounted) return null;

    // tanpa `<bool>`: `routes:` di main.dart menghasilkan route `dynamic`,
    // dan `pushNamed<bool>` akan gagal cast saat runtime
    final hasil = await Navigator.pushNamed(context, '/booking');
    final tersimpan = hasil == true;

    if (tersimpan && mounted) {
      _kunciBeranda.currentState?.muatData();
      _pilih(1);
    }

    return tersimpan;
  }

  @override
  Widget build(BuildContext context) {
    final label = _label(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: currentIndex, children: pages),

      // Ajakan booking paling terlihat hanya di tab Beranda. Tab lain sudah
      // punya jalurnya sendiri (Pesanan: daftar, Profil: tidak perlu).
      floatingActionButton: !_admin && currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: bukaBooking,
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.onDark,
              icon: const Icon(Icons.add),
              label: Text(context.bahasa.buatBooking),
            )
          : null,

      bottomNavigationBar: _NavigasiBawah(
        index: currentIndex,
        label: label,
        ikon: _ikon,
        ikonAktif: _ikonAktif,
        onPilih: _pilih,
      ),
    );
  }
}

/// Navigasi bawah: ikon Material 24, aktif `ink`, tidak aktif `muted`,
/// titik `gold` di bawah label aktif. Tanpa shadow, hanya garis atas.
class _NavigasiBawah extends StatelessWidget {
  const _NavigasiBawah({
    required this.index,
    required this.label,
    required this.ikon,
    required this.ikonAktif,
    required this.onPilih,
  });

  final int index;
  final List<String> label;
  final List<IconData> ikon;
  final List<IconData> ikonAktif;
  final ValueChanged<int> onPilih;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < label.length; i++)
                Expanded(child: _item(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i) {
    final aktif = i == index;

    return Semantics(
      button: true,
      selected: aktif,
      label: label[i],
      child: InkWell(
        onTap: () => onPilih(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              aktif ? ikonAktif[i] : ikon[i],
              size: 24,
              color: aktif ? AppColors.ink : AppColors.muted,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.caption.copyWith(
                fontSize: 11,
                height: 1.1,
                color: aktif ? AppColors.ink : AppColors.muted,
                fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            // indikator aktif tetap memakan ruang supaya label tidak bergeser
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: aktif ? AppColors.gold : AppColors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}