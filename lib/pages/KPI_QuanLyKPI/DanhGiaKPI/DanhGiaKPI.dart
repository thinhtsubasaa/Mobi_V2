import 'package:Thilogi/pages/KPI_QuanLyKPI/DanhGiaKPI/custom_body_DanhGiaKPI.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';

import 'package:sizer/sizer.dart';

import '../../../../widgets/custom_appbar.dart';
import '../../../../widgets/custom_card.dart';
import '../../../../widgets/custom_title.dart';
import 'custom_body_DanhGiaKPI.dart';

class DanhGiaKPIPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Đánh giá KPI cá nhân'),
      ),
      body: Column(
        children: [
          // CustomCardKPI(),
          Expanded(
            child: Container(
              width: 100.w,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomBodyDanhGiaKPI(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      backgroundColor: cs.surface,
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 12,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'ĐÁNH GIÁ KPI CÁ NHÂN',
        ),
      ),
    );
  }
}
