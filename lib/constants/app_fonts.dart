import 'package:flutter/material.dart';
import 'package:project/constants/app_constants.dart';

class AppFonts {
  static const TextStyle headerTextStyle = TextStyle(
    fontFamily: 'Myriad Pro',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle buttonTextStyle(Color color) {
    return TextStyle(
      fontFamily: 'Comfortaa',
      fontSize: AppConstants.buttonTextFontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }
}
