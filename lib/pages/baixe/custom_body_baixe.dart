import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/nhapbai.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/vitri.dart';
import 'package:Thilogi/utils/snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/blocs/khothanhpham_bloc.dart';
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/khoxe.dart';
import '../../services/app_service.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as GeoLocationAccuracy;
import 'package:quickalert/quickalert.dart';
import '../../widgets/loading.dart';
import '../../widgets/map.dart';

class CustomBodyBaiXe extends StatelessWidget {
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
  String? KhoXeId;
  String? BaiXeId;
  String? ViTriId;
  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  KhoThanhPhamModel? _data;

  String barcodeScanResult = '';
  late NhapBaiBloc _bl;

  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;

  List<ViTriModel>? _vitriList;
  List<ViTriModel>? get vitriList => _vitriList;

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
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<NhapBaiBloc>(context, listen: false);

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

    super.dispose();
  }

  void getLocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low);
    print("ss");
    print(position);
  }

  void getData() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        // var data = decodedData["data"];
        // var info = data["info"];

        _khoxeList = (decodedData as List)
            .map((item) => KhoXeModel.fromJson(item))
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

  void getBaiXeList(String KhoXeId) async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_BaiXe?khoXe_Id=$KhoXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        // print("data: ${decodedData}");
        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _baixeList = (decodedData as List)
            .map((item) => BaiXeModel.fromJson(item))
            .toList();
        // Gọi setState để cập nhật giao diện
        // setState(() {
        //   _loading = true;
        // });
      }
    } catch (e) {
      // Xử lý lỗi khi gọi API
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getViTriList(String BaiXeId) async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_ViTri?baiXe_Id=$BaiXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body)['result'];
        // print("data: ${decodedData}");
        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _vitriList = (decodedData as List)
            .map((item) => ViTriModel.fromJson(item))
            .toList();
        // Gọi setState để cập nhật giao diện
        // setState(() {
        //   _loading = true;
        // });
      }
    } catch (e) {
      // Xử lý lỗi khi gọi API
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      height: 8.h,
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
          color: const Color(0xFF818180), // Màu của đường viền
          width: 1, // Độ dày của đường viền
        ),
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
    print("abc: ${barcodeScanResult}");
    // Process the barcode scan result here
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

  Future<void> postData(String ViTriId, String viTri, String soKhung) async {
    _isLoading = true;
    try {
      // var newScanData = scanData;
      // newScanData.soKhung =
      //     newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      // print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/NhapKhoBai?ViTri_Id=$ViTriId&ToaDo=$viTri&SoKhung=$soKhung',
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
          title: "SUCCESS",
          text: "Nhập kho thành công",
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

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _bl.getData(context, value).then((_) {
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

  _onSave() {
    setState(() {
      _loading = true;
    });
    _data?.Kho_Id = KhoXeId;
    _data?.BaiXe_Id = BaiXeId;
    _data?.viTri_Id = ViTriId;
    _data?.id = _bl.baixe?.id;
    _data?.soKhung = _bl.baixe?.soKhung;

    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      _data?.viTri = "${lat},${long}";

      print("viTri:${_data?.viTri}");
      print("ViTri_ID:${_data?.viTri_Id}");
      print("SoKhung: ${_data?.soKhung}");

      // call api

      AppService().checkInternet().then((hasInternet) {
        if (!hasInternet!) {
          openSnackBar(context, 'no internet'.tr());
        } else {
          postData(ViTriId!, _data?.viTri ?? "", _data?.soKhung ?? "")
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
    getData();
    getBaiXeList(KhoXeId ?? "");
    return Container(
        child: Column(
      children: [
        CardVin(),
        const SizedBox(height: 5),
        Center(
          child: Container(
            alignment: Alignment.bottomCenter,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(5),
            //   color: Colors.white.withOpacity(1),
            //   boxShadow: const [
            //     BoxShadow(
            //       color: Color(0x40000000),
            //       blurRadius: 4,
            //       offset: Offset(0, 4),
            //     ),
            //   ],
            // ),
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
                                // Container(
                                //   height:
                                //       MediaQuery.of(context).size.height < 600
                                //           ? 10.h
                                //           : 7.h,
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(5),
                                //     border: Border.all(
                                //       color: const Color(0xFF818180),
                                //       width: 1,
                                //     ),
                                //   ),
                                //   child: Row(
                                //     children: [
                                //       Container(
                                //         width: 20.w,
                                //         decoration: const BoxDecoration(
                                //           color: Color(0xFFF6C6C7),
                                //           border: Border(
                                //             right: BorderSide(
                                //               color: Color(0xFF818180),
                                //               width: 1,
                                //             ),
                                //           ),
                                //         ),
                                //         child: Center(
                                //           child: Text(
                                //             "Kho Xe",
                                //             textAlign: TextAlign.left,
                                //             style: const TextStyle(
                                //               fontFamily: 'Comfortaa',
                                //               fontSize: 16,
                                //               fontWeight: FontWeight.w400,
                                //               color: AppConfig.textInput,
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //       Expanded(
                                //         flex: 1,
                                //         child: Container(
                                //           padding: EdgeInsets.only(
                                //               top: MediaQuery.of(context)
                                //                           .size
                                //                           .height <
                                //                       600
                                //                   ? 0
                                //                   : 10),
                                //           child:
                                //               DropdownButtonFormField<String>(
                                //             isDense: true,
                                //             items: _khoxeList?.map((item) {
                                //               return DropdownMenuItem<String>(
                                //                 value: item.id,
                                //                 child: Container(
                                //                   padding: EdgeInsets.only(
                                //                       left: 15.sp),
                                //                   child: Center(
                                //                     child: Align(
                                //                       alignment:
                                //                           Alignment.center,
                                //                       child: Text(
                                //                         item.tenKhoXe ?? "",
                                //                         style: const TextStyle(
                                //                           fontFamily:
                                //                               'Comfortaa',
                                //                           fontSize: 14,
                                //                           fontWeight:
                                //                               FontWeight.w600,
                                //                           color: AppConfig
                                //                               .textInput,
                                //                         ),
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ),
                                //               );
                                //             }).toList(),
                                //             value: KhoXeId,
                                //             onChanged: (newValue) async {
                                //               setState(() {
                                //                 KhoXeId = newValue;
                                //               });
                                //               if (newValue != null) {
                                //                 getBaiXeList(newValue);
                                //                 print("object : ${KhoXeId}");
                                //               }
                                //               ;
                                //             },
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                const SizedBox(height: 4),
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
                                            "Bãi Xe",
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
                                            isExpanded: true,
                                            items: _baixeList?.map((item) {
                                              return DropdownMenuItem<String>(
                                                value: item.id,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 15.sp),
                                                  child: Text(
                                                    item.tenBaiXe ?? "",
                                                    style: const TextStyle(
                                                      fontFamily: 'Comfortaa',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppConfig.textInput,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            value: BaiXeId,
                                            onChanged: (newValue) async {
                                              setState(() {
                                                BaiXeId = newValue;
                                              });
                                              if (newValue != null) {
                                                getViTriList(newValue);
                                                print("object : ${BaiXeId}");
                                              }
                                              ;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                                            "Vị trí",
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
                                            items: _vitriList?.map((item) {
                                              return DropdownMenuItem<String>(
                                                value: item.id,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      left: 15.sp),
                                                  child: Text(
                                                    item.tenViTri ?? "",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontFamily: 'Comfortaa',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppConfig.textInput,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            value: ViTriId,
                                            onChanged: (newValue) {
                                              setState(() {
                                                ViTriId = newValue;
                                              });
                                              print("object : ${ViTriId}");
                                            },
                                          ),
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
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                _data?.tenSanPham ?? "",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Coda Caption',
                                  fontSize: 15,
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
                                      _data?.soKhung ?? "",
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
                                      _data?.tenMau ?? "",
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
                                    SizedBox(width: 10),
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
                                      _data?.soMay ?? "",
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
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      RoundedLoadingButton(
                        child: Text('Nhập kho',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              color: AppConfig.textButton,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
                        controller: _btnController,
                        onPressed: ViTriId != null ? _onSave : null,
                      ),
                      SizedBox(height: 10),
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
