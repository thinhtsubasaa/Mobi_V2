import 'package:flutter/foundation.dart';
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? _soKhung;
  String? get soKhung => _soKhung;

  String? _id;
  String? get id => _id;

  String? _tenSanPham;
  String? get tenSanPham => _tenSanPham;

  String? _tenMau;
  String? get tenMau => _tenMau;

  String? _tenKho;
  String? get tenKho => _tenKho;

  String? _soMay;
  String? get soMay => _soMay;

  Future saveScanData(ScanModel scanModel) async {
    // ignore: unnecessary_null_comparison
    if (scanModel != null) {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString('id', scanModel.id ?? '');
      sp.setString('soKhung', scanModel.soKhung ?? '');
      sp.setString('tenSanPham', scanModel.tenSanPham ?? '');
      sp.setString('tenMau', scanModel.tenMau ?? '');
      sp.setString('tenKho', scanModel.tenKho ?? '');
      sp.setString('soMay', scanModel.soMay ?? '');

      _id = scanModel.id;
      _soKhung = scanModel.soKhung;
      _tenSanPham = scanModel.tenSanPham;
      _tenMau = scanModel.tenMau;
      _tenKho = scanModel.tenKho;
      _soMay = scanModel.soMay;

      notifyListeners();
    }
  }

  Future getScanData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _id = sp.getString('id');
    _soKhung = sp.getString('soKhung');
    _tenSanPham = sp.getString('tenSanPham');
    _tenMau = sp.getString('tenMau');
    _tenKho = sp.getString('tenKho');
    _soMay = sp.getString('soMay');

    notifyListeners();
  }
}
