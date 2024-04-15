import 'package:flutter/material.dart';

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (builder) => page));
}

<<<<<<< HEAD
=======
void backScreen(context, page) {
  Navigator.pop(context, MaterialPageRoute(builder: (builder) => page));
}

>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
void nextScreenCloseOthers(context, page) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (builder) => page),
    (route) => false,
  );
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (builder) => page),
  );
}

void nextScreenPopup(context, page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (builder) => page, fullscreenDialog: true),
  );
}
