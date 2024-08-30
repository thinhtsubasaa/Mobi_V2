import 'dart:async';
import 'dart:convert';
import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/pages/baixe/custom_body_baixe.dart';
import 'package:Thilogi/pages/lsuxeracong/ls_racong.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import '../../blocs/scan_nhanvien_bloc.dart';
import '../../config/config.dart';
import '../../services/app_service.dart';
import '../../utils/next_screen.dart';
import '../../widgets/checksheet_upload_anh.dart';
import '../../widgets/loading.dart';

class CustomBodyXeRaCong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyXeRaCongScreen());
  }
}

class BodyXeRaCongScreen extends StatefulWidget {
  const BodyXeRaCongScreen({Key? key}) : super(key: key);

  @override
  _BodyXeRaCongScreenState createState() => _BodyXeRaCongScreenState();
}

class _BodyXeRaCongScreenState extends State<BodyXeRaCongScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  XeRaCongModel? _data;

  bool _loading = false;
  String? barcodeScanResult;
  String? viTri;

  late XeRaCongBloc _bl;
  late Scan_NhanVienBloc ub;

  String? _errorCode;
  String? get errorCode => _errorCode;

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _ghiChu = TextEditingController();
  final TextEditingController _noiden = TextEditingController();
  final TextEditingController _lido = TextEditingController();
  TextEditingController _textController = TextEditingController();
  bool _Isred = false;
  bool _Iskehoach = false;

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
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
    super.dispose();
  }

  Future<void> postData(XeRaCongModel scanData, String? nhanvien, String? noiDi,
      String? noiDen, String? ghiChu, String? maPin) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/XeRaCong?MaNhanVien=$nhanvien&NoiDi=$noiDi&NoiDen=$noiDen&GhiChu=$ghiChu&MaPin=$maPin',
          newScanData.toJson());
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
          text: "Thành công",
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
      // height: 11.h,
      height: MediaQuery.of(context).size.height < 880 ? 11.h : 8.h,
      margin: const EdgeInsets.only(top: 10),
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
          Container(
            width: 20.w,
            height: 11.h,
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
              child: TextField(
                controller: _qrDataController,
                decoration: InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
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
        if (_bl.xeracong == null) {
          barcodeScanResult = null;
          _qrData = '';
          _qrDataController.text = '';
          _Iskehoach = false;
          _Isred = false;
        }
        _loading = false;
        _data = _bl.xeracong;
        print("MaNhanVien: ${_bl.xeracong?.maNhanVien}");
        print("NoiDen: ${_bl.xeracong?.noiden}");
        if (_bl.xeracong?.maNhanVien == null) {
          // QuickAlert.show(
          //   // ignore: use_build_context_synchronously
          //   context: context,
          //   type: QuickAlertType.info,
          //   title: '',
          //   text: 'Không có thông tin tài xế',
          //   confirmBtnText: 'Đồng ý',
          // );
          _Isred = true;
        }
        if (_bl.xeracong?.noiden == null) {
          _Iskehoach = true;
        }
        print("isred: ${_Isred}");
        print("iskehoach: ${_Iskehoach}");
      });
    });
  }

  _onSave() {
    setState(() {
      _loading = true;
    });

    _data?.key = _bl.xeracong?.key;
    _data?.id = _bl.xeracong?.id;
    _data?.soKhung = _bl.xeracong?.soKhung;
    _data?.tenSanPham = _bl.xeracong?.tenSanPham;
    _data?.maSanPham = _bl.xeracong?.maSanPham;
    _data?.soMay = _bl.xeracong?.soMay;
    _data?.maMau = _bl.xeracong?.maMau;
    _data?.tenMau = _bl.xeracong?.tenMau;
    _data?.tenKho = _bl.xeracong?.tenKho;
    _data?.maViTri = _bl.xeracong?.maViTri;
    _data?.tenViTri = _bl.xeracong?.tenViTri;
    _data?.mauSon = _bl.xeracong?.mauSon;
    _data?.noidi = _bl.xeracong?.noidi;
    _data?.noiden = _bl.xeracong?.noiden;
    _data?.bienSo_Id = _bl.xeracong?.bienSo_Id;
    _data?.taiXe_Id = _bl.xeracong?.taiXe_Id;
    _data?.tenDiaDiem = _bl.xeracong?.tenDiaDiem;
    _data?.tenPhuongThucVanChuyen = _bl.xeracong?.tenPhuongThucVanChuyen;
    _data?.maNhanVien = _bl.xeracong?.maNhanVien;
    _data?.hinhAnhUrl = _bl.xeracong?.hinhAnhUrl;
    _data?.tenNhanVien = _bl.xeracong?.tenNhanVien;
    _data?.sdt = _bl.xeracong?.sdt;
    _data?.noidi = _bl.xeracong?.noidi;
    _data?.noiden = _bl.xeracong?.noiden;
    _data?.ghiChu = _ghiChu.text;
    _data?.maPin = _textController.text;
    _data?.tencong = _bl.xeracong?.tencong;
    _data?.noiditaixe = _bl.xeracong?.noiditaixe;

    print("MaNhanVien: ${_data?.maNhanVien}");

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
        postData(_data!, _data?.maNhanVien ?? "", _data?.tencong ?? "",
                _data?.noiden ?? "", _ghiChu.text, _textController.text)
            .then((_) {
          setState(() {
            _data = null;
            barcodeScanResult = null;
            _ghiChu.text = "";
            _textController.text = "";
            _qrData = '';
            _qrDataController.text = '';
            _loading = false;
            _Isred = false;
            _Iskehoach = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _lido,
                    decoration: InputDecoration(
                      labelText: 'Nhập lí do từ chối',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Thay đổi giá trị 10 tùy ý để điều chỉnh độ bo tròn
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Vui lòng nhập mã pin của bạn?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Nhập mã pin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10), // Thay đổi giá trị 10 tùy ý để điều chỉnh độ bo tròn
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
                          Navigator.of(context).pop();
                          _btnController.reset();
                        },
                        child: Text(
                          'Không',
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
                        onPressed: _textController.text != ""
                            ? () {
                                Navigator.of(context).pop();
                                _onSave();
                              }
                            : null,
                        child: Text(
                          'Đồng ý',
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
          ),
        );
      },
    );
  }

  void _showConfirmationDialogMaPin(BuildContext context) {
    Navigator.of(context).pop();
    _onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        CardVin(),
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
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Thông tin xe ra cổng',
                                          style: TextStyle(
                                            fontFamily: 'Comfortaa',
                                            color: Colors.red,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          onPressed: () {
                                            nextScreen(context, LSRaCongPage());
                                          },
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: AppConfig.primaryColor,
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Item(
                                            title: 'Loại xe: ',
                                            value: _data?.tenSanPham,
                                          ),
                                          const Divider(
                                              height: 1,
                                              color: Color(0xFFCCCCCC)),
                                          Item(
                                            title: 'Số khung: ',
                                            value: _data?.soKhung,
                                          ),
                                          const Divider(
                                              height: 1,
                                              color: Color(0xFFCCCCCC)),
                                          Item(
                                              title: 'Màu: ',
                                              value: _data != null
                                                  ? (_data?.tenMau != null &&
                                                          _data?.maMau != null
                                                      ? "${_data?.tenMau} (${_data?.maMau})"
                                                      : "")
                                                  : ""),
                                          const Divider(
                                              height: 1,
                                              color: Color(0xFFCCCCCC)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _Iskehoach == true
                                        ? Colors.red
                                        : Colors.grey,
                                    width: _Iskehoach == true ? 5 : 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Kế hoạch xuất xe',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        color: Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: AppConfig.primaryColor,
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Item(
                                            title: 'Phương thức vận chuyển: ',
                                            value:
                                                _data?.tenPhuongThucVanChuyen,
                                          ),
                                          const Divider(
                                              height: 1,
                                              color: Color(0xFFCCCCCC)),
                                          Item(
                                            title: 'Nơi đi: ',
                                            value: _data?.noidi,
                                          ),
                                          const Divider(
                                              height: 1,
                                              color: Color(0xFFCCCCCC)),
                                          ItemNoiden(
                                            title: 'Nơi đến: ',
                                            value: _noiden.text,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _Isred == true
                                        ? Colors.red
                                        : Colors.grey,
                                    width: _Isred == true ? 5 : 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Thông tin lái xe ra cổng',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        color: Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: AppConfig.primaryColor,
                                    ),
                                    Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              child: _data?.hinhAnhUrl != null
                                                  ? Image.network(
                                                      _data?.hinhAnhUrl ?? "",
                                                      fit: BoxFit.contain,
                                                    )
                                                  : Image.network(
                                                      AppConfig.defaultImage,
                                                      fit: BoxFit.contain,
                                                    ),
                                            ),
                                            ItemTaiXe(
                                              title: 'Mã tài xế: ',
                                              value: _data?.maNhanVien,
                                            ),
                                          ],
                                        ),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ItemTaiXe(
                                                title: 'Tên tài xế: ',
                                                value: _data?.tenNhanVien,
                                              ),
                                              const Divider(
                                                  height: 1,
                                                  color: Color(0xFFCCCCCC)),
                                              ItemTaiXe(
                                                title: 'SDT: ',
                                                value: _data?.sdt,
                                              ),
                                              ItemTaiXe(
                                                title: 'Nơi đi: ',
                                                value: _data?.noiditaixe,
                                              ),
                                              ItemTaiXeNoiDen(
                                                title: 'Nơi đến: ',
                                                value: _data?.noiden,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ItemGhiChu(
                                title: 'Ghi chú của bảo vệ: ',
                                controller: _ghiChu,
                              ),
                              const Divider(
                                  height: 1, color: Color(0xFFCCCCCC)),
                              CheckSheetUploadAnh(
                                lstFiles: [],
                              )
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 100.w,
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      minimumSize:
                          Size(200, 50), // Kích thước tối thiểu của button
                    ),
                    onPressed: _data?.maNhanVien != null
                        ? () => _showConfirmationDialog(context)
                        : null,
                    child: Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    )),
              ),
              Expanded(
                child: RoundedLoadingButton(
                  child: Text(
                    'Từ chối',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  color: Colors.red,
                  controller: _btnController,
                  onPressed: _data?.soKhung != null
                      ? () => _showConfirmationDialog(context)
                      : null,
                ),
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 11,
          padding: EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppConfig.bottom,
          ),
          child: customTitle(
            _data?.tencong?.toUpperCase() ?? "",
          ),
        ),

        // Container(
        //   padding: const EdgeInsets.all(5),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       RoundedLoadingButton(
        //         child: Text('Xác nhận',
        //             style: TextStyle(
        //               fontFamily: 'Comfortaa',
        //               color: AppConfig.textButton,
        //               fontWeight: FontWeight.w700,
        //               fontSize: 16,
        //             )),
        //         controller: _btnController,
        //         onPressed: _data?.soKhung != null
        //             ? () => _showConfirmationDialog(context)
        //             : null,
        //       ),
        //     ],
        //   ),
        // ),
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
      height: 7.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            Text(
              value ?? "",
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemTaiXe extends StatelessWidget {
  final String title;
  final String? value;

  const ItemTaiXe({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF818180),
            ),
          ),
          Text(
            value ?? "",
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemTaiXeNoiDen extends StatelessWidget {
  final String title;
  final String? value;
  final ValueChanged<String>? onChanged;

  const ItemTaiXeNoiDen({
    Key? key,
    required this.title,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF818180),
            ),
          ),
          Container(
            width: 37.w,
            // Hoặc dùng Flexible

            child: TextFormField(
              initialValue: value,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 13.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemNoiden extends StatelessWidget {
  final String title;
  final String? value;
  final ValueChanged<String>? onChanged;

  const ItemNoiden({
    Key? key,
    required this.title,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: value,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                onChanged: onChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13.2),
                ),
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
      height: 7.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            SizedBox(width: 10), // Khoảng cách giữa title và text field
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none, // Loại bỏ đường viền mặc định
                  hintText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
