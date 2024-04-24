import 'dart:io';

import 'package:Thilogi/blocs/dieuchuyen_bloc.dart';
import 'package:Thilogi/blocs/dongcont_bloc.dart';
import 'package:Thilogi/blocs/giaoxe_bloc.dart';
import 'package:Thilogi/blocs/menu_roles.dart';
import 'package:Thilogi/blocs/xuatkho_bloc.dart';
import 'package:Thilogi/blocs/image_bloc.dart';
import 'package:Thilogi/blocs/khothanhpham_bloc.dart';
import 'package:Thilogi/blocs/khoxe_bloc.dart';
import 'package:Thilogi/blocs/scan_bloc.dart';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/pages/Home.dart';
import 'package:Thilogi/pages/baixe/baixe.dart';
import 'package:Thilogi/pages/chuyenxe/chuyenxe.dart';
import 'package:Thilogi/pages/giaoxe/giaoxe.dart';
import 'package:Thilogi/pages/khoxe/khoxe.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';

import 'package:Thilogi/pages/splash.dart';
import 'package:Thilogi/pages/tracking/TrackingXe_Vitri.dart';

import 'package:Thilogi/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

import 'package:sizer/sizer.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  // await FlutterDownloader.initialize(
  //   ignoreSsl: true,
  // );
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
          ChangeNotifierProvider<DongContBloc>(
            create: (context) => DongContBloc(),
          ),
          ChangeNotifierProvider<MenuRoleBloc>(
            create: (context) => MenuRoleBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'THILOGI ',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SplashPage(),
        ),
      ),
    );
  }
}
