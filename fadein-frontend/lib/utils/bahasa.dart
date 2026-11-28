import 'package:fadein_app/models/BookingStatus.dart';
import 'package:fadein_app/models/User.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:flutter/material.dart';

/// Dua bahasa yang didukung aplikasi.
///
/// Indonesia adalah bawaan, jadi seluruh tes lama tetap berjalan tanpa
/// menyentuh apa pun.
enum Bahasa {
  id(Locale('id', 'ID')),
  en(Locale('en', 'US'));

  const Bahasa(this.locale);

  /// Locale untuk `MaterialApp` dan `DateFormat`; `toString()`-nya
  /// `id_ID` / `en_US`.
  final Locale locale;

  /// Teks di tombol bahasa: `ID` / `EN`.
  String get kode => name.toUpperCase();
}

/// Seluruh teks yang tampil di layar, satu getter per kalimat.
///
/// Dipisah sebagai kelas abstrak (bukan `Map<String, String>`) supaya nama
/// kuncinya diperiksa compiler: kalau satu bahasa lupa diisi, `flutter
/// analyze` langsung menolak. Tidak ada teks yang diam-diam kembali jadi
/// kunci mentah di layar.
abstract class BahasaData {
  const BahasaData(this.bahasa);

  /// Bahasa yang sedang dipakai, dipakai widget tombol untuk tahu arah
  /// pergantian.
  final Bahasa bahasa;

  // ---------- umum ----------
  String get kembali;
  String get coba;
  String get muatUlang;
  String get tampilkanSemua;
  String get batal;
  String get batalkan;
  String get yaHapus;
  String get edit;
  String get hapus;
  String get tambah;
  String get pilih;
  String get simpanPerubahan;
  String get belumAdaKeterangan;
  String get semua;
  String get customer;
  String get email;
  String get tampilkanPassword;
  String get sembunyikanPassword;
  String get wajibDiisi;
  String get harusAngkaBulat;
  String get harusLebihDari0;
  String maksimal(int n);

  // ---------- navigasi bawah ----------
  String get beranda;
  String get pesanan;
  String get profil;
  String get barber;
  String get layanan;
  String get booking;
  String get buatBooking;

  // ---------- judul halaman ----------
  String get judulDashboard;
  String get judulBarber;
  String get judulLayanan;
  String get judulBooking;
  String get judulPesanan;
  String get judulProfil;

  // ---------- status & peran ----------
  String status(BookingStatus s);
  String peran(UserRole r);
  String get peranLabel;

  // ---------- beranda customer ----------
  String get gagalMuatData;
  String sapa(String nama);
  String get heroJudul;
  String get belumAdaNotifikasi;
  String get belumAdaLayanan;
  String get adminBelumLayanan;
  String get belumAdaBarber;
  String get adminBelumBarber;
  String get jadwalBerikutnya;
  String get dataMasihKosong;
  String get namaFallback;

  // ---------- form booking ----------
  String get pilihTanggal;
  String get pilihJam;
  String get ringkasan;
  String get hariIni;
  List<String> get hariSingkat;
  String get jamTerisiInfo;
  String get tanggal;
  String get jam;
  String get durasi;
  String get total;
  String get menit;
  String get menitSingkat;
  String langkah(int i, int n);
  String get lanjut;
  String get konfirmasiBooking;
  String get bookingBerhasil;
  String bookingBerhasilIsi(
    String layanan,
    String barber,
    String tanggal,
    String jam,
  );
  String get lihatPesanan;
  String get jamBelumTersedia;
  String get cobaTanggalLain;
  String get jadwalSudahDipesan;
  String tanggalSemantics(String label, int hari);

  // ---------- pesanan ----------
  String get gagalMuatPesanan;
  String get belumAdaPesanan;
  String get pesananAkanMuncul;
  String get bookingSekarang;
  String get tidakAdaDiFilter;
  String get cobaStatusLain;
  String get batalkanBookingTanya;
  String jadwalAkanDibatalkan(String layanan, String tanggal, String jam);
  String get yaBatalkan;
  String get bookingDibatalkan;

  // ---------- profil ----------
  String get gagalMuatProfil;
  String get gantiFoto;
  String get nama;
  String get keluar;
  String get keluarTanya;
  String get keluarIsi;
  String get yaKeluar;
  String get fotoMaksimal;
  String get fotoDiperbarui;
  String get fotoSemantics;

