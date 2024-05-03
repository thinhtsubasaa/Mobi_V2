import 'package:Thilogi/blocs/menu_roles.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/models/icon_data.dart';
import 'package:Thilogi/pages/menu/MainMenu.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/auth_service.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:Thilogi/utils/snackbar.dart';
import 'package:Thilogi/widgets/loading_button.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../config/config.dart';
import '../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors
class CustomLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100.w,
        // ignore: prefer_const_constructors
        color: Color.fromRGBO(246, 198, 199, 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: SignUpScreen());
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _loading = false;
  late AppBloc _ab;
  late UserBloc _ub;
  late MenuRoleBloc _mb;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var userNameCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();
  bool obscureText = true;
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = 'cd9961bf-f656-4382-8354-803c16090314';
  late String selectedDomain;
  List<String> items = ['thilogi.com.vn', 'thaco.com.vn', ''];
  Map<String, String> domainTitles = {
    'thilogi.com.vn': '@thilogi.com.vn',
    'thaco.com.vn': '@thaco.com.vn',
    '': 'Cá nhân'
  };

  final _btnController = RoundedLoadingButtonController();

  bool offsecureText = true;
  Icon lockIcon = LockIcon().lock;

  final TextEditingController _diaChiApi = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ab = Provider.of<AppBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);
    _mb = Provider.of<MenuRoleBloc>(context, listen: false);

    setState(() {
      selectedDomain = items[0];
      _diaChiApi.text = _ab.apiUrl;
    });
  }

  void _onlockPressed() {
    if (offsecureText == true) {
      setState(() {
        offsecureText = false;
        lockIcon = LockIcon().open;
      });
    } else {
      setState(() {
        offsecureText = true;
        lockIcon = LockIcon().lock;
      });
    }
  }

  Future _login() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('apiUrl', _ab.apiUrl);
    print('Username: ${userNameCtrl.text}');
    print('Password: ${passwordCtrl.text}');
    if (userNameCtrl.text.isEmpty) {
      _btnController.reset();
      openSnackBar(context, 'username is required'.trim());
    } else if (passwordCtrl.text.isEmpty) {
      _btnController.reset();
      // ignore: use_build_context_synchronously
      openSnackBar(context, 'password is required'.trim());
    } else {
      AppService().checkInternet().then((hasInternet) async {
        if (!hasInternet!) {
          _btnController.reset();
          openSnackBar(context, 'no internet'.trim());
        } else {
          final AuthService asb = context.read<AuthService>();
          await asb
              .login(userNameCtrl.text, passwordCtrl.text, selectedDomain)
              .then((_) {
            if (asb.user != null) {
              _ub
                  .saveUserData(asb.user!)
                  .then((_) => _ub.setSignIn())
                  .then((_) {
                _btnController.success();

                nextScreenReplace(context, QLKhoXePage());

                // _handleButtonTap(QLKhoXePage());
              });
            } else {
              if (asb.hasError) {
                openSnackBar(context, asb.errorCode);
                print("lỗi: ${asb.errorCode}");
              } else {
                openSnackBar(
                    context, 'username or password is incorrect'.trim());
              }
              _btnController.reset();
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : AutofillGroup(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Tài khoản",
                    style: TextStyle(
                      color: AppConfig.textInput,
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 70.w,
                  height: 8.h,
                  child: TextFormField(
                    controller: userNameCtrl,
                    autofillHints: [AutofillHints.username],
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Mật khẩu",
                  style: TextStyle(
                    color: AppConfig.textInput,
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 70.w,
                  height: 8.h,
                  child: TextFormField(
                    controller: passwordCtrl,
                    autofillHints: [AutofillHints.password],
                    obscureText: obscureText,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Domain",
                  style: TextStyle(
                    color: AppConfig.textInput,
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 70.w,
                  height: 8.h,
                  child: DropdownButtonFormField(
                    value: selectedDomain,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem(
                          value: item,
                          // child: Text(item),
                          child: Text(domainTitles[item] ?? ''));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDomain = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                loadingButton(
                  context,
                  _btnController,
                  _login,
                  'Đăng nhập',
                  Theme.of(context).primaryColor,
                  Colors.black,
                ),
                const SizedBox(height: 5),
              ],
            ),
          );
  }

  // void _handleButtonTap(Widget page) {
  //   if (!mounted) return;
  //   setState(() {
  //     _loading = true;
  //   });
  //   nextScreenCloseOthers(context, page);
  //   Future.delayed(Duration(seconds: 1), () {
  //     setState(() {
  //       _loading = false;
  //     });
  //   });
  // }
}
