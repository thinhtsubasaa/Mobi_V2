import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class CustomCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 460,
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFBC2925),
            Color(0xFFE96327),
          ],
        ),
        // Đặt border radius cho card
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: const Text(
              'Account',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Comfortaa',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.17,
                letterSpacing: 0,
              ),
            ),
          ),
          // ignore: avoid_unnecessary_containers
          Container(
            child: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
