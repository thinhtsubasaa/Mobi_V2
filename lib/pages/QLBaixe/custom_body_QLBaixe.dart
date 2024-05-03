import 'package:Thilogi/pages/dongSeal/dongseal.dart';
import 'package:Thilogi/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/baixe/baixe.dart';
import 'package:Thilogi/pages/chuyenxe/chuyenxe.dart';
import 'package:Thilogi/pages/DongCont/dongcont.dart';
import 'package:Thilogi/widgets/custom_page_indicator.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/menu_roles.dart';
import '../../config/config.dart';
import '../../models/menurole.dart';
import '../../services/request_helper.dart';
import '../khoxe/khoxe.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyQLBaiXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyQLBaiXeScreen());
  }
}

class BodyQLBaiXeScreen extends StatefulWidget {
  const BodyQLBaiXeScreen({Key? key}) : super(key: key);

  @override
  _BodyQLBaiXeScreenState createState() => _BodyQLBaiXeScreenState();
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class _BodyQLBaiXeScreenState extends State<BodyQLBaiXeScreen>
    with SingleTickerProviderStateMixin, ChangeNotifier {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  bool _loading = false;
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = 'cd9961bf-f656-4382-8354-803c16090314';
  late MenuRoleBloc _mb;
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
    _mb = Provider.of<MenuRoleBloc>(context, listen: false);
    // _mb.getData(context, DonVi_Id, PhanMem_Id);
    _menuRoleFuture = _fetchMenuRoles();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  Future<List<MenuRoleModel>> _fetchMenuRoles() async {
    // Thực hiện lấy dữ liệu từ MenuRoleBloc
    await _mb.getData(context, DonVi_Id, PhanMem_Id);
    return _mb.menurole ?? [];
  }

  // bool userHasPermission(String? url1) {
  //   print(_mb.menurole);
  //   print('url5:$url1');
  //   // Kiểm tra xem _mb.menurole có null không
  //   if (_mb.menurole != null) {
  //     url = _mb.menurole!
  //         .firstWhere((menuRole) => menuRole.url == url1,
  //             orElse: () => MenuRoleModel() as MenuRoleModel)
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
    return _loading
        ? LoadingWidget(context)
        : Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            margin: const EdgeInsets.only(top: 25, bottom: 25),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (userHasPermission(menuRoles, 'nhap-bai-xe-mobi'))
                      CustomButton(
                        'NHẬP BÃI XE',
                        Stack(
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
                                'assets/images/car2.png',
                                width: 50,
                                height: 55,
                              ),
                            ),
                          ],
                        ),
                        () {
                          _handleButtonTap(BaiXePage());
                        },
                      ),
                    const SizedBox(width: 20),
                    if (userHasPermission(menuRoles, 'dieu-chuyen-xe-mobi'))
                      CustomButton(
                        'ĐIỀU CHUYỂN XE',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/car3.png',
                              width: 120,
                              height: 80,
                            ),
                            Transform.translate(
                              offset: const Offset(0, 3),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 60),
                                child: Image.asset(
                                  'assets/images/car4.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          _handleButtonTap(ChuyenXePage());
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (userHasPermission(menuRoles, 'xuat-kho-xe-mobi'))
                      CustomButton(
                        'XUẤT KHO XE',
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/car5.png',
                              width: 120,
                              height: 80,
                            ),
                            Transform.translate(
                              offset: const Offset(0, -3),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 70),
                                child: Image.asset(
                                  'assets/images/car4.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                        () {
                          _handleButtonTap(KhoXePage());
                        },
                      ),
                    SizedBox(width: 20),
                    if (userHasPermission(menuRoles, 'dong-cont-mobi'))
                      CustomButton(
                        'ĐÓNG CONT',
                        Stack(
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
                        () {
                          _handleButtonTap(XuatCongXePage());
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (userHasPermission(menuRoles, 'dong-seal-mobi'))
                      CustomButton(
                        'ĐÓNG SEAL',
                        Stack(
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
                        () {
                          _handleButtonTap(DongSealPage());
                        },
                      ),
                  ],
                ),
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
            fontFamily: 'Comfortaa',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppConfig.primaryColor,
          ),
        ),
      ],
    ),
  );
}
