import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/pages/guess/custom_body_guess.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:sizer/sizer.dart';
import '../../config/config.dart';
import '../../widgets/custom_page_indicator.dart';

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
                          height: MediaQuery.of(context).size.height / 2,
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              customTitle(
                                'THÔNG TIN DỊCH VỤ\n DÀNH CHO KHÁCH HÀNG',
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

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Key? key;

  const CustomAppBar({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppConfig.appBarImagePath,
            width: 70.w,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
