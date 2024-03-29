import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/chuyenxe/custom_body_chuyenxe.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

// ignore: use_key_in_widget_constructors
// class ChuyenXePage extends StatelessWidget {
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
//                 width: 100.w,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(AppConfig.backgroundImagePath),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     CustomCard(),
//                     SizedBox(height: 10),
//                     CustomBodyChuyenXe(),
//                     const SizedBox(height: 20),
//                     Container(
//                       width: 100.w,
//                       child: Column(
//                         children: [
//                           customTitle('KIỂM TRA - NHẬN XE'),
//                           SizedBox(height: 10),
//                           // customBottom(
//                           //     "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI"),
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
class ChuyenXePage extends StatelessWidget {
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
                    fit: BoxFit.cover,
                  ),
                ),
                child: CustomBodyChuyenXe(),
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
          'KIỂM TRA - ĐIỀU CHUYỂN XE',
        ),
      ),
    );
  }
}
