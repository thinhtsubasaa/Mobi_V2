import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/services/request_helper.dart';

class ScanService extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  ScanModel? _scan;
  ScanModel? get scan => _scan;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  var headers = {
    'ApiKey': 'qtsx2023', // Thêm header này vào request của bạn
  };
  Future<void> getData(String qrcode) async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://qtsxautoapi.thacochulai.vn/api/KhoThanhPham/TraCuuXeThanhPham_Thilogi1?SoKhung=$qrcode"), // Thay thế với URL thực tế của bạn
        headers: headers,
      );

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        // var data = decodedData["data"];

        // var info = data["info"];

        _scan = ScanModel(
          id: decodedData['id'],
          soKhung: decodedData['soKhung'],
          tenSanPham: decodedData['tenSanPham'],
          tenMau: decodedData['tenMau'],
          tenKho: decodedData['tenKho'],
          soMay: decodedData['soMay'],
          ngayXuatKhoView: decodedData['ngayXuatKhoView'],
          tenTaiXe: decodedData['tenTaiXe'],
          ghiChu: decodedData['ghiChu'],
          phuKien: (decodedData['phuKien'] as List<dynamic>)
              .map((item) => PhuKien.fromJson(item))
              .toList(),
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
