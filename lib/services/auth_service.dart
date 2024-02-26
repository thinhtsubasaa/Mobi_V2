// // api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart';

// class ApiService {
//   static Future<Map<String, dynamic>> login(
//       String username, String password, String domain) async {
//     try {
//       Response response = await post(
//         Uri.parse('http://14.241.134.199:8021/token'),
//         body: jsonEncode({
//           'username': username,
//           'password': password,
//           'domain': domain,
//         }),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       print('Response status code: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body.toString());
//         print(data['token']);
//         print('Login successfully');
//         return {'success': true, 'token': data['token']};
//       } else {
//         print('Login failed');
//         return {'success': false, 'error': 'Login failed'};
//       }
//     } catch (e) {
//       print('Error: $e');
//       return {'success': false, 'error': 'An error occurred'};
//     }
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/models/user.dart';
import 'package:project/services/request_helper.dart';

class AuthService extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  UserModel? _user;
  UserModel? get user => _user;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Future login(String userName, String password, String domain) async {
    try {
      _hasError = false;
      final http.Response response = await requestHelper.loginAction(
        jsonEncode(
          {
            "username": userName,
            "password": password,
            "domain": domain,
          },
        ),
      );
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('du lieu :  ${data["id"]}');
        // var data = decodedData["data"];

        // var info = data["info"];

        _user = UserModel(
          id: data['id'],
          email: data['email'],
          fullName: data['fullName'],
          mustChangePass: data['mustChangePass'],
          token: data['token'],
          refreshToken: data['refreshToken'],
          hinhAnhUrl: data['hinhAnhUrl'],
        );
      }
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
