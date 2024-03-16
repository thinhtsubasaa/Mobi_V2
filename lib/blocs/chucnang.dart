import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Nhận xe thành công",
        );
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: '',
          text: errorMessage,
        );
      }
    } catch (e) {
      _hasError = true;
      _isLoading = false;
      _message = e.toString();
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
