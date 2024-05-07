import 'dart:async';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/Home.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:provider/provider.dart';
import '../blocs/app_bloc.dart';
import '../utils/next_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future _afterSplash() async {
    final UserBloc ub = context.read<UserBloc>();
    final AppBloc _ab = context.read<AppBloc>();

    Future.delayed(const Duration(seconds: 3)).then((value) async {
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
    nextScreenReplace(context, QLKhoXePage());
  }

  void _goToLoginPage() {
    nextScreenReplace(context, MyHomePage());
  }

  @override
  void initState() {
    _afterSplash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
    );
  }
}
