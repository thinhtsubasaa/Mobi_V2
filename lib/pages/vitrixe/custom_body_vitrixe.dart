import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/blocs/khothanhpham_bloc.dart';
import 'package:Thilogi/blocs/khoxe_bloc.dart';
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CustomBodyVitriXe extends StatelessWidget {
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
  String? selectedKho;
  List<String> khoList = ['Vị trí 1', 'Vị trí 2', 'Vị trí 3'];
  String _qrData = '';
  final _qrDataController = TextEditingController();
  Timer? _debounce;
  List<String>? _results = [];
  KhoThanhPhamModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';
  TabController? _tabController;
  late KhoThanhPhamBloc _bl;

  String _tenKhoXe = "no";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController!.addListener(_handleTabChange);
    _bl = Provider.of<KhoThanhPhamBloc>(context, listen: false);

    // setState(() {
    //   _tenKhoXe = _kl.tenKhoXe!;
    // });
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
        children: [
          // Phần Text 1
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text trong cột
                Text(
                  'Số khung\n (VIN)',
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
            barcodeScanResult.isNotEmpty
                ? barcodeScanResult
                : '          Scan a barcode         ',
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
        // Box 1
        Center(
          child: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white.withOpacity(0.9),
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
                      const Text(
                        'Thông Tin Xác Nhận',
                        style: TextStyle(
                          fontFamily: 'Comfortaa',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFA71C20)),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoRow(
                            labelText: "Kho Xe",
                            itemList: khoList,
                            selectedValue: selectedKho,
                            onChanged: (newValue) {
                              setState(() {
                                selectedKho = newValue;
                              });
                            },
                          ),
                          InfoRow(
                            labelText: "Bãi Xe",
                            itemList: khoList,
                            selectedValue: selectedKho,
                            onChanged: (newValue) {
                              setState(() {
                                selectedKho = newValue;
                              });
                            },
                          ),
                          InfoRow(
                            labelText: "Vị trí",
                            itemList: khoList,
                            selectedValue: selectedKho,
                            onChanged: (newValue) {
                              setState(() {
                                selectedKho = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    // Box 1
                    Container(
                      margin: EdgeInsets.all(10), // Khoảng cách giữa các box
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Text
                              Text(
                                _data != null ? _data!.tenSanPham ?? "" : "",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Coda Caption',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  height:
                                      1.56, // Corresponds to line-height of 28px
                                  letterSpacing: 0,
                                  color: Color(0xFFA71C20),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        height: 1.08,
                                        letterSpacing: 0,
                                        color: Color(0xFF818180),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Text 2
                                    Text(
                                      _data != null ? _data!.soKhung ?? "" : "",
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

                                SizedBox(
                                    width: 60), // Khoảng cách giữa hai Text

                                // Text 2
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text 1
                                    Text(
                                      'Màu:',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.08,
                                        letterSpacing: 0,
                                        color: Color(0xFF818180),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Text 2
                                    Text(
                                      _data != null ? _data!.tenMau ?? "" : "",
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 14,
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
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 10),

                                    // Text 1
                                    Text(
                                      'Số máy:',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.08,
                                        letterSpacing: 0,
                                        color: Color(0xFF818180),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Text 2
                                    Text(
                                      _data != null ? _data!.soMay ?? "" : "",
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 18,
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
                        ],
                      ),
                    ),
                  ],
                ),

                // _buildButtons(context),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class InfoRow extends StatelessWidget {
  final String labelText;
  final List<String> itemList;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const InfoRow({
    required this.labelText,
    required this.itemList,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 7.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: const Color(0xFF818180),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
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
                      labelText,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: selectedValue,
                  onChanged: onChanged,
                  items: itemList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Container(
                        padding: EdgeInsets.only(left: 15.w),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
