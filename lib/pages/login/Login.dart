import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/login/custom_form_login.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/guess/Guess.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_page_indicator.dart';

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
                          customTitle('DÀNH CHO KHÁCH HÀNG'),
                          SizedBox(height: 20),
                          Container(
                            width: 100.w,
                            color: const Color(0x21428FCA),
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: Column(
                              children: [
                                SizedBox(height: 15),
                                customBottom(
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