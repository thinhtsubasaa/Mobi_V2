import 'dart:async';
import 'package:Thilogi/blocs/phienban_bloc.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/phienban.dart';
import 'package:Thilogi/pages/Bms/bms.dart';
import 'package:Thilogi/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../blocs/app_bloc.dart';
import '../utils/next_screen.dart';
import 'package:new_version/new_version.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late PhienBanBloc _pb;
  PhienBanModel? _model;
  @override
  void initState() {
    super.initState();
    _pb = Provider.of<PhienBanBloc>(context, listen: false);
    _onScan();
    _afterSplash();
    // _checkVersion();
  }

  // void _checkVersion() async {
  //   final newVersion = NewVersion(
  //     iOSId: "com.thilogi.vn.logistics",
  //     androidId: "com.thilogi.vn.logistics",
  //   );
  //   final status = await newVersion.getVersionStatus();
  //   if (status != null) {
  //     if (_isVersionLower(status.localVersion, status.storeVersion)) {
  //       newVersion.showUpdateDialog(
  //         context: context,
  //         versionStatus: status,
  //         dialogTitle: "CẬP NHẬT",
  //         dismissButtonText: "Bỏ qua",
  //         dialogText: "Ứng dụng đã có phiên bản mới, vui lòng cập nhật " + "${status.localVersion}" + " lên " + "${status.storeVersion}",
  //         dismissAction: () {
  //           SystemNavigator.pop();
  //         },
  //         updateButtonText: "Cập nhật",
  //         allowDismissal: false
  //       );
  //     }
  //     print("DEVICE : " + status.localVersion);
  //     print("STORE : " + status.storeVersion);
  //   }
  // }

  void _checkVersion() async {
    print("BACKEND : ${_model?.maPhienBan}");
    final newVersion = NewVersion(
      iOSId: "com.thilogi.vn.logistics",
      androidId: "com.thilogi.vn.logistics",
    );
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      if (_isVersionLower(status.localVersion, _model?.maPhienBan ?? "")) {
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: "CẬP NHẬT",
          dismissButtonText: "Bỏ qua",
          dialogText: "Ứng dụng đã có phiên bản mới, vui lòng cập nhật " + "${status.localVersion}" + " lên " + "${_model?.maPhienBan}",
          dismissAction: () {
            SystemNavigator.pop();
          },
          allowDismissal: false,
          updateButtonText: "Cập nhật",
        );
      }
      print("DEVICE : " + status.localVersion);
      print("STORE : " + status.storeVersion);
    }
  }

  bool _isVersionLower(String localVersion, String storeVersion) {
    final localParts = localVersion.split('.').map(int.parse).toList();
    final storeParts = storeVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < localParts.length; i++) {
      if (localParts[i] < storeParts[i]) return true;
      if (localParts[i] > storeParts[i]) return false;
    }

    // If we get here, all parts are equal
    return false;
  }

  _onScan() {
    _pb.getData(context).then((_) {
      setState(() {
        _model = _pb.phienban;
      });
    });
  }

  Future _afterSplash() async {
    final UserBloc ub = context.read<UserBloc>();
    final AppBloc _ab = context.read<AppBloc>();

    Future.delayed(const Duration(seconds: 2)).then((value) async {
      _ab.getApiUrl();
      // _checkVersion();
      if (ub.isSignedIn) {
        _checkVersion();
        ub.getUserData();
        _ab.getData();
        _goToHomePage();
        print(("API: ${_ab.apiUrl}"));
        print(("API_MMS: ${ub.apiUrl2}"));
      } else {
        _goToLoginPage();
        _checkVersion();
        print(("API: ${_ab.apiUrl}"));
        print(("API_MMS: ${ub.apiUrl2}"));
      }
    });
  }

  void _goToHomePage() {
    nextScreenReplace(context, BMSPage());
  }

  void _goToLoginPage() {
    nextScreenReplace(context, MyHomePage());
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
              const SizedBox(
                height: 20,
              ),
              const Text(
                'HỆ THỐNG QUẢN LÝ DOANH NGHIỆP (BMS)',
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
