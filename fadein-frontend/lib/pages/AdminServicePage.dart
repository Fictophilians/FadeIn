import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Service.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/AksiKecil.dart';
import 'package:fadein_app/widgets/ConfirmDialog.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:flutter/material.dart';

/// Tab Layanan untuk admin — `docs/DESIGN.md` 7 nomor 9.
///
/// Tabel `services` tidak punya kolom foto dan deskripsi, jadi form hanya
/// berisi nama, harga, dan durasi.
class AdminServicePage extends StatefulWidget {
  const AdminServicePage({super.key});

  @override
  State<AdminServicePage> createState() => AdminServicePageState();
}

class AdminServicePageState extends State<AdminServicePage> {
  List<Service> services = [];
  bool isLoading = true;
  bool _pernahMuat = false;
  String? error;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    // Spinner penuh hanya pada muat pertama atau setelah gagal; refresh
    // mempertahankan daftar lama supaya layar tidak berkedip kosong.
    final tampilkanSpinner = !_pernahMuat || error != null;

    setState(() {
      if (tampilkanSpinner) isLoading = true;
      error = null;
    });

    try {
      final data = await Apiservice.get('/services');

      if (!mounted) return;

      setState(() {
        services = (data as List)
            .map((e) => Service.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        isLoading = false;
        _pernahMuat = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '$e';
        isLoading = false;
      });
    }
  }

  Future<void> bukaForm({Service? service}) async {
    final berhasil = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormLayanan(service: service),
    );

    if (berhasil == true) await muatData();
  }

  Future<void> hapus(Service service) async {
    final yakin = await ConfirmDialog.tampilkan(
      context,
      title: 'Hapus layanan?',
      message: '${service.name} akan dihapus permanen.',
      confirmLabel: 'Ya, hapus',
    );

    if (!yakin || !mounted) return;

    try {
      await Apiservice.delete('/services/${service.id}');

      if (!mounted) return;

      Pesan.sukses(context, 'Layanan berhasil dihapus!');
      await muatData();
    } on ApiException catch (e) {
      if (!mounted) return;
      Pesan.gagal(context, e.message);
    } catch (e) {
      if (!mounted) return;
      Pesan.gagal(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('LAYANAN')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => bukaForm(),
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.onDark,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: _isi(),
    );
  }

  Widget _isi() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Gagal memuat layanan',
          message: error,
          actionLabel: 'Coba lagi',
          onAction: muatData,
        ),
      );
    }

    if (services.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.design_services_outlined,
          title: 'Belum ada layanan',
          message: 'Tambahkan layanan pertama lewat tombol di bawah.',
          actionLabel: 'Tambah layanan',
          onAction: () => bukaForm(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: muatData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.md,
          AppSpacing.screenH,
          96,
        ),
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (_, i) {
          final service = services[i];
          return _BarisLayanan(
            service: service,
            nomor: '${i + 1}'.padLeft(2, '0'),
            onEdit: () => bukaForm(service: service),
            onHapus: () => hapus(service),
          );
        },
      ),
    );
  }
}

class _BarisLayanan extends StatelessWidget {
  const _BarisLayanan({
    required this.service,
    required this.nomor,
    required this.onEdit,
    required this.onHapus,
  });

  final Service service;
  final String nomor;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nomor,
            style: AppTextTheme.display.copyWith(
              fontSize: 18,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.label.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '${service.duration} menit',
                  style: AppTextTheme.caption,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  formatRupiah(service.price),
                  style: AppTextTheme.price,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    AksiKecil(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onTap: onEdit,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AksiKecil(
                      icon: Icons.delete_outline,
                      label: 'Hapus',
                      danger: true,
                      onTap: onHapus,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Form tambah/edit layanan di dalam bottom sheet.
class _FormLayanan extends StatefulWidget {
  const _FormLayanan({this.service});

  final Service? service;

  @override
  State<_FormLayanan> createState() => _FormLayananState();
}

class _FormLayananState extends State<_FormLayanan> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _harga;
  late final TextEditingController _durasi;

  bool _menyimpan = false;

  bool get _modeEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.service?.name ?? '');
    _harga = TextEditingController(
      text: widget.service == null ? '' : '${widget.service!.price}',
    );
    _durasi = TextEditingController(
      text: widget.service == null ? '' : '${widget.service!.duration}',
    );
  }

  @override
  void dispose() {
    _nama.dispose();
    _harga.dispose();
    _durasi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);

    try {
      final data = {
        'name': _nama.text.trim(),
        'price': int.parse(_harga.text.trim()),
        'duration': int.parse(_durasi.text.trim()),
      };

      if (_modeEdit) {
        await Apiservice.put('/services/${widget.service!.id}', data);
      } else {
        await Apiservice.post('/services', data);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FormatException {
      // jaring pengaman: validator sudah menahan, tapi kalau lolos jangan
      // sampai layar crash tanpa pesan
      if (!mounted) return;
      setState(() => _menyimpan = false);
      Pesan.gagal(context, 'Harga dan durasi harus berupa angka.');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      Pesan.gagal(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      Pesan.gagal(context, '$e');
    }
  }

  /// Validasi angka bulat lebih dari 0 — aturan yang sama dengan backend.
  String? _validasiAngka(String? v, {int batasAtas = 0}) {
    final teks = (v ?? '').trim();
    if (teks.isEmpty) return 'Wajib diisi.';

    final angka = int.tryParse(teks);
    if (angka == null) return 'Harus berupa angka bulat.';
    if (angka <= 0) return 'Harus lebih dari 0.';
    if (batasAtas > 0 && angka > batasAtas) return 'Maksimal $batasAtas.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.lg,
          AppSpacing.screenH,
          AppSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _modeEdit ? 'Ubah layanan' : 'Layanan baru',
                style: AppTextTheme.display.copyWith(fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nama,
                textInputAction: TextInputAction.next,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Nama layanan',
                  hintText: 'mis. Haircut + Wash',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _harga,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Harga (rupiah)',
                  hintText: 'mis. 50000',
                  prefixText: 'Rp ',
                ),
                validator: (v) => _validasiAngka(v, batasAtas: 100000000),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _durasi,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Durasi (menit)',
                  hintText: 'mis. 45',
                ),
                validator: (v) => _validasiAngka(v, batasAtas: 600),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeInButton(
                label: _modeEdit ? 'Simpan perubahan' : 'Tambah layanan',
                isLoading: _menyimpan,
                onPressed: _menyimpan ? null : _simpan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
