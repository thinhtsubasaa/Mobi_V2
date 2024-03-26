import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/QLBaixe/custom_body_QLBaixe.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

// ignore: use_key_in_widget_constructors
// class QLBaiXePage extends StatelessWidget {
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
//               child: Column(
//                 children: [
//                   Container(
//                     width: 100.w,
//                     decoration: const BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage(AppConfig
//                             .backgroundImagePath), // Đường dẫn đến ảnh nền
//                         fit: BoxFit.cover, // Cách ảnh nền sẽ được hiển thị
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         CustomCard(),
//                         CustomBodyQLBaiXe(),
//                         const SizedBox(height: 20),
//                         Container(
//                           height: MediaQuery.of(context).size.height / 3,
//                           child: Column(
//                             children: [
//                               const SizedBox(height: 20),
//                               customTitle('QUẢN LÝ BÃI XE\n THÀNH PHẨM (WMS)'),
//                               SizedBox(height: 10),
//                               customBottom(
//                                   "Cung cấp ứng dụng quản lý vị trí xe trong bãi; tìm xe, xác nhận vận chuyển, giao xe thành phẩm."),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
class QLBaiXePage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: 100.w,
                // height: MediaQuery.of(context).size.height - 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConfig.backgroundImagePath),
                    // Đường dẫn đến ảnh nền
                    fit: BoxFit.cover,
                    // Cách ảnh nền sẽ được hiển thị
                  ),
                ),
                child: CustomBodyQLBaiXe(),
              ),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      child: Center(
        child: customTitle(
          'KIỂM TRA - NHẬP BÃI XE',
        ),
      ),
    );
  }
}

// class BottomContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Expanded(
//         // height: MediaQuery.of(context).size.height / 5,
//         // padding: EdgeInsets.all(10),

//         child: Column(
//           children: [
//             customTitle('QUẢN LÝ BÃI XE\n THÀNH PHẨM (WMS)'),
//             SizedBox(height: 10),
//             customBottom(
//                 "Cung cấp ứng dụng quản lý vị trí xe trong bãi; tìm xe, xác nhận vận chuyển, giao xe thành phẩm."),
//           ],
//         ),
//       ),
//     );
//   }
// }



