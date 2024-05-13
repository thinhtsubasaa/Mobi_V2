import 'dart:convert';
import 'dart:ffi';

import 'package:Thilogi/pages/vanchuyen/giaoxe/VanChuyen.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/QLBaixe/QLBaixe.dart';
import 'package:Thilogi/pages/giaoxe/giaoxe.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:Thilogi/pages/tracking/TrackingXe_Vitri.dart';
import 'package:Thilogi/widgets/custom_page_indicator.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../blocs/menu_roles.dart';
import '../../config/config.dart';
import '../../models/menurole.dart';
import '../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyQLKhoXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyQLKhoXeScreen());
  }
}

class BodyQLKhoXeScreen extends StatefulWidget {
  const BodyQLKhoXeScreen({Key? key}) : super(key: key);

  @override
  _BodyQLKhoXeScreenState createState() => _BodyQLKhoXeScreenState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyQLKhoXeScreenState extends State<BodyQLKhoXeScreen>
    with SingleTickerProviderStateMixin, ChangeNotifier {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  bool _loading = false;
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = 'cd9961bf-f656-4382-8354-803c16090314';
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

  @override
  void initState() {
    super.initState();
    // getData(context, DonVi_Id, PhanMem_Id);
    _mb = Provider.of<MenuRoleBloc>(context, listen: false);
    // _mb.getData(context, DonVi_Id, PhanMem_Id);
    _menuRoleFuture = _fetchMenuRoles();

    // setState(() {

    // });
  }

  Future<List<MenuRoleModel>> _fetchMenuRoles() async {
    // Thực hiện lấy dữ liệu từ MenuRoleBloc
    await _mb.getData(context, DonVi_Id, PhanMem_Id);
    return _mb.menurole ?? [];
  }

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

        if (decodedData != null) {
          _menurole = (decodedData as List).map((p) {
            return MenuRoleModel.fromJson(p);
          }).toList();

          print(_menurole);
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
        } else {
          // Dữ liệu đã được tải, xây dựng giao diện
          return _buildContent(snapshot.data!);
        }
      },
    );
  }

  @override
  Widget _buildContent(List<MenuRoleModel> menuRoles) {
    // _mb.getData(context, DonVi_Id, PhanMem_Id);
    return _loading
        ? LoadingWidget(context)
        : Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            margin: const EdgeInsets.only(top: 30, bottom: 30),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (userHasPermission(menuRoles, 'nhan-xe-mobi'))
                      CustomButton(
                        'KIỂM TRA NHẬN XE',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/nhanxe.png',
                            ),
                          ],
                        ),
                        () {
                          _handleButtonTap(NhanXePage());
                        },
                      ),
                    const SizedBox(width: 20),
                    if (userHasPermission(menuRoles, 'quan-ly-bai-xe-mobi'))
                      CustomButton(
                        'QUẢN LÝ BÃI XE',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/qlbaixe.png',
                            ),
                          ],
                        ),
                        () {
                          _handleButtonTap(QLBaiXePage());
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (userHasPermission(menuRoles, 'giao-xe-mobi'))
                      CustomButton(
                        'VẬN CHUYỂN/GIAO XE',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/vc_gx.png',
                            ),
                          ],
                        ),
                        () {
                          _handleButtonTap(VanChuyenPage());
                        },
                      ),
                    SizedBox(width: 15),
                    if (userHasPermission(
                        menuRoles, 'tracking-xe-thanh-pham-mobi'))
                      Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 130,
                            height: 150,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  color: Color(0x40000000),
                                ),
                              ],
                              color: AppConfig.primaryColor,
                            ),
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: () {
                                _handleButtonTap(TrackingXeVitriPage());
                              },
                              icon: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/car1.png',
                                    width: 60,
                                    height: 65,
                                  ),
                                  Transform.translate(
                                    offset: const Offset(25, -15),
                                    child: Image.asset(
                                      'assets/images/search.png',
                                      width: 50,
                                      height: 55,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Text(
                            'TRACKING XE\nTHÀNH PHẨM',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppConfig.titleColor,
                            ),
                          )
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                // PageIndicator(currentPage: currentPage, pageCount: pageCount),
              ],
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
    child: Column(
      children: [
        Container(
          width: 130,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                spreadRadius: 0,
                color: Color(0x40000000),
              ),
            ],
            color: AppConfig.primaryColor,
          ),
          alignment: Alignment.center,
          child: page,
        ),
        const SizedBox(height: 8),
        Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppConfig.titleColor,
          ),
        ),
      ],
    ),
  );
}
