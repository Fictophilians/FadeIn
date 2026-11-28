import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/widgets/TombolBahasa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Bungkus satu halaman dengan `L10n` + `MaterialApp` yang ikut berganti
/// bahasa, persis seperti `main.dart`.
Widget _app(Widget child) {
  return ValueListenableBuilder<Bahasa>(
    valueListenable: bahasaAktif,
    builder: (_, bahasa, _) => L10n(
      data: dataBahasa(bahasa),
      child: MaterialApp(
        theme: AppTheme.light,
        locale: bahasa.locale,
        home: Scaffold(appBar: AppBar(title: Text('Uji')), body: child),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    await initializeDateFormatting('en_US');
  });

  tearDown(() => bahasaAktif.value = Bahasa.id);

  test('kedua bahasa mengisi setiap getter teks', () {
    for (final b in Bahasa.values) {
      final t = dataBahasa(b);
      expect(t.beranda, isNotEmpty);
      expect(t.gagalMuatData, isNotEmpty);
      expect(t.splashJudul, isNotEmpty);
      expect(t.hariSingkat, hasLength(7));
      expect(t.bahasa, b);
    }
  });

  test('format tanggal ikut locale', () {
    gantiBahasa(Bahasa.id);
    expect(formatHari('2026-11-20'), 'Jumat');
    expect(formatBulanTahun('2026-11'), 'November 2026');

    gantiBahasa(Bahasa.en);
    expect(formatHari('2026-11-20'), 'Friday');
    expect(formatBulanTahun('2026-11'), 'November 2026');
    // rupiah tidak ikut berganti bahasa
    expect(formatRupiah(35000), 'Rp35.000');
  });

  testWidgets('tombol bahasa mengganti teks di layar', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Column(
            children: [
              const TombolBahasa(),
              Text(context.bahasa.beranda),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Beranda'), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Beranda'), findsNothing);
  });

  testWidgets('EN muat di 360x640 tanpa overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    gantiBahasa(Bahasa.en);

    await tester.pumpWidget(_app(const Center(child: TombolBahasa())));

    expect(tester.takeException(), isNull);
  });
}
