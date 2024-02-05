import 'package:flutter/material.dart';
import 'package:project/widgets/widget_appBar/custom_appBar_QLkhoxe.dart';
import 'package:project/widgets/widget_body/custom_body_NhanXe.dart';
import 'package:project/widgets/widget_tabs/custom_tabs_NhanXe.dart';
import 'package:project/widgets/custom_bottom_login.dart';
import 'package:project/widgets/custom_card_VIN.dart';
import 'package:project/widgets/widget_title/custom_title_home.dart';
import 'package:project/widgets/widget_top_banner/custom_top_banner_QLKhoxe.dart';

// ignore: use_key_in_widget_constructors
class NhanXePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: CustomAppBarQLKhoXe(key: Key('customAppBarQLKhoXe')),
      body: Column(
        children: [
          Expanded(
            // ignore: avoid_unnecessary_containers
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/background.png'), // Đường dẫn đến ảnh nền
                  fit: BoxFit.cover, // Cách ảnh nền sẽ được hiển thị
                ),
              ),
              child: Column(
                children: [
                  CustomCardQLKhoXe(),
                  CustomCardVIN(),
                  CustomTabs(),
                  SizedBox(height: 10),
                  CustomBodyNhanXe(),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: const Column(
                        children: [
                          CustomTitle(text: 'KIỂM TRA - NHẬN XE'),
                          SizedBox(height: 10),
                          Custombottom(
                              text:
                                  "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI,"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
