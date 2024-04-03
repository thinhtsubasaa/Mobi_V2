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
        width: 380,
        height: 550,
        margin: EdgeInsets.only(top: 23, left: 20),
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
              child: Column(
                children: [
                  // Box 1
                  Container(
                    padding: const EdgeInsets.only(top: 80),
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
                            const SizedBox(width: 55),
                            // Button
                            Container(
                              width: 70,
                              height: 14,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFF428FCA),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Xử lý sự kiện khi nút được nhấn
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Đặt màu nền của nút là trong suốt
                                  padding: const EdgeInsets.all(
                                      0), // Đặt khoảng trống bên trong nút
                                ),
                                child: const Text(
                                  'Chờ nhận',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    height:
                                        1.125, // Corresponds to line-height of 9px
                                    letterSpacing: 0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
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
                                    'Nhà máy:',
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
                                    'THACO MAZDA',
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
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFCCCCCC)),
                        SizedBox(
                          height: 190,
                        ),
                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              // Xử lý sự kiện khi nút được nhấn
                            },
                            style: ElevatedButton.styleFrom(
                              primary:
                                  const Color(0xFFE96327), // Màu nền của nút
                              fixedSize: const Size(
                                  320, 33), // Kích thước cố định của nút
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    5), // Độ cong của góc nút
                              ),
                              // Khoảng cách giữa nút và văn bản
                            ),
                            child: const Text(
                              'XÁC NHẬN',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
