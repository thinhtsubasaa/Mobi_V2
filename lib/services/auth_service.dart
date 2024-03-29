import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/user.dart';
import 'package:Thilogi/services/request_helper.dart';

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
        print('du lieu :  ${data}');

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
