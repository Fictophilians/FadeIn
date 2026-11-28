import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:flutter/material.dart';

/// Dialog konfirmasi aksi destruktif — `docs/DESIGN.md` 5.10.
///
/// Dua tombol: Ghost "Batal" di kiri, Danger di kanan.
/// Mengembalikan `true` bila pengguna menekan tombol destruktif.
///
/// Label bawaan mengikuti bahasa aktif; kirim [confirmLabel]/[cancelLabel]
/// hanya bila kalimatnya khusus (mis. "Ya, selesaikan").
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel,
    this.cancelLabel,
  });

  final String title;
  final String? message;
  final String? confirmLabel;
  final String? cancelLabel;

  static Future<bool> tampilkan(
    BuildContext context, {
    required String title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
  }) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
    return hasil ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.bahasa;

    return AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message!),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: FadeInButton(
                label: cancelLabel ?? t.batal,
                variant: FadeInButtonVariant.ghost,
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FadeInButton(
                label: confirmLabel ?? t.yaHapus,
                variant: FadeInButtonVariant.danger,
                onPressed: () => Navigator.pop(context, true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}