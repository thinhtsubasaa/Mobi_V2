import 'package:Thilogi/pages/tracking/TrackingXe_Vitri.dart';
import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/tracking/custom_body_trackingxe.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../utils/next_screen.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

// ignore: use_key_in_widget_constructors

class TrackingXePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Stack(
                children: [
                  // Background Image
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppConfig.backgroundImagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        // CustomCard(),
                        CustomCardVIN(),
                        SizedBox(height: 10),
                        TabNhanXeScreen(),
                        SizedBox(height: 10),
                        CustomTrackingXe(),
                        const SizedBox(height: 20),
                        Container(
                          child: Column(
                            children: [
                              customTitle('TRACKING XE THÀNH PHẨM'),
                              SizedBox(height: 10),
                              customBottom(
                                "Tìm kiếm xe theo Đơn hàng/ Số VIN Theo dõi vị trí xe trong quá trình vận chuyển giao xe",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TabNhanXeScreen extends StatefulWidget {
  const TabNhanXeScreen({Key? key}) : super(key: key);

  @override
  _TabNhanXeScreenState createState() => _TabNhanXeScreenState();
}

class _TabNhanXeScreenState extends State<TabNhanXeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController!.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {
      // Call the action when the tab changes
      // print('Tab changed to: ${_tabController!.index}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        //  Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     TabItem(
        //       label: 'Trạng thái vận chuyển',
        //       textColor: const Color(0xFF818180),
        //       backgroundColor: const Color(0xFF7F7F7F),
        //     ),
        //     TabItem(
        //       label: 'Vị trí trên đường',
        //       textColor: const Color(0xFF428FCA),
        //       backgroundColor: const Color(0xFFF6C6C7),
        //     ),
        //   ],
        // );
        Material(
      child: TabBar(
        controller: _tabController,
        tabs: [
          TabItem(
            label: 'Trạng thái vận chuyển',
            textColor: const Color(0xFF428FCA),
            backgroundColor: const Color(0xFF7F7F7F),
            onTap: () {
              nextScreen(context, TrackingXePage());
            },
          ),
          TabItem(
            label: 'Vị trí trên đường',
            textColor: const Color(0xFF818180),
            backgroundColor: const Color(0xFFF6C6C7),
            onTap: () {
              nextScreen(context, TrackingXeVitriPage());
            },
          ),
        ],
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const TabItem({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Gọi hàm xử lý khi tab được nhấn
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCardVIN extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      height: 8.h,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        // Đặt border radius cho card
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180), // Màu của đường viền
          width: 1, // Độ dày của đường viền
        ),
        color: Colors.white, // Màu nền của card
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Phần Text 1
          Container(
            width: 20.w,
            height: 8.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: Color(0xFFA71C20),
            ),
            child: Center(
              child:
                  // Text trong cột
                  Text(
                'Số Khung\n(VIN)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.08, // Corresponds to line-height of 13px

                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              // Phần Text 2
              child: Text(
                'MALA851CBHM557809',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA71C20),
                ),
              ),
            ),
          ),

          // Phần Icon Barcode
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String barcodeScanResult =
                  await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              print(barcodeScanResult);
            },
          ),
        ],
      ),
    );
  }
}
