import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/SplashPage.dart';
import 'package:fadein_app/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  group('SplashPage.ruteUntuk', () {
    test('tanpa token ke login', () {
      expect(SplashPage.ruteUntuk(token: null, role: 'admin'), '/login');
      expect(SplashPage.ruteUntuk(token: '', role: 'customer'), '/login');
    });

    test('customer ke home', () {
      expect(SplashPage.ruteUntuk(token: 'x', role: 'customer'), '/home');
    });

    test('admin ke halaman admin', () {
      expect(
        SplashPage.ruteUntuk(token: 'x', role: 'admin'),
        '/admin/barbers',
      );
    });
  });

  group('SplashPage', () {
    setUp(() {
      Apiservice.tanpaSecureStorage = true;
    });

    tearDown(() {
      Apiservice.setTokenCache(null);
      Apiservice.setUserCache(null);
      Apiservice.tanpaSecureStorage = false;
    });

    Widget app() => MaterialApp(
          theme: AppTheme.light,
          home: const SplashPage(),
          routes: {
            '/login': (_) => const Scaffold(body: Text('HALAMAN LOGIN')),
            '/home': (_) => const Scaffold(body: Text('HALAMAN HOME')),
          },
        );

    testWidgets('menunggu tombol Mulai, tidak pindah sendiri', (tester) async {
      await tester.pumpWidget(app());
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('HALAMAN LOGIN'), findsNothing);
      expect(find.text('Mulai'), findsOneWidget);
    });

    testWidgets('Mulai membuka login saat belum ada sesi', (tester) async {
      await tester.pumpWidget(app());
      await tester.tap(find.text('Mulai'));
      await tester.pumpAndSettle();

      expect(find.text('HALAMAN LOGIN'), findsOneWidget);
    });
  });
}