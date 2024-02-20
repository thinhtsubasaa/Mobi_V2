import 'package:flutter/material.dart';
import 'package:project/widgets/widget_body/custom_body_guess.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../config/config.dart';

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

class CustomTitleLogin extends StatelessWidget {
  final String text;

  // ignore: use_key_in_widget_constructors
  const CustomTitleLogin({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF0469B9),
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.17,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  // ignore: overridden_fields
  final Key? key;

  // ignore: prefer_const_constructors_in_immutables
  CustomAppBar({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        AppConfig.appBarImagePath,
        width: 300,
      ),
      centerTitle: false,
    );
  }

  @override
  // ignore: prefer_const_constructors
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  PageIndicator({required this.currentPage, required this.pageCount});

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: pageCount,
      position: currentPage.toDouble(),
      decorator: DotsDecorator(
        size: const Size.square(9.0),
        activeSize: const Size(18.0, 9.0),
        color: Colors.grey, // Màu chấm khi không được chọn
        activeColor: Colors.blue, // Màu chấm khi được chọn
        spacing: const EdgeInsets.all(6.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }
}
