import 'package:flutter/material.dart';
import 'package:Thilogi/pages/QLBaixe/QLBaixe.dart';
import 'package:Thilogi/pages/giaoxe/giaoxe.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:Thilogi/pages/tracking/TrackingXe_Vitri.dart';
import 'package:Thilogi/widgets/custom_page_indicator.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:sizer/sizer.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyQLKhoXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, child: BodyQLKhoXe());
  }
}

// ignore: use_key_in_widget_constructors, must_be_immutable
class BodyQLKhoXe extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          // Hàng đầu tiên
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 130,
                    height: 135,
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
                      color: Color(0xFFBC2925),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            nextScreen(context, NhanXePage());
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

                          iconSize: 60, // Kích thước của biểu tượng
                          padding: EdgeInsets
                              .zero, // Xóa padding mặc định của IconButton
                          alignment: Alignment
                              .center, // Căn chỉnh hình ảnh vào giữa nút
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8), // Khoảng cách giữa ảnh và Text
                  const Text(
                    'KIỂM TRA NHẬN XE',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA71C20),
                    ),
                  )
                ],
              ),

              const SizedBox(width: 20), // Khoảng cách giữa 2 button

              Column(
                children: [
                  Container(
                    width: 130,
                    height: 135,
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
                      color: Color(0xFFBC2925),
                    ),
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        nextScreen(context, QLBaiXePage());
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
                  const SizedBox(height: 8), // Khoảng cách giữa ảnh và Text
                  const Text(
                    'QUẢN LÝ BÃI XE',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA71C20),
                    ),
                  )
                ],
              ),
            ],
          ),
          // Hàng thứ hai
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 130,
                    height: 135,
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
                      color: Color(0xFFBC2925),
                    ),
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        nextScreen(context, GiaoXePage());
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

                  const SizedBox(height: 8), // Khoảng cách giữa ảnh và Text
                  const Center(
                    child: Text(
                      'VẬN CHUYỂN GIAO XE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA71C20),
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
                    height: 135,
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
                      color: Color(0xFFBC2925),
                    ),
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        nextScreen(context, TrackingXeVitriPage());
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
                  const SizedBox(height: 8), // Khoảng cách giữa ảnh và Text
                  const Text(
                    'TRACKING XE\n THANH PHAM',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA71C20),
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          PageIndicator(currentPage: currentPage, pageCount: pageCount),
        ],
      ),
    );
  }
}
