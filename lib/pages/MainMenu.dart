import 'package:flutter/material.dart';
import 'package:project/widgets/widget_body/custom_body_mainmenu.dart';
import 'package:project/widgets/custom_bottom_login.dart';
import 'package:project/widgets/widget_title/custom_title_home.dart';
import 'package:project/widgets/widget_appBar/custom_appBar.dart';
import 'package:project/widgets/widget_top_banner/custom_top_banner.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class MainMenuPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // ignore: prefer_const_constructors
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: Column(
        children: [
          Expanded(
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Column(
                children: [
                  CustomCard(),
                  CustomBodyMainMenu(),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      child: const Column(
                        children: [
                          CustomTitle(
                              text:
                                  'HỆ THỐNG QUẢN LÝ \n NGUỒN LỰC DOANH NGHIỆP\n(ERP)'),
                          SizedBox(height: 10),
                          Custombottom(
                              text:
                                  "Hệ thống bao gồm nhiều chức năng quản trị nghiệp vụ/ Dịch vụ của các Tổng công ty/ Công ty/ Đơn vị trực thuộc THILOGI"),
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
