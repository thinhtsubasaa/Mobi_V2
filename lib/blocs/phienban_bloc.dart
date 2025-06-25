import 'dart:convert';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/services/request_helper.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../models/phienban.dart';

class PhienBanBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  PhienBanModel? _phienban;
  PhienBanModel? get phienban => _phienban;

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

  Future<void> getData(BuildContext context) async {
    final AppBloc _ab = context.read<AppBloc>();
    _isLoading = true;
    _phienban = null;
    // String apiUrl = 'https://apiwms.thilogi.vn/api/PhienBan/PhienBan_New';
    try {
      final http.Response response = await http.get(Uri.parse('${_ab.apiUrl}/api/PhienBan/PhienBan_New'));
      print("Api_PhienBan: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _phienban = PhienBanModel(
            id: decodedData['id'],
            maPhienBan: decodedData['maPhienBan'],
            moTa: decodedData['moTa'],
          );
        }
      } else {
        _phienban = null;
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
