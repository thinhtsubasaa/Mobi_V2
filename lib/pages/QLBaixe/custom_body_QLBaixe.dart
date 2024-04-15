import 'package:Thilogi/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/baixe/baixe.dart';
import 'package:Thilogi/pages/chuyenxe/chuyenxe.dart';
import 'package:Thilogi/pages/DongCont/dongcont.dart';
import 'package:Thilogi/widgets/custom_page_indicator.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:sizer/sizer.dart';

import '../../config/config.dart';
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
    with SingleTickerProviderStateMixin {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            margin: const EdgeInsets.only(top: 25, bottom: 25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _handleButtonTap(BaiXePage());
                                },
                                icon: Stack(
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
                                iconSize: 60,
                                padding: EdgeInsets.zero,
                                alignment: Alignment.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'NHẬP BÃI XE',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppConfig.primaryColor,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
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
                              _handleButtonTap(ChuyenXePage());
                            },
                            icon: Stack(
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
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ĐIỀU CHUYỂN XE',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppConfig.primaryColor,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
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
                              _handleButtonTap(KhoXePage());
                            },
                            icon: Stack(
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
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'XUẤT KHO XE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppConfig.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
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
                              _handleButtonTap(XuatCongXePage());
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
                        const SizedBox(height: 8),
                        const Text(
                          'ĐÓNG CONT',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppConfig.primaryColor,
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
