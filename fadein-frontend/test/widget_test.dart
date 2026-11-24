import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/SplashPage.dart';
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
}