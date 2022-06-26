// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors

import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class CustomRadioGroupedButton extends StatefulWidget {
  const CustomRadioGroupedButton(
      {Key? key,
      required this.value,
      required this.options,
      required this.onChanged,
      this.useCheckIcon = false,
      this.defaultIcon,
      this.icons})
      : super(key: key);

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool useCheckIcon;
  final Icon? defaultIcon;
  final List<IconData>? icons;

  @override
  _CustomRadioGroupedButtonState createState() =>
      _CustomRadioGroupedButtonState();
}

class _CustomRadioGroupedButtonState extends State<CustomRadioGroupedButton> {
  late String _selected;

  String get value => widget.value;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: widget.options.length,
        itemBuilder: (BuildContext _, int index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selected = widget.options[index];
              });
              widget.onChanged(_selected);
            },
            child: _buildRadioButton(
              value: widget.options[index],
              icon: widget.icons?.elementAt(index),
            ),
          );
        },
      ),
    );
  }

  _buildRadioButton({required String value, IconData? icon}) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: _selected == value && !widget.useCheckIcon
                  ? SECONDARY_COLOR
                  : Colors.grey.shade200,
            ),
            color: _selected == value && !widget.useCheckIcon
                ? SECONDARY_COLOR
                : Colors.transparent,
          ),
          child: Row(
            children: [
              _renderIcon(value, icon),
              SizedBox(width: 2),
              Text(
                value,
                style: TextStyle(
                  color: _selected == value 
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
        _selected == value && widget.useCheckIcon
            ? Positioned(
                right: 1,
                child: Icon(
                  Icons.check_circle,
                  color: SECONDARY_COLOR,
                  size: 18,
                ),
              )
            : SizedBox()
      ],
    );
  }

  _renderIcon(String? value, IconData? icon) {
    if (widget.defaultIcon != null) {
      return widget.defaultIcon;
    } else if (icon != null) {
      return Icon(
        icon,
        color: _selected == value ? Colors.black54 : SECONDARY_COLOR,
        size: 20,
      );
    } else {
      return SizedBox();
    }
  }
}
