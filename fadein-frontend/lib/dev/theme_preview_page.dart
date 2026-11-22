import 'package:flutter/material.dart';

import '../core/tokens.dart';

/// Halaman pratinjau tema — hanya untuk QA visual, bukan bagian alur aplikasi.
///
/// Dipakai selama pengembangan untuk memastikan token `docs/DESIGN.md` tampil
/// benar di perangkat. Tidak dirujuk oleh alur Splash/Login.
class ThemePreviewPage extends StatelessWidget {
  const ThemePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FADEIN')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.lg,
          AppSpacing.screenH,
          AppSpacing.xxl,
        ),
        children: [
          Text('PREVIEW TEMA', style: AppTextTheme.display),
          const SizedBox(height: AppSpacing.xs),
          Text('Ivory & Ink · Oswald + Inter', style: AppTextTheme.caption),

          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle('WARNA'),
          const _PaletteGrid(),

          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle('TIPE'),
          Text('Judul layar — Oswald 600 / 26', style: AppTextTheme.display),
          const SizedBox(height: AppSpacing.sm),
          Text('JUDUL SECTION', style: AppTextTheme.section),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Body Inter 400 / 15. Dipakai untuk paragraf dan keterangan '
            'panjang di dalam aplikasi.',
            style: AppTextTheme.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Caption Inter 400 / 13 — teks sekunder.',
            style: AppTextTheme.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Rp50.000', style: AppTextTheme.price),

          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle('KOMPONEN'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Booking Sekarang'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Lihat Layanan'),
              ),
              const ElevatedButton(
                onPressed: null,
                child: Text('Nonaktif'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nama lengkap',
              hintText: 'Mis. Budi Santoso',
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Haircut + Wash',
                          style: AppTextTheme.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text('45 menit', style: AppTextTheme.caption),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rp50.000', style: AppTextTheme.price),
                      const SizedBox(height: AppSpacing.xxs),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _StatusBadge(
                label: 'Menunggu',
                fg: AppStatusColors.pendingFg,
                bg: AppStatusColors.pendingBg,
              ),
              _StatusBadge(
                label: 'Dikonfirmasi',
                fg: AppStatusColors.confirmedFg,
                bg: AppStatusColors.confirmedBg,
              ),
              _StatusBadge(
                label: 'Selesai',
                fg: AppStatusColors.completedFg,
                bg: AppStatusColors.completedBg,
              ),
              _StatusBadge(
                label: 'Dibatalkan',
                fg: AppStatusColors.cancelledFg,
                bg: AppStatusColors.cancelledBg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTextTheme.section),
    );
  }
}

class _PaletteGrid extends StatelessWidget {
  const _PaletteGrid();

  static const _swatches = <(String, Color)>[
    ('bg', AppColors.bg),
    ('surface', AppColors.surface),
    ('ink', AppColors.ink),
    ('inkSoft', AppColors.inkSoft),
    ('gold', AppColors.gold),
    ('goldSoft', AppColors.goldSoft),
    ('muted', AppColors.muted),
    ('border', AppColors.border),
    ('success', AppColors.success),
    ('warning', AppColors.warning),
    ('info', AppColors.info),
    ('danger', AppColors.danger),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (name, color) in _swatches) _Swatch(name, color),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(name, style: AppTextTheme.caption),
        ],
      ),
    );
  }
}

/// Pratinjau badge status. Komponen produksi dibuat di T7.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextTheme.caption.copyWith(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
