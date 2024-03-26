import 'package:Thilogi/pages/XuatCong/custom_body_vitrixe.dart';
import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/baixe/custom_body_baixe.dart';

import 'package:sizer/sizer.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';

// class XuatCongXePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 100.w,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage(AppConfig.backgroundImagePath),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         CustomCard(),
//                         SizedBox(height: 5),
//                         CustomBodyBaiXe(),
//                         SizedBox(height: 20),
//                         Container(
//                           width: 100.w,
//                           child: Column(
//                             children: [
//                               customTitle('KIỂM TRA - NHẬN XE'),
//                               SizedBox(height: 10),
//                               customBottom(
//                                 "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI",
//                               ),
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
class XuatCongXePage extends StatelessWidget {
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
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConfig.backgroundImagePath),
                    // Đường dẫn đến ảnh nền
                    fit: BoxFit.cover,
                    // Cách ảnh nền sẽ được hiển thị
                  ),
                ),
                child: CustomBodyXuatCongXe(),
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
          'KIỂM TRA - XUẤT CÔNG',
        ),
      ),
    );
  }
}
