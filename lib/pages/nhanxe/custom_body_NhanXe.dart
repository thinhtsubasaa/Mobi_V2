import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe2.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:Thilogi/pages/nhanxe/tabs/custom_tabs_NhanXe.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import '../../blocs/scan_bloc.dart';
import '../../utils/next_screen.dart';

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

class _BodyNhanxeScreenState extends State<BodyNhanxeScreen>
    with SingleTickerProviderStateMixin {
  static RequestHelper requestHelper = RequestHelper();

  String _qrData = '';
  final _qrDataController = TextEditingController();
  Timer? _debounce;
  List<String>? _results = [];
  ScanModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';
  late ScanBloc _sb;

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  @override
  void initState() {
    super.initState();
    _sb = Provider.of<ScanBloc>(context, listen: false);
    dataWedge = FlutterDataWedge(profileName: "Example Profile");

    // Subscribe to scan results
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult);
    });
  }

  @override
  void dispose() {
    scanSubscription.cancel();
    // dataWedge.dispose();
    super.dispose();
  }

  Widget CardVin() {
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
              child: Text(
                'Số khung\n (VIN)',
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
          SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(5),
              //   border: Border.all(color: Color(0xFFA71C20), width: 1),
              // ),
              child: Text(
                barcodeScanResult.isNotEmpty ? barcodeScanResult : '',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA71C20),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
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
              print(barcodeScanResult);
              _handleBarcodeScanResult(barcodeScanResult);
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print("Sokhungg:${barcodeScanResult}");
    // Process the barcode scan result here
    setState(() {
      _qrData = '';
      _qrDataController.text = '';
      _data = null;
      Future.delayed(const Duration(seconds: 1), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _sb.getData(value).then((_) {
      setState(() {
        _qrData = value;
        if (_sb.scan == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _sb.scan;
      });
    });
  }
  // void _handleBarcodeScanResult(String barcodeScanResult) {
  //   print("111:${barcodeScanResult}");
  //   setState(() {
  //     if (barcodeScanResult.isEmpty) {
  //       _qrData = '';
  //       _qrDataController.text = '';
  //       _data = null;
  //     } else {
  //       _qrData = barcodeScanResult;
  //       _qrDataController.text = barcodeScanResult;
  //       _onScan(barcodeScanResult);
  //     }
  //   });
  // }

  // _onScan(value) {
  //   setState(() {
  //     _loading = true;
  //   });
  //   _sb.getData(value).then((_) {
  //     setState(() {
  //       if (_sb.scan == null) {
  //         _qrData = '';
  //         _qrDataController.text = '';
  //         _data = null;
  //       } else {
  //         _qrData = value;
  //         _qrDataController.text = value;
  //         _data = _sb.scan;
  //       }
  //       _loading = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        const SizedBox(height: 3),
        CardVin(),
        const SizedBox(height: 5),
        TabsNhanXe(),
        const SizedBox(height: 10),
        // Box 1
        Container(
          width: 90.w,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          margin: const EdgeInsets.all(15), // Khoảng cách giữa các box
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      height: 8.h,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          _data != null ? _data!.tenSanPham ?? "" : "",
                          style: TextStyle(
                            fontFamily: 'Coda Caption',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFA71C20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 16.w,
                    height: 3.h,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF428FCA),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          // Xử lý sự kiện khi nút được nhấn
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(0),
                        ),
                        child: const Text(
                          'Chờ nhận',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                height: 9.h,
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Text 1
                    showInfoXe(
                      'Số khung (VIN):',
                      _data != null ? _data!.soKhung ?? "" : "",
                    ),

                    SizedBox(width: 8.w), // Khoảng cách giữa hai Text
                    showInfoXe(
                      'Màu:',
                      _data != null ? _data!.tenMau ?? "" : "",
                    ),
                    SizedBox(width: 5.w),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                height: 9.h,
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    SizedBox(width: 5.w),
                    showInfoXe(
                      'Nhà máy',
                      _data != null ? _data!.tenKho ?? "" : "",
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    nextScreen(
                        context,
                        NhanXe2Page(
                          soKhung: _data!.soKhung ?? "",
                          soMay: _data!.soMay ?? "",
                          tenMau: _data!.tenMau ?? "",
                          tenSanPham: _data!.tenSanPham ?? "",
                          ngayXuatKhoView: _data!.ngayXuatKhoView ?? "",
                          tenTaiXe: _data!.tenTaiXe ?? " ",
                          ghiChu: _data!.ghiChu ?? "No",
                          tenKho: _data!.tenKho ?? "",
                          phuKien: _data!.phuKien ?? [],
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE96327), // Màu nền của nút
                    fixedSize: Size(85.w, 7.h), // Kích thước cố định của nút
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Độ cong của góc nút
                    ),
                  ),
                  child: const Text(
                    'NHẬN XE',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 16,
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
          color: Color(0xFF818180),
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFFA71C20),
        ),
      )
    ],
  );
}
