import 'package:flutter/material.dart';

class HTextArea extends StatelessWidget {
  HTextArea({
    Key? key,
    required this.onChanged,
    required this.text,
  }) : super(key: key);

  final ValueChanged<String>? onChanged;
  final String text;

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlignVertical: TextAlignVertical.top,
      minLines: 4,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      onChanged: onChanged,
      decoration: InputDecoration(
        focusedBorder: border,
        border: border,
        hintStyle: TextStyle(color: const Color(0xff121212).withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white,
        hintText: text,
        labelText: text,
      ),
    );
  }
}
