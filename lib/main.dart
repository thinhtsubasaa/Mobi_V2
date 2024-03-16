import 'package:Thilogi/blocs/xuatkho_bloc.dart';
import 'package:Thilogi/pages/login/Login.dart';
import 'package:Thilogi/services/image_service.dart';
import 'package:flutter/material.dart';

import 'package:Thilogi/blocs/khothanhpham_bloc.dart';
import 'package:Thilogi/blocs/khoxe_bloc.dart';
import 'package:Thilogi/blocs/scan_bloc.dart';
import 'package:Thilogi/pages/Home.dart';
import 'package:Thilogi/pages/baixe/baixe.dart';
import 'package:Thilogi/pages/menu/MainMenu.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe2.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe3.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:Thilogi/pages/tracking/TrackingXe_TrangThai.dart';
import 'package:Thilogi/services/auth_service.dart';
import 'package:Thilogi/services/scan_service.dart';
import 'package:provider/provider.dart';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
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
          ChangeNotifierProvider<ScanService>(
            create: (context) => ScanService(),
          ),
          ChangeNotifierProvider<KhoThanhPhamBloc>(
            create: (context) => KhoThanhPhamBloc(),
          ),
          ChangeNotifierProvider<KhoXeBloc>(
            create: (context) => KhoXeBloc(),
          ),
          ChangeNotifierProvider<ImageService>(
            create: (context) => ImageService(),
          ),
          ChangeNotifierProvider<XuatKhoBloc>(
            create: (context) => XuatKhoBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Thilogi ',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(),
        ),
      ),
    );
  }
}
