import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

<<<<<<< HEAD
=======
import '../config/config.dart';

>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
Widget loadingButton(
    context, controller, action, title, valueColor, textColor) {
  return RoundedLoadingButton(
    animateOnTap: true,
    controller: controller,
    onPressed: () => action(),
    width: MediaQuery.of(context).size.width * 1.0,
<<<<<<< HEAD
    color: Colors.white,
=======
    color: AppConfig.primaryColor,
>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
    valueColor: valueColor,
    borderRadius: 10,
    elevation: 0,
    child: Wrap(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
<<<<<<< HEAD
            color: textColor,
=======
            color: AppConfig.textButton,
>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
          ),
        ).tr()
      ],
    ),
  );
}
