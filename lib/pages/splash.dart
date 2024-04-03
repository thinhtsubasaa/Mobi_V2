import 'package:flutter/material.dart';
import 'package:project/blocs/user_bloc.dart';
import 'package:project/config/config.dart';
import 'package:project/pages/Login.dart';
import 'package:project/pages/MainMenu.dart';
import 'package:provider/provider.dart';

// import '../blocs/user_bloc.dart';
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
    Future.delayed(const Duration(seconds: 2)).then((value) async {
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
    nextScreenReplace(context, MainMenuPage());
  }

  void _goToLoginPage() {
    nextScreenReplace(context, LoginPage());
  }

  @override
  void initState() {
    _afterSplash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
    );
  }
}