  // ---------- dashboard admin ----------
  String get gagalMuatRingkasan;
  String ringkasanBulan(String bulan);
  String get pendapatanBulanIni;
  String get rataRataPerHari;
  String hariAdaTransaksi(int n);
  String get pembagiRataRata;
  String get bookingBulanIni;
  String get semuaStatus;
  String get okupansiHariIni;
  String slotTerisi(int a, int b);
  String get layananTerpopuler;
  String get trenPendapatan;
  String get belumAdaBookingAktif;
  String dariBooking(int a, int b);
  String get porsiSemantics;
  String get bulanLaluBelumAda;
  String get duaBulanKosong;
  String dariBulanLalu(String rupiah);
  String get samaDenganBulanLalu;

  // ---------- admin barber ----------
  String get gagalMuatBarber;
  String get tambahBarber;
  String get tambahkanBarberPertama;
  String get hapusBarberTanya;
  String akanDihapus(String nama);
  String get barberDihapus;
  String get ubahBarber;
  String get barberBaru;
  String get namaField;
  String get namaContohBarber;
  String get spesialisasi;
  String get spesialisasiHint;
  String get namaWajib;
  String get gantiFotoOpsional;
  String get pilihFoto;
  String get tambahBarberAksi;
  String get pilihFotoDulu;

  // ---------- admin layanan ----------
  String get gagalMuatLayanan;
  String get tambahLayanan;
  String get tambahkanLayananPertama;
  String get hapusLayananTanya;
  String get layananDihapus;
  String get ubahLayanan;
  String get layananBaru;
  String get namaLayanan;
  String get namaLayananHint;
  String get hargaRupiah;
  String get hargaHint;
  String get durasiMenit;
  String get durasiHint;
  String get hargaDurasiAngka;

  // ---------- admin booking ----------
  String get gagalMuatBooking;
  String get belumAdaBooking;
  String get bookingCustomerMuncul;
  String get selesaikanTanya;
  String selesaikanIsi(String customer, String tanggal, String jam);
  String get yaSelesaikan;
  String get konfirmasi;
  String get selesai;
  String statusDiubah(String label);

  // ---------- widget ----------
  String jamSemantics(String waktu);
  String jamTerisiSemantics(String waktu);
}

/// Bahasa Indonesia — bawaan aplikasi.
class _BahasaId extends BahasaData {
  const _BahasaId() : super(Bahasa.id);

  @override
  String get kembali => 'Kembali';
  @override
  String get coba => 'Coba lagi';
  @override
  String get muatUlang => 'Muat ulang';
  @override
  String get tampilkanSemua => 'Tampilkan semua';
  @override
  String get batal => 'Batal';
  @override
  String get batalkan => 'Batalkan';
  @override
  String get yaHapus => 'Ya, hapus';
  @override
  String get edit => 'Edit';
  @override
  String get hapus => 'Hapus';
  @override
  String get tambah => 'Tambah';
  @override
  String get pilih => 'Pilih';
  @override
  String get simpanPerubahan => 'Simpan perubahan';
  @override
  String get belumAdaKeterangan => 'Belum ada keterangan.';
  @override
  String get semua => 'Semua';
  @override
  String get customer => 'Customer';
  @override
  String get email => 'Email';
  @override
  String get tampilkanPassword => 'Tampilkan password';
  @override
  String get sembunyikanPassword => 'Sembunyikan password';
  @override
  String get wajibDiisi => 'Wajib diisi.';
  @override
  String get harusAngkaBulat => 'Harus berupa angka bulat.';
  @override
  String get harusLebihDari0 => 'Harus lebih dari 0.';
  @override
  String maksimal(int n) => 'Maksimal $n.';

  @override
  String get beranda => 'Beranda';
  @override
  String get pesanan => 'Pesanan';
  @override
  String get profil => 'Profil';
  @override
  String get barber => 'Barber';
  @override
  String get layanan => 'Layanan';
  @override
  String get booking => 'Booking';
  @override
  String get buatBooking => 'Buat Booking';

