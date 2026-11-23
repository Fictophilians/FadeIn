import 'package:fadein_app/service/api.dart';
import 'package:flutter/material.dart';

/// Route yang hanya boleh dibuka peran tertentu — `docs/DESIGN.md` 6.
///
/// Peran lain langsung dialihkan ke berandanya sendiri:
/// customer → `/home`, admin → `/admin/barbers`.
class RuteTerjaga extends StatelessWidget {
  const RuteTerjaga({super.key, required this.role, required this.child});

  /// Peran yang diizinkan: `customer` atau `admin`.
  final String role;
  final Widget child;

  /// Peran `null` (data user hilang) diperlakukan sebagai customer.
  static String normalisasi(String? peran) {
    return peran == 'admin' ? 'admin' : 'customer';
  }

  static bool boleh(String? peran, String role) {
    return normalisasi(peran) == role;
  }

  /// Beranda milik peran tersebut.
  static String beranda(String? peran) {
    return normalisasi(peran) == 'admin' ? '/admin/barbers' : '/home';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: Apiservice.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final peran = snapshot.data?['role']?.toString();
        if (boleh(peran, role)) return child;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            beranda(peran),
            (_) => false,
          );
        });

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}