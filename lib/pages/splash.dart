<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:project/blocs/user_bloc.dart';
import 'package:project/config/config.dart';
import 'package:project/pages/Login.dart';
import 'package:project/pages/MainMenu.dart';
import 'package:provider/provider.dart';

// import '../blocs/user_bloc.dart';
=======
import 'dart:async';

import 'package:Thilogi/blocs/menu_roles.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/Home.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/user_bloc.dart';

import 'package:provider/provider.dart';
>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
import '../blocs/app_bloc.dart';

import '../utils/next_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
<<<<<<< HEAD
<<<<<<< HEAD
  Future _afterSplash() async {
    final UserBloc ub = context.read<UserBloc>();
    final AppBloc _ab = context.read<AppBloc>();
    Future.delayed(const Duration(seconds: 2)).then((value) async {
=======
    bool _loading = false;
=======
  bool _loading = false;

>>>>>>> b3a8889a9acc5e1cc10f7c901661ac2582de27df
  Future _afterSplash() async {
    final UserBloc ub = context.read<UserBloc>();
    final AppBloc _ab = context.read<AppBloc>();

    Future.delayed(const Duration(seconds: 3)).then((value) async {
>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
      _ab.getApiUrl();
      if (ub.isSignedIn) {
        ub.getUserData();
        _ab.getData();

        _goToHomePage();
      } else {
        _goToLoginPage();
      }
    });
  }

  void _goToHomePage() {
<<<<<<< HEAD
<<<<<<< HEAD
    nextScreenReplace(context, MainMenuPage());
  }

  void _goToLoginPage() {
    nextScreenReplace(context, LoginPage());
=======
    nextScreenReplace(context, MainMenuPage(resetLoadingState: () {
                  setState(() {
                    _loading = false;
                  });
                },));
=======
    nextScreenReplace(context, QLKhoXePage());
>>>>>>> b3a8889a9acc5e1cc10f7c901661ac2582de27df
  }

  void _goToLoginPage() {
    nextScreenReplace(context, MyHomePage());
>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
  }

  @override
  void initState() {
    _afterSplash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      // backgroundColor: Config().appThemeColor,
      body: Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Image(
              height: MediaQuery.of(context).size.width - 100,
              width: MediaQuery.of(context).size.width - 100,
              image: const AssetImage(AppConfig.appBarImagePath),
              fit: BoxFit.contain,
            ),
          ],
=======
      body: Container(
        margin: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppConfig.appBarImagePath,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'HỆ THỐNG QUẢN LÝ\n NGUỒN LỰC DOANH NGHIỆP (ERP)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.0, color: AppConfig.textInput),
              ),
            ],
          ),
>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
        ),
      ),
    );
  }
}
