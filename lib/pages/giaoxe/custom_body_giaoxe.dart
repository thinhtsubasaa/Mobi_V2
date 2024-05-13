import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Thilogi/models/giaoxe.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as GeoLocationAccuracy;
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/giaoxe_bloc.dart';
import '../../config/config.dart';
import '../../models/diadiem.dart';
import '../../models/phuongthucvanchuyen.dart';
import '../../services/app_service.dart';
import '../../blocs/image_bloc.dart';
import '../../utils/snackbar.dart';
import '../../widgets/loading.dart';

class CustomBodyGiaoXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyGiaoXeScreen());
  }
}

class BodyGiaoXeScreen extends StatefulWidget {
  const BodyGiaoXeScreen({Key? key}) : super(key: key);

  @override
  _BodyGiaoXeScreenState createState() => _BodyGiaoXeScreenState();
}

class _BodyGiaoXeScreenState extends State<BodyGiaoXeScreen>
    with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  GiaoXeModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';
  String? viTri;

  late GiaoXeBloc _bl;
  File? _selectImage;
  List<File> _selectedImages = [];

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  late ImageBloc _ib;
  List<DiaDiemModel>? _diadiemList;
  List<DiaDiemModel>? get diadiemList => _diadiemList;
  List<PhuongThucVanChuyenModel>? _phuongthucvanchuyenList;
  List<PhuongThucVanChuyenModel>? get phuongthucvanchuyenList =>
      _phuongthucvanchuyenList;
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
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<GiaoXeBloc>(context, listen: false);
    _ib = Provider.of<ImageBloc>(context, listen: false);
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

  Future<void> postData(GiaoXeModel scanData, String viTri) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/GiaoXe?ViTri=$viTri', newScanData.toJson());
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
          text: "Giao xe thành công",
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
    _bl.getData(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.giaoxe == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.giaoxe;
      });
    });
  }

  _onSave() {
    setState(() {
      _loading = true;
    });

    _data?.key = _bl.giaoxe?.key;
    _data?.id = _bl.giaoxe?.id;
    _data?.soKhung = _bl.giaoxe?.soKhung;
    _data?.tenSanPham = _bl.giaoxe?.tenSanPham;
    _data?.maSanPham = _bl.giaoxe?.maSanPham;
    _data?.soMay = _bl.giaoxe?.soMay;
    _data?.maMau = _bl.giaoxe?.maMau;
    _data?.tenMau = _bl.giaoxe?.tenMau;
    _data?.tenKho = _bl.giaoxe?.tenKho;
    _data?.maViTri = _bl.giaoxe?.maViTri;
    _data?.tenViTri = _bl.giaoxe?.tenViTri;
    _data?.mauSon = _bl.giaoxe?.mauSon;
    _data?.ngayNhapKhoView = _bl.giaoxe?.ngayNhapKhoView;
    _data?.maKho = _bl.giaoxe?.maKho;
    _data?.kho_Id = _bl.giaoxe?.kho_Id;
    _data?.noigiao = _bl.giaoxe?.noigiao;
    _data?.tenDiaDiem = _bl.giaoxe?.tenDiaDiem;
    _data?.tenPhuongThucVanChuyen = _bl.giaoxe?.tenPhuongThucVanChuyen;
    _data?.bienSo_Id = _bl.giaoxe?.bienSo_Id;
    _data?.taiXe_Id = _bl.giaoxe?.taiXe_Id;
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      // Assuming `_data` is not null
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      _data?.toaDo = "${lat},${long}";
      print("Vi tri: ${_data?.toaDo}");

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
        text: 'Bạn có muốn giao xe không?',
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
                            const Divider(
                              height: 1,
                              color: AppConfig.primaryColor,
                            ),
                            const SizedBox(height: 10),
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
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
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
                          Item(
                            title: 'Nơi giao:',
                            value: _data?.noigiao,
                          ),
                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SizedBox(
                                //   height: 150,
                                //   child: ListView.builder(
                                //     scrollDirection: Axis.horizontal,
                                //     itemCount: _selectedImages.length,
                                //     itemBuilder: (context, index) {
                                //       return Padding(
                                //         padding: const EdgeInsets.all(8.0),
                                //         child: Image.file(
                                //           _selectedImages[index],
                                //           width: 100,
                                //           height: 100,
                                //           fit: BoxFit.cover,
                                //         ),
                                //       );
                                //     },
                                //   ),
                                // ),
                                // MaterialButton(
                                //   color: Colors.red,
                                //   child: Text(
                                //     "Ảnh",
                                //     style: TextStyle(
                                //       fontFamily: 'Comfortaa',
                                //       color: Colors.white,
                                //       fontWeight: FontWeight.w700,
                                //       fontSize: 16,
                                //     ),
                                //   ),
                                //   onPressed: () {
                                //     _imageService.pickImage(
                                //         context, _selectedImages);
                                //   },
                                // ),

                                // MaterialButton(
                                //   color: Colors.red,
                                //   child: Text(
                                //     "Lưu",
                                //     style: TextStyle(
                                //       fontFamily: 'Comfortaa',
                                //       color: Colors.white,
                                //       fontWeight: FontWeight.w700,
                                //       fontSize: 16,
                                //     ),
                                //   ),
                                //   onPressed: () {
                                //     // Gọi phương thức uploadImages từ _imageService và chuyển danh sách _selectedImages
                                //     _imageService.upload(
                                //         context, _selectedImages);
                                //   },
                                // ),
                              ],
                            ),
                          ),
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
                        child: Text('Giao Xe',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              color: AppConfig.textButton,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
                        controller: _btnController,
                        onPressed: _data?.soKhung != null
                            ? () => _showConfirmationDialog(context)
                            : null,
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
                  fontSize: 18,
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
