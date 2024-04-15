import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:Thilogi/widgets/custom_page_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyMainMenu extends StatefulWidget {
  @override
  _CustomBodyMainMenuState createState() => _CustomBodyMainMenuState();
}

class _CustomBodyMainMenuState extends State<CustomBodyMainMenu> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : Container(
            width: 100.w,
            color: Color.fromRGBO(246, 198, 199, 0.2),
            child: BodyMainMenu(onNextScreen: () {
              setState(() {
                _loading = true;
              });
              // Navigate to the next screen
              nextScreen(context, QLKhoXePage(
                resetLoadingState: () {
                  setState(() {
                    _loading = true;
                  });
                },
              ));
            }),
          );
  }
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class BodyMainMenu extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  final VoidCallback onNextScreen;
  BodyMainMenu({required this.onNextScreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: onNextScreen,
                    icon: Image.asset(
                      'assets/images/toyota7.png',
                      width: AppConfig.buttonMainMenuWidth,
                      height: AppConfig.buttonMainMenuHeight,
                    ),
                    iconSize: AppConfig
                        .buttonMainMenuWidth, // Kích thước của biểu tượng
                    padding:
                        EdgeInsets.zero, // Xóa padding mặc định của IconButton
                    alignment:
                        Alignment.center, // Căn chỉnh hình ảnh vào giữa nút
                  ),
                  const SizedBox(
                    child: Text(
                      "QUẢN LÝ KHO XE\n THÀNH PHẨM",
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const CustomButton(
                  width: AppConfig.buttonMainMenuWidth,
                  height: AppConfig.buttonMainMenuHeight,
                  color: AppConfig.buttonColorMenu),
            ],
          ),
          const SizedBox(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                  width: AppConfig.buttonMainMenuWidth,
                  height: AppConfig.buttonMainMenuHeight,
                  color: AppConfig.buttonColorMenu),
              CustomButton(
                  width: AppConfig.buttonMainMenuWidth,
                  height: AppConfig.buttonMainMenuHeight,
                  color: AppConfig.buttonColorMenu),
            ],
          ),
          const SizedBox(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                  width: AppConfig.buttonMainMenuWidth,
                  height: AppConfig.buttonMainMenuHeight,
                  color: AppConfig.buttonColorMenu),
              CustomButton(
                  width: AppConfig.buttonMainMenuWidth,
                  height: AppConfig.buttonMainMenuHeight,
                  color: AppConfig.buttonColorMenu),
            ],
          ),
          const SizedBox(height: 30),
          PageIndicator(currentPage: currentPage, pageCount: pageCount),
        ],
      ),
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
