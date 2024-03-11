import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class CustomTabsTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      // ignore: prefer_const_constructors
      child: TabsNhanXe(),
    );
  }
}

class TabsNhanXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tab 1
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Danh sách chờ',
                style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.14, // Corresponds to line-height of 16px
                    letterSpacing: 0,
                    color: Color(0xFF818180) // Màu chữ
                    ),
              ),
            ),
            Container(
              width: 160,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF7F7F7F),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),

        // Tab 2
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Đã nhận trong ngày',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.14, // Corresponds to line-height of 16px
                  letterSpacing: 0,
                  color: Color(0xFF428FCA), // Màu chữ
                ),
              ),
            ),
            Container(
              width: 160,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFF6C6C7),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
