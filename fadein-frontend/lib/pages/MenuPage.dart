import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/HomePage.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:flutter/material.dart';

/// Kerangka utama aplikasi customer — `docs/DESIGN.md` 6.
///
/// Pola sama seperti `MenuPage` pada proyek GameHaven: satu daftar [pages],
/// satu [currentIndex], dan `IndexedStack` supaya tiap tab tidak dibangun
/// ulang (data tidak di-fetch ulang setiap pindah tab).
///
/// Tab Booking belum ada layarnya (T12), jadi navigasi baru tiga tab:
/// Beranda · Pesanan · Profil.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int currentIndex = 0;

  late final List<Widget> pages = const [
    HomePage(),
    _SegeraHadir(
      icon: Icons.receipt_long_outlined,
      title: 'Belum ada pesanan',
      message: 'Booking yang kamu buat akan muncul di sini.',
    ),
    _SegeraHadir(
      icon: Icons.person_outline,
      title: 'Profil',
      message: 'Halaman profil sedang disiapkan.',
    ),
  ];

  static const _label = ['Beranda', 'Pesanan', 'Profil'];
  static const _ikon = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.person_outline,
  ];
  static const _ikonAktif = [
    Icons.home_rounded,
    Icons.receipt_long_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _NavigasiBawah(
        index: currentIndex,
        onPilih: (i) => setState(() => currentIndex = i),
      ),
    );
  }
}

/// Navigasi bawah: ikon Material 24, aktif `ink`, tidak aktif `muted`,
/// titik `gold` di bawah label aktif. Tanpa shadow, hanya garis atas.
class _NavigasiBawah extends StatelessWidget {
  const _NavigasiBawah({required this.index, required this.onPilih});

  final int index;
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
              for (var i = 0; i < _MenuPageState._label.length; i++)
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
      label: _MenuPageState._label[i],
      child: InkWell(
        onTap: () => onPilih(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              aktif ? _MenuPageState._ikonAktif[i] : _MenuPageState._ikon[i],
              size: 24,
              color: aktif ? AppColors.ink : AppColors.muted,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              _MenuPageState._label[i],
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

/// Isi tab yang layarnya belum dibuat (T14 Pesanan, T15 Profil).
class _SegeraHadir extends StatelessWidget {
  const _SegeraHadir({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: EmptyState(icon: icon, title: title, message: message),
      ),
    );
  }
}