  @override
  String get judulDashboard => 'DASHBOARD';
  @override
  String get judulBarber => 'BARBER';
  @override
  String get judulLayanan => 'LAYANAN';
  @override
  String get judulBooking => 'BOOKING';
  @override
  String get judulPesanan => 'PESANAN';
  @override
  String get judulProfil => 'PROFIL';

  @override
  String status(BookingStatus s) => s.label;
  @override
  String peran(UserRole r) => r.label;
  @override
  String get peranLabel => 'Peran';

  @override
  String get gagalMuatData => 'Gagal memuat data';
  @override
  String sapa(String nama) => 'Halo, $nama';
  @override
  String get heroJudul => 'MAU POTONG\nRAMBUT APA HARI INI?';
  @override
  String get belumAdaNotifikasi => 'Belum ada notifikasi.';
  @override
  String get belumAdaLayanan => 'Belum ada layanan';
  @override
  String get adminBelumLayanan => 'Admin belum menambahkan layanan.';
  @override
  String get belumAdaBarber => 'Belum ada barber';
  @override
  String get adminBelumBarber => 'Admin belum menambahkan barber.';
  @override
  String get jadwalBerikutnya => 'JADWAL BERIKUTNYA';
  @override
  String get dataMasihKosong => 'Data layanan atau barber masih kosong!';
  @override
  String get namaFallback => 'Kak';

  @override
  String get pilihTanggal => 'PILIH TANGGAL';
  @override
  String get pilihJam => 'PILIH JAM';
  @override
  String get ringkasan => 'RINGKASAN';
  @override
  String get hariIni => 'Hari ini';
  @override
  List<String> get hariSingkat => const [
        'Sen',
        'Sel',
        'Rab',
        'Kam',
        'Jum',
        'Sab',
        'Min',
      ];
  @override
  String get jamTerisiInfo => 'Jam yang sudah terisi ditandai coret.';
  @override
  String get tanggal => 'Tanggal';
  @override
  String get jam => 'Jam';
  @override
  String get durasi => 'Durasi';
  @override
  String get total => 'Total';
  @override
  String get menit => 'menit';
  @override
  String get menitSingkat => 'mnt';
  @override
  String langkah(int i, int n) => 'LANGKAH $i/$n';
  @override
  String get lanjut => 'Lanjut';
  @override
  String get konfirmasiBooking => 'Konfirmasi Booking';
  @override
  String get bookingBerhasil => 'Booking berhasil';
  @override
  String bookingBerhasilIsi(
    String layanan,
    String barber,
    String tanggal,
    String jam,
  ) =>
      '$layanan bersama $barber pada $tanggal pukul $jam sudah tercatat.';
  @override
  String get lihatPesanan => 'Lihat pesanan';
  @override
  String get jamBelumTersedia => 'Jam belum tersedia';
  @override
  String get cobaTanggalLain => 'Coba pilih tanggal lain.';
  @override
  String get jadwalSudahDipesan =>
      'Jadwal tersebut sudah dipesan, silakan pilih jam lain!';
  @override
  String tanggalSemantics(String label, int hari) => 'Tanggal $label $hari';

  @override
  String get gagalMuatPesanan => 'Gagal memuat pesanan';
  @override
  String get belumAdaPesanan => 'Belum ada pesanan';
  @override
  String get pesananAkanMuncul => 'Booking yang kamu buat akan muncul di sini.';
  @override
  String get bookingSekarang => 'Booking sekarang';
  @override
  String get tidakAdaDiFilter => 'Tidak ada di filter ini';
  @override
  String get cobaStatusLain => 'Coba pilih status lain.';
  @override
  String get batalkanBookingTanya => 'Batalkan booking?';
  @override
  String jadwalAkanDibatalkan(String layanan, String tanggal, String jam) =>
      'Jadwal $layanan pada $tanggal $jam akan dibatalkan.';
  @override
  String get yaBatalkan => 'Ya, batalkan';
  @override
  String get bookingDibatalkan => 'Booking berhasil dibatalkan!';

  @override
  String get gagalMuatProfil => 'Gagal memuat profil';
  @override
  String get gantiFoto => 'Ganti foto';
  @override
  String get nama => 'Nama';
  @override
  String get keluar => 'Keluar';
  @override
  String get keluarTanya => 'Keluar dari akun?';
  @override
  String get keluarIsi => 'Kamu perlu login lagi untuk melihat pesanan.';
  @override
  String get yaKeluar => 'Ya, keluar';
  @override
  String get fotoMaksimal => 'Ukuran foto maksimal 2 MB.';
  @override
  String get fotoDiperbarui => 'Foto profil berhasil diperbarui!';
  @override
  String get fotoSemantics => 'Foto profil, ketuk untuk mengganti';

