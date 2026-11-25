import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/User.dart';
import 'package:fadein_app/pages/AdminBarberPage.dart';
import 'package:fadein_app/pages/AdminBookingPage.dart';
import 'package:fadein_app/pages/AdminServicePage.dart';
import 'package:fadein_app/pages/HomePage.dart';
import 'package:fadein_app/pages/MyBookingPage.dart';
import 'package:fadein_app/pages/ProfilePage.dart';
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
/// admin    : Barber · Layanan · Booking · Profil
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

  /// Supaya tab Pesanan bisa disegarkan saat dibuka — `IndexedStack` membuat
  /// layarnya tidak pernah dibangun ulang, jadi booking baru tidak akan
  /// muncul tanpa dorongan ini.
  final _kunciPesanan = GlobalKey<MyBookingPageState>();
  final _kunciBookingAdmin = GlobalKey<AdminBookingPageState>();

  bool get _admin => widget.role == UserRole.admin.value;

  late final List<Widget> pages = _admin
      ? [
          const AdminBarberPage(),
          const AdminServicePage(),
          AdminBookingPage(key: _kunciBookingAdmin),
          const ProfilePage(),
        ]
      : [
          HomePage(onBukaPesanan: () => _pilih(1)),
          MyBookingPage(key: _kunciPesanan),
          const ProfilePage(),
        ];

  void _pilih(int i) {
    setState(() => currentIndex = i);

    // muat ulang data tab yang butuh data segar
    if (_admin && i == 2) _kunciBookingAdmin.currentState?.muatData();
    if (!_admin && i == 1) _kunciPesanan.currentState?.muatData();
  }

  static const _labelCustomer = ['Beranda', 'Pesanan', 'Profil'];
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

  static const _labelAdmin = ['Barber', 'Layanan', 'Booking', 'Profil'];
  static const _ikonAdmin = [
    Icons.content_cut_outlined,
    Icons.design_services_outlined,
    Icons.event_note_outlined,
    Icons.person_outline,
  ];
  static const _ikonAdminAktif = [
    Icons.content_cut,
    Icons.design_services,
    Icons.event_note_rounded,
    Icons.person_rounded,
  ];

  List<String> get _label => _admin ? _labelAdmin : _labelCustomer;
  List<IconData> get _ikon => _admin ? _ikonAdmin : _ikonCustomer;
  List<IconData> get _ikonAktif =>
      _admin ? _ikonAdminAktif : _ikonCustomerAktif;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _NavigasiBawah(
        index: currentIndex,
        label: _label,
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
