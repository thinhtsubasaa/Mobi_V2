import 'package:flutter/material.dart';
import 'package:project/widgets/widget_title/custom_title_home.dart';
import 'package:project/widgets/widget_appBar/custom_appBar.dart';
import 'package:project/widgets/widget_button/custom_button_home.dart';
import 'package:project/widgets/custom_image_home.dart';

// ignore: use_key_in_widget_constructors
class MyHomePage extends StatelessWidget {
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
                  const CustomImage(imagePath: 'assets/images/toyota13.png'),
                  const SizedBox(height: 10),
                  const CustomTitle(
                      text: 'LOGISTIC TRỌN GÓI\n HÀNG ĐẦU MIỀN TRUNG'),
                  const SizedBox(height: 10),
                  const CustomImage(imagePath: 'assets/images/toyota14.png'),
                  const SizedBox(height: 15),
                  CustomButton(onPressed: () {
                    // Handle button press
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
