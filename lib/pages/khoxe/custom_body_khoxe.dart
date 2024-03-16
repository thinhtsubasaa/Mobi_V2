import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/xuatkho_bloc.dart';
import 'package:Thilogi/models/danhsachphuongtien.dart';
import 'package:Thilogi/models/diadiem.dart';
import 'package:Thilogi/models/loaiphuongtien.dart';
import 'package:Thilogi/models/phuongthucvanchuyen.dart';
import 'package:Thilogi/models/xuatkho.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/blocs/khothanhpham_bloc.dart';
import 'package:Thilogi/blocs/khoxe_bloc.dart';
import 'package:Thilogi/models/khothanhpham.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../services/app_service.dart';
import '../../utils/snackbar.dart';

class CustomBodyKhoXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyKhoXeScreen());
  }
}

class BodyKhoXeScreen extends StatefulWidget {
  const BodyKhoXeScreen({Key? key}) : super(key: key);

  @override
  _BodyKhoXeScreenState createState() => _BodyKhoXeScreenState();
}

class _BodyKhoXeScreenState extends State<BodyKhoXeScreen>
    with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String? DiaDiemId;
  String? PhuongThucVanChuyenId;
  String? DanhSachPhuongTienId;
  String? LoaiPhuongTienId;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  Timer? _debounce;
  List<String>? _results = [];
  XuatKhoModel? _data;
  bool _loading = false;
  String barcodeScanResult = '';
  TabController? _tabController;
  late XuatKhoBloc _bl;

  List<DiaDiemModel>? _diadiemList; // Định nghĩa danh sách khoxeList ở đây
  List<DiaDiemModel>? get diadiemList => _diadiemList;
  List<PhuongThucVanChuyenModel>?
      _phuongthucvanchuyenList; // Định nghĩa danh sách khoxeList ở đây
  List<PhuongThucVanChuyenModel>? get phuongthucvanchuyenList =>
      _phuongthucvanchuyenList;
  List<DanhSachPhuongTienModel>?
      _danhsachphuongtienList; // Định nghĩa danh sách khoxeList ở đây
  List<DanhSachPhuongTienModel>? get danhsachphuongtienList =>
      _danhsachphuongtienList;
  List<LoaiPhuongTienModel>?
      _loaiphuongtienList; // Định nghĩa danh sách khoxeList ở đây
  List<LoaiPhuongTienModel>? get loaiphuongtienList => _loaiphuongtienList;

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
    // _tabController = TabController(vsync: this, length: 3);
    // _tabController!.addListener(_handleTabChange);
    _bl = Provider.of<XuatKhoBloc>(context, listen: false);

    // setState(() {
    //   _tenKhoXe = _kl.tenKhoXe!;
    // });
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
        // _khoxeList = [
        //   KhoXeModel(
        //     id: decodedData['id'],
        //     maKhoXe: decodedData['maKhoXe'],
        //     tenKhoXe: decodedData['tenKhoXe'],
        //     isLogistic: decodedData['isLogistic'],
        //   )
        // ];
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

  void getDanhSachPhuongTienList() async {
    try {
      final http.Response response =
          await requestHelper.getData('TMS_DanhSachPhuongTien');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body)['datalist'];

        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _danhsachphuongtienList = (decodedData as List)
            .map((item) => DanhSachPhuongTienModel.fromJson(item))
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

  void getLoaiPhuongTienList() async {
    try {
      final http.Response response =
          await requestHelper.getData('LoaiPhuongTien');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        // Xử lý dữ liệu và cập nhật UI tương ứng với danh sách bãi xe đã lấy được
        _loaiphuongtienList = (decodedData as List)
            .map((item) => LoaiPhuongTienModel.fromJson(item))
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

  Future<void> postData(XuatKhoModel scanData) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/XuatKho', newScanData.toJson());
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
          text: "Xuất kho thành công",
        );
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: '',
          text: errorMessage,
        );
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // @override
  // void dispose() {
  //   _tabController?.dispose();
  //   super.dispose();
  // }

  // void _handleTabChange() {
  //   if (_tabController!.indexIsChanging) {
  //     // Call the action when the tab changes
  //     // print('Tab changed to: ${_tabController!.index}');
  //   }
  // }

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
                : '       Scan a barcode       ',
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
        if (_bl.xuatkho == null) {
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.xuatkho;
      });
    });
  }

  _onSave() {
    setState(() {
      _loading = true;
    });

    _data?.key = _bl.xuatkho?.key;
    _data?.id = _bl.xuatkho?.id;
    _data?.soKhung = _bl.xuatkho?.soKhung;
    _data?.tenSanPham = _bl.xuatkho?.tenSanPham;
    _data?.maSanPham = _bl.xuatkho?.maSanPham;
    _data?.soMay = _bl.xuatkho?.soMay;
    _data?.maMau = _bl.xuatkho?.maMau;
    _data?.tenMau = _bl.xuatkho?.tenMau;
    _data?.tenKho = _bl.xuatkho?.tenKho;
    _data?.maViTri = _bl.xuatkho?.maViTri;
    _data?.tenViTri = _bl.xuatkho?.tenViTri;
    _data?.mauSon = _bl.xuatkho?.mauSon;
    _data?.ngayNhapKhoView = _bl.xuatkho?.ngayNhapKhoView;
    _data?.maKho = _bl.xuatkho?.maKho;
    _data?.kho_Id = _bl.xuatkho?.kho_Id;
    _data?.Diadiem_Id = DiaDiemId;
    _data?.phuongThucVanChuyen_Id = PhuongThucVanChuyenId;
    _data?.loaiPhuongTien_Id = LoaiPhuongTienId;
    _data?.danhSachPhuongTien_Id = DanhSachPhuongTienId;
    _data?.bienSo_Id = _bl.xuatkho?.bienSo_Id;
    _data?.taiXe_Id = _bl.xuatkho?.taiXe_Id;

    print("Kho_ID:${_data?.kho_Id}");
    print("danhSachPhuongTien_Id:${_data?.danhSachPhuongTien_Id}");
    print("phuongThucVanChuyen_Id:${_data?.phuongThucVanChuyen_Id}");

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
  }

  @override
  Widget build(BuildContext context) {
    getData();
    getPhuongThucVanChuyenList();
    getLoaiPhuongTienList();
    getDanhSachPhuongTienList();

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
                          Container(
                            height: 9.h,
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
                                  child: DropdownButtonFormField<String>(
                                    items: _diadiemList?.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.id,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15.sp),
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
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 9.h,
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
                                      "Phương thức vận chuyển",
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
                                  child: DropdownButtonFormField<String>(
                                    items:
                                        _phuongthucvanchuyenList?.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.id,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15.sp),
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
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 9.h,
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
                                      "Loại phương tiện",
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
                                  child: DropdownButtonFormField<String>(
                                    items: _loaiphuongtienList?.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.id,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15.sp),
                                          child: Text(
                                            item.tenLoaiPhuongTien ?? "",
                                            textAlign: TextAlign.center,
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
                                    value: LoaiPhuongTienId,
                                    onChanged: (newValue) {
                                      setState(() {
                                        LoaiPhuongTienId = newValue;
                                      });
                                      // print("object : ${LoaiPhuongTienId}");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 9.h,
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
                                      "Danh sách phương tiện",
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
                                  child: DropdownButtonFormField<String>(
                                    items: _danhsachphuongtienList?.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.id,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15.sp),
                                          child: Text(
                                            item.bienSo ?? "",
                                            textAlign: TextAlign.center,
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
                                    value: DanhSachPhuongTienId,
                                    onChanged: (newValue) {
                                      setState(() {
                                        DanhSachPhuongTienId = newValue;
                                      });
                                      // print("object : ${DanhSachPhuongTienId}");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
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
                                    width: 40), // Khoảng cách giữa hai Text

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
                          onPressed:
                              DanhSachPhuongTienId != null ? _onSave : null,
                          child: Text("Xuất Kho",
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
        ),
      ],
    ));
  }
}
