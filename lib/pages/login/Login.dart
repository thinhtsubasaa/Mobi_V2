import 'package:flutter/material.dart';
import 'package:Thilogi/pages/login/custom_form_login.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/guess/Guess.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                width: 100.w,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      width: 100.w,
                      child: Column(
                        children: [
                          CustomLoginForm(),
                          SizedBox(height: 20),
                          CustomTitleLogin(text: 'DÀNH CHO KHÁCH HÀNG'),
                          SizedBox(height: 20),
                          Container(
                            width: 100.w,
                            color: const Color(0x21428FCA),
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: Column(
                              children: [
                                SizedBox(height: 15),
                                Custombottom(
                                  text:
                                      "Tìm hiểu về THILOGI và các Dịch vụ Theo dõi Thông tin Đơn hàng",
                                ),
                                SizedBox(height: 30),
                                PageIndicator(
                                  currentPage: currentPage,
                                  pageCount: pageCount,
                                ),
                                SizedBox(height: 20),
                                CustomButtonLogin(onPressed: () {
                                  // Handle button press
                                  nextScreen(context, GuessPage());
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
            ),
          );
        },
      ),
    );
  }
}

class CustomTitleLogin extends StatelessWidget {
  final String text;

  const CustomTitleLogin({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF0469B9),
          fontFamily: 'Roboto',
          fontSize: 20.sp,
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
      onPressed: onPressed,
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
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          height: 1.16,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Key? key;

  const CustomAppBar({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Image.asset(
        AppConfig.appBarImagePath,
      ),
      centerTitle: false,
    );
  }

  @override
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
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF000000),
          fontFamily: 'Roboto',
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
