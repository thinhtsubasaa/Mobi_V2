import 'dart:convert';
import 'package:Thilogi/models/lsxequa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

import '../models/lsnhapbai.dart';
import '../models/lsxuatxe.dart';

class TrackingBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  List<LSXeQuaModel>? _lsxequa;
  List<LSXeQuaModel>? get lsxequa => _lsxequa;
  List<LSNhapBaiModel>? _lsnhapbai;
  List<LSNhapBaiModel>? get lsnhapbai => _lsnhapbai;
  List<LSXuatXeModel>? _lsxuatxe;
  List<LSXuatXeModel>? get lsxuatxe => _lsxuatxe;

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

  Future<void> getTrackingXe(BuildContext context, String soKhung) async {
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
            List<dynamic> lsXeQuaDataList = decodedData['infor_LsXeQua'];

            // Tạo danh sách để lưu trữ các thông tin xe qua
            List<LSXeQuaModel> lsXeQuaList = [];

            // Duyệt qua từng phần tử trong danh sách và thêm vào danh sách kết quả
            lsXeQuaDataList.forEach((lsXeQuaData) {
              LSXeQuaModel xeQuaModel = LSXeQuaModel(
                id: lsXeQuaData['id'],
                tuNgay: lsXeQuaData['tuNgay'],
                nguoiNhan: lsXeQuaData['nguoiNhan'],
                noiNhan: lsXeQuaData['noiNhan'],
                toaDo: lsXeQuaData['toaDo'],
              );
              lsXeQuaList.add(xeQuaModel);
            });

            // Lưu danh sách thông tin xe qua vào biến _lsxequa
            _lsxequa = lsXeQuaList;
          }
          if (decodedData['infor_NhapBai'] != null &&
              decodedData['infor_NhapBai'].isNotEmpty) {
            List<dynamic> lsNhapBaiDataList = decodedData['infor_NhapBai'];

            // Tạo danh sách để lưu trữ các thông tin xe qua
            List<LSNhapBaiModel> lsNhapBaiList = [];
            lsNhapBaiDataList.forEach((lsNhapBaiData) {
              LSNhapBaiModel nhapBaiModel = LSNhapBaiModel(
                id: lsNhapBaiData['id'],
                ngay: lsNhapBaiData['ngay'],
                thongTinChiTiet: lsNhapBaiData['thongTinChiTiet'],
                toaDo: lsNhapBaiData['toaDo'],
              );

              lsNhapBaiList.add(nhapBaiModel);
            });

            // Lưu danh sách thông tin xe qua vào biến _lsxequa
            _lsnhapbai = lsNhapBaiList;
          }
          if (decodedData['infor_LsXuatXe'] != null &&
              decodedData['infor_LsXuatXe'].isNotEmpty) {
            List<dynamic> lsXuatXeDataList = decodedData['infor_LsXuatXe'];

            // Tạo danh sách để lưu trữ các thông tin xe qua
            List<LSXuatXeModel> lsXuatXeList = [];
            lsXuatXeDataList.forEach((lsXuatXeData) {
              LSXuatXeModel xuatXeModel = LSXuatXeModel(
                id: lsXuatXeData['id'],
                ngay: lsXuatXeData['ngay'],
                thongTinChiTiet: lsXuatXeData['thongTinChiTiet'],
                thongtinvanchuyen: lsXuatXeData['thongtinvanchuyen'],
                toaDo: lsXuatXeData['toaDo'],
              );
              lsXuatXeList.add(xuatXeModel);
            });

            // Lưu danh sách thông tin xe qua vào biến _lsxequa
            _lsxuatxe = lsXuatXeList;
          }
        } else {
          String errorMessage = response.body.replaceAll('"', '');
          notifyListeners();
          if (errorMessage.isEmpty) {
            errorMessage = "Không có dữ liệu";
          }
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
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
