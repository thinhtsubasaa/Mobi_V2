import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

class ScanBloc extends ChangeNotifier {
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

  var headers = {
    'ApiKey': 'qtsx2023',
  };
  Future<void> getData(BuildContext context, String qrcode) async {
    _scan = null;
    _isLoading = true;
    try {
      final response = await http.get(
        Uri.parse(
            "https://qtsxautoapi.thacochulai.vn/api/KhoThanhPham/TraCuuXeThanhPham_Thilogi1?SoKhung=$qrcode"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          _scan = ScanModel(
            key: decodedData["key"],
            id: decodedData['id'],
            soKhung: decodedData['soKhung'],
            maSanPham: decodedData['maSanPham'],
            tenSanPham: decodedData['tenSanPham'],
            soMay: decodedData['soMay'],
            maMau: decodedData['maMau'],
            tenMau: decodedData['tenMau'],
            tenKho: decodedData['tenKho'],
            maViTri: decodedData['maViTri'],
            tenViTri: decodedData['tenViTri'],
            mauSon: decodedData['mauSon'],
            ngayXuatKhoView: decodedData['ngayXuatKhoView'],
            tenTaiXe: decodedData['tenTaiXe'],
            ghiChu: decodedData['ghiChu'],
            Kho_Id: decodedData['Kho_Id'],
            BaiXe_Id: decodedData['BaiXe_Id'],
            viTri_Id: decodedData['viTri_Id'],
            phuKien: (decodedData['phuKien'] as List<dynamic>)
                .map((item) => PhuKien.fromJson(item))
                .toList(),
          );
        } else {
          String errorMessage = response.body.replaceAll('"', '');
          notifyListeners();
          QuickAlert.show(
            // ignore: use_build_context_synchronously
            context: context,
            type: QuickAlertType.info,
            title: '',
            text: errorMessage,
            confirmBtnText: 'Đồng ý',
          );
          _scan = null;
          _isLoading = false;
        }
      }
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future clearData() async {
    _scan = null;
    notifyListeners();
  }
}

  // Future postData(ScanModel scanData) async {
  //   _isLoading = true;
  //   try {
  //     var newScanData = scanData;
  //     newScanData.soKhung =
  //         newScanData.soKhung == 'null' ? null : newScanData.soKhung;
  //     final http.Response response = await requestHelper.postData(
  //         'KhoThanhPham/NhapKhoBai', newScanData.toJson());
  //     var decodedData = jsonDecode(response.body);
  //     print("data: ${decodedData}");
  //     _isLoading = false;
  //     _success = decodedData["success"];
  //   } catch (e) {
  //     _message = e.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

