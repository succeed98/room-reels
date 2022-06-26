import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class HTextFormField extends StatelessWidget {
  HTextFormField({
    Key? key,
    this.onChanged,
    this.iconData,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.validator,
  }) : super(key: key);

  final ValueChanged<String>? onChanged;
  final IconData? iconData;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        focusedBorder: border,
        border: border,
        prefixIcon: Icon(iconData, color: DARK.withOpacity(0.5)),
        hintStyle: TextStyle(color: DARK.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
      ),
    );
  }
}
