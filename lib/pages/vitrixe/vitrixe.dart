import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/baixe/custom_body_baixe.dart';

import 'package:sizer/sizer.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';

class VitriXePage extends StatelessWidget {
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
                        CustomBodyBaiXe(),
                        SizedBox(height: 20),
                        Container(
                          width: 100.w,
                          child: Column(
                            children: [
                              customTitle('KIỂM TRA - NHẬN XE'),
                              SizedBox(height: 10),
                              customBottom(
                                "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI",
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
