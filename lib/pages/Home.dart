import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/login/Login.dart';
import 'package:sizer/sizer.dart';
import '../utils/next_screen.dart';
import '../widgets/custom_title.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CustomImage(imagePath: AppConfig.homeImagePath),
                ],
              ),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height > 885 ? 30.h : null,
      child: Column(
        children: [
          customTitle('LOGISTIC TRỌN GÓI\nHÀNG ĐẦU MIỀN TRUNG'),
          const SizedBox(height: 10),
          CustomImage(imagePath: AppConfig.bottomHomeImagePath),
          const SizedBox(height: 15),
          CustomButton(onPressed: () {
            nextScreen(context, LoginPage());
          }),
          const SizedBox(height: 10),
        ],
      ),
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
        fixedSize: Size(
            MediaQuery.of(context).size.width * 1.0, AppConfig.buttonHeight),
        backgroundColor: AppConfig.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.all(10),
      ),
      child: Text(
        'WELCOME',
        style: TextStyle(
          color: AppConfig.textButton,
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w600,
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
    );
  }

  @override
  // ignore: prefer_const_constructors
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
