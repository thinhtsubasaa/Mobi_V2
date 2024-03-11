import 'package:flutter/material.dart';
import 'package:Thilogi/widgets/map.dart';

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
            left: 45,
            top: 0,
            child: Container(
              width: 320,
              height: 470,
              child: Stack(
                children: [
                  HomePage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
