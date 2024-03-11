import 'package:flutter/foundation.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KhoXeBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? _fullName;
  String? get name => _fullName;

  String? _id;
  String? get id => _id;

  String? _maKhoXe;
  String? get maxKhoXe => _maKhoXe;

  String? _tenKhoXe;
  String? get tenKhoXe => _tenKhoXe;

  bool _isLogistic = false;
  bool get isLogistic => _isLogistic;

  Future saveKhoXeData(KhoXeModel khoxeModel) async {
    // ignore: unnecessary_null_comparison
    if (khoxeModel != null) {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString('id', khoxeModel.id ?? '');
      sp.setString('maKhoXe', khoxeModel.maKhoXe ?? '');
      sp.setString('tenKhoXe', khoxeModel.tenKhoXe ?? '');
      sp.setBool('isLogistic', khoxeModel.isLogistic ?? false);

      _id = khoxeModel.id;
      _maKhoXe = khoxeModel.maKhoXe;
      _tenKhoXe = khoxeModel.tenKhoXe;
      _isLogistic = khoxeModel.isLogistic ?? false;

      notifyListeners();
    }
  }

  Future getKhoXeData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _id = sp.getString('id');
    _maKhoXe = sp.getString('maKhoXe');
    _tenKhoXe = sp.getString('tenKhoXe');
    _isLogistic = sp.getBool('isLogistic')!;
    notifyListeners();
  }
}
