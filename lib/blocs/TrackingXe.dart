import 'dart:convert';
import 'package:Thilogi/models/lsxequa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

import '../models/lsnhapbai.dart';
import '../models/lsxuatxe.dart';

class TrackingBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  LSXeQuaModel? _lsxequa;
  LSXeQuaModel? get lsxequa => _lsxequa;
  LSNhapBaiModel? _lsnhapbai;
  LSNhapBaiModel? get lsnhapbai => _lsnhapbai;
  LSXuatXeModel? _lsxuatxe;
  LSXuatXeModel? get lsxuatxe => _lsxuatxe;

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

  Future<void> getLSXeQua(BuildContext context, String soKhung) async {
    _isLoading = true;
    _lsxequa = null;
    _lsnhapbai = null;
    _lsxuatxe = null;
    try {
      final http.Response response = await requestHelper
          .getData('GetDataXeThaPham/TrackingXeThanhPham?SoKhung=$soKhung');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          if (decodedData['infor_LsXeQua'] != null &&
              decodedData['infor_LsXeQua'].isNotEmpty) {
            var lsXeQuaData = decodedData['infor_LsXeQua'][0];
            _lsxequa = LSXeQuaModel(
              id: lsXeQuaData['id'],
              tuNgay: lsXeQuaData['tuNgay'],
              nguoiNhan: lsXeQuaData['nguoiNhan'],
              noiNhan: lsXeQuaData['noiNhan'],
              toaDo: lsXeQuaData['toaDo'],
            );
          }
          if (decodedData['infor_NhapBai'] != null &&
              decodedData['infor_NhapBai'].isNotEmpty) {
            var lsNhapBaiData = decodedData['infor_NhapBai'][0];
            _lsnhapbai = LSNhapBaiModel(
              id: lsNhapBaiData['id'],
              ngay: lsNhapBaiData['ngay'],
              thongTinChiTiet: lsNhapBaiData['thongTinChiTiet'],
              toaDo: lsNhapBaiData['toaDo'],
            );
          }
          if (decodedData['infor_LsXuatXe'] != null &&
              decodedData['infor_LsXuatXe'].isNotEmpty) {
            var lsXuatXeData = decodedData['infor_LsXuatXe'][0];
            _lsxuatxe = LSXuatXeModel(
              id: lsXuatXeData['id'],
              ngay: lsXuatXeData['ngay'],
              thongTinChiTiet: lsXuatXeData['thongTinChiTiet'],
              thongtinvanchuyen: lsXuatXeData['thongtinvanchuyen'],
              toaDo: lsXuatXeData['toaDo'],
            );
          }
        }
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
        _lsxequa = null;
        _lsnhapbai = null;
        _lsxuatxe = null;
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
