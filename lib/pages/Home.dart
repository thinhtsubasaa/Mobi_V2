import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/login/Login.dart';
import 'package:sizer/sizer.dart';
import '../utils/next_screen.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: ListView(
        children: [
          CustomImage(imagePath: AppConfig.homeImagePath),
          const SizedBox(height: 5),
          customTitle('LOGISTIC TRỌN GÓI\n HÀNG ĐẦU MIỀN TRUNG'),
          const SizedBox(height: 5),
          CustomImage(imagePath: AppConfig.bottomHomeImagePath),
          const SizedBox(
              height: 65), // Khoảng cách để làm cho nút không che phần body
          // Thêm khoảng cách tương ứng với chiều cao của nút
        ],
      ),
      floatingActionButton: CustomButton(onPressed: () {
        nextScreen(context, LoginPage());
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class CustomImage extends StatelessWidget {
  final String imagePath;

  const CustomImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
    );
  }
}

Widget customTitle(String text) {
  return Padding(
    padding: EdgeInsets.only(left: 20, right: 20),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(255, 216, 30, 16),
        fontFamily: 'Roboto',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.17,
        letterSpacing: 0,
      ),
    ),
  );
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        nextScreen(context, LoginPage());
      },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(AppConfig.buttonWidth, AppConfig.buttonHeight),
        backgroundColor: AppConfig.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.all(10),
      ),
      child: Text(
        'WELCOME',
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
      ),
      centerTitle: false,
    );
  }

  @override
  // ignore: prefer_const_constructors
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
