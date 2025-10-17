import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:Thilogi/widgets/custom_card.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'custom_body_lambaithi.dart';

class LamBaiThiPage extends StatelessWidget {
  final String deThiId;
  final String? userId;
  final String? baiThiId;
  const LamBaiThiPage({super.key, required this.deThiId, required this.userId, required this.baiThiId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        children: [
          const CustomCard(),
          Expanded(
            child: Container(
              width: 100.w,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppConfig.backgroundImagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: CustomBodyLamBaiThi(deThiId: deThiId, userId: userId!, baiThiId: baiThiId!,),
            ),
          ),
          // const BottomContent(),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  const BottomContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'Làm Bài Thi',
        ),
      ),
    );
  }
}
