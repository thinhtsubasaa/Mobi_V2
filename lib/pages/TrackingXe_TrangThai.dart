import 'package:flutter/material.dart';
import 'package:project/widgets/widget_appBar/custom_appBar_QLkhoxe.dart';
import 'package:project/widgets/widget_body/custom_body_trackingxe.dart';
import 'package:project/widgets/custom_bottom_login.dart';
import 'package:project/widgets/custom_card_VIN.dart';
import 'package:project/widgets/widget_tabs/custom_tabs_TrackingXe_TrangThai.dart';
import 'package:project/widgets/widget_title/custom_title_home.dart';
import 'package:project/widgets/widget_top_banner/custom_top_banner_QLKhoxe.dart';

// ignore: use_key_in_widget_constructors
class TrackingXePage extends StatelessWidget {
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
                  SizedBox(height: 10),
                  CustomTabsTracking(),
                  SizedBox(height: 10),
                  CustomTrackingXe(),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: const Column(
                        children: [
                          CustomTitle(text: 'TRACKING XE THÀNH PHẨM'),
                          SizedBox(height: 10),
                          Custombottom(
                              text:
                                  "Tìm kiếm xe theo Đơn hàng/ Số VIN\n Theo dõi vị trí xe trong quá trình vận chuyển giao xe"),
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
