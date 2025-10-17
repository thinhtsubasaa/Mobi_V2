import 'dart:convert';
import 'package:Thilogi/pages/login/Login.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:Thilogi/utils/next_screen.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../../blocs/menu_roles.dart';
import '../../../config/config.dart';
import '../../../models/menurole.dart';
import '../../../widgets/loading.dart';
import '../mms_danhsachphuongtien/dsphuongtien.dart';
import '../mms_quanlydanhsachphuongtien/qldsphuongtien.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyMMS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyMMSScreen());
  }
}

class BodyMMSScreen extends StatefulWidget {
  const BodyMMSScreen({Key? key}) : super(key: key);

  @override
  _BodyMMSScreenState createState() => _BodyMMSScreenState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyMMSScreenState extends State<BodyMMSScreen> with TickerProviderStateMixin, ChangeNotifier {
  int currentPage = 0;
  int pageCount = 3;
  bool _loading = false;
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = '10517ff1-8e30-42eb-bac0-6b4902944fdb';
  late MenuRoleBloc _mb;
  List<MenuRoleModel>? _menurole;
  List<MenuRoleModel>? get menurole => _menurole;

  static RequestHelper requestHelper = RequestHelper();
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _message;
  String? get message => _message;

  String? url;
  late Future<List<MenuRoleModel>> _menuRoleFuture;

  late bool hasAdminRole = false;

  @override
  void initState() {
    super.initState();
    _checkInternetAndShowAlert();
    _mb = Provider.of<MenuRoleBloc>(context, listen: false);
    _menuRoleFuture = _fetchMenuRoles();
    getDataRole(context);
    // getListXeRaCong();
    FlutterAppBadger.isAppBadgeSupported().then((isSupported) {
      print("Badge supported: $isSupported");
      if (!isSupported) {
        print("Badge is not supported on this device or launcher.");
      }
    });
  }

  Future<void> getDataRole(BuildContext context) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.getData('Role/RoleById');
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("Role:${decodedData}");

        if (decodedData is List) {
          // Kiểm tra xem danh sách có phải List<String> không
          bool isStringList = decodedData.every((item) => item is String);

          if (isStringList) {
            List<String> roleList = List<String>.from(decodedData);
            hasAdminRole = roleList.contains("ADMINISTRATOR_MMS");
            if (hasAdminRole) {
              print("Người dùng có quyền Administrator");
            } else {
              print("Người dùng không có quyền Administrator");
            }
          } else {
            throw Exception("Dữ liệu API không đúng định dạng List<String>");
          }
        } else {
          throw Exception("Dữ liệu API không phải là List");
        }

        notifyListeners();
      } else {
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

  Future<List<MenuRoleModel>> _fetchMenuRoles() async {
    // Thực hiện lấy dữ liệu từ MenuRoleBloc
    await _mb.getData(context, DonVi_Id, PhanMem_Id);
    return _mb.menurole ?? [];
  }

  void _checkInternetAndShowAlert() {
    AppService().checkInternet().then((hasInternet) async {
      if (!hasInternet!) {
        // Reset the button state if necessary

        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
          confirmBtnText: 'Đồng ý',
        );
      }
    });
  }

  // bool userHasPermission(String? url1) {
  //   print(_mb.menurole);
  //   print('url5:$url1');
  //   // Kiểm tra xem _mb.menurole có null không
  //   if (_mb.menurole != null) {
  //     url = _mb.menurole!
  //         .firstWhere((menuRole) => menuRole.url == url1,
  //             orElse: () => MenuRoleModel())
  //         ?.url;
  //     print('url1:$url');
  //     if (url == url1) {
  //       print("object:$url");
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     // Trả về false nếu _mb.menurole là null
  //     return false;
  //   }
  // }

  bool userHasPermission(List<MenuRoleModel> menuRoles, String? url1) {
    // Kiểm tra xem menuRoles có chứa quyền truy cập đến url1 không
    return menuRoles.any((menuRole) => menuRole.url == url1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuRoleModel>>(
      future: _menuRoleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget(context);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          // Chuyển hướng sang trang đăng nhập nếu không có dữ liệu
          Future.microtask(() => _goToLoginPage());
          return Container();
        } else {
          // Dữ liệu đã được tải, xây dựng giao diện
          return _buildContent(snapshot.data!);
        }
      },
    );
  }

  void _goToLoginPage() {
    nextScreenReplace(context, LoginPage());
  }

  @override
  @override
  Widget _buildContent(List<MenuRoleModel> menuRoles) {
    return _loading
        ? LoadingWidget(context)
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              margin: const EdgeInsets.only(top: 25, bottom: 25),
              child: Wrap(
                spacing: 20.0, // khoảng cách giữa các nút
                runSpacing: 20.0, // khoảng cách giữa các hàng
                alignment: WrapAlignment.center,
                children: [
                  if (userHasPermission(menuRoles, 'quan-ly-phuong-tien-mobi'))
                    CustomButton(
                      'QUẢN LÝ PHƯƠNG TIỆN',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Main_button_THILOTrans.png',
                          ),
                        ],
                      ),
                      () {
                        if (hasAdminRole) {
                          _handleButtonTap(DanhSachPhuongTienQLPage());
                        } else {
                          _handleButtonTap(DanhSachPhuongTienPage());
                        }
                      },
                    ),
                  if (userHasPermission(menuRoles, 'quan-ly-phuong-tien-admin-mobi'))
                    CustomButton(
                      'QUẢN LÝ PHƯƠNG TIỆN (QL)',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Main_button_THILOTrans.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(DanhSachPhuongTienQLPage());
                      },
                    ),
                  if (userHasPermission(menuRoles, 'quan-ly-phuong-tien-tai-xe-mobi'))
                    CustomButton(
                      'QUẢN LÝ PHƯƠNG TIỆN (TX)',
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Main_button_THILOTrans.png',
                          ),
                        ],
                      ),
                      () {
                        _handleButtonTap(DanhSachPhuongTienPage());
                      },
                    ),
                  // if (userHasPermission(menuRoles, 'quan-ly-thiet-bi-mobi'))
                  //   CustomButton(
                  //     'QUẢN LÝ THIẾT BỊ',
                  //     Stack(
                  //       alignment: Alignment.center,
                  //       children: [
                  //         Image.asset(
                  //           'assets/images/Main_button_THILOTrans.png',
                  //         ),
                  //       ],
                  //     ),
                  //     () {
                  //       _handleButtonTap(DanhSachThietBiPage());
                  //     },
                  //   ),
                ],
              ),
            ),
          );
  }

  void _handleButtonTap(Widget page) {
    setState(() {
      _loading = true;
    });
    nextScreen(context, page);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
  }
}

Widget CustomButton(String buttonText, Widget page, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 35.w,
      // height: 35.h,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: page,
          ),
          Text(
            buttonText.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppConfig.titleColor,
            ),
          ),
        ],
      ),
    ),
  );
}
