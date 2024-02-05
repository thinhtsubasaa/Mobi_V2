import 'package:flutter/material.dart';
import 'package:project/widgets/widget_appBar/custom_appBar.dart';
import 'package:project/widgets/widget_body/custom_body_guess.dart';
import 'package:project/widgets/custom_page_indicator.dart';
import 'package:project/widgets/widget_title/custom_title_login.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class GuessPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: Column(
        children: [
          Expanded(
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Column(
                children: [
                  CustomBodyGuess(),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const CustomTitleLogin(
                              text: 'THÔNG TIN DỊCH VỤ\n DÀNH CHO KHÁCH HÀNG'),
                          SizedBox(height: 10),
                          Text("......"),
                          const SizedBox(height: 50),
                          PageIndicator(
                              currentPage: currentPage, pageCount: pageCount),
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
