import 'dart:convert';

import 'package:Thilogi/models/vitri.dart';
import 'package:Thilogi/models/xuatkho.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

class ViTriBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  List<ViTriModel>? _vitriList;
  List<ViTriModel>? get vitriList => _vitriList;

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

  Future<void> getViTriList(String BaiXeId) async {
    _isLoading = true;
    _vitriList = null;
    try {
      final http.Response response = await requestHelper
          .getData('DM_WMS_Kho_ViTri/Mobi?baiXe_Id=$BaiXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body)['result'];
        // print("data: ${decodedData}");
        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _vitriList = (decodedData as List)
            .map((item) => ViTriModel.fromJson(item))
            .toList();
        print(_vitriList);
        // Gọi setState để cập nhật giao diện
        // setState(() {
        //   _loading = true;
        // });
      }
    } catch (e) {
      // Xử lý lỗi khi gọi API
      _hasError = true;
      _errorCode = e.toString();
    }
  }
}
