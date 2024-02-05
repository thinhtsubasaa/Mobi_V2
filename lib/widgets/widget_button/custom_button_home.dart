import 'package:flutter/material.dart';
import 'package:project/constants/app_colors.dart';
import 'package:project/constants/app_constants.dart';
import 'package:project/pages/Login.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Call the provided onPressed callback
        onPressed();

        // Navigate to a new screen after the button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(AppConstants.buttonWidth, AppConstants.buttonHeight),
        backgroundColor: AppColors.primaryColor,
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
