import 'BookingStatus.dart';
import 'JsonHelper.dart';

/// Satu baris booking lengkap dengan nama customer, barber, dan layanan.
///
/// Backend mengirim hasil JOIN:
/// `id, user_id, barber_id, service_id, booking_date, booking_time, status,
/// created_at, customer_name, barber_name, service_name, price, duration`.
class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.barberId,
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    required this.customerName,
    required this.barberName,
    required this.serviceName,
    required this.price,
    required this.duration,
    this.createdAt,
  });

  final int id;
  final int userId;
  final int barberId;
  final int serviceId;

  /// Format `YYYY-MM-DD` (dateStrings aktif di pool MySQL).
  final String bookingDate;

  /// Format `HH:mm`.
  final String bookingTime;

  final BookingStatus status;
  final String customerName;
  final String barberName;
  final String serviceName;
  final num price;
  final int duration;
  final String? createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: asInt(json['id']),
      userId: asInt(json['user_id']),
      barberId: asInt(json['barber_id']),
      serviceId: asInt(json['service_id']),
      bookingDate: asString(json['booking_date']),
      bookingTime: asString(json['booking_time']),
      status: BookingStatus.fromValue(asStringOrNull(json['status'])),
      customerName: asString(json['customer_name']),
      barberName: asString(json['barber_name']),
      serviceName: asString(json['service_name']),
      price: asNum(json['price']),
      duration: asInt(json['duration']),
      createdAt: asStringOrNull(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'barber_id': barberId,
      'service_id': serviceId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'status': status.value,
      'customer_name': customerName,
      'barber_name': barberName,
      'service_name': serviceName,
      'price': price,
      'duration': duration,
      'created_at': createdAt,
    };
  }
}
