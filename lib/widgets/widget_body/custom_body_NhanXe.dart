// import 'dart:async';
// import 'dart:convert';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;
// import 'package:project/models/scan.dart';
// import 'package:project/services/app_service.dart';
// import 'package:project/services/request_helper.dart';
// import 'package:provider/provider.dart';

// import '../../blocs/app_bloc.dart';
// import '../../blocs/scan_bloc.dart';
// import '../../utils/snackbar.dart';

// class CustomBodyNhanXe extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(child: BodyNhanxeScreen());
//   }
// }

// class BodyNhanxeScreen extends StatefulWidget {
//   const BodyNhanxeScreen({Key? key}) : super(key: key);

//   @override
//   _BodyNhanxeScreenState createState() => _BodyNhanxeScreenState();
// }

// class _BodyNhanxeScreenState extends State<BodyNhanxeScreen> {
//   static RequestHelper requestHelper = RequestHelper();
//   late AppBloc _ab;
//   late ScanBloc _sb;
//   String _qrData = '';
//   final _qrDataController = TextEditingController();
//   Timer? _debounce;
//   List<String>? _results = [];
//   ScanModel? _data;
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         child: Column(
//       children: [
//         // Box 1
//         Container(
//           width: 340,
//           height: 180,
//           padding: const EdgeInsets.only(top: 5, bottom: 10),
//           margin: const EdgeInsets.all(5), // Khoảng cách giữa các box
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(
//               color: const Color(0xFFCCCCCC), // Màu của đường viền
//               width: 1, // Độ dày của đường viền
//             ),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Text
//                   const Text(
//                     'MAZDA CX 5 DELUX MT',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       fontFamily: 'Coda Caption',
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                       height: 1.56, // Corresponds to line-height of 28px
//                       letterSpacing: 0,
//                       color: Color(0xFFA71C20),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   // Button
//                   Container(
//                     width: 70,
//                     height: 14,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: const Color(0xFF428FCA),
//                     ),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Xử lý sự kiện khi nút được nhấn
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors
//                             .transparent, // Đặt màu nền của nút là trong suốt
//                         padding: const EdgeInsets.all(
//                             0), // Đặt khoảng trống bên trong nút
//                       ),
//                       child: const Text(
//                         'Chờ nhận',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontFamily: 'Comfortaa',
//                           fontSize: 8,
//                           fontWeight: FontWeight.w700,
//                           height: 1.125, // Corresponds to line-height of 9px
//                           letterSpacing: 0,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               const Divider(height: 1, color: Color(0xFFCCCCCC)),
//               Container(
//                 padding: const EdgeInsets.all(2),
//                 child: const Row(
//                   children: [
//                     SizedBox(width: 10),

//                     // Text 1
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(width: 10),

//                         // Text 1
//                         Text(
//                           'Số khung (VIN):',
//                           style: TextStyle(
//                             fontFamily: 'Comfortaa',
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                             height: 1.08,
//                             letterSpacing: 0,
//                             color: Color(0xFF818180),
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         // Text 2
//                         Text(
//                           'MALA851CBHM557809',
//                           style: TextStyle(
//                             fontFamily: 'Comfortaa',
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             height: 1.125,
//                             letterSpacing: 0,
//                             color: Color(0xFFA71C20),
//                           ),
//                         ),
//                       ],
//                     ),

//                     SizedBox(width: 70), // Khoảng cách giữa hai Text

//                     // Text 2
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Text 1
//                         Text(
//                           'Màu:',
//                           style: TextStyle(
//                             fontFamily: 'Comfortaa',
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                             height: 1.08,
//                             letterSpacing: 0,
//                             color: Color(0xFF818180),
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         // Text 2
//                         Text(
//                           'Đỏ',
//                           style: TextStyle(
//                             fontFamily: 'Comfortaa',
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             height: 1.125,
//                             letterSpacing: 0,
//                             color: Color(0xFFFF0007),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Color(0xFFCCCCCC)),
//               Container(
//                 padding: const EdgeInsets.all(1),
//                 child: const Row(
//                   children: [
//                     SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(width: 10),

//                         // Text 1
//                         Text(
//                           'Nhà máy:',
//                           style: TextStyle(
//                             fontFamily: 'Comfortaa',
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                             height: 1.08,
//                             letterSpacing: 0,
//                             color: Color(0xFF818180),
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         // Text 2
//                         Text(
//                           'THACO MAZDA',
//                           style: TextStyle(
//                             fontFamily: 'Comfortaa',
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             height: 1.125,
//                             letterSpacing: 0,
//                             color: Color(0xFFA71C20),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Color(0xFFCCCCCC)),
//               Container(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Xử lý sự kiện khi nút được nhấn
//                   },
//                   style: ElevatedButton.styleFrom(
//                     primary: const Color(0xFFE96327), // Màu nền của nút
//                     fixedSize:
//                         const Size(309, 33), // Kích thước cố định của nút
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(5), // Độ cong của góc nút
//                     ),
//                     // Khoảng cách giữa nút và văn bản
//                   ),
//                   child: const Text(
//                     'NHẬN XE',
//                     style: TextStyle(
//                       fontFamily: 'Comfortaa',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),

//         const SizedBox(height: 3),

//         // Box 2
//         Container(
//           width: 320,
//           height: 180,
//           padding: const EdgeInsets.only(top: 5, bottom: 10),
//           margin: const EdgeInsets.all(5), // Khoảng cách giữa các box
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(
//               color: const Color(0xFFCCCCCC), // Màu của đường viền
//               width: 1, // Độ dày của đường viền
//             ),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Text
//                   Text(
//                     'MAZDA CX 5 DELUX MT',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       fontFamily: 'Coda Caption',
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                       height: 1.56, // Corresponds to line-height of 28px
//                       letterSpacing: 0,
//                       color: Color(0xFFA71C20),
//                     ),
//                   ).tr(),
//                   const SizedBox(width: 15),
//                   // Button
//                   Container(
//                     width: 70,
//                     height: 14,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: const Color(0xFF428FCA),
//                     ),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Xử lý sự kiện khi nút được nhấn
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors
//                             .transparent, // Đặt màu nền của nút là trong suốt
//                         padding: const EdgeInsets.all(
//                             0), // Đặt khoảng trống bên trong nút
//                       ),
//                       child: const Text(
//                         'Chờ nhận',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontFamily: 'Comfortaa',
//                           fontSize: 8,
//                           fontWeight: FontWeight.w700,
//                           height: 1.125, // Corresponds to line-height of 9px
//                           letterSpacing: 0,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               const Divider(height: 1, color: Color(0xFFCCCCCC)),
//               Container(
//                 padding: const EdgeInsets.all(2),
//                 child: Row(
//                   children: [
//                     SizedBox(width: 10),
//                     // Gọi hàm showInfoXe và truyền các tham số tương ứng vào
//                     showInfoXe('Số khung (VIN):', "MALA851CBHM557809"),
//                     SizedBox(width: 70), // Khoảng cách giữa hai Text
//                     showInfoXe('Màu:', "Xanh"),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Color(0xFFCCCCCC)),
//               Container(
//                 padding: const EdgeInsets.all(1),
//                 child: const Row(
//                   children: [
//                     SizedBox(width: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(width: 10),

//                         // Text 1
//                         Text(
//                           'Nhà máy:',
//                           style: TextStyle(
//                             fontFamily: 'Comfortaa',
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                             height: 1.08,
//                             letterSpacing: 0,
//                             color: Color(0xFF818180),
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         // Text 2
//                         Text(
//                           'THACO MAZDA',
//                           style: TextStyle(
//                             fontFamily: 'Comfortaa',
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             height: 1.125,
//                             letterSpacing: 0,
//                             color: Color(0xFFA71C20),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Color(0xFFCCCCCC)),
//               Container(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Xử lý sự kiện khi nút được nhấn
//                   },
//                   style: ElevatedButton.styleFrom(
//                     primary: const Color(0xFFE96327), // Màu nền của nút
//                     fixedSize:
//                         const Size(309, 33), // Kích thước cố định của nút
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(5), // Độ cong của góc nút
//                     ),
//                     // Khoảng cách giữa nút và văn bản
//                   ),
//                   child: const Text(
//                     'NHẬN XE',
//                     style: TextStyle(
//                       fontFamily: 'Comfortaa',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     ));
//   }
// }

// Widget showInfoXe(String title, String value) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         title,
//         style: const TextStyle(
//           fontFamily: 'Comfortaa',
//           fontSize: 12,
//           fontWeight: FontWeight.w700,
//           height: 1.08,
//           letterSpacing: 0,
//           color: Color(0xFF818180),
//         ),
//       ),
//       Text(
//         value,
//         style: const TextStyle(
//           fontFamily: 'Comfortaa',
//           fontSize: 16,
//           fontWeight: FontWeight.w700,
//           height: 1.125,
//           letterSpacing: 0,
//           color: Color(0xFFA71C20),
//         ),
//       )
//     ],
//   );
// }
