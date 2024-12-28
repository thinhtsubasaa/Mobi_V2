import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/thaydoikehoach_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/models/giaoxe.dart';
import 'package:Thilogi/models/kehoachgiaoxe.dart';
import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/taixe.dart';
import 'package:Thilogi/pages/dsgiaoxe/ds_giaoxe.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/giaoxe_bloc.dart';
import '../../config/config.dart';
import '../../models/diadiem.dart';
import '../../models/doitac.dart';
import '../../models/kehoach.dart';
import '../../models/phuongthucvanchuyen.dart';
import '../../services/app_service.dart';
import '../../utils/next_screen.dart';
import '../../widgets/checksheet_upload_anh.dart';
import '../../widgets/loading.dart';
import '../lichsuyeucaucanhan/dsx_yeucaucanhan.dart';

class CustomBodyThayDoiKH extends StatelessWidget {
  final String? soKhung;
  CustomBodyThayDoiKH({this.soKhung});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyThayDoiKHScreen(
      soKhung: soKhung,
      lstFiles: [],
    ));
  }
}

class BodyThayDoiKHScreen extends StatefulWidget {
  final String? soKhung;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyThayDoiKHScreen({super.key, required this.lstFiles, this.soKhung});

  @override
  _BodyThayDoiKHScreenState createState() => _BodyThayDoiKHScreenState();
}

