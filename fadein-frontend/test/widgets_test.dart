import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/models/BookingStatus.dart';
import 'package:fadein_app/widgets/BarberCard.dart';
import 'package:fadein_app/widgets/BookingCard.dart';
import 'package:fadein_app/widgets/ConfirmDialog.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/FadeInTextField.dart';
import 'package:fadein_app/widgets/LoadingOverlay.dart';
import 'package:fadein_app/widgets/ServiceCard.dart';
import 'package:fadein_app/widgets/SlotChip.dart';
import 'package:fadein_app/widgets/StatusBadge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Booking _booking({
  BookingStatus status = BookingStatus.pending,
  int id = 1,
}) {
  return Booking(
    id: id,
    userId: 2,
    barberId: 1,
    serviceId: 1,
    bookingDate: '2026-11-20',
    bookingTime: '14:00',
    status: status,
    customerName: 'Budi',
    barberName: 'Andi',
    serviceName: 'Haircut',
    price: 50000,
    duration: 45,
  );
}

/// Membungkus widget dalam scaffold minimal + theme aplikasi.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('FadeInButton tampil dan bisa ditekan', (tester) async {
    var ditekan = 0;

    await tester.pumpWidget(
      _wrap(FadeInButton(label: 'Simpan', onPressed: () => ditekan++)),
    );
    await tester.tap(find.text('Simpan'));

    expect(ditekan, 1);
  });

  testWidgets('FadeInButton loading menyembunyikan teks', (tester) async {
    await tester.pumpWidget(
      _wrap(FadeInButton(label: 'Simpan', isLoading: true, onPressed: () {})),
    );

    expect(find.text('Simpan'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('FadeInButton disabled tidak bisa ditekan', (tester) async {
    await tester.pumpWidget(_wrap(const FadeInButton(label: 'Simpan')));

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('FadeInTextField password punya toggle mata', (tester) async {
    await tester.pumpWidget(
      _wrap(const FadeInTextField(label: 'Password', obscure: true)),
    );

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('FadeInTextField menampilkan error dari luar', (tester) async {
    await tester.pumpWidget(
      _wrap(const FadeInTextField(label: 'Email', error: 'Format email salah')),
    );

    expect(find.text('Format email salah'), findsOneWidget);
  });

  testWidgets('ServiceCard menampilkan nama, durasi, harga', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ServiceCard(
          name: 'Haircut + Wash',
          price: 'Rp50.000',
          duration: 45,
        ),
      ),
    );

    expect(find.text('Haircut + Wash'), findsOneWidget);
    expect(find.text('45 menit'), findsOneWidget);
    expect(find.text('Rp50.000'), findsOneWidget);
  });

  testWidgets('BarberCard tampil dan tombol Pilih memicu callback', (
    tester,
  ) async {
    var dipilih = 0;

    await tester.pumpWidget(
      _wrap(
        BarberCard(
          name: 'Andi',
          description: 'Spesialis fade',
          onSelect: () => dipilih++,
        ),
      ),
    );

    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('Spesialis fade'), findsOneWidget);

    await tester.tap(find.text('Pilih'));
    expect(dipilih, 1);
  });

  testWidgets('StatusBadge menampilkan label sesuai status', (tester) async {
    await tester.pumpWidget(
      _wrap(const StatusBadge(status: BookingStatus.confirmed)),
    );

    expect(find.text('Dikonfirmasi'), findsOneWidget);
  });

  testWidgets('SlotChip terisi tidak bisa ditekan', (tester) async {
    var ditekan = 0;

    await tester.pumpWidget(
      _wrap(
        SlotChip(time: '10:00', available: false, onTap: () => ditekan++),
      ),
    );

    await tester.tap(find.text('10:00'));
    expect(ditekan, 0);
  });

  testWidgets('SlotChip tersedia bisa ditekan', (tester) async {
    var ditekan = 0;

    await tester.pumpWidget(
      _wrap(SlotChip(time: '11:00', available: true, onTap: () => ditekan++)),
    );

    await tester.tap(find.text('11:00'));
    expect(ditekan, 1);
  });

  testWidgets('BookingCard pending menampilkan tombol Batalkan', (tester) async {
    var dibatalkan = 0;

    await tester.pumpWidget(
      _wrap(
        SingleChildScrollView(
          child: BookingCard(
            booking: _booking(),
            onCancel: () => dibatalkan++,
          ),
        ),
      ),
    );

    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('Rp50.000'), findsOneWidget);

    await tester.tap(find.text('Batalkan'));
    expect(dibatalkan, 1);
  });

  testWidgets('BookingCard selesai tidak punya aksi batal', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SingleChildScrollView(
          child: BookingCard(
            booking: _booking(status: BookingStatus.completed),
            onCancel: () {},
          ),
        ),
      ),
    );

    expect(find.text('Selesai'), findsOneWidget);
    expect(find.text('Batalkan'), findsNothing);
  });

  testWidgets('EmptyState menampilkan judul dan aksi', (tester) async {
    var ditekan = 0;

    await tester.pumpWidget(
      _wrap(
        EmptyState(
          title: 'Belum ada booking',
          message: 'Yuk booking sekarang.',
          actionLabel: 'Booking Sekarang',
          onAction: () => ditekan++,
        ),
      ),
    );

    expect(find.text('Belum ada booking'), findsOneWidget);

    await tester.tap(find.text('Booking Sekarang'));
    expect(ditekan, 1);
  });

  testWidgets('LoadingOverlay menampilkan pesan', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoadingOverlay(message: 'Menyimpan...')),
    );

    expect(find.text('Menyimpan...'), findsOneWidget);
  });

  testWidgets('ConfirmDialog mengembalikan true saat dikonfirmasi', (
    tester,
  ) async {
    bool? hasil;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FadeInButton(
                label: 'Hapus',
                onPressed: () async {
                  hasil = await ConfirmDialog.tampilkan(
                    context,
                    title: 'Hapus layanan?',
                    message: 'Tindakan ini tidak bisa dibatalkan.',
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus layanan?'), findsOneWidget);

    await tester.tap(find.text('Ya, hapus'));
    await tester.pumpAndSettle();

    expect(hasil, isTrue);
  });
}