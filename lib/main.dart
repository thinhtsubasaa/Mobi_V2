import 'package:flutter/material.dart';
import 'package:project/pages/TrackingXe_TrangThai.dart';
// import 'package:project/pages/MainMenu.dart';
// import 'package:project/pages/Guess.dart';
// import 'package:project/pages/Login.dart';
import 'package:project/pages/NhanXe.dart';
import 'package:project/pages/NhanXe2.dart';
import 'package:project/pages/TrackingXe_Vitri.dart';
import 'package:project/widgets/widget_body/map.dart';
import 'package:project/pages/home.dart';
// import 'package:project/pages/MainMenu.dart';
// import 'package:project/pages/QLKhoXe.dart';

void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
