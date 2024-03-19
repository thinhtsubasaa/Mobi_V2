import 'package:Thilogi/config/config.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

PreferredSizeWidget customAppBar() {
  return AppBar(
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
              height: 16 / 14,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    ),
    centerTitle: false,
  );
}



// class CustomAppBarQLKhoXe extends StatelessWidget
//     implements PreferredSizeWidget {
//   @override
//   final Key? key;

//   const CustomAppBarQLKhoXe({this.key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Image.asset(
//             AppConfig.QLKhoImagePath,
//             width: 300,
//           ),
//           Container(
//             child: Padding(
//               padding: EdgeInsets.only(left: 5.w),
//               child: Text(
//                 'TCT VẬN TẢI ĐƯỜNG BỘ THILOGI',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontFamily: 'Roboto',
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFFBC2925),
//                   height: 16 / 14,
//                   letterSpacing: 0,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       centerTitle: false,
//     );
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight);
// }
