import 'JsonHelper.dart';

/// Peran pengguna. Registrasi selalu menghasilkan `customer`.
enum UserRole {
  customer('customer', 'Customer'),
  admin('admin', 'Admin');

  const UserRole(this.value, this.label);

  final String value;
  final String label;

  /// Parser aman: nilai tidak dikenal dianggap `customer`.
  static UserRole fromValue(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }
}

/// Data pengguna yang dikirim backend pada login dan profil.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photo,
  });

  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? photo;

  bool get isAdmin => role == UserRole.admin;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: asInt(json['id']),
      name: asString(json['name']),
      email: asString(json['email']),
      role: UserRole.fromValue(asStringOrNull(json['role'])),
      photo: asStringOrNull(json['photo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'photo': photo,
    };
  }
}
