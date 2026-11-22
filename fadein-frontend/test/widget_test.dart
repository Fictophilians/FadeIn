import 'package:fadein_app/core/theme.dart';
import 'package:fadein_app/core/tokens.dart';
import 'package:fadein_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('halaman pratinjau tema tampil', (tester) async {
    // Viewport tinggi supaya seluruh ListView dibangun (bukan lazy).
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FadeInApp());

    expect(find.text('PREVIEW TEMA'), findsOneWidget);
    expect(find.text('Booking Sekarang'), findsOneWidget);
    expect(find.text('Lihat Layanan'), findsOneWidget);
    expect(find.text('Nama lengkap'), findsOneWidget);
    expect(find.text('Rp50.000'), findsWidgets);
    expect(find.text('Selesai'), findsOneWidget);
  });

  test('token dan theme sesuai DESIGN.md', () {
    expect(AppTextTheme.display.fontFamily, 'Oswald');
    expect(AppTextTheme.section.fontFamily, 'Oswald');
    expect(AppTextTheme.body.fontFamily, 'Inter');
    expect(AppSpacing.screenH, 20);
    expect(AppRadius.card, 16);
    expect(AppRadius.input, 14);
    expect(AppRadius.button, 12);

    final theme = AppTheme.light;
    expect(theme.useMaterial3, isTrue);
    expect(theme.textTheme.displaySmall?.fontFamily, 'Oswald');
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(theme.cardTheme.elevation, 0);
    expect(theme.scaffoldBackgroundColor, AppColors.bg);
  });
}
