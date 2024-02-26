import 'package:flutter/material.dart';

class CustomPopUpNhanXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopUp(),
    );
  }
}

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
          color: Colors.white
              .withOpacity(0.9), // You can adjust the opacity as needed
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000), // Adjust the opacity of the shadow
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 380,
              height: 50,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: Colors.red,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                  ),
                  Container(
                    child: Text(
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
                  ),
                  SizedBox(
                    width: 85,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      // Add functionality for the close button
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10), // Padding cho container chính
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    'Thông Tin Xác Nhận',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFA71C20)),
                  SizedBox(
                      height:
                          10), // Khoảng cách giữa tiêu đề và các container phía dưới
                  // Container chứa TextBox 1
                  Container(
                    height: 132, // Chiều cao của container

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomInputBox(text: "Người nhận"),
                        SizedBox(height: 4),
                        CustomInputBox(text: "Nơi nhận xe"),
                        SizedBox(height: 4),
                        CustomInputBox(
                          text: "Người nhận",
                        ),
                        SizedBox(height: 4),
                        CustomInputBox(
                          text: "Ghi chú",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  // Box 1
                  Container(
                    margin:
                        const EdgeInsets.all(10), // Khoảng cách giữa các box

                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Text
                            const Text(
                              'MAZDA CX 5 DELUX MT',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Coda Caption',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height:
                                    1.56, // Corresponds to line-height of 28px
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
                                      fontSize: 18,
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
              ),
            ),
            SizedBox(height: 115),
            Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  SizedBox(
                      height:
                          10), // Khoảng cách giữa nội dung pop-up và nút "XÁC NHẬN"
                  ElevatedButton(
                    onPressed: () {
                      // Xử lý sự kiện khi nút được nhấn
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF00B528), // Màu nền của nút
                      fixedSize:
                          const Size(380, 50), // Kích thước cố định của nút
                      padding: EdgeInsets
                          .zero, // Bỏ padding mặc định của ElevatedButton
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(5), // Độ cong của góc nút
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10), // Sát lề trái
                          child: Text(
                            'KIỂM TRA OPTION THEO XE',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 20,
                              height: 23.07 / 19.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                            child:
                                Container()), // Container để tạo ra khoảng trống giữa văn bản và icon
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 10), // Sát lề phải
                          child: Icon(
                            Icons.edit, // Icon "edit"
                            color: Colors.white, // Màu của icon
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10), // Khoảng cách giữa các nút
                  ElevatedButton(
                    onPressed: () {
                      // Xử lý sự kiện khi nút được nhấn
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFFFF0000), // Màu nền của nút
                      fixedSize:
                          const Size(380, 45), // Kích thước cố định của nút
                      padding: EdgeInsets
                          .zero, // Bỏ padding mặc định của ElevatedButton
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(5), // Độ cong của góc nút
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10), // Sát lề trái
                          child: Text(
                            'KIỂM TRA HẠNG MỤC KHÁC',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 20,
                              height: 23.07 / 19.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                            child:
                                Container()), // Container để tạo ra khoảng trống giữa văn bản và icon
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 10), // Sát lề phải
                          child: Icon(
                            Icons.edit, // Icon "edit"
                            color: Colors.white, // Màu của icon
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 7),
                  ElevatedButton(
                    onPressed: () {
                      // Xử lý sự kiện khi nút được nhấn
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFFE96327), // Màu nền của nút
                      fixedSize:
                          const Size(350, 30), // Kích thước cố định của nút
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(5), // Độ cong của góc nút
                      ),
                    ),
                    child: const Text(
                      'XÁC NHẬN',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 17,
                        height: 20.07 / 17.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
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
          color: Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
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
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 18 / 16, // line-height
                    letterSpacing: 0,

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
              child: Center(
                child: Text(
                  '',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 18 / 16, // line-height
                    letterSpacing: 0,

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
