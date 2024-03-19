import 'package:Thilogi/pages/giaoxe/custom_body_giaoxe.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';

import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

// ignore: use_key_in_widget_constructors
class GiaoXePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  Container(
                    width: 100.w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppConfig.backgroundImagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        // CustomCard(),
                        SizedBox(height: 5),
                        CustomBodyGiaoXe(),
                        const SizedBox(height: 20),
                        Container(
                          width: 100.w,
                          child: Column(
                            children: [
                              customTitle('KIỂM TRA - NHẬN XE'),
                              SizedBox(height: 10),
                              customBottom(
                                  "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI"),
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
