import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/utils/snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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

import '../../blocs/dongseal_bloc.dart';
import '../../config/config.dart';
import '../../models/danhsachphuongtien.dart';
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
  String? soCont;
  String? TauId;
  String? viTri;
  TextEditingController _soSeal = TextEditingController();

  List<DSX_DongContModel>? _dsxdongcontList;
  List<DSX_DongContModel>? get dsxdongcont => _dsxdongcontList;

  List<DanhSachPhuongTienModel>? _danhsachphuongtientauList;
  List<DanhSachPhuongTienModel>? get danhsachphuongtientauList =>
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

  late DongSealBloc _bl;

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<DongSealBloc>(context, listen: false);
  }

  void getSoCont() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_DongCont/GetListContMobi');
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
          await requestHelper.getData('TMS_DanhSachPhuongTien/Tau');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _danhsachphuongtientauList = (decodedData as List)
            .map((item) => DanhSachPhuongTienModel.fromJson(item))
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

  Future<void> postData(
      String soSeal, String viTri, String soCont, String TauId) async {
    _isLoading = true;

    try {
      // var newScanData = scanData;
      // newScanData.soKhung =
      //     newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      // print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/DongSeal?SoSeal=$soSeal&ViTri=$viTri&SoCont=$soCont&TauId=$TauId',
          _data?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'SUCCESS',
          text: "Đóng seal thành công",
        );
        _btnController.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        _btnController.error();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ERROR',
          text: errorMessage,
        );
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  _onSave() {
    setState(() {
      _loading = true;
    });

    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });
      _data?.lat = lat;
      _data?.long = long;
      viTri = "${lat},${long}";
      _data?.soSeal = _soSeal.text;

      print("viTri: ${viTri}");
      print("soSeal:${_soSeal.text}");
      print("soCont:${soCont}");
      print("TauId: ${TauId}");

      AppService().checkInternet().then((hasInternet) {
        if (!hasInternet!) {
          openSnackBar(context, 'no internet'.tr());
        } else {
          postData(_soSeal.text, viTri ?? "", soCont ?? "", TauId ?? "")
              .then((_) {
            setState(() {
              _data = null;
              _qrData = '';
              _qrDataController.text = '';
              _loading = false;
            });
          });
        }
      });
    }).catchError((error) {
      print("Error getting location: $error");
    });
  }

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
                                                  : 5),
                                          child:
                                              DropdownButtonFormField<String>(
                                            isDense: true,
                                            items:
                                                _dsxdongcontList?.map((item) {
                                              return DropdownMenuItem<String>(
                                                value: item.soCont,
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
                                            value: soCont,
                                            onChanged: (newValue) {
                                              setState(() {
                                                soCont = newValue;
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
                                  controller: _soSeal,
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
                                                  : 5),
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
                                            onChanged: (newValue) {
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
                                        onPressed:
                                            soCont != null ? _onSave : null,
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