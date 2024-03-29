import 'package:Thilogi/pages/tracking/custom_body_trackingxe.dart';
import 'package:Thilogi/pages/XuatCong/custom_body_vitrixe.dart';

import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/tracking/custom_body_tracking_vitri.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

// ignore: use_key_in_widget_constructors
// class TrackingXeVitriPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight: constraints.maxHeight,
//               ),
//               child: Container(
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(AppConfig.backgroundImagePath),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     CustomCard(),
//                     CustomCardVIN(),
//                     SizedBox(height: 10),
//                     TabNhanXeScreen(),
//                     SizedBox(height: 10),
//                     CustomTrackingXeVitri(),
//                     const SizedBox(height: 20),
//                     Container(
//                       width: 100.w,
//                       child: Column(
//                         children: [
//                           customTitle('TRACKING XE THÀNH PHẨM'),
//                           SizedBox(height: 10),
//                           customBottom(
//                               "Tìm kiếm xe theo Đơn hàng/ Số VIN Theo dõi vị trí xe trong quá trình vận chuyển giao xe"),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class TrackingXeVitriPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(),
//       body: Column(
//         children: [
//           CustomCard(),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Container(
//                 width: 100.w,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(AppConfig.backgroundImagePath),
//                     // Đường dẫn đến ảnh nền
//                     fit: BoxFit.cover,
//                     // Cách ảnh nền sẽ được hiển thị
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     CustomCardVIN(),
//                     SizedBox(height: 10),
//                     TabNhanXeScreen(),
//                     SizedBox(height: 15),
//                     CustomTrackingXeVitri(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           BottomContent(),
//         ],
//       ),
//     );
//   }
// }

// class BottomContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height / 7,
//       padding: EdgeInsets.all(10),
//       child: Center(
//         child: customTitle(
//           'TRACKING XE THÀNH PHẨM',
//         ),
//       ),
//     );
//   }
// }

// class TabNhanXeScreen extends StatefulWidget {
//   const TabNhanXeScreen({Key? key}) : super(key: key);

//   @override
//   _TabNhanXeScreenState createState() => _TabNhanXeScreenState();
// }

// class _TabNhanXeScreenState extends State<TabNhanXeScreen>
//     with SingleTickerProviderStateMixin {
//   TabController? _tabController;
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(vsync: this, length: 2);
//     _tabController!.addListener(_handleTabChange);
//   }

//   @override
//   void dispose() {
//     _tabController?.dispose();
//     super.dispose();
//   }

//   void _handleTabChange() {
//     if (_tabController!.indexIsChanging) {
//       // Call the action when the tab changes
//       // print('Tab changed to: ${_tabController!.index}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: TabBar(
//         controller: _tabController,
//         tabs: [
//           TabItem(
//             label: 'Vị trí trên đường',
//             textColor: const Color(0xFF428FCA),
//             backgroundColor: const Color(0xFFF6C6C7),
//             onTap: () {
//               nextScreen(context, TrackingXeVitriPage());
//             },
//           ),
//           TabItem(
//             label: 'Trạng thái vận chuyển',
//             textColor: const Color(0xFF818180),
//             backgroundColor: const Color(0xFF7F7F7F),
//             onTap: () {
//               nextScreen(context, TrackingXePage());
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TabItem extends StatelessWidget {
//   final String label;
//   final Color textColor;
//   final Color backgroundColor;
//   final VoidCallback onTap;

//   const TabItem({
//     required this.label,
//     required this.textColor,
//     required this.backgroundColor,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap, // Gọi hàm xử lý khi tab được nhấn
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.only(top: 10, bottom: 5),
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontFamily: 'Comfortaa',
//                 fontSize: 12,
//                 fontWeight: FontWeight.w700,
//                 color: textColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class CustomCardVIN extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: 8.h,
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        // Đặt border radius cho card
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180), // Màu của đường viền
          width: 1, // Độ dày của đường viền
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20.w,
            height: 8.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
            ),
            child: Center(
              child: Text(
                'Số Khung\n(VIN)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'RN2B12SAARM134506',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA71C20),
                ),
              ),
            ),
          ),
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

class TrackingXeVitriPage extends StatefulWidget {
  const TrackingXeVitriPage({super.key});

  @override
  State<TrackingXeVitriPage> createState() => _TrackingXeVitriPageState();
}

class _TrackingXeVitriPageState extends State<TrackingXeVitriPage>
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
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AppConfig.QLKhoImagePath,
              width: 70.w,
            ),
            Container(
              child: Text(
                'TCT VẬN TẢI ĐƯỜNG BỘ THILOGI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFBC2925),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height < 600
                          ? 29.h
                          : 25.h),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  width: 100.w,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppConfig.backgroundImagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      CustomTrackingXeVitri(),
                      CustomTrackingXe(),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 11,
                padding: EdgeInsets.all(10),
                child: Center(
                  child: customTitle(
                    'TRACKING XE THÀNH PHẨM',
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  CustomCard(),
                  CustomCardVIN(),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Vị trí trên đường'),
                      Tab(text: 'Trạng thái vận chuyển'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
