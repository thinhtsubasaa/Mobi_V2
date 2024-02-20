import 'package:flutter/material.dart';
import 'package:project/config/config.dart';
import 'package:project/widgets/custom_page_indicator.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyMainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
          // ignore: prefer_const_constructors
          color: Color.fromRGBO(246, 198, 199, 0.2), // Đặt màu nền cho phần này
          child: BodyMainMenu()),
    );
  }
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class BodyMainMenu extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/images/toyota7.png',
                  width: AppConfig.buttonMainMenuWidth,
                  height: AppConfig.buttonMainMenuHeight,
                ),
                const SizedBox(
                  child: Text(
                    "QUẢN LÝ KHO XE\n THÀNH PHẨM",
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 13 / 12,
                      letterSpacing: 0,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const CustomButton(
                width: AppConfig.buttonMainMenuWidth,
                height: AppConfig.buttonMainMenuHeight,
                color: AppConfig.buttonColor),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButton(
                width: AppConfig.buttonMainMenuWidth,
                height: AppConfig.buttonMainMenuHeight,
                color: AppConfig.buttonColor),
            CustomButton(
                width: AppConfig.buttonMainMenuWidth,
                height: AppConfig.buttonMainMenuHeight,
                color: AppConfig.buttonColor),
          ],
        ),
        const SizedBox(height: 30),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButton(
                width: AppConfig.buttonMainMenuWidth,
                height: AppConfig.buttonMainMenuHeight,
                color: AppConfig.buttonColor),
            CustomButton(
                width: AppConfig.buttonMainMenuWidth,
                height: AppConfig.buttonMainMenuHeight,
                color: AppConfig.buttonColor),
          ],
        ),
        const SizedBox(height: 30),
        PageIndicator(currentPage: currentPage, pageCount: pageCount),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  // ignore: use_key_in_widget_constructors
  const CustomButton({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color,
    );
  }
}
