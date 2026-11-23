// Helper konversi nilai JSON dari MySQL.
//
// MySQL bisa mengirim angka sebagai string (mis. `price` DECIMAL),
// jadi semua pembacaan angka lewat sini supaya tidak crash.

int asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse('${value ?? ''}') ?? 0;
}

num asNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse('${value ?? ''}') ?? 0;
}

String asString(dynamic value) {
  if (value == null) return '';
  return '$value';
}

String? asStringOrNull(dynamic value) {
  if (value == null) return null;
  final text = '$value';
  return text.isEmpty ? null : text;
}

bool asBool(dynamic value) {
  if (value is bool) return value;
  if (value == 1 || value == '1' || value == 'true') return true;
  return false;
}
