import 'dart:convert';

import 'package:Thilogi/models/xuatkho.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:quickalert/quickalert.dart';

import '../models/kehoachgiaoxe.dart';

class ThayDoiKeHoachBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  KeHoachGiaoXeModel? _khgx;
  KeHoachGiaoXeModel? get khgx => _khgx;

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

  Future<void> getData(BuildContext context, String qrcode) async {
    _isLoading = true;
    _khgx = null;
    try {
      final http.Response response = await requestHelper.getData('Kho/GetThongTinKeHoach?SoKhung=$qrcode');
      print(response.statusCode);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          _khgx = KeHoachGiaoXeModel(
            id: decodedData['id'],
            soKhung: decodedData['soKhung'],
            tenTaiXe: decodedData['tenTaiXe'],
            benVanChuyen: decodedData['benVanChuyen'],
            soXe: decodedData['soXe'],
            doiTac_Id: decodedData['doiTac_Id'],
            bienSo_Id: decodedData['bienSo_Id'],
            taiXe_Id: decodedData['taiXe_Id'],
            noiDi_Id:  decodedData['noiDi_Id'],
             noiDen_Id:  decodedData['noiDen_Id'],
             noiDiKH: decodedData['noiDiKH'],
             noiDenKH: decodedData['noiDenKH']
            

          );
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        // openSnackBar(context, errorMessage);
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _khgx = null;
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
