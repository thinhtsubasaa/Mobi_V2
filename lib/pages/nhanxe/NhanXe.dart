import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:project/blocs/app_bloc.dart';
import 'package:project/blocs/scan_bloc.dart';

import 'package:project/config/config.dart';
import 'package:project/models/scan.dart';
import 'package:project/services/request_helper.dart';

import 'package:project/widgets/widget_body/custom_body_NhanXe.dart';
import 'package:project/widgets/widget_tabs/custom_tabs_NhanXe.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/user_bloc.dart';
import '../../services/app_service.dart';
import '../../utils/snackbar.dart';
import '../../widgets/loading.dart';

// ignore: use_key_in_widget_constructors
class NhanXePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_constructors
      appBar: CustomAppBarQLKhoXe(key: Key('customAppBarQLKhoXe')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 340,
              height: 800,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      AppConfig.backgroundImagePath), // Đường dẫn đến ảnh nền
                  fit: BoxFit.cover, // Cách ảnh nền sẽ được hiển thị
                ),
              ),
              child: Column(
                children: [
                  CustomCardQLKhoXe(),
                  CustomTabs(),
                  SizedBox(height: 10),
                  CustomBodyNhanXe(),
                  const SizedBox(height: 30),
                  Container(
                    width: 340,
                    height: 150,
                    child: const Column(
                      children: [
                        CustomTitle(text: 'KIỂM TRA - NHẬN XE'),
                        SizedBox(height: 10),
                        Custombottom(
                            text:
                                "Kiểm tra chất lượng, tình trạng xe;\n Xác nhận nhận xe vào kho THILOGI,"),
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
  }
}

class CustomTitle extends StatelessWidget {
  final String text;

  const CustomTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 216, 30, 16),
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.17,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class CustomAppBarQLKhoXe extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  // ignore: overridden_fields
  final Key? key;

  // ignore: prefer_const_constructors_in_immutables
  CustomAppBarQLKhoXe({this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppConfig.QLKhoImagePath,
            width: 300,
          ),
          // ignore: avoid_unnecessary_containers
          Container(
            child: const Padding(
              padding: EdgeInsets.only(left: 50),
              child: Text(
                'TCT VẬN TẢI ĐƯỜNG BỘ THILOGI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFBC2925), // Màu chữ
                  height: 16 / 14, // Tính line-height
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // ignore: prefer_const_constructors
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class Custombottom extends StatelessWidget {
  final String text;

  const Custombottom({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF000000),
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

// class CustomCardVIN extends StatefulWidget {
//   @override
//   _CustomCardVIN createState() => _CustomCardVIN();
// }

// class _CustomCardVIN extends State<CustomCardVIN> {
//   String barcodeScanResult = '';
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300,
//       height: 50,
//       margin: const EdgeInsets.only(top: 10),
//       decoration: BoxDecoration(
//         // Đặt border radius cho card
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: const Color(0xFF818180), // Màu của đường viền
//           width: 1, // Độ dày của đường viền
//         ),
//         color: Colors.white, // Màu nền của card
//       ),
//       child: Row(
//         children: [
//           // Phần Text 1
//           Container(
//             width: 76.48,
//             height: 48,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(5),
//                 bottomLeft: Radius.circular(5),
//               ),
//               color: Color(0xFFA71C20),
//             ),
//             child: const Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Text trong cột
//                 Text(
//                   'Số Khung\n(VIN)',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontFamily: 'Comfortaa',
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                     height: 1.08, // Corresponds to line-height of 13px
//                     letterSpacing: 0,

//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           // Phần Text 2
//           Text(
//             barcodeScanResult.isNotEmpty ? barcodeScanResult : 'Scan a barcode',
//             style: TextStyle(
//               fontFamily: 'Comfortaa',
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               height: 1.11,
//               letterSpacing: 0,
//               color: Color(0xFFA71C20),
//             ),
//           ),

//           IconButton(
//             icon: const Icon(Icons.qr_code_scanner),
//             color: Colors.black,
//             onPressed: () async {
//               String result = await FlutterBarcodeScanner.scanBarcode(
//                 '#A71C20',
//                 'Cancel',
//                 false,
//                 ScanMode.QR,
//               );
//               setState(() {
//                 barcodeScanResult = result;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

class CustomBodyNhanXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyNhanxeScreen());
  }
}

class BodyNhanxeScreen extends StatefulWidget {
  const BodyNhanxeScreen({Key? key}) : super(key: key);

  @override
  _BodyNhanxeScreenState createState() => _BodyNhanxeScreenState();
}

class _BodyNhanxeScreenState extends State<BodyNhanxeScreen> {
  static RequestHelper requestHelper = RequestHelper();
  late AppBloc _ab;
  late ScanBloc _sb;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  Timer? _debounce;
  List<String>? _results = [];
  ScanModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';

  @override
  void initState() {
    super.initState();
    _ab = Provider.of<AppBloc>(context, listen: false);
    _sb = Provider.of<ScanBloc>(context, listen: false);
  }

  Widget showInfoXe2() {
    return Container(
      width: 300,
      height: 50,
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
        children: [
          // Phần Text 1
          Container(
            width: 76.48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: Color(0xFFA71C20),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text trong cột
                Text(
                  'Số Khung\n(VIN)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.08, // Corresponds to line-height of 13px
                    letterSpacing: 0,

                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Phần Text 2
          Text(
            barcodeScanResult.isNotEmpty ? barcodeScanResult : 'Scan a barcode',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.11,
              letterSpacing: 0,
              color: Color(0xFFA71C20),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String result = await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              setState(() {
                barcodeScanResult = result;
              });
              print(result);
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult() {
    // Process the barcode scan result here
    setState(() {
      _qrData = '';
      _qrDataController.text = barcodeScanResult;
      _data = null;
      Future.delayed(const Duration(seconds: 1), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      print("du lieu : ${query}");
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _getListCode();
      });
    } else {
      setState(() {
        _data = null;
      });
    }
  }

  Future<void> _getListCode() async {
    setState(() {
      _loading = true;
    });
    var headers = {
      'ApiKey': 'qtsx2023', // Thêm header này vào request của bạn
    };
    try {
      final http.Response response = await requestHelper.getData(
          "https://qtsxautoapi.thacochulai.vn/api/KhoThanhPham/TraCuuXeThanhPham_Thilogi1?SoKhung=$barcodeScanResult");
      var decodedData = jsonDecode(response.body);
      print("du lieu:, ${response}");
      setState(() {
        _results = decodedData == null ? [] : List<String>.from(decodedData);
      });
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _sb.getData(value).then((_) {
      setState(() {
        _qrData = value;
        if (_sb.data == null) {
          _qrData = '';
          _qrDataController.text = '';
          if (_sb.success == false && _sb.message!.isNotEmpty) {
            openSnackBar(context, _sb.message!);
          } else {
            openSnackBar(context, "Không có dữ liệu");
          }
        }
        _loading = false;
        _data = _sb.data;
      });
    });
  }

  _onSave() {
    setState(() {
      _loading = true;
    });
    _data!.id = _ab.id;
    // call api
    AppService().checkInternet().then((hasInternet) {
      if (!hasInternet!) {
        openSnackBar(context, 'no internet'.tr());
      } else {
        _sb.postData(_data!).then((_) {
          if (_sb.success) {
            openSnackBar(context, "Lưu thành công");
          } else {
            openSnackBar(context, "Lưu thất bại");
          }
          setState(() {
            _data = null;
            _qrData = '';
            _qrDataController.text = '';
            _loading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        // Box 1
        Container(
          width: 340,
          height: 170,
          padding: const EdgeInsets.only(top: 5, bottom: 10),
          margin: const EdgeInsets.all(5), // Khoảng cách giữa các box
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFCCCCCC), // Màu của đường viền
              width: 1, // Độ dày của đường viền
            ),
          ),

          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text
                  const Text(
                    'MAZDA CX 5 DELUX MT',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Coda Caption',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.56, // Corresponds to line-height of 28px
                      letterSpacing: 0,
                      color: Color(0xFFA71C20),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Button
                  Container(
                    width: 70,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF428FCA),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý sự kiện khi nút được nhấn
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .transparent, // Đặt màu nền của nút là trong suốt
                        padding: const EdgeInsets.all(
                            0), // Đặt khoảng trống bên trong nút
                      ),
                      child: const Text(
                        'Chờ nhận',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1.125, // Corresponds to line-height of 9px
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              _loading
                  ? LoadingWidget(height: 200)
                  : _data == null
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.all(2),
                          child: const Row(
                            children: [
                              SizedBox(width: 10),

                              // Text 1
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),

                                  // Text 1
                                  Text(
                                    'Số khung (VIN):',
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.08,
                                      letterSpacing: 0,
                                      color: Color(0xFF818180),
                                    ),
                                  ),
                                  SizedBox(height: 5),

                                  // Text 2
                                  Text(
                                    'MALA851CBHM557809',
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      height: 1.125,
                                      letterSpacing: 0,
                                      color: Color(0xFFA71C20),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: 70), // Khoảng cách giữa hai Text

                              // Text 2
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text 1
                                  Text(
                                    'Màu:',
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.08,
                                      letterSpacing: 0,
                                      color: Color(0xFF818180),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Text 2
                                  Text(
                                    'Đỏ',
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.125,
                                      letterSpacing: 0,
                                      color: Color(0xFFFF0007),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(1),
                child: const Row(
                  children: [
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),

                        // Text 1
                        Text(
                          'Nhà máy:',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                            letterSpacing: 0,
                            color: Color(0xFF818180),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Text 2
                        Text(
                          'THACO MAZDA',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.125,
                            letterSpacing: 0,
                            color: Color(0xFFA71C20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              SizedBox(height: 10),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện khi nút được nhấn
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFFE96327), // Màu nền của nút
                    fixedSize:
                        const Size(309, 33), // Kích thước cố định của nút
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Độ cong của góc nút
                    ),
                    // Khoảng cách giữa nút và văn bản
                  ),
                  child: const Text(
                    'NHẬN XE',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 3),
        showInfoXe2(),

        const SizedBox(height: 5),

        // Box 2
        Container(
          width: 320,
          height: 180,
          padding: const EdgeInsets.only(top: 5, bottom: 10),
          margin: const EdgeInsets.all(5), // Khoảng cách giữa các box
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFCCCCCC), // Màu của đường viền
              width: 1, // Độ dày của đường viền
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text
                  Text(
                    'MAZDA CX 5 DELUX MT',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Coda Caption',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.56, // Corresponds to line-height of 28px
                      letterSpacing: 0,
                      color: Color(0xFFA71C20),
                    ),
                  ).tr(),
                  const SizedBox(width: 15),
                  // Button
                  Container(
                    width: 70,
                    height: 14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF428FCA),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý sự kiện khi nút được nhấn
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .transparent, // Đặt màu nền của nút là trong suốt
                        padding: const EdgeInsets.all(
                            0), // Đặt khoảng trống bên trong nút
                      ),
                      child: const Text(
                        'Chờ nhận',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1.125, // Corresponds to line-height of 9px
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    // Gọi hàm showInfoXe và truyền các tham số tương ứng vào
                    showInfoXe('Số khung (VIN):', 'MALA851CBHM557809'),
                    SizedBox(width: 70), // Khoảng cách giữa hai Text
                    showInfoXe('Màu:', "Xanh"),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(1),
                child: const Row(
                  children: [
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),

                        // Text 1
                        Text(
                          'Nhà máy:',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                            letterSpacing: 0,
                            color: Color(0xFF818180),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Text 2
                        Text(
                          'THACO MAZDA',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.125,
                            letterSpacing: 0,
                            color: Color(0xFFA71C20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện khi nút được nhấn
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFFE96327), // Màu nền của nút
                    fixedSize:
                        const Size(309, 33), // Kích thước cố định của nút
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Độ cong của góc nút
                    ),
                    // Khoảng cách giữa nút và văn bản
                  ),
                  child: const Text(
                    'NHẬN XE',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    ));
  }
}

Widget showInfoXe(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.08,
          letterSpacing: 0,
          color: Color(0xFF818180),
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.125,
          letterSpacing: 0,
          color: Color(0xFFA71C20),
        ),
      )
    ],
  );
}

// ignore: use_key_in_widget_constructors
class CustomCardQLKhoXe extends StatefulWidget {
  const CustomCardQLKhoXe({super.key});

  @override
  State<CustomCardQLKhoXe> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCardQLKhoXe>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late UserBloc _ub;
  String _fullName = "No name";
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController!.addListener(_handleTabChange);
    _ub = Provider.of<UserBloc>(context, listen: false);
    setState(() {
      _fullName = _ub.name!;
    });
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
    return Container(
      width: 460,
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE96327),
            Color(0xFFBC2925),
          ],
        ),
        // Đặt border radius cho card
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Đặt giữa các thành phần
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: const Text(
              'WMS',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height:
                    28 / 24, // Tính line-height dựa trên fontSize và lineHeight
                letterSpacing: 0,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 10),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  _fullName ?? "No name",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.17,
                    letterSpacing: 0,
                  ),
                ),
              ),
              // ignore: avoid_unnecessary_containers
              Container(
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
