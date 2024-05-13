import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/dongcont_bloc.dart';
import 'package:Thilogi/models/dongcont.dart';
import 'package:Thilogi/utils/snackbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
import '../../models/dsxdongcont.dart';
import '../../services/app_service.dart';
import '../../widgets/loading.dart';

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
    with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  String? soContId;

  String? DanhSachPhuongTienId;

  List<DSX_DongContModel>? _dsxdongcontList;
  List<DSX_DongContModel>? get dsxdongcont => _dsxdongcontList;

  DongContModel? _data;
  DSX_DongContModel? _dc;
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
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<DongContBloc>(context, listen: false);
    requestLocationPermission();
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
    textEditingController.dispose();
    super.dispose();
  }

  void requestLocationPermission() async {
    // Kiểm tra quyền truy cập vị trí
    LocationPermission permission = await Geolocator.checkPermission();
    // Nếu chưa có quyền, yêu cầu quyền truy cập vị trí
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Yêu cầu quyền truy cập vị trí
      await Geolocator.requestPermission();
    }
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
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> postData(DongContModel? scanData, String soContId,
      String soKhung, String toaDo) async {
    _isLoading = true;

    try {
      var newScanData = scanData;

      newScanData?.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData?.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/DongCont?SoContId=$soContId&SoKhung=$soKhung&ViTri=$toaDo',
          newScanData?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: "Đóng cont thành công",
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        _btnController.error();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
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
        if (_bl.dongcont == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.dongcont;
      });
    });
  }

  _onSave() {
    setState(() {
      _loading = true;
    });

    _data?.key = _bl.dongcont?.key;
    _data?.id = _bl.dongcont?.id;
    _data?.soKhung = _bl.dongcont?.soKhung;
    _data?.tenSanPham = _bl.dongcont?.tenSanPham;
    _data?.maSanPham = _bl.dongcont?.maSanPham;
    _data?.soMay = _bl.dongcont?.soMay;
    _data?.maMau = _bl.dongcont?.maMau;
    _data?.tenMau = _bl.dongcont?.tenMau;
    _data?.tenKho = _bl.dongcont?.tenKho;
    _data?.maViTri = _bl.dongcont?.maViTri;
    _data?.tenViTri = _bl.dongcont?.tenViTri;
    _data?.mauSon = _bl.dongcont?.mauSon;
    _data?.ngayNhapKhoView = _bl.dongcont?.ngayNhapKhoView;
    _data?.maKho = _bl.dongcont?.maKho;
    _data?.soCont = _bl.dongcont?.soCont;

    _data?.soSeal = _bl.dongcont?.soSeal;

    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      _data?.toaDo = "${lat},${long}";

      print("viTri: ${_data?.toaDo}");
      print("soContId: ${soContId}");
      print("soKhung:${_data?.soKhung}");

      AppService().checkInternet().then((hasInternet) {
        if (!hasInternet!) {
          // openSnackBar(context, 'no internet'.tr());
          QuickAlert.show(
            // ignore: use_build_context_synchronously
            context: context,
            type: QuickAlertType.error,
            title: 'Thất bại',
            text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
            confirmBtnText: 'Đồng ý',
          );
        } else {
          postData(_data!, soContId ?? "", _data?.soKhung ?? "",
                  _data?.toaDo ?? "")
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
      // Handle error while getting location
      print("Error getting location: $error");
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn đóng cont không?',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: TextStyle(
          color: Colors.red,
          fontSize: 19.0,
          fontWeight: FontWeight.bold,
        ),
        onCancelBtnTap: () {
          Navigator.of(context).pop();
          _btnController.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _onSave();
        });
  }

  @override
  Widget build(BuildContext context) {
    getSoCont();
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
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  items: _dsxdongcontList
                                                      ?.map((item) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: item.id,
                                                      child: Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.9),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Text(
                                                            item.soCont ?? "",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  'Comfortaa',
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppConfig
                                                                  .textInput,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  value: soContId,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      soContId = newValue;
                                                    });
                                                  },
                                                  dropdownSearchData:
                                                      DropdownSearchData(
                                                    searchController:
                                                        textEditingController,
                                                    searchInnerWidgetHeight: 50,
                                                    searchInnerWidget:
                                                        Container(
                                                      height: 50,
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 8,
                                                        bottom: 4,
                                                        right: 8,
                                                        left: 8,
                                                      ),
                                                      child: TextFormField(
                                                        expands: true,
                                                        maxLines: null,
                                                        controller:
                                                            textEditingController,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 10,
                                                            vertical: 8,
                                                          ),
                                                          hintText:
                                                              'Tìm số cont',
                                                          hintStyle:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    searchMatchFn:
                                                        (item, searchValue) {
                                                      if (item
                                                          is DropdownMenuItem<
                                                              String>) {
                                                        // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                        String itemId =
                                                            item.value ?? "";
                                                        // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                        return _dsxdongcontList
                                                                ?.any((soCont) =>
                                                                    soCont.id ==
                                                                        itemId &&
                                                                    soCont.soCont
                                                                            ?.toLowerCase()
                                                                            .contains(searchValue.toLowerCase()) ==
                                                                        true) ??
                                                            false;
                                                      } else {
                                                        return false;
                                                      }
                                                    },
                                                  ),
                                                  onMenuStateChange: (isOpen) {
                                                    if (!isOpen) {
                                                      textEditingController
                                                          .clear();
                                                    }
                                                  },
                                                ),
                                              ))),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Item(
                                  title: 'Số khung:',
                                  value: _data?.soKhung,
                                ),
                                Item(
                                  title: 'Màu:',
                                  value: _data?.tenMau,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                          Item(
                            title: 'Số máy:',
                            value: _data?.soMay,
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
                        child: Text('Xác nhận',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              color: AppConfig.textButton,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
                        controller: _btnController,
                        onPressed: soContId != null
                            ? () => _showConfirmationDialog(context)
                            : null,
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

class MyInputWidget extends StatelessWidget {
  final String title;
  final String text;
  final TextStyle textStyle;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              padding: EdgeInsets.only(top: 5, left: 15.sp),
              child: Text(
                text,
                style: textStyle,
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
