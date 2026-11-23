/// Status booking sesuai kolom `bookings.status`.
enum BookingStatus {
  pending('pending', 'Menunggu'),
  confirmed('confirmed', 'Dikonfirmasi'),
  completed('completed', 'Selesai'),
  cancelled('cancelled', 'Dibatalkan');

  const BookingStatus(this.value, this.label);

  /// Nilai yang dipakai backend & dikirim ke API.
  final String value;

  /// Label bahasa Indonesia untuk ditampilkan di layar.
  final String label;

  /// Status yang masih memakai slot: pending & confirmed.
  bool get isActive => this == pending || this == confirmed;

  /// Hanya booking aktif yang boleh dibatalkan.
  bool get canCancel => isActive;

  /// Parser aman: nilai tidak dikenal dianggap `pending`.
  static BookingStatus fromValue(String? value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}
