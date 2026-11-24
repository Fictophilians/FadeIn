import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Kepala beranda: blok `ink` gelap dengan sudut bawah membulat.
///
/// Isi: avatar + sapaan + lokasi + lonceng, judul besar Oswald, garis gold,
/// lalu [child] opsional (beranda menaruh kartu jadwal di sini).
///
/// Satu titik gelap di atas supaya beranda punya fokus; sisanya ivory lapang.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    this.photoUrl,
    this.onBellTap,
    this.child,
  });

  final String name;

  /// URL foto profil dari Cloudinary. `null` → `avatar_default.png`.
  final String? photoUrl;

  final VoidCallback? onBellTap;

  /// Isi tambahan di bawah garis gold, masih di dalam blok gelap.
  final Widget? child;

  static const _fallback = 'assets/images/avatar_default.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: ClipOval(child: _foto()),
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
                          style: AppTextTheme.label.copyWith(
                            fontSize: 15,
                            color: AppColors.onDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 13,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                'FadeIn Barbershop',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextTheme.caption.copyWith(
                                  color:
                                      AppColors.onDark.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _TombolLonceng(onTap: onBellTap),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'MAU POTONG\nRAMBUT APA HARI INI?',
                style: AppTextTheme.display.copyWith(
                  fontSize: 28,
                  height: 1.1,
                  color: AppColors.onDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(width: 40, height: 3, color: AppColors.gold),
              if (child != null) ...[
                const SizedBox(height: AppSpacing.lg),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _foto() {
    if (photoUrl == null) {
      return Image.asset(_fallback, width: 44, height: 44, fit: BoxFit.cover);
    }
    return Image.network(
      photoUrl!,
      width: 44,
      height: 44,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          Image.asset(_fallback, width: 44, height: 44, fit: BoxFit.cover),
    );
  }
}

/// Lonceng transparan di kanan atas blok gelap.
class _TombolLonceng extends StatelessWidget {
  const _TombolLonceng({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onDark.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.notifications_none_rounded,
            size: 20,
            color: AppColors.onDark,
          ),
        ),
      ),
    );
  }
}
