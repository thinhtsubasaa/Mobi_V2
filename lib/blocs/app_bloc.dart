import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBloc extends ChangeNotifier {
  SharedPreferences? _pref;

  String _apiUrl = "http://10.17.40.172:5000";
  String get apiUrl => _apiUrl;

  String? _id;
  String? get id => _id;
  String? _soKhung;
  String? get soKhung => _soKhung;

  String? _tenKho;
  String? get tenKho => _tenKho;
  String? _tenSanPham;
  String? get tenSanPham => _tenSanPham;

  String? _tenMau;
  String? get tenMau => _tenMau;

  String? _appVersion = '1.0.0';
  String? get appVersion => _appVersion;

  _initPrefs() async {
    _pref ??= await SharedPreferences.getInstance();
  }

  Future getApiUrl() async {
    await _initPrefs();
    _apiUrl = _pref!.getString('apiUrl') != null
        ? _pref!.getString('apiUrl')!
        : _apiUrl;
    notifyListeners();
  }

  Future saveApiUrl(String url) async {
    await _initPrefs();
    await _pref!.setString('apiUrl', url);
    _apiUrl = url;
    notifyListeners();
  }

  Future saveData(
      String? iD, String sK, String tK, String tSp, String tM) async {
    await _initPrefs();
    await _pref!.setString('soKhung', iD!.toString());
    await _pref!.setString('soKhung', sK);
    await _pref!.setString('tenKho', tK);
    await _pref!.setString('tenSanPham', tSp);
    await _pref!.setString('tenMau', tM);

    _id = iD.toString();
    _soKhung = sK;
    _tenKho = tK;
    _tenSanPham = tSp;
    _tenMau = tM;
    notifyListeners();
  }

  Future getData() async {
    await _initPrefs();
    _id = _pref!.getString('id');
    _soKhung = _pref!.getString('soKhung');
    _tenKho = _pref!.getString('tenKho');
    _tenSanPham = _pref!.getString('tenSanPham');
    _tenMau = _pref!.getString('tenMau');
    _appVersion = _pref!.getString('appVersion');
    notifyListeners();
  }

  Future clearData() async {
    _id = null;
    _soKhung = null;
    _tenKho = null;
    _tenSanPham = null;
    _tenMau = null;
    notifyListeners();
  }
}
