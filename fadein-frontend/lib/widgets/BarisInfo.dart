import 'package:fadein_app/constants/theme.dart';
import 'package:flutter/material.dart';

/// Satu baris `label : nilai` untuk ringkasan booking dan detail profil.
///
/// Label punya lebar tetap supaya semua nilai rata di kolom yang sama.
class BarisInfo extends StatelessWidget {
  const BarisInfo({
    super.key,
    required this.label,
    required this.nilai,
    this.lebarLabel = 72,
    this.style,
  });

  final String label;
  final String nilai;
  final double lebarLabel;

  /// Gaya nilai; `null` = [AppTextTheme.body].
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: lebarLabel,
          child: Text(label, style: AppTextTheme.caption),
        ),
        Expanded(
          child: Text(nilai, style: style ?? AppTextTheme.body),
        ),
      ],
    );
  }
}