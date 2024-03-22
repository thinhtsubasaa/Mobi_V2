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
import 'package:sizer/sizer.dart';

import '../../blocs/giaoxe_bloc.dart';
import '../../models/diadiem.dart';
import '../../models/phuongthucvanchuyen.dart';
import '../../services/app_service.dart';
import '../../blocs/image_bloc.dart';
import '../../utils/snackbar.dart';

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
  String? DiaDiemId;
  String? PhuongThucVanChuyenId;
  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  Timer? _debounce;
  List<String>? _results = [];
  GiaoXeModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';

  late GiaoXeBloc _bl;

  File? _selectImage;
  List<File> _selectedImages = [];

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  late ImageService _imageService;
  List<DiaDiemModel>? _diadiemList; // Định nghĩa danh sách khoxeList ở đây
  List<DiaDiemModel>? get diadiemList => _diadiemList;
  List<PhuongThucVanChuyenModel>?
      _phuongthucvanchuyenList; // Định nghĩa danh sách khoxeList ở đây
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

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<GiaoXeBloc>(context, listen: false);
    _imageService = Provider.of<ImageService>(context, listen: false);
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

  void getData() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_DiaLy_DiaDiem/DiaDiemmobi');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        // var data = decodedData["data"];
        // var info = data["info"];

        _diadiemList = (decodedData as List)
            .map((item) => DiaDiemModel.fromJson(item))
            .toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          _loading = true;
        });
      }

      // notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      // notifyListeners();
    }
  }

  void getPhuongThucVanChuyenList() async {
    try {
      final http.Response response =
          await requestHelper.getData('TMS_PhuongThucVanChuyen');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body)['datalist'];

        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _phuongthucvanchuyenList = (decodedData as List)
            .map((item) => PhuongThucVanChuyenModel.fromJson(item))
            .toList();
        // Gọi setState để cập nhật giao diện
        setState(() {
          _loading = true;
        });
      }
    } catch (e) {
      // Xử lý lỗi khi gọi API
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> postData(GiaoXeModel scanData) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/GiaoXe', newScanData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");
        // _isLoading = false;
        // _success = decodedData["success"];

        notifyListeners();

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'SUCCESS',
          text: "Giao xe thành công",
        );
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ERROR',
          text: errorMessage,
        );
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
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
                'Số khung\n (VIN)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.08, // Corresponds to line-height of 13px
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              // padding: EdgeInsets.symmetric(horizontal: 10),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(5),
              //   border: Border.all(color: Color(0xFFA71C20), width: 1),
              // ),
              child: Text(
                barcodeScanResult.isNotEmpty ? barcodeScanResult : '',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
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
    _bl.getData(value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.giaoxe == null) {
          _qrData = '';
          _qrDataController.text = '';
          if (_bl.success == false && _bl.message!.isNotEmpty) {
            openSnackBar(context, _bl.message!);
          } else {
            openSnackBar(context, "Không có dữ liệu");
          }
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
    _data?.Diadiem_Id = DiaDiemId;
    _data?.phuongThucVanChuyen_Id = PhuongThucVanChuyenId;

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
      _data?.lat = lat;
      _data?.long = long;
      print("Kho_ID:${_data?.kho_Id}");
      print("phuongThucVanChuyen_Id:${_data?.phuongThucVanChuyen_Id}");
      print("lat: ${_data?.lat}");
      print("long: ${_data?.long}");

      // call api

      AppService().checkInternet().then((hasInternet) {
        if (!hasInternet!) {
          openSnackBar(context, 'no internet'.tr());
        } else {
          postData(_data!).then((_) {
            // if (_bl.success) {
            //   openSnackBar(context, "Lưu thành công");
            // } else {
            //   openSnackBar(context, "Lưu thất bại");
            // }
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

  @override
  Widget build(BuildContext context) {
    getData();
    getPhuongThucVanChuyenList();
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
                                      "Địa điểm",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: DropdownButtonFormField<String>(
                                      items: _diadiemList?.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item.id,
                                          child: Container(
                                            padding:
                                                EdgeInsets.only(left: 15.sp),
                                            child: Text(
                                              item.tenDiaDiem ?? "",
                                              style: const TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF000000),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: DiaDiemId,
                                      onChanged: (newValue) {
                                        setState(() {
                                          DiaDiemId = newValue;
                                        });
                                        // if (newValue != null) {
                                        //   getBaiXeList(newValue);

                                        // }
                                        ;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
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
                                      "Phương thức\nvận chuyển",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: DropdownButtonFormField<String>(
                                      items:
                                          _phuongthucvanchuyenList?.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item.id,
                                          child: Container(
                                            padding:
                                                EdgeInsets.only(left: 15.sp),
                                            child: Text(
                                              item.tenPhuongThucVanChuyen ?? "",
                                              style: const TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF000000),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: PhuongThucVanChuyenId,
                                      onChanged: (newValue) {
                                        setState(() {
                                          PhuongThucVanChuyenId = newValue;
                                        });
                                        // if (newValue != null) {
                                        //   getDanhSachPhuongTienList(newValue);
                                        //   print(
                                        //       "object : ${PhuongThucVanChuyenId}");
                                        // }
                                        // ;
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
                                // Text 1
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text 1
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
                                    // Text 2
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
                                    // Text 1
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
                                    // Text 2
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
                                SizedBox(height: 10),
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
                          Container(
                            width: 90.w,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(90.w, 50),
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: PhuongThucVanChuyenId != null
                                        ? _onSave
                                        : null,
                                    child: Text("Giao Xe",
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ))),
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