  @override
  String get gagalMuatRingkasan => 'Gagal memuat ringkasan';
  @override
  String ringkasanBulan(String bulan) => 'Ringkasan $bulan';
  @override
  String get pendapatanBulanIni => 'Pendapatan bulan ini';
  @override
  String get rataRataPerHari => 'Rata-rata per hari';
  @override
  String hariAdaTransaksi(int n) => '$n hari ada transaksi';
  @override
  String get pembagiRataRata => 'pendapatan ÷ hari aktif';
  @override
  String get bookingBulanIni => 'Booking bulan ini';
  @override
  String get semuaStatus => 'semua status';
  @override
  String get okupansiHariIni => 'Okupansi hari ini';
  @override
  String slotTerisi(int a, int b) => '$a dari $b slot';
  @override
  String get layananTerpopuler => 'LAYANAN TERPOPULER';
  @override
  String get trenPendapatan => 'TREN PENDAPATAN';
  @override
  String get belumAdaBookingAktif => 'Belum ada booking aktif bulan ini.';
  @override
  String dariBooking(int a, int b) => '$a dari $b booking';
  @override
  String get porsiSemantics => 'Porsi layanan terpopuler';
  @override
  String get bulanLaluBelumAda => 'bulan lalu belum ada transaksi';
  @override
  String get duaBulanKosong => 'belum ada transaksi bulan ini & bulan lalu';
  @override
  String dariBulanLalu(String rupiah) => 'dari $rupiah bulan lalu';
  @override
  String get samaDenganBulanLalu => 'sama dengan bulan lalu';

  @override
  String get gagalMuatBarber => 'Gagal memuat barber';
  @override
  String get tambahBarber => 'Tambah barber';
  @override
  String get tambahkanBarberPertama =>
      'Tambahkan barber pertama lewat tombol di bawah.';
  @override
  String get hapusBarberTanya => 'Hapus barber?';
  @override
  String akanDihapus(String nama) => '$nama akan dihapus permanen.';
  @override
  String get barberDihapus => 'Barber berhasil dihapus!';
  @override
  String get ubahBarber => 'Ubah barber';
  @override
  String get barberBaru => 'Barber baru';
  @override
  String get namaField => 'Nama';
  @override
  String get namaContohBarber => 'mis. Amba';
  @override
  String get spesialisasi => 'Spesialisasi';
  @override
  String get spesialisasiHint => 'mis. Spesialis fade dan pompadour.';
  @override
  String get namaWajib => 'Nama wajib diisi.';
  @override
  String get gantiFotoOpsional => 'Ganti foto (opsional)';
  @override
  String get pilihFoto => 'Pilih foto';
  @override
  String get tambahBarberAksi => 'Tambah barber';
  @override
  String get pilihFotoDulu => 'Pilih foto barber terlebih dahulu.';

  @override
  String get gagalMuatLayanan => 'Gagal memuat layanan';
  @override
  String get tambahLayanan => 'Tambah layanan';
  @override
  String get tambahkanLayananPertama =>
      'Tambahkan layanan pertama lewat tombol di bawah.';
  @override
  String get hapusLayananTanya => 'Hapus layanan?';
  @override
  String get layananDihapus => 'Layanan berhasil dihapus!';
  @override
  String get ubahLayanan => 'Ubah layanan';
  @override
  String get layananBaru => 'Layanan baru';
  @override
  String get namaLayanan => 'Nama layanan';
  @override
  String get namaLayananHint => 'mis. Haircut + Wash';
  @override
  String get hargaRupiah => 'Harga (rupiah)';
  @override
  String get hargaHint => 'mis. 50000';
  @override
  String get durasiMenit => 'Durasi (menit)';
  @override
  String get durasiHint => 'mis. 45';
  @override
  String get hargaDurasiAngka => 'Harga dan durasi harus berupa angka.';

