import 'package:flutter/material.dart';
import 'package:project/constants/app_constants.dart';
import 'package:project/pages/Guess.dart';

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
        fixedSize: Size(AppConstants.buttonWidth, AppConstants.buttonHeight),
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
