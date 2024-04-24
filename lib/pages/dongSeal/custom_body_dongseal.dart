import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/dongcont_bloc.dart';
import 'package:Thilogi/models/danhsachphuongtientau.dart';
import 'package:Thilogi/models/dongcont.dart';
import 'package:Thilogi/utils/snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import 'package:http/http.dart' as http;
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as GeoLocationAccuracy;

import '../../config/config.dart';
import '../../models/dongseal.dart';
import '../../models/dsxdongcont.dart';

import '../../services/app_service.dart';
import '../../widgets/loading.dart';

class CustomBodyDongSealXe extends StatelessWidget {
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
    with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  String? soContId;
  String? TauId;
  TextEditingController _controller = TextEditingController();

  List<DSX_DongContModel>? _dsxdongcontList;
  List<DSX_DongContModel>? get dsxdongcont => _dsxdongcontList;

  List<DanhSachPhuongTienTauModel>? _danhsachphuongtientauList;
  List<DanhSachPhuongTienTauModel>? get danhsachphuongtientauList =>
      _danhsachphuongtientauList;

  DongSealModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';
  String? lat;
  String? long;
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

  late DongContBloc _bl;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<DongContBloc>(context, listen: false);
  }

  void getSoCont() async {
    try {
      final http.Response response =
          await requestHelper.getData('GetListContMobi');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _dsxdongcontList = (decodedData as List)
            .map((item) => DSX_DongContModel.fromJson(item))
            .toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          _loading = false;
        });
      }

      // notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      // notifyListeners();
    }
  }

  void getDanhSachPhuongTienTauList() async {
    try {
      final http.Response response =
          await requestHelper.getData('TMS_DanhSachPhuongTienTau');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body)['datalist'];

        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _danhsachphuongtientauList = (decodedData as List)
            .map((item) => DanhSachPhuongTienTauModel.fromJson(item))
            .toList();
        // Gọi setState để cập nhật giao diện
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      // Xử lý lỗi khi gọi API
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  // Future<void> postData(String soKhung, String viTri, String soCont) async {
  //   _isLoading = true;

  //   try {
  //     // var newScanData = scanData;

  //     // newScanData.soKhung =
  //     //     newScanData.soKhung == 'null' ? null : newScanData.soKhung;
  //     // print("print data: ${newScanData.soKhung}");
  //     final http.Response response = await requestHelper.postData(
  //         'KhoThanhPham/DongCont?SoKhung=$soKhung&ViTri=$viTri&SoCont=$soCont',
  //         _data?.toJson());
  //     print("statusCode: ${response.statusCode}");
  //     if (response.statusCode == 200) {
  //       var decodedData = jsonDecode(response.body);

  //       print("data: ${decodedData}");

  //       notifyListeners();
  //       _btnController.success();
  //       QuickAlert.show(
  //         context: context,
  //         type: QuickAlertType.success,
  //         text: "Đóng cont thành công",
  //       );
  //       _btnController.reset();
  //     } else {
  //       String errorMessage = response.body.replaceAll('"', '');
  //       notifyListeners();
  //       _btnController.error();
  //       QuickAlert.show(
  //         context: context,
  //         type: QuickAlertType.error,
  //         title: '',
  //         text: errorMessage,
  //       );
  //       _btnController.reset();
  //     }
  //   } catch (e) {
  //     _message = e.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  @override
  void dispose() {
    scanSubscription.cancel();
    // dataWedge.dispose();
    super.dispose();
  }

  // _onSave() {
  //   setState(() {
  //     _loading = true;
  //   });

  //   _data?.key = _bl.dongcont?.key;
  //   _data?.id = _bl.dongcont?.id;
  //   _data?.soCont = _bl.dongcont?.soCont;
  //   _data?.soSeal = _bl.dongcont?.soSeal;

  //   Geolocator.getCurrentPosition(
  //     desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
  //   ).then((position) {
  //     // Assuming `_data` is not null
  //     setState(() {
  //       lat = "${position.latitude}";
  //       long = "${position.longitude}";
  //     });
  //     _data?.lat = lat;
  //     _data?.long = long;
  //     _data?.viTri = "${lat},${long}";

  //     print("lat: ${_data?.lat}");
  //     print("long: ${_data?.long}");
  //     print("viTri: ${_data?.viTri}");

  //     // call api

  //     AppService().checkInternet().then((hasInternet) {
  //       if (!hasInternet!) {
  //         openSnackBar(context, 'no internet'.tr());
  //       } else {
  //         postData(
  //                 _data?.soKhung ?? "", _data?.viTri ?? "", _data?.soCont ?? "")
  //             .then((_) {
  //           setState(() {
  //             _data = null;
  //             _qrData = '';
  //             _qrDataController.text = '';
  //             _loading = false;
  //           });
  //         });
  //       }
  //     });
  //   }).catchError((error) {
  //     // Handle error while getting location
  //     print("Error getting location: $error");
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    getSoCont();
    getDanhSachPhuongTienTauList();
    return Container(
        child: Column(
      children: [
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
                _loading
                    ? LoadingWidget(context)
                    : Container(
                        padding: const EdgeInsets.all(10),
                        margin: EdgeInsets.only(top: 20),
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
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height < 600
                                          ? 10.h
                                          : 7.h,
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
                                        width: 20.w,
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
                                            "Số Cont",
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
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      600
                                                  ? 0
                                                  : 10),
                                          child:
                                              DropdownButtonFormField<String>(
                                            isDense: true,
                                            items:
                                                _dsxdongcontList?.map((item) {
                                              return DropdownMenuItem<String>(
                                                value: item.id,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 15.sp),
                                                  child: Center(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        item.soCont ?? "",
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Comfortaa',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppConfig
                                                              .textInput,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            value: soContId,
                                            onChanged: (newValue) async {
                                              setState(() {
                                                soContId = newValue;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                MyInputWidget(
                                  title: 'Số Seal',
                                  controller: _controller,
                                  textStyle: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppConfig.textInput,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height < 600
                                          ? 10.h
                                          : 7.h,
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
                                        width: 20.w,
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
                                            "Tàu",
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
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      600
                                                  ? 0
                                                  : 10),
                                          child:
                                              DropdownButtonFormField<String>(
                                            isDense: true,
                                            items: _danhsachphuongtientauList
                                                ?.map((item) {
                                              return DropdownMenuItem<String>(
                                                value: item.id,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 15.sp),
                                                  child: Center(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        item.tenPhuongTien ??
                                                            "",
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Comfortaa',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppConfig
                                                              .textInput,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            value: TauId,
                                            onChanged: (newValue) async {
                                              setState(() {
                                                TauId = newValue;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      RoundedLoadingButton(
                                        child: Text('Xác nhận',
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
                          ],
                        ),
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
  final TextEditingController controller;
  final TextStyle textStyle;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.controller,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height < 600 ? 10.h : 7.h,
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
            width: 20.w,
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
              padding: EdgeInsets.only(top: 5, left: 15.sp),
              child: TextFormField(
                controller: controller,
                style: textStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
