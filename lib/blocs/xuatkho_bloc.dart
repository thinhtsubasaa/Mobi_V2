import 'dart:convert';

import 'package:Thilogi/models/xuatkho.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';

class XuatKhoBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  XuatKhoModel? _xuatkho;
  XuatKhoModel? get xuatkho => _xuatkho;

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
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetSoKhungXuatKhomobi?SoKhung=$qrcode');
      print(response.statusCode);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        // var data = decodedData["data"];

        // var info = data["info"];

        _xuatkho = XuatKhoModel(
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
          ngayNhapKhoView: decodedData['ngayNhapKhoView'],
          tenTaiXe: decodedData['tenTaiXe'],
          ghiChu: decodedData['ghiChu'],
          maKho: decodedData['maKho'],
          kho_Id: decodedData['kho_Id'],
          Diadiem_Id: decodedData['Diadiem_Id'],
          phuongThucVanChuyen_Id: decodedData['phuongThucVanChuyen_Id'],
          loaiPhuongTien_Id: decodedData['loaiPhuongTien_Id'],
          danhSachPhuongTien_Id: decodedData['danhSachPhuongTien_Id'],
          bienSo_Id: decodedData['bienSo_Id'],
          taiXe_Id: decodedData['taiXe_Id'],
          // latLng: decodedData['latLng'],
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
