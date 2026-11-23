import 'JsonHelper.dart';

/// Satu slot jam dari `GET /api/bookings/slots`.
class Slot {
  const Slot({required this.time, required this.available});

  /// Format `HH:mm`, mis. `09:00`.
  final String time;

  /// `false` berarti slot sudah dipakai booking berstatus pending/confirmed.
  final bool available;

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      time: asString(json['time']),
      available: asBool(json['available']),
    );
  }
}
