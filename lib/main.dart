import 'package:flutter/material.dart';
import 'package:project/pages/Home.dart';
import 'package:project/pages/MainMenu.dart';
import 'package:project/pages/nhanxe/NhanXe.dart';
import 'package:project/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:project/blocs/app_bloc.dart';
import 'package:project/blocs/user_bloc.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MultiProvider(
        providers: [
          ChangeNotifierProvider<AppBloc>(
            create: (context) => AppBloc(),
          ),
          ChangeNotifierProvider<UserBloc>(
            create: (context) => UserBloc(),
          ),
          ChangeNotifierProvider<AuthService>(
            create: (context) => AuthService(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(),
        ),
      ),
    );
  }
}
