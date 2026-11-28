import 'package:fadein_app/constants/app_colors.dart';
import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/utils/bahasa.dart';
import 'package:flutter/material.dart';

/// Input teks sesuai `docs/DESIGN.md` 5.2.
///
/// Tinggi 52, radius 14, fill `surface`, border fokus `gold` 1.5.
/// Password memakai ikon mata untuk toggle.
class FadeInTextField extends StatefulWidget {
  const FadeInTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.error,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;

  /// Pesan error dari luar (mis. hasil validasi submit).
  final String? error;

  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;

  /// Bila diisi, `TextFormField` menampilkan error sendiri.
  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final bool enabled;

  @override
  State<FadeInTextField> createState() => _FadeInTextFieldState();
}

class _FadeInTextFieldState extends State<FadeInTextField> {
  // password: teks tersembunyi secara default
  late bool _tersembunyi = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _tersembunyi,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      style: AppTextTheme.body,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.error,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(
                widget.prefixIcon,
                size: 20,
                color: AppColors.muted,
              ),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _tersembunyi ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: AppColors.muted,
                ),
                tooltip: _tersembunyi
                    ? context.bahasa.tampilkanPassword
                    : context.bahasa.sembunyikanPassword,
                onPressed: () {
                  setState(() => _tersembunyi = !_tersembunyi);
                },
              )
            : null,
      ),
    );
  }
}