// ignore_for_file: prefer_const_constructors_in_immutables, sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';

class HButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double width;
  final String text;

  HButton({Key? key, this.onPressed, this.width = double.infinity, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: 50, width: width),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
