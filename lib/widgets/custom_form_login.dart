import 'package:flutter/material.dart';
import 'package:project/config/config.dart';
import 'package:project/pages/MainMenu.dart';
import 'package:project/services/auth_service.dart';

// ignore: use_key_in_widget_constructors
class CustomLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
          // ignore: prefer_const_constructors
          color: Color.fromRGBO(246, 198, 199, 0.2),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SignUpScreen()),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String selectedDomain = 'thilogi.com.vn';
  void login(String username, password, domain) async {
    Map<String, dynamic> result =
        await ApiService.login(username, password, domain);

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainMenuPage()),
      );
    } else {
      // Handle login failure
      print('Login failed: ${result['error']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Text(
            "Tài khoản",
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Roboto',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.17,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 254,
          height: 55,
          child: TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
        const SizedBox(height: 25),
        const Text(
          "Mật khẩu",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Roboto',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 254,
          height: 55,
          child: TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
        const SizedBox(height: 25),
        const Text(
          "Domain",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Roboto',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 254,
          height: 55,
          child: DropdownButtonFormField(
            value: selectedDomain,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            login(
              usernameController.text.toString(), // Change this line
              passwordController.text.toString(),
              selectedDomain,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            fixedSize:
                const Size(AppConfig.buttonWidth, AppConfig.buttonHeight),
          ),
          child: const Text(
            "ĐĂNG NHẬP",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.16,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
