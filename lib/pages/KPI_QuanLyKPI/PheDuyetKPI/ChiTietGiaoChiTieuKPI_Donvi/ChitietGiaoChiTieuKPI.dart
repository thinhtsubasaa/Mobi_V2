import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import 'custom_body_ChitietGiaochitieuKPI_dk.dart';

class ChiTietGiaoChiTieuKPI_DonViPage extends StatefulWidget {
  final String? id;
  final String? kyDanhGia;
  final bool isChiTiet;

  const ChiTietGiaoChiTieuKPI_DonViPage({
    super.key,
    required this.id,
    required this.kyDanhGia,
    required this.isChiTiet,
  });

  State<ChiTietGiaoChiTieuKPI_DonViPage> createState() => _ChiTietGiaoChiTieuKPI_DonViPage();
}

class _ChiTietGiaoChiTieuKPI_DonViPage extends State<ChiTietGiaoChiTieuKPI_DonViPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.isChiTiet ? "Chi tiết đăng ký KPI" : "Duyệt đăng ký KPI"),
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
              child: BodyGiaoChiTieuKPI_DonViScreen2(
                id: widget.id,
                lstFiles: [],
                isChiTiet: widget.isChiTiet,
              ),
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
