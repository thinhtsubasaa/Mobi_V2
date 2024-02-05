import 'package:flutter/material.dart';
import 'package:project/widgets/widget_tabs/widget_tabs_item/custom_tabs_item.dart';

class CustomTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        TabItem(
          label: 'Danh sách chờ',
          textColor: const Color(0xFF428FCA),
          backgroundColor: const Color(0xFF7F7F7F),
        ),
        TabItem(
          label: 'Đã nhận trong ngày',
          textColor: const Color(0xFF818180),
          backgroundColor: const Color(0xFFF6C6C7),
        ),
      ],
    );
  }
}
