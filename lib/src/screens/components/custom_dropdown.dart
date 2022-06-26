// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> dropdownMenuItemList;
  final ValueChanged<T?>? onChanged;
  final T value;
  final bool isEnabled;
  CustomDropdown({
    Key? key,
    required this.dropdownMenuItemList,
    required this.onChanged,
    required this.value,
    this.isEnabled = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(left: 15.0, right: 10.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          color: isEnabled ? Colors.white : Colors.grey.withAlpha(100),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            itemHeight: 50.0,
            style: F_18,
            items: dropdownMenuItemList,
            onChanged: onChanged,
            value: value,
          ),
        ),
      ),
    );
  }
}
