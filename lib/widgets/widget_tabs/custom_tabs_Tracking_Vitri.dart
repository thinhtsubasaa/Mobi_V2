import 'package:flutter/material.dart';
import 'package:project/widgets/widget_tabs/widget_tabs_item/custom_tabs_item.dart';

// ignore: use_key_in_widget_constructors
class CustomTabsTrackingVitri extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TabsNhanXeTracking(),
    );
  }
}

class TabsNhanXeTracking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TabItem(
          label: 'Trạng thái vận chuyển',
          textColor: const Color(0xFF818180),
          backgroundColor: const Color(0xFF7F7F7F),
        ),
        TabItem(
          label: 'Vị trí trên đường',
          textColor: const Color(0xFF428FCA),
          backgroundColor: const Color(0xFFF6C6C7),
        ),
      ],
    );
  }
}
