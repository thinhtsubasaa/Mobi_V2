import 'package:flutter/material.dart';

Widget customTitle(String text) {
  return Padding(
    padding: EdgeInsets.only(left: 20, right: 20),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(255, 216, 30, 16),
        fontFamily: 'Roboto',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.17,
        letterSpacing: 0,
      ),
    ),
  );
}
