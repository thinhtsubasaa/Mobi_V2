import 'package:flutter/material.dart';
import 'package:Thilogi/pages/menu/custom_body_mainmenu.dart';
import 'package:Thilogi/config/config.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

// class MainMenuPage extends StatelessWidget {
//   int currentPage = 0; // Đặt giá trị hiện tại của trang
//   int pageCount = 3;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(key: Key('customAppBar')),
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
//                     child: Column(
//                       children: [
//                         CustomCard(),
//                         CustomBodyMainMenu(),
//                         const SizedBox(height: 20),
//                         Container(
//                           height: MediaQuery.of(context).size.height / 3,
//                           color: Colors.white,
//                           child: Column(
//                             children: [
//                               const SizedBox(height: 20),
//                               customTitle(
//                                 'HỆ THỐNG QUẢN LÝ\n NGUỒN LỰC DOANH NGHIỆP (ERP)',
//                               ),
//                               SizedBox(height: 10),
//                               customBottom(
//                                 "Hệ thống bao gồm nhiều chức năng quản trị nghiệp vụ/ Dịch vụ của các Tổng công ty/ Công ty/ Đơn vị trực thuộc THILOGI",
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
class MainMenuPage extends StatelessWidget {
  int currentPage = 0; // Đặt giá trị hiện tại của trang
  int pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(key: Key('customAppBar')),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: 100.w,
                child: CustomBodyMainMenu(),
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
      height: MediaQuery.of(context).size.height / 8,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(left: 20),
      child: customTitle(
        'HỆ THỐNG QUẢN LÝ NGUỒN LỰC DOANH NGHIỆP (ERP)',
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Key? key;

  const CustomAppBar({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppConfig.appBarImagePath,
            width: 70.w,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
