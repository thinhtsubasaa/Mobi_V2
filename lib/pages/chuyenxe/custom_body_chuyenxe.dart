import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/dieuchuyen_bloc.dart';
import 'package:Thilogi/models/dieuchuyen.dart';
import 'package:Thilogi/models/taixe.dart';
import 'package:Thilogi/utils/snackbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as GeoLocationAccuracy;
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/vitri_bloc.dart';
import '../../config/config.dart';
import '../../models/baixe.dart';
import '../../models/khoxe.dart';
import '../../models/vitri.dart';
import 'package:http/http.dart' as http;

import '../../services/app_service.dart';
import '../../widgets/loading.dart';

class CustomBodyChuyenXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyChuyenXeScreen());
  }
}

class BodyChuyenXeScreen extends StatefulWidget {
  const BodyChuyenXeScreen({Key? key}) : super(key: key);

  @override
  _BodyChuyenXeScreenState createState() => _BodyChuyenXeScreenState();
}

class _BodyChuyenXeScreenState extends State<BodyChuyenXeScreen>
    with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String _qrData = '';
  String? lat;
  String? long;
  String? KhoXeId;
  String? BaiXeId;
  String? ViTriId;
  String? TaiXeId;
  final _qrDataController = TextEditingController();
  DieuChuyenModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';
  late ViTriBloc _vl;
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;

  List<ViTriModel>? _vitriList;
  List<ViTriModel>? get vitriList => _vitriList;
  List<TaiXeModel>? _taixeList;
  List<TaiXeModel>? get taixeList => _taixeList;

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

  late DieuChuyenBloc _bl;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _bl = Provider.of<DieuChuyenBloc>(context, listen: false);
    _vl = Provider.of<ViTriBloc>(context, listen: false);
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

  void getData() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _khoxeList = (decodedData as List)
            .map((item) => KhoXeModel.fromJson(item))
            .toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          _loading = false;
        });
      }
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  void getBaiXeList(String KhoXeId) async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_BaiXe?khoXe_Id=$KhoXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");

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
      final http.Response response = await requestHelper
          .getData('DM_WMS_Kho_ViTri/Mobi?baiXe_Id=$BaiXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body)['result'];
        print("data: ${decodedData}");
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

  Future<void> postData(DieuChuyenModel scanData, String ToaDo) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/DieuChuyen?ToaDo=$ToaDo', newScanData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Thành công",
          text: "Điều chuyển thành công",
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
                  fontSize: 12,
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
    print(barcodeScanResult);

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
        if (_bl.dieuchuyen == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.dieuchuyen;
      });
    });
  }

  _onSave() {
    setState(() {
      _loading = true;
    });

    _data?.khoDen_Id = KhoXeId;
    _data?.baiXe_Id = BaiXeId;
    _data?.viTri_Id = ViTriId;
    _data?.taiXe_Id = TaiXeId;
    _data?.key = _bl.dieuchuyen?.key;
    _data?.id = _bl.dieuchuyen?.id;
    _data?.soKhung = _bl.dieuchuyen?.soKhung;
    _data?.tenSanPham = _bl.dieuchuyen?.tenSanPham;
    _data?.maSanPham = _bl.dieuchuyen?.maSanPham;
    _data?.soMay = _bl.dieuchuyen?.soMay;
    _data?.maMau = _bl.dieuchuyen?.maMau;
    _data?.tenMau = _bl.dieuchuyen?.tenMau;
    _data?.tenKho = _bl.dieuchuyen?.tenKho;
    _data?.tenViTri = _bl.dieuchuyen?.tenViTri;
    _data?.mauSon = _bl.dieuchuyen?.mauSon;
    _data?.ngayNhapKhoView = _bl.dieuchuyen?.ngayNhapKhoView;
    _data?.tenViTri = _bl.dieuchuyen?.tenViTri;
    _data?.mauSon = _bl.dieuchuyen?.mauSon;
    _data?.ngayNhapKhoView = _bl.dieuchuyen?.ngayNhapKhoView;
    _data?.tenTaiXe = _bl.dieuchuyen?.tenTaiXe;

    // Get location here
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      // Assuming `_data` is not null
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });
      _data?.toaDo = "${lat}, ${long}";
      print("viTri: ${_data?.toaDo}");
      print("Kho_ID:${_data?.khoDen_Id}");
      print("Bai_ID:${_data?.baiXe_Id}");

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
          postData(_data!, _data?.toaDo ?? "").then((_) {
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

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn điều chuyển không?',
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
    getData();
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
                              'Thông Tin Xác Nhận',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFA71C20)),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.87),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                _data?.tenSanPham ?? "",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontFamily: 'Coda Caption',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppConfig.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Số máy:',
                                        value: _data?.soMay,
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Kho đi:',
                                        value: _data?.tenKho ?? "",
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Bãi xe đi:',
                                        value: _data?.tenBaiXe ?? "",
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Item(
                                        title: 'Vị trí:',
                                        value: _data?.tenViTri ?? "",
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
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
                                        width: 25.w,
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
                                            "Kho đến",
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
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                items: _khoxeList?.map((item) {
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
                                                          item.tenKhoXe ?? "",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
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
                                                  );
                                                }).toList(),
                                                value: KhoXeId,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    KhoXeId = newValue;
                                                  });
                                                  if (newValue != null) {
                                                    getBaiXeList(newValue);
                                                    print(
                                                        "object : ${KhoXeId}");
                                                  }
                                                },
                                                dropdownSearchData:
                                                    DropdownSearchData(
                                                  searchController:
                                                      textEditingController,
                                                  searchInnerWidgetHeight: 50,
                                                  searchInnerWidget: Container(
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
                                                        hintText: 'Tìm kho xe',
                                                        hintStyle:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
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
                                                      return _khoxeList?.any((khoXe) =>
                                                              khoXe.id ==
                                                                  itemId &&
                                                              khoXe.tenKhoXe
                                                                      ?.toLowerCase()
                                                                      .contains(
                                                                          searchValue
                                                                              .toLowerCase()) ==
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
                                            )),
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
                                        width: 25.w,
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
                                            "Bãi xe đến",
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
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                items: _baixeList?.map((item) {
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
                                                          item.tenBaiXe ?? "",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
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
                                                  );
                                                }).toList(),
                                                value: BaiXeId,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    BaiXeId = newValue;
                                                  });
                                                  if (newValue != null) {
                                                    getViTriList(newValue);
                                                    print(
                                                        "object : ${BaiXeId}");
                                                  }
                                                },
                                                dropdownSearchData:
                                                    DropdownSearchData(
                                                  searchController:
                                                      textEditingController,
                                                  searchInnerWidgetHeight: 50,
                                                  searchInnerWidget: Container(
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
                                                        hintText: 'Tìm bãi xe',
                                                        hintStyle:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
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
                                                      return _baixeList?.any((baiXe) =>
                                                              baiXe.id ==
                                                                  itemId &&
                                                              baiXe.tenBaiXe
                                                                      ?.toLowerCase()
                                                                      .contains(
                                                                          searchValue
                                                                              .toLowerCase()) ==
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
                                            )),
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
                                        width: 25.w,
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
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                items: _vitriList?.map((item) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: item.id,
                                                    child: Container(
                                                      child: Text(
                                                        item.tenViTri ?? "",
                                                        textAlign:
                                                            TextAlign.center,
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
                                                  );
                                                }).toList(),
                                                value: ViTriId,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    ViTriId = newValue;
                                                  });
                                                  print("object : ${ViTriId}");
                                                },
                                                dropdownSearchData:
                                                    DropdownSearchData(
                                                  searchController:
                                                      textEditingController,
                                                  searchInnerWidgetHeight: 50,
                                                  searchInnerWidget: Container(
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
                                                        hintText: 'Tìm vị trí',
                                                        hintStyle:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
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
                                                      return _vitriList?.any((viTri) =>
                                                              viTri.id ==
                                                                  itemId &&
                                                              viTri.tenViTri
                                                                      ?.toLowerCase()
                                                                      .contains(
                                                                          searchValue
                                                                              .toLowerCase()) ==
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
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      RoundedLoadingButton(
                        child: Text('Điều chuyển',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              color: AppConfig.textButton,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
                        controller: _btnController,
                        onPressed: ViTriId != null
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
