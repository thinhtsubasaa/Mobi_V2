import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import 'custom_body_ChitietPheDuyetKetQuaKPI.dart';

class ChiTietPheDuyetKetQuaKPIPage extends StatefulWidget {
  final String? id;
  final bool isCaNhan;
  final String? tenDonViKPI;
  final bool isChiTiet;

  const ChiTietPheDuyetKetQuaKPIPage({super.key, required this.id, required this.isCaNhan, required this.tenDonViKPI, required this.isChiTiet});

  State<ChiTietPheDuyetKetQuaKPIPage> createState() => _ChiTietKPIPage();
}

class _ChiTietKPIPage extends State<ChiTietPheDuyetKetQuaKPIPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    final bool hasDonVi = (widget.tenDonViKPI?.trim().isNotEmpty ?? false);

    // final String titleStr =
    // 'Chi tiết đề xuất phê duyệt kết quả đánh giá/ xếp loại KPI${widget.isCaNhan ? (hasDonVi ? ' CBNV' : ' TPNS LÃNH ĐẠO & TIỀM NĂNG') : ' Đơn vị'}';
    final String titleStr = '${widget.isChiTiet ? 'Chi tiết' : 'Duyệt'} đề xuất phê duyệt kết quả đánh giá/xếp loại KPI'
        '${widget.isCaNhan ? (hasDonVi ? ' CBNV' : ' TPNS LÃNH ĐẠO & TIỀM NĂNG') : ' Đơn vị'}';

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          titleStr,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          textScaler: TextScaler.noScaling,
          style: const TextStyle(
            fontSize: 18, // ~ như ảnh
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827), // đen đậm
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: 100.w,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: BodyChiTietPheDuyetKetQuaKPIScreen(
                id: widget.id,
                isCaNhan: widget.isCaNhan,
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
