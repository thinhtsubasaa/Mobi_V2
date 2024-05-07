import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe2.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import '../../blocs/scan_bloc.dart';
import '../../config/config.dart';
import '../../utils/next_screen.dart';
import '../../widgets/loading.dart';

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
  String _qrData = '';
  final _qrDataController = TextEditingController();
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
    super.dispose();
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: 8.h,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
        color: Theme.of(context).colorScheme.onPrimary,
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
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
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
    _sb.getData(context, value).then((_) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        const SizedBox(height: 5),
        CardVin(),
        const SizedBox(height: 15),
        _loading
            ? LoadingWidget(context)
            : Container(
                width: 90.w,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 8.h,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                _data?.tenSanPham ?? "",
                                style: TextStyle(
                                  fontFamily: 'Coda Caption',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppConfig.primaryColor,
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
                              onPressed: () {},
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
                                  color: AppConfig.textButton,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                    Container(
                      height: 13.h,
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          showInfoXe(
                            'Số khung (VIN):',
                            _data?.soKhung ?? "",
                          ),
                          showInfoXe(
                            'Màu:',
                            _data?.tenMau ?? "",
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                    Container(
                      height: 13.h,
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        children: [
                          showInfoXe(
                            'Nhà máy:',
                            _data?.tenKho ?? "",
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          _handleButtonTap(NhanXe2Page(
                            soKhung: _data!.soKhung ?? "",
                            soMay: _data!.soMay ?? "",
                            tenMau: _data!.tenMau ?? "",
                            tenSanPham: _data!.tenSanPham ?? "",
                            ngayXuatKhoView: _data!.ngayXuatKhoView ?? "",
                            tenTaiXe: _data!.tenTaiXe ?? " ",
                            ghiChu: _data!.ghiChu ?? "",
                            tenKho: _data!.tenKho ?? "",
                            phuKien: _data!.phuKien ?? [],
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE96327),
                          fixedSize: Size(85.w, 7.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'NHẬN XE',
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppConfig.textButton,
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

  void _handleButtonTap(Widget page) {
    setState(() {
      _loading = true;
    });
    nextScreen(context, page);
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _loading = false;
      });
    });
  }
}

Widget showInfoXe(String title, String value) {
  return Container(
    padding: EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF818180),
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppConfig.primaryColor,
          ),
        )
      ],
    ),
  );
}
