import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/services/request_helper.dart';

class KhoXeService extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  List<KhoXeModel>? _khoxeList; // Định nghĩa danh sách khoxeList ở đây
  List<KhoXeModel>? get khoxeList => _khoxeList;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  int? _statusCode;
  int? get statusCode => _statusCode;

  Future<void> getData() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body)['dataList'];
        print("data: ${decodedData}");

        // var data = decodedData["data"];

        // var info = data["info"];

        _khoxeList = [
          KhoXeModel(
            id: decodedData['id'],
            maKhoXe: decodedData['maKhoXe'],
            tenKhoXe: decodedData['tenKhoXe'],
            isLogistic: decodedData['isLogistic'],
          )
        ];
      }
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
