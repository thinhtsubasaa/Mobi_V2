import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/services/request_helper.dart';

class KhoThanhPhamBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  KhoThanhPhamModel? _baixe;
  KhoThanhPhamModel? get baixe => _baixe;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Future<void> getData(String qrcode) async {
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetSoKhungNhapKhoBaimobi?SoKhung=$qrcode');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");

        // var data = decodedData["data"];

        // var info = data["info"];

        _baixe = KhoThanhPhamModel(
          id: decodedData['id'],
          soKhung: decodedData['soKhung'],
          tenSanPham: decodedData['tenSanPham'],
          tenMau: decodedData['tenMau'],
          soMay: decodedData['soMay'],
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
