import 'package:flutter/material.dart';
import 'package:project/widgets/widget_body/map.dart';

class CustomTrackingXeVitri extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 470,
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
          Positioned(
            child: Container(
              width: 55,
              height: 470,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Color(0xFFF6C6C7),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Text(
                      '15/01/2023\n(13h45)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Comfortaa',
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 50,
            top: 0,
            child: Container(
              width: 320,
              height: 470,
              child: Stack(
                children: [
                  HomePage(),
                  // Positioned(
                  //   right: 100,
                  //   top:
                  //       210, // Adjust the top position to center the line vertically
                  //   child: Container(
                  //     width: 250, // Set the width to match the container width
                  //     height:
                  //         1, // Set the height to the desired thickness of the line
                  //     child: CustomPaint(
                  //       painter: DashedLinePainter(),
                  //     ), // Set the color of the line
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.square;

    double dashWidth = 5.0;
    double dashSpace = 5.0;

    double startY = size.height / 2;
    double endX = size.width;

    for (double offsetX = 0;
        offsetX < endX - 39; // Trừ đi chiều rộng của hộp tròn
        offsetX += (dashWidth + dashSpace)) {
      canvas.drawLine(
          Offset(offsetX, startY), Offset(offsetX + dashWidth, startY), paint);
    }

    // Vẽ hộp tròn ở cuối
    paint.color = const Color(0xFF7F7F7F); // Màu nền của hộp tròn
    paint.strokeWidth = 10.0;
    paint.style = PaintingStyle.fill;

    double circleRadius = 5.0; // Bán kính của hộp tròn

    double circleOffsetX =
        endX - 28 + circleRadius; // Điều chỉnh vị trí X của hộp tròn
    canvas.drawCircle(Offset(circleOffsetX, startY), circleRadius, paint);
    double circleOffsetY =
        endX - 220 + circleRadius; // Điều chỉnh vị trí X của hộp tròn
    canvas.drawCircle(Offset(circleOffsetY, startY), circleRadius, paint);

    // Vẽ hộp tròn to bao quanh
    Paint outerCircleBackgroundPaint = Paint()
      ..color =
          const Color.fromARGB(0, 165, 165, 162) // Màu nền của hộp tròn to
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    double outerCircleRadius = 18.5; // Bán kính của hộp tròn to
    canvas.drawCircle(Offset(circleOffsetX, startY), outerCircleRadius,
        outerCircleBackgroundPaint);

    // Vẽ đường viền xung quanh hộp tròn to
    Paint outerCircleBorderPaint = Paint()
      ..color = Colors.red // Màu đường viền của hộp tròn to
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(circleOffsetX, startY), outerCircleRadius,
        outerCircleBorderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
