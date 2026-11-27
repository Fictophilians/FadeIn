import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:flutter/material.dart';

/// Dialog konfirmasi aksi destruktif — `docs/DESIGN.md` 5.10.
///
/// Dua tombol: Ghost "Batal" di kiri, Danger di kanan.
/// Mengembalikan `true` bila pengguna menekan tombol destruktif.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = 'Ya, hapus',
    this.cancelLabel = 'Batal',
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;

  static Future<bool> tampilkan(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Ya, hapus',
    String cancelLabel = 'Batal',
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
                label: cancelLabel,
                variant: FadeInButtonVariant.ghost,
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FadeInButton(
                label: confirmLabel,
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