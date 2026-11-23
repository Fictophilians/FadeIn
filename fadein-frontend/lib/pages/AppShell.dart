import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:flutter/material.dart';

/// Satu tab pada navigasi bawah.
class AppTab {
  const AppTab({
    required this.label,
    required this.icon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Widget page;
}

/// Kerangka beranda per peran — `docs/DESIGN.md` 6.
///
/// Navigasi bawah memakai ikon Material 24, aktif `ink`, tidak aktif `muted`,
/// dengan titik `gold` di bawah label aktif.
///
/// Isi tiap tab diserahkan lewat [tabs] supaya shell tidak bergantung pada
/// layar yang belum jadi.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onLogout,
    this.logoutTabLabel = 'Profile',
  });

  final List<AppTab> tabs;
  final int initialIndex;

  /// Dipanggil dari menu di tab Profile. `null` → menu tidak tampil.
  final Future<void> Function()? onLogout;

  final String logoutTabLabel;

  /// Tab customer: Home · Booking · My Booking · Profile.
  static List<AppTab> tabCustomer({
    required Widget home,
    required Widget booking,
    required Widget myBookings,
    required Widget profile,
  }) {
    return [
      AppTab(label: 'Home', icon: Icons.home_outlined, page: home),
      AppTab(label: 'Booking', icon: Icons.content_cut, page: booking),
      AppTab(label: 'My Booking', icon: Icons.receipt_long_outlined, page: myBookings),
      AppTab(label: 'Profile', icon: Icons.person_outline, page: profile),
    ];
  }

  /// Tab admin: Barber · Layanan · Booking · Profile.
  static List<AppTab> tabAdmin({
    required Widget barbers,
    required Widget services,
    required Widget bookings,
    required Widget profile,
  }) {
    return [
      AppTab(label: 'Barber', icon: Icons.content_cut, page: barbers),
      AppTab(label: 'Layanan', icon: Icons.design_services_outlined, page: services),
      AppTab(label: 'Booking', icon: Icons.receipt_long_outlined, page: bookings),
      AppTab(label: 'Profile', icon: Icons.person_outline, page: profile),
    ];
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  bool get _diTabLogout => widget.tabs[_index].label == widget.logoutTabLabel;

  Future<void> _keluar() async {
    final keluar = widget.onLogout;
    if (keluar == null) return;

    try {
      await keluar();
    } catch (e) {
      if (mounted) Pesan.gagal(context, '$e');
      return;
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tabs[_index].label.toUpperCase()),
        automaticallyImplyLeading: false,
        actions: [
          if (_diTabLogout && widget.onLogout != null)
            IconButton(
              onPressed: _keluar,
              icon: const Icon(Icons.logout, color: AppColors.ink),
              tooltip: 'Keluar',
            ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [for (final tab in widget.tabs) tab.page],
      ),
      bottomNavigationBar: _NavigasiBawah(
        tabs: widget.tabs,
        index: _index,
        onPilih: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _NavigasiBawah extends StatelessWidget {
  const _NavigasiBawah({
    required this.tabs,
    required this.index,
    required this.onPilih,
  });

  final List<AppTab> tabs;
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
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _item(i),
              ),
          ],
        ),
      ),
    );
  }

  Widget _item(int i) {
    final aktif = i == index;
    final tab = tabs[i];

    return Semantics(
      button: true,
      selected: aktif,
      label: tab.label,
      child: InkWell(
        onTap: () => onPilih(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tab.icon,
                size: 24,
                color: aktif ? AppColors.ink : AppColors.muted,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextTheme.caption.copyWith(
                  fontSize: 11,
                  color: aktif ? AppColors.ink : AppColors.muted,
                  fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              // indikator aktif: titik gold, tetap memakan ruang saat tidak aktif
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
      ),
    );
  }
}