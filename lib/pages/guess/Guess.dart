import 'package:flutter/material.dart';
import 'package:Thilogi/pages/guess/custom_body_guess.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:sizer/sizer.dart';
import '../../config/config.dart';

class GuessPage extends StatelessWidget {
  int currentPage = 0;
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  Container(
                    child: Column(
                      children: [
                        CustomBodyGuess(),
                        const SizedBox(height: 20),
                        Container(
                          width: 100.w,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const CustomTitleLogin(
                                text: 'THÔNG TIN DỊCH VỤ\n DÀNH CHO KHÁCH HÀNG',
                              ),
                              SizedBox(height: 10),
                              Text("......"),
                              const SizedBox(height: 20),
                              PageIndicator(
                                currentPage: currentPage,
                                pageCount: pageCount,
                              ),
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
        },
      ),
    );
  }
}

class CustomTitleLogin extends StatelessWidget {
  final String text;

  const CustomTitleLogin({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF0469B9),
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.17,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Key? key;

  const CustomAppBar({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Image.asset(
        AppConfig.appBarImagePath,
      ),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  PageIndicator({required this.currentPage, required this.pageCount});

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: pageCount,
      position: currentPage.toDouble(),
      decorator: DotsDecorator(
        size: const Size.square(9.0),
        activeSize: const Size(18.0, 9.0),
        color: Colors.grey,
        activeColor: Colors.blue,
        spacing: const EdgeInsets.all(6.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }
}
