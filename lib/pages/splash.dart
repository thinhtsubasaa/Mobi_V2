// import 'package:flutter/material.dart';
// import 'package:Thilogi/blocs/user_bloc.dart';
// import 'package:Thilogi/config/config.dart';
// import 'package:Thilogi/pages/login/Login.dart';
// import 'package:Thilogi/pages/menu/MainMenu.dart';
// import 'package:provider/provider.dart';

// // import '../blocs/user_bloc.dart';
// import '../blocs/app_bloc.dart';

// import '../utils/next_screen.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   Future _afterSplash() async {
//     final UserBloc ub = context.read<UserBloc>();
//     final AppBloc _ab = context.read<AppBloc>();
//     Future.delayed(const Duration(seconds: 2)).then((value) async {
//       _ab.getApiUrl();
//       if (ub.isSignedIn) {
//         ub.getUserData();
//         _ab.getData();
//         _goToHomePage();
//       } else {
//         _goToLoginPage();
//       }
//     });
//   }

//   void _goToHomePage() {
//     nextScreenReplace(context, MainMenuPage());
//   }

//   void _goToLoginPage() {
//     nextScreenReplace(context, LoginPage());
//   }

//   @override
//   void initState() {
//     _afterSplash();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Config().appThemeColor,
//       body: Container(
//         alignment: Alignment.center,
//         child: Stack(
//           children: [
//             Image(
//               height: MediaQuery.of(context).size.width - 100,
//               width: MediaQuery.of(context).size.width - 100,
//               image: const AssetImage(AppConfig.appBarImagePath),
//               fit: BoxFit.contain,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// // class MyHomePage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: CustomAppBar(key: Key('customAppBar')),
// //       body: Container(
// //         child: Column(
// //           children: [
// //             const CustomImage(imagePath: AppConfig.homeImagePath),
// //             const SizedBox(height: 5),
// //             customTitle('LOGISTIC TRỌN GÓI\n HÀNG ĐẦU MIỀN TRUNG'),
// //             const SizedBox(height: 5),
// //             CustomImage(imagePath: AppConfig.bottomHomeImagePath),
// //             const SizedBox(height: 15),
// //             CustomButton(onPressed: () {
// //               nextScreen(context, LoginPage());
// //             }),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }



// class MainMenuPage extends StatelessWidget {
//   int currentPage = 0; // Đặt giá trị hiện tại của trang
//   int pageCount = 3;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(key: Key('customAppBar')),
//       body: LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 Container(
//                   width: 100.w,
//                   child: Column(
//                     children: [
//                       CustomCard(),
//                       CustomBodyMainMenu(),
//                       const SizedBox(height: 20),
//                       Container(
//                         color: Colors.white,
//                         child: Column(
//                           children: [
//                             customTitle(
//                               'HỆ THỐNG QUẢN LÝ NGUỒN LỰC DOANH NGHIỆP (ERP)',
//                             ),
//                             SizedBox(height: 10),
//                             customBottom(
//                               "Hệ thống bao gồm nhiều chức năng quản trị nghiệp vụ/ Dịch vụ của các Tổng công ty/ Công ty/ Đơn vị trực thuộc THILOGI",
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }