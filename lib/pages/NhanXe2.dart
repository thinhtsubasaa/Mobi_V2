import 'package:flutter/material.dart';
import 'package:project/widgets/widget_appBar/custom_appBar_QLkhoxe.dart';
import 'package:project/widgets/custom_popup_NhanXe.dart';
import 'package:project/widgets/custom_bottom_login.dart';
import 'package:project/widgets/custom_card_VIN.dart';
import 'package:project/widgets/widget_tabs/custom_tabs_NhanXe2.dart';
import 'package:project/widgets/widget_title/custom_title_home.dart';
import 'package:project/widgets/widget_top_banner/custom_top_banner_QLKhoxe.dart';

class NhanXe2Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarQLKhoXe(key: const Key('customAppBarQLKhoXe')),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black
                    .withOpacity(0.8), // Adjust the opacity here for darkness
                BlendMode.srcATop,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CustomCardQLKhoXe(),
                    CustomCardVIN(),
                    CustomTabsTwo(),
                    const SizedBox(height: 20),
                    Expanded(
                      flex: 1,
                      // ignore: avoid_unnecessary_containers
                      child: Container(
                        child: const Column(
                          children: [
                            CustomTitle(text: 'KIỂM TRA - NHẬN XE'),
                            SizedBox(height: 10),
                            Custombottom(
                              text:
                                  "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI,",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Popup
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPopUpNhanXe(),
          ),
        ],
      ),
    );
  }
}
