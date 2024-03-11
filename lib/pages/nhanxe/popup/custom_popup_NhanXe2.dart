import 'package:flutter/material.dart';

import 'package:Thilogi/pages/nhanxe/NhanXe3.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:sizer/sizer.dart';

// ignore: use_key_in_widget_constructors
class PopUp2 extends StatelessWidget {
  String soKhung;
  String tenMau;
  String tenSanPham;
  List phuKien;

  PopUp2({
    required this.soKhung,
    required this.tenMau,
    required this.tenSanPham,
    required this.phuKien,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        alignment: Alignment.bottomCenter,
        constraints: BoxConstraints(
          maxHeight: screenHeight *
              0.9, // Đặt chiều cao tối đa của popup là 90% của chiều cao màn hình
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white.withOpacity(0.9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(), // Đặt phần này ở đây để nó không cuộn cùng nội dung
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputFields(),
                    _buildCarDetails(),
                    _buildTableOptions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 8.h,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.red,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 50),
          const Text(
            'NHẬN XE',
            style: TextStyle(
              fontFamily: 'Myriad Pro',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 36 / 30,
              letterSpacing: 0.0,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              // Add functionality for the close button
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin xe Kiểm Tra',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 1, color: Color(0xFFA71C20)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCarDetails() {
    return Column(
      children: [
        // Box 1
        Container(
          margin: EdgeInsets.all(10), // Khoảng cách giữa các box
          child: Column(
            children: [
              Row(
                children: [
                  // Text
                  Text(
                    tenSanPham,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Coda Caption',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.56, // Corresponds to line-height of 28px
                      letterSpacing: 0,
                      color: Color(0xFFA71C20),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    // Text 1
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        // Text 1
                        Text(
                          'Số khung (VIN):',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                            letterSpacing: 0,
                            color: Color(0xFF818180),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Text 2
                        Text(
                          soKhung,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.125,
                            letterSpacing: 0,
                            color: Color(0xFFA71C20),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 60), // Khoảng cách giữa hai Text

                    // Text 2
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text 1
                        Text(
                          'Màu:',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                            letterSpacing: 0,
                            color: Color(0xFF818180),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Text 2
                        Text(
                          tenMau,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.125,
                            letterSpacing: 0,
                            color: Color(0xFFFF0007),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableOptions() {
    int index = 0; // Biến đếm số thứ tự
    return Container(
      width: 100.w,
      height: 100.h,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DS Option theo xe',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(),
            columnWidths: {
              0: FlexColumnWidth(0.2), // Cột 'TT' chiếm 20% chiều ngang
              1: FlexColumnWidth(0.6), // Cột 'Tên Option' chiếm 60% chiều ngang
              2: FlexColumnWidth(0.2), // Cột 'Số lượng' chiếm 20% chiều ngang
            },
            children: [
              TableRow(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    child: _buildTableCell('TT', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child:
                        _buildTableCell('Tên Option', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Số lượng', textColor: Colors.white),
                  ),
                ],
              ),
              ...phuKien?.map((item) {
                    index++; // Tăng số thứ tự sau mỗi lần lặp

                    return TableRow(
                      children: [
                        _buildTableCell(index.toString()), // Số thứ tự
                        _buildTableCell(item.tenPhuKien ?? ""),
                        _buildTableCell(item.giaTri ??
                            ""), // Giả sử mỗi item có một trường 'giaTri'
                      ],
                    );
                  })?.toList() ??
                  [],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String content, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        content,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