  @override
  String get gagalMuatBooking => 'Gagal memuat booking';
  @override
  String get belumAdaBooking => 'Belum ada booking';
  @override
  String get bookingCustomerMuncul =>
      'Booking dari customer akan muncul di sini.';
  @override
  String get selesaikanTanya => 'Selesaikan booking?';
  @override
  String selesaikanIsi(String customer, String tanggal, String jam) =>
      'Booking $customer pada $tanggal $jam akan ditandai selesai '
      'dan tidak bisa diubah lagi.';
  @override
  String get yaSelesaikan => 'Ya, selesaikan';
  @override
  String get konfirmasi => 'Konfirmasi';
  @override
  String get selesai => 'Selesai';
  @override
  String statusDiubah(String label) => 'Status diubah menjadi $label.';

  @override
  String jamSemantics(String waktu) => 'Jam $waktu';
  @override
  String jamTerisiSemantics(String waktu) => 'Jam $waktu sudah terisi';
}

/// English.
class _BahasaEn extends BahasaData {
  const _BahasaEn() : super(Bahasa.en);

  @override
  String get kembali => 'Back';
  @override
  String get coba => 'Try again';
  @override
  String get muatUlang => 'Reload';
  @override
  String get tampilkanSemua => 'Show all';
  @override
  String get batal => 'Cancel';
  @override
  String get batalkan => 'Cancel booking';
  @override
  String get yaHapus => 'Yes, delete';
  @override
  String get edit => 'Edit';
  @override
  String get hapus => 'Delete';
  @override
  String get tambah => 'Add';
  @override
  String get pilih => 'Select';
  @override
  String get simpanPerubahan => 'Save changes';
  @override
  String get belumAdaKeterangan => 'No description yet.';
  @override
  String get semua => 'All';
  @override
  String get customer => 'Customer';
  @override
  String get email => 'Email';
  @override
  String get tampilkanPassword => 'Show password';
  @override
  String get sembunyikanPassword => 'Hide password';
  @override
  String get wajibDiisi => 'Required.';
  @override
  String get harusAngkaBulat => 'Must be a whole number.';
  @override
  String get harusLebihDari0 => 'Must be greater than 0.';
  @override
  String maksimal(int n) => 'Maximum $n.';

  @override
  String get beranda => 'Home';
  @override
  String get pesanan => 'Orders';
  @override
  String get profil => 'Profile';
  @override
  String get barber => 'Barbers';
  @override
  String get layanan => 'Services';
  @override
  String get booking => 'Bookings';
  @override
  String get buatBooking => 'Book now';

  @override
  String get judulDashboard => 'DASHBOARD';
  @override
  String get judulBarber => 'BARBERS';
  @override
  String get judulLayanan => 'SERVICES';
  @override
  String get judulBooking => 'BOOKINGS';
  @override
  String get judulPesanan => 'ORDERS';
  @override
  String get judulProfil => 'PROFILE';

  @override
  String status(BookingStatus s) => switch (s) {
        BookingStatus.pending => 'Pending',
        BookingStatus.confirmed => 'Confirmed',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
      };
  @override
  String peran(UserRole r) => r == UserRole.admin ? 'Admin' : 'Customer';
  @override
  String get peranLabel => 'Role';

  @override
  String get gagalMuatData => 'Failed to load data';
  @override
  String sapa(String nama) => 'Hi, $nama';
  @override
  String get heroJudul => 'WHAT HAIRCUT\nDO YOU WANT TODAY?';
  @override
  String get belumAdaNotifikasi => 'No notifications yet.';
  @override
  String get belumAdaLayanan => 'No services yet';
  @override
  String get adminBelumLayanan => 'The admin has not added any services.';
  @override
  String get belumAdaBarber => 'No barbers yet';
  @override
  String get adminBelumBarber => 'The admin has not added any barbers.';
  @override
  String get jadwalBerikutnya => 'NEXT APPOINTMENT';
  @override
  String get dataMasihKosong => 'Service or barber data is still empty!';
  @override
  String get namaFallback => 'there';

