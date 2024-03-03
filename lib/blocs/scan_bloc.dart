import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/models/scan.dart';
import 'package:project/services/request_helper.dart';

class ScanBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  ScanModel? _data;
  ScanModel? get data => _data;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _success = false;
  bool get success => _success;

  String? _message;
  String? get message => _message;

  Future<void> getData(String qrCode) async {
    _isLoading = true;
    _data = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/TraCuuXeThanhPham_Thilogi1?SoKhung=$qrCode');
      if (response.statusCode == 200) {
        // Nếu server trả về một response OK, parse và gán dữ liệu vào _data
        var decodedData = jsonDecode(response.body);
        if (decodedData["data"] != null) {
          _data = ScanModel.fromJson(decodedData["data"]);
        } else {
          _data = null;
        }
        _success = decodedData["success"];
        _message = decodedData["message"];
      } else {
        // Nếu server không trả về response thành công, gán _success = false và thông báo lỗi
        _success = false;
        _message = 'Failed to load data';
      }
    } catch (e) {
      // Nếu có lỗi xảy ra trong quá trình gọi API, gán _success = false và thông báo lỗi
      _message = e.toString();
    }
  }

  Future postData(ScanModel scanData) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData.chuyenId =
          newScanData.chuyenId == 'null' ? null : newScanData.chuyenId;
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/TraCuuXeThanhPham_Thilogi1', newScanData.toJson());
      var decodedData = jsonDecode(response.body);
      _isLoading = false;
      _success = decodedData["success"];
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
