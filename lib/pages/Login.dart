import 'package:flutter/material.dart';
import 'package:project/widgets/custom_form_login.dart';
import 'package:project/config/config.dart';
import 'package:project/pages/Guess.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:sizer/sizer.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class LoginPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 100.w,
              child: Column(
                children: [
                  CustomLoginForm(),
                  const SizedBox(height: 20),
                  const CustomTitleLogin(text: 'DÀNH CHO KHÁCH HÀNG'),
                  const SizedBox(height: 20),
                  Container(
                    width: 100.w,
                    height: 55.h,
                    color: const Color(0x21428FCA), // Đặt màu nền cho phần này
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
                ],
              ),
            ),
          ],
        ),
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
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.17,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class CustomButtonLogin extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomButtonLogin({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Call the provided onPressed callback
        onPressed();

        // Navigate to a new screen after the button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GuessPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(AppConfig.buttonWidth, AppConfig.buttonHeight),
        backgroundColor: Color(0xFF428FCA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.all(10),
      ),
      child: Text(
        'TIẾP TỤC',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.16,
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

class Custombottom extends StatelessWidget {
  final String text;

  const Custombottom({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF000000),
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
