import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/qlkho/custom_body_QLKhoxe.dart';

import 'package:sizer/sizer.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

// ignore: use_key_in_widget_constructors
class QLKhoXePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  Container(
                    width: 100.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppConfig.backgroundImagePath),
                        // Đường dẫn đến ảnh nền
                        fit: BoxFit.cover,
                        // Cách ảnh nền sẽ được hiển thị
                      ),
                    ),
                    child: Column(
                      children: [
                        // CustomCard(),
                        CustomBodyQLKhoXe(),
                        const SizedBox(height: 20),
                        Container(
                          child: Column(
                            children: [
                              customTitle('QUẢN LÝ KHO XE THÀNH PHẨM (WMS)'),
                              SizedBox(height: 10),
                              customBottom(
                                  "Cung cấp ứng dụng quản lý vị trí xe trong bãi; tìm xe, xác nhận vận chuyển, giao xe thành phẩm."),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
