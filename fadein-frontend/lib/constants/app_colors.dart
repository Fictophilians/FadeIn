import 'package:flutter/material.dart';

/// Palet "Ivory & Ink" — sumber: `docs/DESIGN.md` bagian 2.
///
/// Semua warna aplikasi wajib diambil dari sini. Jangan menulis `Color(0x...)`
/// langsung di layar atau widget.
abstract final class AppColors {
  /// Background scaffold seluruh halaman terang.
  static const bg = Color(0xFFFBF7EF);

  /// Card, input, bottom sheet, dialog.
  static const surface = Color(0xFFFFFFFF);

  /// Teks utama, tombol primer, ikon aktif.
  static const ink = Color(0xFF121212);

  /// Hero, header gelap, splash.
  static const inkSoft = Color(0xFF1E1E1E);

  /// Aksen, garis, ikon terpilih, border fokus.
  static const gold = Color(0xFFC9A227);

  /// Chip, highlight, latar badge netral.
  static const goldSoft = Color(0xFFF2E4B8);

  /// Teks sekunder, placeholder, caption.
  static const muted = Color(0xFF6B6B6B);

  /// Divider, outline input, border card.
  static const border = Color(0xFFE6DFD1);

  /// Status completed, aksi berhasil.
  static const success = Color(0xFF16A34A);

  /// Status pending, peringatan.
  static const warning = Color(0xFFD97706);

  /// Status confirmed, tautan.
  static const info = Color(0xFF2563EB);

  /// Status cancelled, tombol hapus, error.
  static const danger = Color(0xFFDC2626);

  // ——— Turunan yang dipakai theme & komponen ———

  /// Teks/ikon di atas `ink` atau `inkSoft`.
  static const onDark = Color(0xFFFFFFFF);

  /// Slot jadwal yang sudah terisi atau sudah lewat.
  static const slotDisabledBg = Color(0xFFF3EFE6);

  /// Warna isi transparan.
  static const transparent = Color(0x00000000);

  /// Shadow bottom sheet & dialog (`#00000014`).
  static const shadow = Color(0x14000000);

  /// Scrim `LoadingOverlay` (`#00000040`).
  static const scrim = Color(0x40000000);
}

/// Pasangan warna [StatusBadge] per status booking.
///
/// Label yang ditampilkan: Menunggu, Dikonfirmasi, Selesai, Dibatalkan.
abstract final class AppStatusColors {
  static const pendingFg = AppColors.warning;
  static const pendingBg = Color(0xFFFEF3C7);

  static const confirmedFg = AppColors.info;
  static const confirmedBg = Color(0xFFDBEAFE);

  static const completedFg = AppColors.success;
  static const completedBg = Color(0xFFDCFCE7);

  static const cancelledFg = AppColors.danger;
  static const cancelledBg = Color(0xFFFEE2E2);
}
