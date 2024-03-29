import 'package:Thilogi/blocs/dieuchuyen_bloc.dart';
import 'package:Thilogi/blocs/giaoxe_bloc.dart';
import 'package:Thilogi/blocs/xuatkho_bloc.dart';
import 'package:Thilogi/blocs/image_bloc.dart';
import 'package:Thilogi/blocs/khothanhpham_bloc.dart';
import 'package:Thilogi/blocs/khoxe_bloc.dart';
import 'package:Thilogi/blocs/scan_bloc.dart';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/user_bloc.dart';

import 'package:Thilogi/pages/splash.dart';

import 'package:Thilogi/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          ChangeNotifierProvider<ScanBloc>(
            create: (context) => ScanBloc(),
          ),
          ChangeNotifierProvider<KhoThanhPhamBloc>(
            create: (context) => KhoThanhPhamBloc(),
          ),
          ChangeNotifierProvider<KhoXeBloc>(
            create: (context) => KhoXeBloc(),
          ),
          ChangeNotifierProvider<ImageBloc>(
            create: (context) => ImageBloc(),
          ),
          ChangeNotifierProvider<XuatKhoBloc>(
            create: (context) => XuatKhoBloc(),
          ),
          ChangeNotifierProvider<GiaoXeBloc>(
            create: (context) => GiaoXeBloc(),
          ),
          ChangeNotifierProvider<DieuChuyenBloc>(
            create: (context) => DieuChuyenBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'THILOGI ',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SplashPage(),
          // routes: {
          //   '/home': (context) => MyHomePage(),
          // },
        ),
      ),
    );
  }
}
