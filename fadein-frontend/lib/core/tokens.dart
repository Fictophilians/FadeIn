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

/// Skala jarak — `docs/DESIGN.md` bagian 4.
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;

  /// Padding horizontal layar.
  static const lg = 20.0;

  /// Padding vertikal section.
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Alias konteks supaya layar mudah dibaca.
  static const screenH = lg;
  static const sectionV = xl;
  static const cardGap = sm;
  static const cardPadding = md;
  static const labelGap = xs;
  static const fieldGap = md;
}

/// Radius sudut — `docs/DESIGN.md` bagian 4.
abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;

  static const button = md;
  static const input = 14.0;
  static const card = lg;

  /// Bottom sheet / dialog (atas saja).
  static const sheet = 20.0;

  /// Chip / badge.
  static const pill = 999.0;
}

/// Tipografi — `docs/DESIGN.md` bagian 3.
///
/// Oswald hanya untuk display/judul, Inter untuk seluruh teks lain.
abstract final class AppTextTheme {
  /// Judul layar: Oswald 600 / 26 / 1.15 — pakai UPPERCASE.
  static const display = TextStyle(
    fontFamily: 'Oswald',
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 1.15,
    letterSpacing: 0.5,
    color: AppColors.ink,
  );

  /// Judul section: Oswald 500 / 18 / 1.2 — pakai UPPERCASE.
  static const section = TextStyle(
    fontFamily: 'Oswald',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 1.2,
    letterSpacing: 0.5,
    color: AppColors.ink,
  );

  /// Body: Inter 400 / 15 / 1.5.
  static const body = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.5,
    color: AppColors.ink,
  );

  /// Body kecil / caption: Inter 400 / 13 / 1.4.
  static const caption = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.4,
    color: AppColors.muted,
  );

  /// Label tombol & form: Inter 600 / 14 / 1.2.
  static const label = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.2,
    color: AppColors.ink,
  );

  /// Harga: Inter 700 / 16 / 1.2.
  static const price = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.2,
    color: AppColors.ink,
  );
}
