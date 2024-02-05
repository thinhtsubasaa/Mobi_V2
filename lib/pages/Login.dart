import 'package:flutter/material.dart';
import 'package:project/widgets/custom_bottom_login.dart';
import 'package:project/widgets/custom_page_indicator.dart';
import 'package:project/widgets/widget_title/custom_title_login.dart';
import 'package:project/widgets/widget_appBar/custom_appBar.dart';
import 'package:project/widgets/widget_button/custom_button_login.dart';
import 'package:project/widgets/custom_form_login.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class LoginPage extends StatelessWidget {
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
                  CustomLoginForm(),
                  const SizedBox(height: 20),
                  const CustomTitleLogin(text: 'DÀNH CHO KHÁCH HÀNG'),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color:
                          const Color(0x21428FCA), // Đặt màu nền cho phần này
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          const Custombottom(
                              text:
                                  "Tìm hiểu về THILOGI và các Dịch vụ\n Theo dõi Thông tin Đơn hàng"),
                          const SizedBox(height: 30),
                          PageIndicator(
                              currentPage: currentPage, pageCount: pageCount),
                          const SizedBox(height: 20),
                          CustomButtonLogin(onPressed: () {
                            // Handle button press
                          }),
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
