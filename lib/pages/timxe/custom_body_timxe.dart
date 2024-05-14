import 'dart:async';
import 'package:Thilogi/blocs/timxe.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/timxe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/loading.dart';

class CustomBodyTimXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyTimXeScreen());
  }
}

class BodyTimXeScreen extends StatefulWidget {
  const BodyTimXeScreen({Key? key}) : super(key: key);

  @override
  _BodyTimXeScreenState createState() => _BodyTimXeScreenState();
}

class _BodyTimXeScreenState extends State<BodyTimXeScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  TimXeModel? _data;
  late TimXeBloc _bl;
  String barcodeScanResult = '';

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<TimXeBloc>(context, listen: false);
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
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
    _qrDataController.dispose();
    super.dispose();
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: 11.h,
      margin: const EdgeInsets.only(top: 10),
      // decoration: BoxDecoration(
      //   // Đặt border radius cho card
      //   borderRadius: BorderRadius.circular(10),
      //   border: Border.all(
      //     color: const Color(0xFF818180), // Màu của đường viền
      //     width: 1, // Độ dày của đường viền
      //   ),
      //   color: Colors.white, // Màu nền của card
      // ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20.w,
            height: 11.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
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
          // Expanded(
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 10),
          //     child: Text(
          //       barcodeScanResult.isNotEmpty ? barcodeScanResult : '',
          //       style: TextStyle(
          //         fontFamily: 'Comfortaa',
          //         fontSize: 15,
          //         fontWeight: FontWeight.w600,
          //         color: AppConfig.primaryColor,
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _qrDataController,
                decoration: InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
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
                _qrDataController.text = result;
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
    print("abc: ${barcodeScanResult}");
    setState(() {
      _qrData = '';
      _qrDataController.text = '';
      _data = null;
      Future.delayed(const Duration(seconds: 0), () {
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
    _bl.getData(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.timxe == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.timxe;
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
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _loading
                      ? LoadingWidget(context)
                      : Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thông Tin Tìm Kiếm',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Divider(
                                  height: 1, color: Color(0xFFA71C20)),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Item(
                                      title: 'Kho Xe:',
                                      value: _data?.tenKho,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Bãi Xe:',
                                      value: _data?.tenBaiXe,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Vị Trí xe:',
                                      value: _data?.tenViTri,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  final String title;
  final String? value;

  const Item({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF818180),
                ),
              ),
              SizedBox(height: 5),
              Text(
                value ?? "",
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
