import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  double height = 200;
  LoadingWidget({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      padding: const EdgeInsets.all(20),
      height: height,
      child: Center(
        child: LoadingAnimationWidget.twistingDots(
          leftDotColor: const Color.fromARGB(197, 1, 100, 198),
          rightDotColor: const Color.fromARGB(255, 229, 229, 25),
          size: 30,
        ),
      ),
    );
  }
}
