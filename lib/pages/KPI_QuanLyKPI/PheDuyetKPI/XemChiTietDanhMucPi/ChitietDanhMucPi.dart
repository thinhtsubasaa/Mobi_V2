import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import 'custom_body_ChitietDanhMucPi.dart';

class ChiTietDanhMucPiPage extends StatefulWidget {
  final String? id;
  final String? kyDanhGia;
  final bool isChiTiet;

  const ChiTietDanhMucPiPage({
    super.key,
    required this.id,
    required this.kyDanhGia,
    required this.isChiTiet,
  });

  State<ChiTietDanhMucPiPage> createState() => _ChiTietKPIPage();
}

class _ChiTietKPIPage extends State<ChiTietDanhMucPiPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.isChiTiet ? "Chi tiết danh mục PI" : "Duyệt danh mục PI"),
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
              child: BodyChiTietDMPIScreen(
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
