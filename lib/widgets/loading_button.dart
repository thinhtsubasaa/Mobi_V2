import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

Widget loadingButton(
    context, controller, action, title, valueColor, textColor) {
  return RoundedLoadingButton(
    animateOnTap: true,
    controller: controller,
    onPressed: () => action(),
    width: MediaQuery.of(context).size.width * 1.0,
    color: Colors.white,
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
            color: textColor,
          ),
        ).tr()
      ],
    ),
  );
}
