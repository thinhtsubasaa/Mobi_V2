import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomTrackingXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 100.w,
        alignment: Alignment.bottomCenter,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height < 600
              ? MediaQuery.of(context).size.height * 0.9
              : MediaQuery.of(context).size.height * 0.6,
          // Đặt chiều cao tối đa của popup là 90% của chiều cao màn hình
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(
            color: Color(0xFFCCCCCC),
            width: 1,
          ),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Phần Text 1
            Positioned(
              left: 0, // Adjust left position as needed
              top: 0, // Adjust top position as needed
              child: Container(
                width: 15.w,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Color(0xFFF6C6C7),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Image.asset(
                    'assets/images/road.png',
                    height: MediaQuery.of(context).size.height < 600
                        ? MediaQuery.of(context).size.height * 0.9
                        : MediaQuery.of(context).size.height * 0.6,
                  ),
                ),
              ),
            ),
            // Your BodyTrackingXe widget goes here
            Positioned(
              left: 0, // Adjust left position as needed
              top: 0, // Adjust top position as needed
              child: BodyTrackingXe(),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class BodyTrackingXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 20,
          ),
          buildRowItem(
            customImage: CustomImage1(),
            textLine1: '15/01/2023 - GiaoXe - SRAnLac - Số\n BB Giao xe',
            textLine2: '',
          ),
          buildDivider(),
          buildRowItem(
            customImage: CustomImage2(),
            textLine1: '15/01/2023 - VCNB - SRAnLac - đến',
            textLine2: '15/01/2023 - VCNB - HCM - đi',
          ),
          buildDivider(),
          buildRowItem(
            customImage: CustomImage3(),
            textLine1: '11/01/2023 - HCM - Bãi xe ...',
            textLine2:
                '07/01/2023 - CLA - Bãi Xuất - Cont\n 1235123AGGS123 - seal F1242003',
          ),
          buildDivider(),
          buildRowItem(
            customImage: CustomImage4(),
            textLine1: '03/01/2023 - Kho Chu Lai - REMIND ',
            textLine2: '02/01/2023 - Kho Chu Lai - FAILED',
          ),
          buildDivider(),
          buildRowItem(
            customImage: CustomImage5(),
            textLine1: '03/01/2023 - NM KIA',
            textLine2: '01/01/2023 - NM KIA',
          ),
          buildDivider(),
        ],
      ),
    );
  }
}

class buildRowItem extends StatelessWidget {
  final Widget customImage;
  final String textLine1;
  final String textLine2;

  const buildRowItem({
    required this.customImage,
    required this.textLine1,
    required this.textLine2,
  });

  @override
  Widget build(BuildContext context) {
    // Widget buildRowItem({
    //   required Widget customImage,
    //   required String textLine1,
    //   required String textLine2,
    // }) {

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 330
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.6,
      ),
      height: 80, // Set a fixed height as needed
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            customImage, // Custom Image widget goes here
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '• ', // Dot character
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0469B9),
                    ),
                  ),
                  TextSpan(
                    text: textLine1 + '\n',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0469B9),
                    ),
                  ),
                  if (textLine2.isNotEmpty) ...[
                    TextSpan(
                      text: '• ', // Dot character
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF818180),
                      ),
                    ),
                    TextSpan(
                      text: textLine2,
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF818180),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomImage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/car4.png',
          width: 65,
          height: 85,
        ),
        Transform.translate(
          offset: const Offset(-40, -5),
          child: Image.asset(
            'assets/images/tick.png',
            width: 40,
            height: 40,
          ),
        ),
      ],
    );
  }
}

class CustomImage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/car5.png',
          width: 105,
          height: 80,
        ),
        Transform.translate(
          offset: const Offset(0, -3),
          child: Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Image.asset(
              'assets/images/car4.png',
              width: 35,
              height: 40,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomImage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/car3.png',
          width: 105,
          height: 80,
        ),
        Transform.translate(
          offset: const Offset(0, 3),
          child: Padding(
            padding: const EdgeInsets.only(right: 55),
            child: Image.asset(
              'assets/images/car4.png',
              width: 40,
              height: 40,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomImage4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/car4.png',
          width: 65,
          height: 75,
        ),
        Transform.translate(
          offset: const Offset(-25, -15),
          child: Image.asset(
            'assets/images/search.png',
            width: 40,
            height: 60,
          ),
        ),
      ],
    );
  }
}

class CustomImage5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-50, -5),
      child: Image.asset(
        'assets/images/car4.png',
        width: 70,
        height: 80,
      ),
    );
  }
}

Widget buildDivider() {
  return Container(
    width: 95.w,
    height: 2,
    padding: const EdgeInsets.only(right: 5),
    child: CustomPaint(
      painter: DashedLinePainter(
        color: const Color(0xFFD8D8D8), // Adjust the color as needed
        strokeWidth: 2, // Adjust the stroke width as needed
        dashLength: 5, // Adjust the length of each dash
        dashSpace: 3, // Adjust the space between dashes
      ),
    ),
  );
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final double totalWidth = size.width;
    final double dashTotal = dashLength + dashSpace;
    final double dashCount = (totalWidth / dashTotal).floor().toDouble();

    for (int i = 0; i < dashCount; i++) {
      final double dx = i * dashTotal;
      canvas.drawLine(Offset(dx, 0), Offset(dx + dashLength, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