  @override
  String get pilihTanggal => 'PICK A DATE';
  @override
  String get pilihJam => 'PICK A TIME';
  @override
  String get ringkasan => 'SUMMARY';
  @override
  String get hariIni => 'Today';
  @override
  List<String> get hariSingkat => const [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];
  @override
  String get jamTerisiInfo => 'Booked times are crossed out.';
  @override
  String get tanggal => 'Date';
  @override
  String get jam => 'Time';
  @override
  String get durasi => 'Duration';
  @override
  String get total => 'Total';
  @override
  String get menit => 'minutes';
  @override
  String get menitSingkat => 'min';
  @override
  String langkah(int i, int n) => 'STEP $i/$n';
  @override
  String get lanjut => 'Next';
  @override
  String get konfirmasiBooking => 'Confirm Booking';
  @override
  String get bookingBerhasil => 'Booking confirmed';
  @override
  String bookingBerhasilIsi(
    String layanan,
    String barber,
    String tanggal,
    String jam,
  ) =>
      '$layanan with $barber on $tanggal at $jam has been recorded.';
  @override
  String get lihatPesanan => 'View order';
  @override
  String get jamBelumTersedia => 'No times available';
  @override
  String get cobaTanggalLain => 'Try another date.';
  @override
  String get jadwalSudahDipesan =>
      'That slot has just been booked, please pick another time!';
  @override
  String tanggalSemantics(String label, int hari) => 'Date $label $hari';

  @override
  String get gagalMuatPesanan => 'Failed to load orders';
  @override
  String get belumAdaPesanan => 'No orders yet';
  @override
  String get pesananAkanMuncul => 'Bookings you make will show up here.';
  @override
  String get bookingSekarang => 'Book now';
  @override
  String get tidakAdaDiFilter => 'Nothing in this filter';
  @override
  String get cobaStatusLain => 'Try another status.';
  @override
  String get batalkanBookingTanya => 'Cancel this booking?';
  @override
  String jadwalAkanDibatalkan(String layanan, String tanggal, String jam) =>
      '$layanan on $tanggal at $jam will be cancelled.';
  @override
  String get yaBatalkan => 'Yes, cancel';
  @override
  String get bookingDibatalkan => 'Booking cancelled!';

  @override
  String get gagalMuatProfil => 'Failed to load profile';
  @override
  String get gantiFoto => 'Change photo';
  @override
  String get nama => 'Name';
  @override
  String get keluar => 'Sign out';
  @override
  String get keluarTanya => 'Sign out of your account?';
  @override
  String get keluarIsi => 'You will need to sign in again to see orders.';
  @override
  String get yaKeluar => 'Yes, sign out';
  @override
  String get fotoMaksimal => 'Photo size is limited to 2 MB.';
  @override
  String get fotoDiperbarui => 'Profile photo updated!';
  @override
  String get fotoSemantics => 'Profile photo, tap to change';

  @override
  String get gagalMuatRingkasan => 'Failed to load summary';
  @override
  String ringkasanBulan(String bulan) => 'Summary of $bulan';
  @override
  String get pendapatanBulanIni => 'Revenue this month';
  @override
  String get rataRataPerHari => 'Daily average';
  @override
  String hariAdaTransaksi(int n) => '$n days with transactions';
  @override
  String get pembagiRataRata => 'revenue ÷ active days';
  @override
  String get bookingBulanIni => 'Bookings this month';
  @override
  String get semuaStatus => 'all statuses';
  @override
  String get okupansiHariIni => "Today's occupancy";
  @override
  String slotTerisi(int a, int b) => '$a of $b slots';
  @override
  String get layananTerpopuler => 'MOST POPULAR SERVICE';
  @override
  String get trenPendapatan => 'REVENUE TREND';
  @override
  String get belumAdaBookingAktif => 'No active bookings this month.';
  @override
  String dariBooking(int a, int b) => '$a of $b bookings';
  @override
  String get porsiSemantics => 'Share of the most popular service';
  @override
  String get bulanLaluBelumAda => 'no transactions last month';
  @override
  String get duaBulanKosong => 'no transactions this month or last month';
  @override
  String dariBulanLalu(String rupiah) => 'from $rupiah last month';
  @override
  String get samaDenganBulanLalu => 'same as last month';