class _BodyThayDoiKHScreenState extends State<BodyThayDoiKHScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String _qrData = '';
  final _qrDataController = TextEditingController();

  KeHoachGiaoXeModel? _data;

  KeHoachModel? _thongbao;
  bool _loading = false;
  String? barcodeScanResult;
  String? viTri;

  late ThayDoiKeHoachBloc _bl;

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  List<DiaDiemModel>? _diadiemList;
  List<DiaDiemModel>? get diadiemList => _diadiemList;
  List<PhuongThucVanChuyenModel>? _phuongthucvanchuyenList;
  List<PhuongThucVanChuyenModel>? get phuongthucvanchuyenList => _phuongthucvanchuyenList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? _errorCode;
  String? get errorCode => _errorCode;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _ghiChu = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController _lido = TextEditingController();
  String? doiTac_Id;
  List<DoiTacModel>? _doitacList;
  List<DoiTacModel>? get doitacList => _doitacList;
  List<NoiDenModel>? _biensoList;
  List<NoiDenModel>? get biensoList => _biensoList;
  List<TaiXeModel>? _taixeList;
  List<TaiXeModel>? get taixeList => _taixeList;
  String? BienSo;
  String? DoiTacId;
  String? BienSoId;
  String? TaiXeId;
  String? body;
  List<LyDoModel>? _lydoList;
  List<LyDoModel>? get lydoList => _lydoList;
  List<KeHoachGiaoXeModel>? _kehoachList;
  List<KeHoachGiaoXeModel>? get kehoachList => _kehoachList;
  bool ispush = false;

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<ThayDoiKeHoachBloc>(context, listen: false);
    getDoiTac();
    getTaiXe(DoiTacId ?? "");
    getBienSo(DoiTacId ?? "");
    getDataLyDo();
    getListThayDoiKH();
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult ?? "");
    });
  }

  @override
  void dispose() {
    _qrDataController.dispose();
    super.dispose();
  }

  Future<void> getListThayDoiKH() async {
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('Kho/GetThongTinYeuCauThayDoiKH');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachList = (decodedData as List).map((item) => KeHoachGiaoXeModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
          });
        }
      } else {
        _kehoachList = [];
        // Làm sạch danh sách cũ trước khi tải mới
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> getDataLyDo() async {
    try {
      final http.Response response = await requestHelper.getData('Kho/GetListLyDo_KH');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _lydoList = (decodedData as List).map((item) => LyDoModel.fromJson(item)).toList();
        _lydoList?.insert(0, LyDoModel(id: '', lyDo: 'Nhập lý do'));
        _lydoList?.insert(1, LyDoModel(id: '1', lyDo: ''));

        // Gọi setState để cập nhật giao diện
        setState(() {
          _lido.text = 'Nhập lý do';
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDoiTac() async {
    try {
      final http.Response response = await requestHelper.getData('DM_DoiTac/GetDoiTacLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _doitacList = (decodedData as List).map((item) => DoiTacModel.fromJson(item)).toList();

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getBienSo(String? doiTac_Id) async {
    print("DoiTac_Id = $DoiTacId");
    try {
      final http.Response response = await requestHelper.getData('TMS_DanhSachPhuongTien/GetBienSoTheoDoiTac?DoiTac_Id=$doiTac_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _biensoList = (decodedData as List).map((item) => NoiDenModel.fromJson(item)).toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          // _biensoList = (decodedData as List).map((item) => NoiDenModel.fromJson(item)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getTaiXe(String? doiTac_Id) async {
    try {
      final http.Response response = await requestHelper.getData('TaiXe/GetTaiXeTheoDoiTac?DoiTac_Id=$doiTac_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _taixeList = (decodedData as List).map((item) => TaiXeModel.fromJson(item)).toList();
        // _taixeList?.insert(0, TaiXeModel(id: '', tenTaiXe: ''));
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

  Future<void> postData(KeHoachGiaoXeModel scanData) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData('Kho/YeuCauThayDoiKH', newScanData.toJson());
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
          text: "Yêu cầu thành công",
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
        await getListThayDoiKH();
        body = "Bạn đang có ${_kehoachList?.length.toString() ?? ""} yêu cầu kế hoạch cần xác nhận ";
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

  Future<void> postDataFireBase(KeHoachModel? scanData, String? body, String? keHoach_Id, String? taiXeYC_Id, String? taiXeTD_Id) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;

      final http.Response response = await requestHelper.postData('FireBase?body=$body&Kehoach_Id=$keHoach_Id&TaiXeYC_Id=$taiXeYC_Id&TaiXeTD_Id=$taiXeTD_Id', newScanData?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");
        setState(() {
          _loading = false;
        });

        notifyListeners();
      } else {}
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.88,
      height: MediaQuery.of(context).size.height < 880 ? 8.h : 8.h,
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Container(
          //   width: 20.w,
          //   height: 10.h,
          //   decoration: BoxDecoration(
          //     borderRadius: const BorderRadius.only(
          //       topLeft: Radius.circular(5),
          //       bottomLeft: Radius.circular(5),
          //     ),
          //     color: AppConfig.primaryColor,
          //   ),
          //   child: Center(
          //     child: Text(
          //       'Số khung\n(VIN)',
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         fontFamily: 'Comfortaa',
          //         fontSize: 13,
          //         fontWeight: FontWeight.w400,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _qrDataController,
                decoration: InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.textInput,
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
                _qrDataController.text = result;
              });
              print(barcodeScanResult);
              _handleBarcodeScanResult(barcodeScanResult ?? "");
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
        if (_bl.khgx == null) {
          barcodeScanResult = null;
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = _bl.khgx;
        DoiTacId = _data?.doiTac_Id ?? "";
        BienSoId = _data?.bienSo_Id ?? "";
        TaiXeId = _data?.taiXe_Id ?? "";
      });
    });
  }

  _onSave() async {
    setState(() {
      _loading = true;
    });

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy

    _data?.keHoachGiaoXe_Id = _bl.khgx?.id;
    _data?.soKhung = _bl.khgx?.soKhung;
    _data?.nhaXeYC = _bl.khgx?.benVanChuyen;
    _data?.bienSoYC = _bl.khgx?.soXe;
    _data?.taiXeYC = _bl.khgx?.tenTaiXe;
    _data?.nhaXeThayDoi_Id = DoiTacId;
    _data?.phuongTienThayDoi_Id = BienSoId;
    _data?.taiXeThayDoi_Id = TaiXeId;
    _data?.taiXe_Id = _bl.khgx?.taiXe_Id;
    _data?.taiXeYeuCau_Id = _bl.khgx?.taiXe_Id;
    _data?.nhaXeYeuCau_Id = _bl.khgx?.doiTac_Id;
    _data?.phuongTienYeuCau_Id = _bl.khgx?.bienSo_Id;

    if (_lido.text == 'Nhập lý do') {
      _lido.text = '';
    }
    _data?.lyDo = _lido.text;

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
        postData(_data!).then((_) {
          setState(() {
            _ghiChu.text = '';
            barcodeScanResult = null;
            _qrData = '';
            _qrDataController.text = '';
            _lido.text = '';
            _loading = false;
            DoiTacId = null;
            BienSoId = null;
            TaiXeId = null;
            postDataFireBase(_thongbao, body ?? "", _data?.keHoachGiaoXe_Id ?? "", "", "");
            _data = null;
          });
        });
      }
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn gửi yêu cầu không?',
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

  void _showInputDialogLiDo(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Vui lòng nhập lý do của bạn?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _lido,
                        decoration: InputDecoration(
                          labelText: 'Nhập lý do',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _lido.text = (_lydoList!.isNotEmpty ? _lydoList!.first.lyDo : '')!; // Đảm bảo giá trị hợp lệ
                              });
                              Navigator.of(context).pop();
                              _btnController.reset();
                            },
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                String newValue = _lido.text;
                                if (_lydoList != null && newValue.isNotEmpty) {
                                  _lydoList!.add(LyDoModel(lyDo: newValue));
                                  _lido.text = newValue;
                                }
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Lưu',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).then((_) {
      // Kiểm tra xem _selectedValue có còn hợp lệ không
      if (_lido.text != '' && !_lydoList!.any((item) => item.lyDo == _lido.text)) {
        setState(() {
          _lido.text = (_lydoList!.isNotEmpty ? _lydoList!.first.lyDo : '')!; // Hoặc đặt về giá trị mặc định
        });
      }
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [
            CardVin(),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  nextScreen(context, DSYCCaNhanPage());
                },
              ),
            ),
          ],
        ),
        // CardVin(),
        const SizedBox(height: 5),
        Expanded(
          child: SingleChildScrollView(
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
                          padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_data?.soKhung != null)
                                Container(
                                  child: Column(
                                    children: [
                                      Item(
                                        value: _data?.soKhung ?? "",
                                      ),
                                      Item(value: _data?.benVanChuyen ?? ""),
                                      Item(
                                        value: _data?.soXe ?? "",
                                      ),
                                      Item(
                                        value: _data?.tenTaiXe ?? "",
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft, // Căn sát lề trái
                                        padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
                                        child: const Text(
                                          "Nhà xe mới:",
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppConfig.textInput,
                                          ),
                                        ),
                                      ),
                                      Container(
                                          width: 100.w,
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: Colors.green,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              items: _doitacList?.where((item) => (item.tenDoiTac?.isNotEmpty == true))?.map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item.id,
                                                  child: Container(
                                                    child: Text(
                                                      item.tenDoiTac ?? "",
                                                      style: const TextStyle(
                                                        fontFamily: 'Comfortaa',
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppConfig.textInput,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              // value: DoiTacId,
                                              value: _doitacList!.where((item) => (item.tenDoiTac?.isNotEmpty == true)).any((item) => item.id == DoiTacId) ? DoiTacId : null,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  DoiTacId = newValue ?? "";
                                                });
                                                if (newValue != null) {
                                                  getBienSo(newValue);
                                                  getTaiXe(newValue);
                                                }
                                                print("objectcong : ${newValue}");
                                              },
                                              buttonStyleData: const ButtonStyleData(
                                                padding: EdgeInsets.symmetric(horizontal: 16),
                                                height: 40,
                                                width: 200,
                                              ),
                                              dropdownStyleData: const DropdownStyleData(
                                                maxHeight: 200,
                                              ),
                                              menuItemStyleData: const MenuItemStyleData(
                                                height: 40,
                                              ),
                                              dropdownSearchData: DropdownSearchData(
                                                searchController: textEditingController,
                                                searchInnerWidgetHeight: 50,
                                                searchInnerWidget: Container(
                                                  height: 50,
                                                  padding: const EdgeInsets.only(
                                                    top: 8,
                                                    bottom: 4,
                                                    right: 8,
                                                    left: 8,
                                                  ),
                                                  child: TextFormField(
                                                    expands: true,
                                                    maxLines: null,
                                                    controller: textEditingController,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8,
                                                      ),
                                                      hintText: 'Tìm nhà xe',
                                                      hintStyle: const TextStyle(fontSize: 12),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                searchMatchFn: (item, searchValue) {
                                                  if (item is DropdownMenuItem<String>) {
                                                    // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                    String itemId = item.value ?? "";
                                                    // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                    return _doitacList?.any((viTri) => viTri.id == itemId && viTri.tenDoiTac?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                  } else {
                                                    return false;
                                                  }
                                                },
                                              ),
                                              onMenuStateChange: (isOpen) {
                                                if (!isOpen) {
                                                  textEditingController.clear();
                                                }
                                              },
                                            ),
                                          )),
                                      SizedBox(height: 5),
                                      Container(
                                        alignment: Alignment.centerLeft, // Căn sát lề trái
                                        padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
                                        child: const Text(
                                          "Biển số mới:",
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppConfig.textInput,
                                          ),
                                        ),
                                      ),
                                      Container(
                                          width: 100.w,
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: Colors.green,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              items: _biensoList?.where((item) => (item.bienSo?.isNotEmpty == true) && (item.id == BienSoId || item.doiTac_Id == DoiTacId))?.map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item.id,
                                                  child: Container(
                                                    child: Text(
                                                      item.bienSo ?? "",
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontFamily: 'Comfortaa',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppConfig.textInput,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              // value: BienSoId,
                                              value: _biensoList!.where((item) => (item.bienSo?.isNotEmpty == true)).any((item) => item.id == BienSoId) ? BienSoId : null,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  BienSoId = newValue ?? "";
                                                });
                                                print("objectcong : ${newValue}");
                                              },
                                              buttonStyleData: const ButtonStyleData(
                                                padding: EdgeInsets.symmetric(horizontal: 16),
                                                height: 40,
                                                width: 200,
                                              ),
                                              dropdownStyleData: const DropdownStyleData(
                                                maxHeight: 200,
                                              ),
                                              menuItemStyleData: const MenuItemStyleData(
                                                height: 40,
                                              ),
                                              dropdownSearchData: DropdownSearchData(
                                                searchController: textEditingController,
                                                searchInnerWidgetHeight: 50,
                                                searchInnerWidget: Container(
                                                  height: 50,
                                                  padding: const EdgeInsets.only(
                                                    top: 8,
                                                    bottom: 4,
                                                    right: 8,
                                                    left: 8,
                                                  ),
                                                  child: TextFormField(
                                                    expands: true,
                                                    maxLines: null,
                                                    controller: textEditingController,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8,
                                                      ),
                                                      hintText: 'Tìm biển số',
                                                      hintStyle: const TextStyle(fontSize: 12),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                searchMatchFn: (item, searchValue) {
                                                  if (item is DropdownMenuItem<String>) {
                                                    // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                    String itemId = item.value ?? "";
                                                    // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                    return _biensoList?.any((viTri) => viTri.id == itemId && viTri.bienSo?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                  } else {
                                                    return false;
                                                  }
                                                },
                                              ),
                                              onMenuStateChange: (isOpen) {
                                                if (!isOpen) {
                                                  textEditingController.clear();
                                                }
                                              },
                                            ),
                                          )),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft, // Căn sát lề trái
                                        padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
                                        child: const Text(
                                          "Tài xế mới:",
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppConfig.textInput,
                                          ),
                                        ),
                                      ),
                                      Container(
                                          width: 100.w,
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: Colors.green,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              items: _taixeList
                                                  ?.where((item) =>
                                                      (item.tenTaiXe?.isNotEmpty == true && item.maTaiXe?.isNotEmpty == true) &&
                                                      (item.id == TaiXeId || item.doiTac_Id == DoiTacId || item.doiTac_Id == "bc919654-7d86-4285-9e9a-6c0d37ddaaab"))
                                                  ?.map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item.id,
                                                  child: Container(
                                                    child: Text(
                                                      (item.tenTaiXe != null && item.maTaiXe != null) ? "${item.tenTaiXe} - ${item.maTaiXe}" : "",
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontFamily: 'Comfortaa',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppConfig.textInput,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              // value: TaiXeId,
                                              value: _taixeList!.where((item) => (item.tenTaiXe?.isNotEmpty == true && item.maTaiXe?.isNotEmpty == true)).any((item) => item.id == TaiXeId) ? TaiXeId : null,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  TaiXeId = newValue ?? '';
                                                });
                                                print("objectcong : ${newValue}");
                                              },
                                              buttonStyleData: const ButtonStyleData(
                                                padding: EdgeInsets.symmetric(horizontal: 16),
                                                height: 40,
                                                width: 200,
                                              ),
                                              dropdownStyleData: const DropdownStyleData(
                                                maxHeight: 200,
                                              ),
                                              menuItemStyleData: const MenuItemStyleData(
                                                height: 40,
                                              ),
                                              dropdownSearchData: DropdownSearchData(
                                                searchController: textEditingController,
                                                searchInnerWidgetHeight: 50,
                                                searchInnerWidget: Container(
                                                  height: 50,
                                                  padding: const EdgeInsets.only(
                                                    top: 8,
                                                    bottom: 4,
                                                    right: 8,
                                                    left: 8,
                                                  ),
                                                  child: TextFormField(
                                                    expands: true,
                                                    maxLines: null,
                                                    controller: textEditingController,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 8,
                                                      ),
                                                      hintText: 'Tìm tài xế',
                                                      hintStyle: const TextStyle(fontSize: 12),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                searchMatchFn: (item, searchValue) {
                                                  if (item is DropdownMenuItem<String>) {
                                                    // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                    String itemId = item.value ?? "";
                                                    // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                    return _taixeList?.any((viTri) => viTri.id == itemId && viTri.tenTaiXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                  } else {
                                                    return false;
                                                  }
                                                },
                                              ),
                                              onMenuStateChange: (isOpen) {
                                                if (!isOpen) {
                                                  textEditingController.clear();
                                                }
                                              },
                                            ),
                                          )),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft, // Căn sát lề trái
                                        padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
                                        child: const Text(
                                          "Lý do đổi:",
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppConfig.textInput,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100.w,
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Container(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                items: _lydoList
                                                    ?.map((item) {
                                                      if (item.lyDo != null && item.lyDo!.isNotEmpty) {
                                                        return DropdownMenuItem<String>(
                                                          value: item.lyDo ?? "",
                                                          child: Container(
                                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                            child: SingleChildScrollView(
                                                              scrollDirection: Axis.horizontal,
                                                              child: Text(
                                                                item.lyDo ?? "",
                                                                textAlign: TextAlign.center,
                                                                style: const TextStyle(
                                                                  fontFamily: 'Comfortaa',
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: AppConfig.textInput,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      return null; // Ẩn giá trị rỗng khỏi danh sách hiển thị
                                                    })
                                                    .whereType<DropdownMenuItem<String>>()
                                                    .toList(),
                                                value: _lido.text.isNotEmpty ? _lido.text : null,
                                                onChanged: (String? newValue) {
                                                  if (newValue == 'Nhập lý do') {
                                                    _lido.text = "";
                                                    _showInputDialogLiDo(context);
                                                  } else {
                                                    setState(() {
                                                      _lido.text = newValue!;
                                                    });
                                                  }
                                                },
                                                buttonStyleData: const ButtonStyleData(
                                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                                  height: 40,
                                                  width: 200,
                                                ),
                                                dropdownStyleData: const DropdownStyleData(
                                                  maxHeight: 200,
                                                ),
                                                menuItemStyleData: const MenuItemStyleData(
                                                  height: 40,
                                                ),
                                                dropdownSearchData: DropdownSearchData(
                                                  searchController: textEditingController,
                                                  searchInnerWidgetHeight: 50,
                                                  searchInnerWidget: Container(
                                                    height: 50,
                                                    padding: const EdgeInsets.only(
                                                      top: 8,
                                                      bottom: 4,
                                                      right: 8,
                                                      left: 8,
                                                    ),
                                                    child: TextFormField(
                                                      expands: true,
                                                      maxLines: null,
                                                      controller: textEditingController,
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding: const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                        hintText: 'Tìm lý do',
                                                        hintStyle: const TextStyle(fontSize: 10),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  searchMatchFn: (item, searchValue) {
                                                    return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                                                  },
                                                ),
                                                onMenuStateChange: (isOpen) {
                                                  if (!isOpen) {
                                                    textEditingController.clear();
                                                  }
                                                },
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RoundedLoadingButton(
              //     child: Text('Xác nhận',
              //         style: TextStyle(
              //           fontFamily: 'Comfortaa',
              //           color: AppConfig.textButton,
              //           fontWeight: FontWeight.w700,
              //           fontSize: 16,
              //         )),
              //     controller: _btnController,
              //     color: Colors.green,
              //     onPressed: _data?.soKhung != null ? () => _showConfirmationDialog(context) : null,
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // Chiều rộng 70% màn hình
                child: ElevatedButton(
                    onPressed: (_data?.soKhung != null && _lido.text.isNotEmpty && _lido.text != "Nhập lý do") ? () => _showConfirmationDialog(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Màu nền xanh lá cây
                      foregroundColor: AppConfig.textButton, // Màu chữ
                      textStyle: const TextStyle(
                        fontFamily: 'Comfortaa',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13), // Bo góc
                      ),
                    ),
                    child: const Text(
                      'XÁC NHẬN',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        color: AppConfig.textButton,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class Item extends StatelessWidget {
  final String? value;

  const Item({
    Key? key,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            SelectableText(
              value ?? "",
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppConfig.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemGhiChu extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const ItemGhiChu({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            SizedBox(width: 10), // Khoảng cách giữa title và text field
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none, // Loại bỏ đường viền mặc định
                  hintText: '',
                  // contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
