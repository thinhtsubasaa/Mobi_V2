import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const TabItem({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        Container(
          width: 150,
          height: 3,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}
