import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:flutter/material.dart';

/// Kartu barber — `docs/DESIGN.md` 5.4.
///
/// Dua bentuk:
///
/// - **baris** (default): foto bundar 64, nama, deskripsi, tombol "Pilih".
///   Dipakai form booking.
/// - **potret** (`portrait: true`): foto mengisi kartu 140×190 dengan tirai
///   bawah dan nama di atasnya. Dipakai rail barber di beranda.
class BarberCard extends StatelessWidget {
  const BarberCard({
    super.key,
    required this.name,
    this.description,
    this.photoUrl,
    this.selected = false,
    this.onSelect,
    this.portrait = false,
  });

  final String name;
  final String? description;

  /// URL foto dari Cloudinary. `null` → pakai `avatar_default.png`.
  final String? photoUrl;

  final bool selected;
  final VoidCallback? onSelect;

  /// `true` = kartu potret untuk daftar horizontal.
  final bool portrait;

  static const _fallback = 'assets/images/avatar_default.png';

  /// Foto lokal per nama barber — dipakai kalau `photoUrl` kosong atau gagal
  /// dimuat. Tiga barber seed punya asetnya sendiri, jadi kartu tidak pernah
  /// tampil sebagai avatar kosong saat Cloudinary belum terisi.
  static const _fotoLokal = {
    'amba': 'assets/images/barber_amba.jpg',
    'nasir': 'assets/images/barber_nasir.jpg',
    'rusdi': 'assets/images/barber_rusdi.jpg',
  };

  String get _asetLokal => _fotoLokal[name.toLowerCase()] ?? _fallback;

  static const double lebarPotret = 140;
  static const double tinggiPotret = 190;

  @override
  Widget build(BuildContext context) {
    return portrait ? _potret() : _baris(context);
  }

  Widget _foto({
    required double lebar,
    required double tinggi,
    Alignment alignment = Alignment.center,
  }) {
    final aset = _asetLokal;

    if (photoUrl == null || photoUrl!.isEmpty) {
      return Image.asset(
        aset,
        width: lebar,
        height: tinggi,
        fit: BoxFit.cover,
        alignment: alignment,
      );
    }
    return Image.network(
      photoUrl!,
      width: lebar,
      height: tinggi,
      fit: BoxFit.cover,
      alignment: alignment,
      errorBuilder: (_, _, _) => Image.asset(
        aset,
        width: lebar,
        height: tinggi,
        fit: BoxFit.cover,
        alignment: alignment,
      ),
    );
  }

  Widget _potret() {
    return SizedBox(
      width: lebarPotret,
      height: tinggiPotret,
      child: Material(
        color: AppColors.inkSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _foto(lebar: lebarPotret, tinggi: tinggiPotret),

              // tirai bawah: kontras nama tidak bisa dijamin dari foto acak
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradient.photoScrim),
              ),

              if (selected)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.card),
                    ),
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.gold, width: 2),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTheme.label.copyWith(
                        fontSize: 15,
                        color: AppColors.onDark,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTheme.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.onDark.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _baris(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: selected ? AppColors.gold : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.goldSoft,
                width: 2,
              ),
            ),
            child: ClipOval(
              // potret barber diambil dari dada ke atas; lingkaran 64 harus
              // mengambil bagian kepala, bukan perut
              child: _foto(
                lebar: 64,
                tinggi: 64,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextTheme.label.copyWith(fontSize: 16)),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTheme.caption,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (!selected)
            TextButton(
              onPressed: onSelect,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                textStyle: AppTextTheme.label,
              ),
              child: Text(context.bahasa.pilih),
            )
          else
            const Icon(Icons.check_circle, color: AppColors.gold, size: 24),
        ],
      ),
    );
  }
}
