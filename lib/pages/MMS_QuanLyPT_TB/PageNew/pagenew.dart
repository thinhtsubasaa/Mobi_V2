import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/scheduler.dart';

class PageNew extends StatefulWidget {
  @override
  _PageNewState createState() => _PageNewState();
}

class _PageNewState extends State<PageNew> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Thời gian chạy từ trái sang phải
    )..repeat(reverse: true); // Lặp lại và đảo ngược liên tục

    _animation = Tween<double>(begin: -50.w, end: 50.w).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        padding: EdgeInsets.only(top: 20),
        color: Colors.white,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_animation.value, 0), // Di chuyển ngang
              child: child,
            );
          },
          child: Text(
            'CHUẨN BỊ LÀM',
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
