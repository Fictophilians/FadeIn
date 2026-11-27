import 'package:fadein_app/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// SnackBar seragam: sukses latar `ink`, gagal latar `danger`.
abstract final class Pesan {
  static void sukses(BuildContext context, String teks) {
    _tampilkan(context, teks, AppColors.ink);
  }

  static void gagal(BuildContext context, String teks) {
    _tampilkan(context, teks, AppColors.danger);
  }

  static void _tampilkan(BuildContext context, String teks, Color latar) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(teks),
          backgroundColor: latar,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}