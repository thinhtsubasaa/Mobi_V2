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
import '../timxe/timxe.dart';

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
    with TickerProviderStateMixin, ChangeNotifier {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  bool _loading = false;
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = 'cd9961bf-f656-4382-8354-803c16090314';
  late MenuRoleBloc _mb;
  static RequestHelper requestHelper = RequestHelper();

  String? _message;
  String? get message => _message;

  String? url;
  late Future<List<MenuRoleModel>> _menuRoleFuture;

  @override
  void initState() {
    super.initState();
    _mb = Provider.of<MenuRoleBloc>(context, listen: false);
    _menuRoleFuture = _fetchMenuRoles();
  }

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
        : SingleChildScrollView(
            child: Container(
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
                                  'assets/images/Button_QLBaiXe_NhapBai.png',
                                ),
                              ],
                            ), () {
                          _handleButtonTap(BaiXePage());
                        }),
                      const SizedBox(width: 10),
                      if (userHasPermission(menuRoles, 'dieu-chuyen-xe-mobi'))
                        CustomButton(
                            'ĐIỀU CHUYỂN XE',
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/Button_QLBaiXe_ChuyenBai.png',
                                ),
                              ],
                            ), () {
                          _handleButtonTap(ChuyenXePage());
                        }),
                      SizedBox(width: 10),
                      CustomButton(
                          'TÌM XE',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_QLBaiXe_TimXeTrongBai.png',
                              ),
                            ],
                          ), () {
                        _handleButtonTap(TimXePage());
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      if (userHasPermission(menuRoles, 'dong-cont-mobi'))
                        CustomButton(
                          'ĐÓNG CONT',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_QLBaiXe_DongCont.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(XuatCongXePage());
                          },
                        ),
                      SizedBox(width: 20),
                      if (userHasPermission(menuRoles, 'dong-seal-mobi'))
                        CustomButton(
                          'ĐÓNG SEAL',
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Button_QLBaiXe_DongSeal.png',
                              ),
                            ],
                          ),
                          () {
                            _handleButtonTap(DongSealPage());
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  // PageIndicator(currentPage: currentPage, pageCount: pageCount),
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
      child: Column(
        children: [
          Container(
            width: 25.w,
            height: 20.h,
            alignment: Alignment.center,
            child: page,
          ),
          Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppConfig.titleColor,
            ),
          ),
        ],
      ));
}
