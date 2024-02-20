import 'dart:ui';
import 'package:flutter/material.dart';

class AppConfig {
  // Colors
  static const Color primaryColor = Color(0xFFA71C20);
  static const Color titleColor = Color.fromARGB(255, 216, 30, 16);
  static const Color buttonColor = Color(0xFFCCCCCC);

  // Constants
  static const double boxWidth = 320;
  static const double boxHeight = 180;
  static const double buttonWidth = 328;
  static const double buttonHeight = 55;
  static const double buttonMainMenuWidth = 140;
  static const double buttonMainMenuHeight = 80;
  static const double buttonTextFontSize = 14;

  // Fonts
  static const TextStyle headerTextStyle = TextStyle(
    fontFamily: 'Myriad Pro',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle buttonTextStyle(Color color) {
    return TextStyle(
      fontFamily: 'Comfortaa',
      fontSize: buttonTextFontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  // Image path
  static const String QLKhoImagePath = 'assets/images/toyota8.png';
  static const String appBarImagePath = 'assets/images/toyota15.png';
  static const String backgroundImagePath = 'assets/images/background.png';
  static const String homeImagePath = 'assets/images/toyota13.png';
  static const String bottomHomeImagePath = 'assets/images/toyota14.png';
}
