import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import 'custom_body_ChitietKPI_tt.dart';
import 'custom_body_ChitietKPI_kqua.dart';

class ChiTietKPIPage extends StatefulWidget {
  final String? id;
  final String? kyDanhGia;
  final bool isChiTiet;

  const ChiTietKPIPage({
    super.key,
    required this.id,
    required this.kyDanhGia,
    required this.isChiTiet,
  });

  State<ChiTietKPIPage> createState() => _ChiTietKPIPage();
}

class _ChiTietKPIPage extends State<ChiTietKPIPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController!.addListener(_handleTabChange);
    print("Id: ${widget.id} - Type: ${widget.id.runtimeType}");
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {}
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.isChiTiet ? 'Xem chi tiết Đánh giá KPI cá nhân' : 'Duyệt Đánh giá KPI cá nhân'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40), // Chiều cao của TabBar
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 11.sp),
            tabs: [
              Tab(text: 'Thông tin nhân sự'),
              Tab(text: 'Kết quả đánh giá ${widget.kyDanhGia}'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CustomBodyChiTietKPI(id: widget.id),
          CustomBodyChiTietKPI2(id: widget.id, isChiTiet: widget.isChiTiet),
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
    );
  }
}
