import 'package:flutter/material.dart';

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
