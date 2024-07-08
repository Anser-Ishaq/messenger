import 'package:flutter/material.dart';

class CustomTextformfield extends StatelessWidget {
  const CustomTextformfield({
    super.key,
    required this.label,
    this.obscureText = false,
    required this.onSaved,
    required this.height,
    this.suffixIcon,
    this.onIconTap,
  })  : assert((suffixIcon != null && onIconTap != null) || (suffixIcon == null && onIconTap == null),
              'suffixIcon and onIconTap should be either both non-null or both null');

  final double height;
  final String label;
  final bool obscureText;
  final void Function(String?) onSaved;
  final Icon? suffixIcon;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        obscureText: obscureText,
        decoration: InputDecoration(
          label: Text(label),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onIconTap,
                  child: suffixIcon,
                )
              : null,
        ),
        onSaved: onSaved,
      ),
    );
  }
}
