import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/blocs/khothanhpham_bloc.dart';
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../config/config.dart';

class CustomBodyXuatCongXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyBaiXeScreen());
  }
}

class BodyBaiXeScreen extends StatefulWidget {
  const BodyBaiXeScreen({Key? key}) : super(key: key);

  @override
  _BodyBaiXeScreenState createState() => _BodyBaiXeScreenState();
}

class _BodyBaiXeScreenState extends State<BodyBaiXeScreen>
    with SingleTickerProviderStateMixin {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  KhoThanhPhamModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _success = false;
  bool get success => _success;

  String? _message;
  String? get message => _message;

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  late KhoThanhPhamBloc _bl;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  var soContCtrl = TextEditingController();
  var soSiuCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<KhoThanhPhamBloc>(context, listen: false);
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
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: 8.h,
      margin: const EdgeInsets.only(top: 10),
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
              color: Color(0xFFA71C20),
            ),
            child: Center(
              child: Text(
                'Số khung\n(VIN)',
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
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                barcodeScanResult.isNotEmpty ? barcodeScanResult : '',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
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
              print(barcodeScanResult);
              _handleBarcodeScanResult(barcodeScanResult);
            },
          ),
        ],
      ),
    );
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print(barcodeScanResult);
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

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _bl.getData(value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.baixe == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.baixe;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        CardVin(),
        const SizedBox(height: 5),
        Center(
          child: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white.withOpacity(1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông Tin Xác Nhận',
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Divider(height: 1, color: Color(0xFFA71C20)),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyInputWidget(
                            title: "Số Công",
                            text: "",
                            textStyle: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppConfig.textInput,
                            ),
                            controller: soContCtrl,
                          ),
                          SizedBox(height: 4),
                          MyInputWidget(
                            title: "Số siu",
                            text: "",
                            textStyle: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppConfig.textInput,
                            ),
                            controller: soSiuCtrl,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                _data != null ? _data!.tenSanPham ?? "" : "",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Coda Caption',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFA71C20),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Số khung (VIN):',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF818180),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _data != null ? _data!.soKhung ?? "" : "",
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFA71C20),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Màu:',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF818180),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _data != null ? _data!.tenMau ?? "" : "",
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
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
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Số máy:',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF818180),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _data != null ? _data!.soMay ?? "" : "",
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
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
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                RoundedLoadingButton(
                                  child: Text('Lưu',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        color: AppConfig.textButton,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      )),
                                  controller: _btnController,
                                  onPressed: null,
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class MyInputWidget extends StatelessWidget {
  final String title;
  final String text;
  final TextStyle textStyle;
  final TextEditingController? controller;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.text,
    required this.textStyle,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            decoration: const BoxDecoration(
              color: Color(0xFFF6C6C7),
              border: Border(
                right: BorderSide(
                  color: Color(0xFF818180),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppConfig.textInput,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: TextFormField(
                controller: controller,
                style: textStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
