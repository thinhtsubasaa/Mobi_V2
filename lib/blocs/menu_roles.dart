import 'dart:convert';

import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/models/menurole.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:Thilogi/services/request_helper.dart';
import 'package:provider/provider.dart';

import '../pages/QLBaixe/QLBaixe.dart';
import '../pages/qlkho/QLKhoXe.dart';
import '../utils/next_screen.dart';

class MenuRoleBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  List<MenuRoleModel>? _menurole;
  List<MenuRoleModel>? get menurole => _menurole;

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
  String? rule;
  String? url;

  Future<void> getData(
      BuildContext context, DonVi_Id, String PhanMem_Id) async {
    _isLoading = true;

    _menurole = null;

    try {
      final http.Response response = await requestHelper
          .getData('Menu/By_User?DonVi_Id=$DonVi_Id&PhanMem_Id=$PhanMem_Id');

      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data:${decodedData}");

        // if (decodedData != null) {

        // _menurole = []; // Khởi tạo danh sách mới để lưu trữ các MenuRoleModel
        // for (var item in decodedData) {
        //   _menurole?.add(
        //     MenuRoleModel(
        //       id: item['id'],
        //       tenMenu: item['tenMenu'],
        //       url: item['url'],
        //     ),
        //   );

        // }
        if (decodedData != null) {
          _menurole = (decodedData as List).map((p) {
            return MenuRoleModel.fromJson(p);
          }).toList();

          // url = _menurole
          //     ?.firstWhere((menuRole) => menuRole.url == 'Bao-cao',
          //         // ignore: null_check_always_fails
          //         orElse: () => null!)
          //     .url;

          // print("url:$url");
        }

        notifyListeners();
      } else {
        _menurole = null;
        _isLoading = false;
      }
    } catch (e) {
      _hasError = true;
      _isLoading = false;
      _message = e.toString();
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
