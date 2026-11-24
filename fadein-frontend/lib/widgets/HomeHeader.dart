import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Header beranda: avatar, sapaan, dan tombol notifikasi.
///
/// ```dart
/// HomeHeader(name: 'Budi', photoUrl: user.photo, onBellTap: ...)
/// ```
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    this.photoUrl,
    this.onBellTap,
  });

  final String name;

  /// URL foto profil dari Cloudinary. `null` → `avatar_default.png`.
  final String? photoUrl;

  final VoidCallback? onBellTap;

  static const _fallback = 'assets/images/avatar_default.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: photoUrl == null
              ? Image.asset(_fallback, width: 48, height: 48, fit: BoxFit.cover)
              : Image.network(
                  photoUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    _fallback,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextTheme.label.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 13,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      'FadeIn Barbershop',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTheme.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onBellTap,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.notifications_none_rounded,
                size: 22,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
