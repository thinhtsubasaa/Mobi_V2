import 'package:Thilogi/pages/dongSeal/custom_body_dongseal.dart';
import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';

import 'package:sizer/sizer.dart';
import '../../widgets/custom_card.dart';

class DongSealPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: Container(
              width: 100.w,
              decoration: const BoxDecoration(
                  // image: DecorationImage(
                  //   image: AssetImage(AppConfig.backgroundImagePath),
                  //   fit: BoxFit.contain,
                  // ),
                  ),
              child: CustomBodyDongSealXe(),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE96327),
            Color(0xFFBC2925),
          ],
        ),
      ),
      child: customTitle(
        'KIỂM TRA - ĐÓNG SEAL',
      ),
    );
  }
}
