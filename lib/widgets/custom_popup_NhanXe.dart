import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class PopUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.bottomCenter,
        width: 380,
        height: 710,
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
            _buildTopBar(),
            _buildInputFields(),
            _buildCarDetails(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: 380,
      height: 50,
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
            'Thông Tin Xác Nhận',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 1, color: Color(0xFFA71C20)),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputBox(text: "Người nhận"),
                const SizedBox(height: 4),
                CustomInputBox(text: "Nơi nhận xe"),
                const SizedBox(height: 4),
                CustomInputBox(text: "Người nhận"),
                const SizedBox(height: 4),
                CustomInputBox(text: "Ghi chú"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetails() {
    return Column(
      children: [
        // Box 1
        Container(
          margin: const EdgeInsets.all(10), // Khoảng cách giữa các box
          child: Column(
            children: [
              const Row(
                children: [
                  // Text
                  Text(
                    'MAZDA CX 5 DELUX MT',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Coda Caption',
                      fontSize: 20,
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
                child: const Row(
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
                          'MALA851CBHM557809',
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

                    SizedBox(width: 85), // Khoảng cách giữa hai Text

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
                          'Đỏ',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 16,
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
              Container(
                padding: const EdgeInsets.all(10),
                child: const Row(
                  children: [
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),

                        // Text 1
                        Text(
                          'Số máy:',
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
                          '----------------',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.125,
                            letterSpacing: 0,
                            color: Color(0xFFA71C20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              // Xử lý sự kiện khi nút được nhấn
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B528),
              fixedSize: const Size(380, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'KIỂM TRA OPTION THEO XE',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Xử lý sự kiện khi nút được nhấn
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              fixedSize: const Size(380, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'KIỂM TRA HẠNG MỤC KHÁC',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          ElevatedButton(
            onPressed: () {
              // Xử lý sự kiện khi nút được nhấn
            },
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFFE96327),
              fixedSize: const Size(350, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text(
              'XÁC NHẬN',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 7),
        ],
      ),
    );
  }
}

class CustomInputBox extends StatelessWidget {
  final String text;

  CustomInputBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 304,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6C6C7),
                border: Border(
                  right: BorderSide(
                    color: Color(0xFF818180),
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  '',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
