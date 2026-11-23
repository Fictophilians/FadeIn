import 'package:fadein_app/models/Barber.dart';
import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/models/BookingStatus.dart';
import 'package:fadein_app/models/Service.dart';
import 'package:fadein_app/models/Slot.dart';
import 'package:fadein_app/models/User.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    test('parsing user customer', () {
      final user = User.fromJson({
        'id': 2,
        'name': 'Budi Santoso',
        'email': 'budi@gmail.com',
        'role': 'customer',
        'photo': null,
      });

      expect(user.id, 2);
      expect(user.name, 'Budi Santoso');
      expect(user.role, UserRole.customer);
      expect(user.photo, isNull);
      expect(user.isAdmin, isFalse);
    });

    test('role tidak dikenal dianggap customer', () {
      final user = User.fromJson({'id': 1, 'role': 'owner'});
      expect(user.role, UserRole.customer);
    });
  });

  group('Service', () {
    test('harga string dari MySQL dibaca num', () {
      final service = Service.fromJson({
        'id': 1,
        'name': 'Haircut',
        'price': '35000',
        'duration': 30,
        'created_at': '2026-11-20 10:00:00',
      });

      expect(service.id, 1);
      expect(service.name, 'Haircut');
      expect(service.price, 35000);
      expect(service.duration, 30);
    });
  });

  group('Barber', () {
    test('parsing barber dengan foto', () {
      final barber = Barber.fromJson({
        'id': 3,
        'name': 'Rizky',
        'description': 'Spesialis fade',
        'photo': 'https://res.cloudinary.com/fadein/rizky.jpg',
      });

      expect(barber.id, 3);
      expect(barber.name, 'Rizky');
      expect(barber.description, 'Spesialis fade');
      expect(barber.photo, contains('rizky.jpg'));
    });
  });

  group('Booking', () {
    test('parsing hasil JOIN booking', () {
      final booking = Booking.fromJson({
        'id': 10,
        'user_id': 2,
        'barber_id': 1,
        'service_id': 2,
        'booking_date': '2026-11-20',
        'booking_time': '14:00',
        'status': 'confirmed',
        'created_at': '2026-11-19 09:15:00',
        'customer_name': 'Budi Santoso',
        'barber_name': 'Andi',
        'service_name': 'Haircut + Wash',
        'price': '50000',
        'duration': 45,
      });

      expect(booking.id, 10);
      expect(booking.userId, 2);
      expect(booking.barberId, 1);
      expect(booking.serviceId, 2);
      expect(booking.bookingDate, '2026-11-20');
      expect(booking.bookingTime, '14:00');
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.status.label, 'Dikonfirmasi');
      expect(booking.customerName, 'Budi Santoso');
      expect(booking.barberName, 'Andi');
      expect(booking.serviceName, 'Haircut + Wash');
      expect(booking.price, 50000);
      expect(booking.duration, 45);
    });

    test('status tidak dikenal dianggap pending', () {
      final booking = Booking.fromJson({'id': 1, 'status': 'unknown'});
      expect(booking.status, BookingStatus.pending);
    });
  });

  group('BookingStatus', () {
    test('label Indonesia dan aturan batal', () {
      expect(BookingStatus.pending.label, 'Menunggu');
      expect(BookingStatus.completed.label, 'Selesai');
      expect(BookingStatus.pending.canCancel, isTrue);
      expect(BookingStatus.confirmed.canCancel, isTrue);
      expect(BookingStatus.completed.canCancel, isFalse);
      expect(BookingStatus.cancelled.canCancel, isFalse);
    });
  });

  group('Slot', () {
    test('parsing slot tersedia dan terisi', () {
      final tersedia = Slot.fromJson({'time': '09:00', 'available': true});
      final terisi = Slot.fromJson({'time': '10:00', 'available': false});

      expect(tersedia.time, '09:00');
      expect(tersedia.available, isTrue);
      expect(terisi.available, isFalse);
    });
  });
}