  @override
  String get gagalMuatBarber => 'Failed to load barbers';
  @override
  String get tambahBarber => 'Add barber';
  @override
  String get tambahkanBarberPertama =>
      'Add your first barber using the button below.';
  @override
  String get hapusBarberTanya => 'Delete this barber?';
  @override
  String akanDihapus(String nama) => '$nama will be deleted permanently.';
  @override
  String get barberDihapus => 'Barber deleted!';
  @override
  String get ubahBarber => 'Edit barber';
  @override
  String get barberBaru => 'New barber';
  @override
  String get namaField => 'Name';
  @override
  String get namaContohBarber => 'e.g. Amba';
  @override
  String get spesialisasi => 'Specialty';
  @override
  String get spesialisasiHint => 'e.g. Fade and pompadour specialist.';
  @override
  String get namaWajib => 'Name is required.';
  @override
  String get gantiFotoOpsional => 'Change photo (optional)';
  @override
  String get pilihFoto => 'Choose photo';
  @override
  String get tambahBarberAksi => 'Add barber';
  @override
  String get pilihFotoDulu => 'Choose a barber photo first.';

  @override
  String get gagalMuatLayanan => 'Failed to load services';
  @override
  String get tambahLayanan => 'Add service';
  @override
  String get tambahkanLayananPertama =>
      'Add your first service using the button below.';
  @override
  String get hapusLayananTanya => 'Delete this service?';
  @override
  String get layananDihapus => 'Service deleted!';
  @override
  String get ubahLayanan => 'Edit service';
  @override
  String get layananBaru => 'New service';
  @override
  String get namaLayanan => 'Service name';
  @override
  String get namaLayananHint => 'e.g. Haircut + Wash';
  @override
  String get hargaRupiah => 'Price (rupiah)';
  @override
  String get hargaHint => 'e.g. 50000';
  @override
  String get durasiMenit => 'Duration (minutes)';
  @override
  String get durasiHint => 'e.g. 45';
  @override
  String get hargaDurasiAngka => 'Price and duration must be numbers.';

  @override
  String get gagalMuatBooking => 'Failed to load bookings';
  @override
  String get belumAdaBooking => 'No bookings yet';
  @override
  String get bookingCustomerMuncul => 'Bookings from customers will show up here.';
  @override
  String get selesaikanTanya => 'Complete this booking?';
  @override
  String selesaikanIsi(String customer, String tanggal, String jam) =>
      'Booking for $customer on $tanggal at $jam will be marked complete '
      'and cannot be changed again.';
  @override
  String get yaSelesaikan => 'Yes, complete';
  @override
  String get konfirmasi => 'Confirm';
  @override
  String get selesai => 'Complete';
  @override
  String statusDiubah(String label) => 'Status changed to $label.';

  @override
  String jamSemantics(String waktu) => 'Time $waktu';
  @override
  String jamTerisiSemantics(String waktu) => 'Time $waktu is already booked';
}

const BahasaData bahasaId = _BahasaId();
const BahasaData bahasaEn = _BahasaEn();

/// Ambil tabel teks untuk [bahasa].
BahasaData dataBahasa(Bahasa bahasa) =>
    bahasa == Bahasa.id ? bahasaId : bahasaEn;

/// Bahasa yang sedang dipakai aplikasi.
///
/// `ValueNotifier` (bukan `setState`) supaya seluruh pohon widget ikut
/// dibangun ulang dari satu titik, tanpa setiap halaman perlu tahu.
final ValueNotifier<Bahasa> bahasaAktif = ValueNotifier(Bahasa.id);

/// Ganti bahasa sekaligus locale `DateFormat`.
///
/// Angka rupiah sengaja tidak ikut: mata uangnya tetap rupiah walau
/// antarmuka berbahasa Inggris.
void gantiBahasa(Bahasa baru) {
  if (bahasaAktif.value == baru) return;
  bahasaAktif.value = baru;
  setLocaleFormat(baru.locale.toString());
}

/// Menyediakan [BahasaData] ke seluruh pohon widget.
class L10n extends InheritedWidget {
  const L10n({super.key, required this.data, required super.child});

  final BahasaData data;

  static BahasaData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<L10n>();
    // tanpa L10n (mis. tes widget yang membungkus satu halaman saja)
    // aplikasi tetap berbahasa Indonesia, bukan crash.
    return scope?.data ?? bahasaId;
  }

  @override
  bool updateShouldNotify(L10n oldWidget) => oldWidget.data != data;
}

extension BahasaContext on BuildContext {
  /// `context.bahasa.beranda` → `Beranda` atau `Home`.
  BahasaData get bahasa => L10n.of(this);
}
