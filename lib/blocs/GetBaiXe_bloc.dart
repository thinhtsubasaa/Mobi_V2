import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

import '../models/khoxe.dart';

class GetBaiXeBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;

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

  Future<void> getData() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        // var data = decodedData["data"];
        // var info = data["info"];

        _khoxeList = (decodedData as List)
            .map((item) => KhoXeModel.fromJson(item))
            .toList();

        // Gọi setState để cập nhật giao diện
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }
}
