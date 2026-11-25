import 'dart:typed_data';

import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/models/Barber.dart';
import 'package:fadein_app/pages/ProfilePage.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/pesan.dart';
import 'package:fadein_app/widgets/AksiKecil.dart';
import 'package:fadein_app/widgets/ConfirmDialog.dart';
import 'package:fadein_app/widgets/EmptyState.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Tab Barber untuk admin — `docs/DESIGN.md` 7 nomor 8.
///
/// CRUD penuh. Foto opsional: kalau tidak dipilih, `photo` lama dipertahankan
/// saat edit dan dibiarkan kosong saat tambah (kartu memakai avatar bawaan).
class AdminBarberPage extends StatefulWidget {
  const AdminBarberPage({super.key});

  @override
  State<AdminBarberPage> createState() => AdminBarberPageState();
}

class AdminBarberPageState extends State<AdminBarberPage> {
  List<Barber> barbers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await Apiservice.get('/barbers');

      if (!mounted) return;

      setState(() {
        barbers = (data as List)
            .map((e) => Barber.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        isLoading = false;
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

  Future<void> bukaForm({Barber? barber}) async {
    final berhasil = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormBarber(barber: barber),
    );

    if (berhasil == true) await muatData();
  }

  Future<void> hapus(Barber barber) async {
    final yakin = await ConfirmDialog.tampilkan(
      context,
      title: 'Hapus barber?',
      message: '${barber.name} akan dihapus permanen.',
      confirmLabel: 'Ya, hapus',
    );

    if (!yakin || !mounted) return;

    try {
      await Apiservice.delete('/barbers/${barber.id}');

      if (!mounted) return;

      Pesan.sukses(context, 'Barber berhasil dihapus!');
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
      appBar: AppBar(title: const Text('BARBER')),
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
          title: 'Gagal memuat barber',
          message: error,
          actionLabel: 'Coba lagi',
          onAction: muatData,
        ),
      );
    }

    if (barbers.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.content_cut_outlined,
          title: 'Belum ada barber',
          message: 'Tambahkan barber pertama lewat tombol di bawah.',
          actionLabel: 'Tambah barber',
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
        itemCount: barbers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
        itemBuilder: (_, i) {
          final barber = barbers[i];
          return _BarisBarber(
            barber: barber,
            onEdit: () => bukaForm(barber: barber),
            onHapus: () => hapus(barber),
          );
        },
      ),
    );
  }
}

class _BarisBarber extends StatelessWidget {
  const _BarisBarber({
    required this.barber,
    required this.onEdit,
    required this.onHapus,
  });

  final Barber barber;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  static const _fallback = 'assets/images/avatar_default.png';

  @override
  Widget build(BuildContext context) {
    final adaFoto = barber.photo.isNotEmpty;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: adaFoto
                ? Image.network(
                    barber.photo,
                    width: 56,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      _fallback,
                      width: 56,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    _fallback,
                    width: 56,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.label.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  barber.description ?? 'Belum ada keterangan.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.caption,
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

/// Form tambah/edit barber di dalam bottom sheet.
class _FormBarber extends StatefulWidget {
  const _FormBarber({this.barber});

  final Barber? barber;

  @override
  State<_FormBarber> createState() => _FormBarberState();
}

class _FormBarberState extends State<_FormBarber> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _deskripsi;

  Uint8List? _fotoBaru;
  String? _namaFoto;
  bool _menyimpan = false;

  bool get _modeEdit => widget.barber != null;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.barber?.name ?? '');
    _deskripsi = TextEditingController(text: widget.barber?.description ?? '');
  }

  @override
  void dispose() {
    _nama.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final berkas = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );

    if (berkas == null) return;

    final bytes = await berkas.readAsBytes();

    if (!mounted) return;

    if (bytes.length > ProfilePage.batasUkuran) {
      Pesan.gagal(context, 'Ukuran foto maksimal 2 MB.');
      return;
    }

    setState(() {
      _fotoBaru = bytes;
      _namaFoto = berkas.name;
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    // backend mewajibkan foto saat membuat barber baru
    if (!_modeEdit && _fotoBaru == null) {
      Pesan.gagal(context, 'Pilih foto barber terlebih dahulu.');
      return;
    }

    setState(() => _menyimpan = true);

    try {
      final nama = _nama.text.trim();
      final deskripsi = _deskripsi.text.trim();

      if (_fotoBaru == null) {
        // tanpa foto: JSON biasa, field foto tidak disentuh
        if (_modeEdit) {
          await Apiservice.put('/barbers/${widget.barber!.id}', {
            'name': nama,
            'description': deskripsi,
          });
        } else {
          await Apiservice.post('/barbers', {
            'name': nama,
            'description': deskripsi,
          });
        }
      } else {
        // dengan foto: multipart, field teks ikut dikirim sebagai `fields`
        final endpoint =
            _modeEdit ? '/barbers/${widget.barber!.id}' : '/barbers';
        await Apiservice.upload(
          endpoint,
          _fotoBaru!,
          filename: _namaFoto ?? 'barber.jpg',
          method: _modeEdit ? 'PUT' : 'POST',
          fields: {'name': nama, 'description': deskripsi},
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
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
                _modeEdit ? 'Ubah barber' : 'Barber baru',
                style: AppTextTheme.display.copyWith(fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nama,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'mis. Amba',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _deskripsi,
                maxLines: 3,
                maxLength: 255,
                decoration: const InputDecoration(
                  labelText: 'Spesialisasi',
                  hintText: 'mis. Spesialis fade dan pompadour.',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              FadeInButton(
                label: _fotoBaru != null
                    ? 'Ganti foto'
                    : (_modeEdit ? 'Ganti foto (opsional)' : 'Pilih foto'),
                icon: Icons.photo_camera_outlined,
                variant: FadeInButtonVariant.ghost,
                onPressed: _menyimpan ? null : _pilihFoto,
              ),
              if (_fotoBaru != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.memory(
                      _fotoBaru!,
                      width: 72,
                      height: 92,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              FadeInButton(
                label: _modeEdit ? 'Simpan perubahan' : 'Tambah barber',
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
