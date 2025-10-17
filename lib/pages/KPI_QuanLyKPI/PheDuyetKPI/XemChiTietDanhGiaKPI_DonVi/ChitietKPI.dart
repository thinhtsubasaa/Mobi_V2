import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

import 'custom_body_ChitietKPI_kqua.dart';

class ChiTietDanhGiaKPI_DonViPage extends StatefulWidget {
  final String? id;
  final String? kyDanhGia;
  final bool isChiTiet;

  const ChiTietDanhGiaKPI_DonViPage({
    super.key,
    required this.id,
    required this.kyDanhGia,
    required this.isChiTiet,
  });

  State<ChiTietDanhGiaKPI_DonViPage> createState() => _ChiTietKPIPage();
}

class _ChiTietKPIPage extends State<ChiTietDanhGiaKPI_DonViPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.isChiTiet ? 'Chi tiết đánh giá KPI Đơn vị' : 'Duyệt đánh giá KPI Đơn vị'),
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
              child: BodyChiTietDanhGiaKPI_DonViScreen(
                id: widget.id,
                isChiTiet: widget.isChiTiet,
                lstFiles: [],
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
