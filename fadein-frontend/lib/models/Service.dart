import 'JsonHelper.dart';

/// Layanan yang dijual barbershop.
///
/// Backend mengirim: `id, name, price, duration, created_at`.
class Service {
  const Service({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  final int id;
  final String name;

  /// Harga dalam rupiah. Dibaca `num` karena MySQL bisa mengirim string.
  final num price;

  /// Durasi dalam menit.
  final int duration;

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: asInt(json['id']),
      name: asString(json['name']),
      price: asNum(json['price']),
      duration: asInt(json['duration']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
    };
  }
}
