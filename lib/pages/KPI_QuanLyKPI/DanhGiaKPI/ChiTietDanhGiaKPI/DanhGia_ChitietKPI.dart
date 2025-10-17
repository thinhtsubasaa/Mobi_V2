import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'custom_body_DanhGiaChitietKPI_thongtin.dart';
import 'custom_body_DanhGiaChitietKPI_ketqua.dart';

class DanhGiaChiTietKPIPage extends StatefulWidget {
  final String? id;
  final String? kyDanhGia;

  const DanhGiaChiTietKPIPage({
    super.key,
    required this.id,
    required this.kyDanhGia,
  });

  State<DanhGiaChiTietKPIPage> createState() => _DanhGiaChiTietKPIPage();
}

class _DanhGiaChiTietKPIPage extends State<DanhGiaChiTietKPIPage> with SingleTickerProviderStateMixin, ChangeNotifier {
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
        title: const Text('Đánh giá KPI cá nhân'),
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
          CustomBodyDanhGiaChiTietKPI(id: widget.id),
          CustomBodyDanhGiaChiTietKPI2(id: widget.id),
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
