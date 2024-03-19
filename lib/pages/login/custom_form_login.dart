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
  late AppBloc _ab;
  late UserBloc _ub;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var userNameCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();
  bool obscureText = true;
  String selectedDomain = 'thilogi.com.vn';
  final _btnController = RoundedLoadingButtonController();

  bool offsecureText = true;
  Icon lockIcon = LockIcon().lock;

  final TextEditingController _diaChiApi = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ab = Provider.of<AppBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);

    setState(() {
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
      // ignore: use_build_context_synchronously
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
                nextScreen(context, MainMenuPage());
              });
            } else {
              if (asb.hasError) {
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
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Tài khoản",
            style: TextStyle(
              color: Colors.black,
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
            color: Colors.black,
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
              // Sử dụng suffixIcon để thêm biểu tượng con mắt
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  // Khi nhấn vào biểu tượng con mắt, thay đổi trạng thái của obscureText
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
            color: Colors.black,
            fontFamily: 'Roboto',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.17,
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
            items: [
              DropdownMenuItem(
                child: Text(selectedDomain),
                value: selectedDomain,
              ),
              DropdownMenuItem(
                child: Text('Option 1'),
                value: 'option1',
              ),
              DropdownMenuItem(
                child: Text('Option 2'),
                value: 'option2',
              ),
              // Add more items as needed
            ],
            onChanged: (value) {
              setState(() {
                selectedDomain = value.toString();
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
    );
  }
}
