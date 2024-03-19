import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// ignore: use_key_in_widget_constructors
class CustomBodyGuess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 60.h,

        // ignore: prefer_const_constructors
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(246, 198, 199, 0.2),
              Color.fromRGBO(66, 143, 202, 0.2),
            ],
          ),
        ), // Đặt màu nền cho phần này
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: MainButton());
  }
}

class MainButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            // Xử lý khi button 1 được nhấn
          },
          child: Container(
            width: 35.w,
            height: 30.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset:
                      Offset(0, 4), // Độ dịch chuyển theo chiều ngang và dọc
                  blurRadius: 4, // Độ mờ của bóng
                  spreadRadius: 0, // Phạm vi của bóng
                  color:
                      Color(0x40000000), // Màu của bóng (0x40 là giá trị alpha)
                ),
              ],
              // Các thuộc tính khác của BoxDecoration
              color: Color(0xFF428FCA), // Màu nền // Màu nền của nút
            ),
            alignment: Alignment.center,
            child: const Center(
              child: Text(
                'THÔNG TIN\n DỊCH VỤ', // Nội dung của button
                style: TextStyle(
                  color: Colors.white, // Màu chữ
                  fontFamily: 'Comfortaa',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 5.w),
        GestureDetector(
          onTap: () {
            // Xử lý khi button 1 được nhấn
          },
          child: Container(
            width: 35.w,
            height: 30.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset:
                      Offset(0, 4), // Độ dịch chuyển theo chiều ngang và dọc
                  blurRadius: 4, // Độ mờ của bóng
                  spreadRadius: 0, // Phạm vi của bóng
                  color:
                      Color(0x40000000), // Màu của bóng (0x40 là giá trị alpha)
                ),
              ],
              // Các thuộc tính khác của BoxDecoration
              color: Color(0xFF428FCA), // Màu nền // Màu nền của nút
            ),
            alignment: Alignment.center,
            child: const Center(
              child: Text(
                'TRA CỨU\nĐƠN HÀNG', // Nội dung của button
                style: TextStyle(
                  color: Colors.white, // Màu chữ
                  fontFamily: 'Comfortaa',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}