import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBloc extends ChangeNotifier {
  SharedPreferences? _pref;

  String _apiUrl = "http://14.241.134.199:8021";
  String get apiUrl => _apiUrl;

  String? _chuyenId;
  String? get chuyenId => _chuyenId;

  String? _tenChuyen;
  String? get tenChuyen => _tenChuyen;

  String? _tenNhomChucNang;
  String? get tenNhomChucNang => _tenNhomChucNang;

  bool _isNhapKho = false;
  bool get isNhapKho => _isNhapKho;

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

  Future saveData(String? cId, String tC, String tNcn, bool isNhapKho) async {
    await _initPrefs();
    await _pref!.setString('chuyenId', cId!.toString());
    await _pref!.setString('tenChuyen', tC);
    await _pref!.setString('tenNhomChucNang', tNcn);
    await _pref!.setBool('_isNhapKho', isNhapKho);

    _chuyenId = cId;
    _tenChuyen = tC;
    _tenNhomChucNang = tNcn;
    _isNhapKho = isNhapKho;
    notifyListeners();
  }

  Future getData() async {
    await _initPrefs();
    _chuyenId = _pref!.getString('chuyenId');
    _tenChuyen = _pref!.getString('tenChuyen');
    _tenNhomChucNang = _pref!.getString('tenNhomChucNang');
    _isNhapKho = _pref!.getBool('isNhapKho') ?? false;
    _appVersion = _pref!.getString('appVersion');
    notifyListeners();
  }

  Future clearData() async {
    _chuyenId = null;
    _tenChuyen = null;
    _tenNhomChucNang = null;
    _isNhapKho = false;
    notifyListeners();
  }
}
