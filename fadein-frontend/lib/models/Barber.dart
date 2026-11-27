import 'JsonHelper.dart';

/// Barber (kapster) yang bisa dipilih customer.
///
/// Backend mengirim: `id, name, description, photo, created_at`.
class Barber {
  const Barber({
    required this.id,
    required this.name,
    required this.photo,
    this.description,
  });

  final int id;
  final String name;

  /// URL foto dari Cloudinary.
  final String photo;

  /// Spesialisasi / keterangan singkat, boleh kosong.
  final String? description;

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: asInt(json['id']),
      name: asString(json['name']),
      photo: asString(json['photo']),
      description: asStringOrNull(json['description']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo': photo,
    };
  }
}
