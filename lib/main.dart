import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/nhanxe/NhanXe2.dart';
import 'package:project/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:project/blocs/app_bloc.dart';
import 'package:project/blocs/user_bloc.dart';
import 'package:project/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
        home: NhanXe2Page(),
      ),
    );
  }
}
