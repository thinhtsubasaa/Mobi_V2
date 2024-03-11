import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/services/request_helper.dart';

class ChucnangService extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  ScanModel? _scan;
  ScanModel? get scan => _scan;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _success = false;
  bool get success => _success;

  String? _message;
  String? get message => _message;

  Future<void> getData(BuildContext context, String soKhung) async {
    _isLoading = true;
    try {
      final http.Response response =
          await requestHelper.getData('GetDataXeThaPham?keyword=$soKhung');
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        // _isLoading = false;
        // _success = decodedData["success"];
        // _message = decodedData["message"];
        notifyListeners();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Thành công"),
              content: Text(response.body), // Hiển thị dữ liệu từ response.body
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Đóng"),
                ),
              ],
            );
          },
        );
      } else {
        notifyListeners();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Thành công"),
              content: Text(response.body), // Hiển thị dữ liệu từ response.body
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Đóng"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      _hasError = true;
      _message = e.toString();
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
