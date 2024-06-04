import 'dart:convert';
import 'package:Thilogi/models/nhanvien.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

class Scan_NhanVienBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  NhanVienModel? _nhanvien;
  NhanVienModel? get nhanvien => _nhanvien;

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
    _nhanvien = null;
    try {
      final http.Response response = await requestHelper
          .getData('Account/thongtincbnv?plainText=$soKhung');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          _nhanvien = NhanVienModel(
            id: decodedData['id'],
            email: decodedData['email'],
            fullName: decodedData['fullName'],
            mustChangePass: decodedData['mustChangePass'],
            token: decodedData['token'],
            refreshToken: decodedData['refreshToken'],
            accessRole: decodedData['accessRole'],
            hinhAnhUrl: decodedData['hinhAnhUrl'],
          );
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        if (errorMessage.isEmpty) {
          errorMessage = "Không có thông tin CBNV";
        }

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _nhanvien = null;
        _isLoading = false;
      }

      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
