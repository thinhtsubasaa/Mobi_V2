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
      appBar: customAppBar(),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: 100.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConfig.backgroundImagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: CustomBodyDongSealXe(),
              ),
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
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      child: Center(
        child: customTitle(
          'KIỂM TRA - ĐÓNG SEAL',
        ),
      ),
    );
  }
}
