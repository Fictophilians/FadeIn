import 'package:flutter/material.dart';

import 'app_colors.dart';

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

  /// Sheet besar yang naik dari bawah (login, register).
  static const sheetLg = 28.0;

  /// Kartu foto besar (hero, banner).
  static const xl = 24.0;

  /// Chip / badge.
  static const pill = 999.0;
}

/// Gradien bersama. Jangan tulis `LinearGradient` langsung di layar.
abstract final class AppGradient {
  /// Tirai gelap di bawah foto hero supaya judul putih tetap terbaca.
  static const heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.heroTop, AppColors.heroMid, AppColors.heroBottom],
    stops: [0, 0.35, 1],
  );

  /// Latar kartu promo / ajakan di beranda.
  static const promo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.inkSoft, AppColors.ink],
  );

  /// Sampul kartu layanan tanpa foto.
  static const cardCover = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.goldSoft, AppColors.bg],
  );
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

/// `ThemeData` resmi FadeIn — dipetakan langsung dari `docs/DESIGN.md`.
///
/// Aturan penting: card memakai border tanpa shadow, tombol setinggi 48,
/// input radius 14 dengan border fokus `gold`.
abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.ink,
      onPrimary: AppColors.onDark,
      primaryContainer: AppColors.inkSoft,
      onPrimaryContainer: AppColors.onDark,
      secondary: AppColors.gold,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.goldSoft,
      onSecondaryContainer: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.danger,
      onError: AppColors.onDark,
      errorContainer: AppStatusColors.cancelledBg,
      onErrorContainer: AppColors.danger,
    );

    const cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      side: BorderSide(color: AppColors.border),
    );

    const buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
    );

    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
      borderSide: BorderSide(color: AppColors.border),
    );

    const inputBorderFocused = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
      borderSide: BorderSide(color: AppColors.gold, width: 1.5),
    );

    const inputBorderError = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
      borderSide: BorderSide(color: AppColors.danger, width: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      splashFactory: InkRipple.splashFactory,

      // ——— Tipografi ———
      textTheme: const TextTheme(
        // Judul layar.
        displaySmall: AppTextTheme.display,
        // Judul section.
        headlineSmall: AppTextTheme.section,
        titleLarge: AppTextTheme.section,
        // Body.
        bodyLarge: AppTextTheme.body,
        bodyMedium: AppTextTheme.body,
        // Caption.
        bodySmall: AppTextTheme.caption,
        labelMedium: AppTextTheme.caption,
        // Label tombol & form.
        labelLarge: AppTextTheme.label,
        // Harga.
        titleMedium: AppTextTheme.price,
      ),

      // ——— AppBar ———
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.ink,
        surfaceTintColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextTheme.display.copyWith(fontSize: 20),
      ),

      // ——— Card: border, tanpa shadow ———
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: cardShape,
      ),

      // ——— Tombol ———
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.onDark,
          disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.onDark.withValues(alpha: 0.7),
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: buttonShape,
          textStyle: AppTextTheme.label.copyWith(color: AppColors.onDark),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.transparent,
          disabledForegroundColor: AppColors.muted,
          side: const BorderSide(color: AppColors.border),
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: buttonShape,
          textStyle: AppTextTheme.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: AppTextTheme.label,
          shape: buttonShape,
        ),
      ),

      // ——— Input ———
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        hintStyle: AppTextTheme.caption,
        labelStyle: AppTextTheme.caption,
        floatingLabelStyle: AppTextTheme.caption.copyWith(color: AppColors.ink),
        errorStyle: AppTextTheme.caption.copyWith(color: AppColors.danger),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: inputBorderFocused,
        errorBorder: inputBorderError,
        focusedErrorBorder: inputBorderError,
      ),

      // ——— Divider ———
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ——— SnackBar ———
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextTheme.body.copyWith(color: AppColors.onDark),
        actionTextColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // ——— Dialog & bottom sheet ———
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        titleTextStyle: AppTextTheme.section,
        contentTextStyle: AppTextTheme.body,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),

      // ——— Chip & badge ———
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.goldSoft,
        selectedColor: AppColors.goldSoft,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: AppTextTheme.caption.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ——— Loading ———
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
      ),
    );
  }
}
