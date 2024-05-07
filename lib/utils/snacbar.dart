import 'package:flutter/material.dart';

void openSnacbar(context, snacMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      content: Container(
        alignment: Alignment.centerLeft,
        height: 300,
        child: Text(
          snacMessage,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      action: SnackBarAction(
        label: 'Đồng ý',
        textColor: Colors.blueAccent,
        onPressed: () {},
      ),
    ),
  );
}
