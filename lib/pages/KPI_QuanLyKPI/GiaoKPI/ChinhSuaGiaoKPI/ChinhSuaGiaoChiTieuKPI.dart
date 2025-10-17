import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import 'custom_body_ChinhSuaGiaochitieuKPI_tt.dart';
import 'custom_body_ChinhSuaGiaochitieuKPI_dk.dart';

class ChinhSuaGiaoChiTieuKPIPage extends StatefulWidget {
  final String? id;
  final String? kyDanhGia;
  final bool isChiTiet;

  const ChinhSuaGiaoChiTieuKPIPage({super.key, required this.id, required this.kyDanhGia, required this.isChiTiet});

  State<ChinhSuaGiaoChiTieuKPIPage> createState() => _ChinhSuaGiaoChiTieuKPIPage();
}

class _ChinhSuaGiaoChiTieuKPIPage extends State<ChinhSuaGiaoChiTieuKPIPage> with SingleTickerProviderStateMixin, ChangeNotifier {
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
        title: const Text("Giao chỉ tiêu KPI cá nhân"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40), // Chiều cao của TabBar
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 11.sp),
            tabs: const [
              Tab(text: 'Thông tin nhân sự'),
              Tab(text: 'Thông tin đăng ký'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BodyCSGiaoChiTieuKPIScreen(
            id: widget.id,
            lstFiles: [],
          ),
          BodyCSGiaoChiTieuKPIScreen2(id: widget.id, lstFiles: [], isChiTiet: widget.isChiTiet, kyDanhGia: widget.kyDanhGia),
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
