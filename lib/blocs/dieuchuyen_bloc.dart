import 'dart:convert';

import 'package:Thilogi/models/dieuchuyen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';

class DieuChuyenBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  DieuChuyenModel? _dieuchuyen;
  DieuChuyenModel? get dieuchuyen => _dieuchuyen;

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

  Future<void> getData(String qrcode) async {
    _isLoading = true;
    _dieuchuyen = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetSoKhungDieuchuyenmobi?SoKhung=$qrcode');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          // var data = decodedData["data"];

          // var info = data["info"];

          _dieuchuyen = DieuChuyenModel(
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
            tenBaiXe: decodedData['tenBaiXe'],
            mauSon: decodedData['mauSon'],
            ngayNhapKhoView: decodedData['ngayNhapKhoView'],
            tenTaiXe: decodedData['tenTaiXe'],
            ghiChu: decodedData['ghiChu'],
            Kho_Id: decodedData['Kho_Id'],
            BaiXe_Id: decodedData['BaiXe_Id'],
            viTri_Id: decodedData['viTri_Id'],
            // latLng: decodedData['latLng'],
          );
        }
      } else {
        _dieuchuyen = null; // Gán _scan thành null nếu không có dữ liệu
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