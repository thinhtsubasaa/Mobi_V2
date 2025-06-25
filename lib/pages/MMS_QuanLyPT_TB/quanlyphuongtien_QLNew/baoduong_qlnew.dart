import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../../blocs/user_bloc.dart';
import '../../../config/config.dart';
import '../../../models/checksheet.dart';
import '../../../models/diadiem.dart';
import '../../../models/kehoach.dart';
import '../../../models/mms/baoduong.dart';
import '../../../models/mms/hangmuc.dart';
import '../../../models/mms/lichsubaoduong.dart';
import '../../../services/request_helper_mms.dart';
import '../../../widgets/custom_title.dart';
import 'quanlyphuongtien_map.dart';

class CustomBodyBaoDuongQLNew extends StatelessWidget {
  final String? id;
  CustomBodyBaoDuongQLNew({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyBaoDuongQLNewScreen(
      id: id,
      lstFiles: [],
    ));
  }
}

class BodyBaoDuongQLNewScreen extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyBaoDuongQLNewScreen({super.key, required this.lstFiles, required this.id});

  @override
  _BodyBaoDuongQLNewScreenState createState() => _BodyBaoDuongQLNewScreenState();
}

class _BodyBaoDuongQLNewScreenState extends State<BodyBaoDuongQLNewScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();

  String _qrData = '';
  final _qrDataController = TextEditingController();
  LichSuBaoDuongModel? _data;
  LichSuBaoDuongNewModel? _data1;

  bool _loading = false;

  late XeRaCongBloc _bl;
  String? _errorCode;
  String? get errorCode => _errorCode;
  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  String? id;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController soKhungController = TextEditingController();
  final TextEditingController _ghiChu = TextEditingController();
  final TextEditingController _chiphi = TextEditingController();
  Map<String, TextEditingController> chiphiControllers = {};
  bool _IsTuChoi = false;
  bool _IsXacNhan = false;
  late UserBloc? _ub;
  String? bienSo;
  KeHoachModel? _thongbao;
  List<LichSuBaoDuongModel>? _kehoachList;
  List<LichSuBaoDuongModel>? get kehoachList => _kehoachList;
  List<LichSuBaoDuongModel>? _kehoachListold;
  List<LichSuBaoDuongModel>? get kehoachListold => _kehoachListold;
  List<DiaDiemModel>? _dn;
  List<DiaDiemModel>? get dn => _dn;
  List<bool> selectedItems = [];
  bool selectAll = false;
  String? body;
  String? selectedDate;
  String? DiaDiem_Id;
  List<HangMucModel>? _hangmucList;
  List<HangMucModel>? get hangmucList => _hangmucList;
  List<HangMucModel>? _kehoachListhm;
  List<HangMucModel>? get kehoachListhm => _kehoachListhm;
  List<HangMucModel>? _hangmucList2;
  List<HangMucModel>? get hangmucList2 => _hangmucList2;
  List<HangMucModel>? _hangmucListnew;
  List<HangMucModel>? get hangmucListnew => _hangmucListnew;
  List<dynamic> _selectedItems = [];
  String? _previousPhuongTienId;
  double _tongChiPhi = 0.0;
  final formatter = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);

    print("Id: ${widget.id} - Type: ${widget.id.runtimeType}");
    if (widget.id?.isNotEmpty ?? false) {
      getListThayDoiKH(widget.id, textEditingController.text);
      getDiaDiem();
    } else {
      print("theo ca nhan");
    }
  }

  @override
  void dispose() {
    // _textController.dispose();
    // textEditingController.dispose();
    // _ghiChu.dispose();
    // _chiphi.dispose();
    super.dispose();
  }

  void _updateTongChiPhi(StateSetter dialogSetState, TextEditingController bdCtrl, TextEditingController scCtrl) {
    double tongBD = double.tryParse(bdCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;
    double tongSC = double.tryParse(scCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;

    dialogSetState(() {
      _tongChiPhi = tongBD + tongSC;
    });
  }

  Future<void> getChiTietHM(String? phuongTien_Id, String? hangMuc_Id, StateSetter dialogSetState) async {
    print("hangmuc2");
    _loading = true;
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuongChiTiet?PhuongTien_Id=$phuongTien_Id&HangMuc_Id=$hangMuc_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _hangmucList2 = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();

        dialogSetState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("databienso2:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> getAllHM(String? phuongTien_Id, StateSetter dialogSetState) async {
    _loading = true;
    try {
      final http.Response response = await requestHelper.getData('MMS_ThongTinTheoHangMuc/DSHangMuc?Id_PhuongTien=$phuongTien_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _kehoachListhm = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();

        dialogSetState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("databienso2:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> getListChiTietHangMuc(String? listIds, StateSetter dialogSetState) async {
    print("data999:${listIds}");
    _isLoading = true;
    _hangmucList = [];
    dialogSetState(() {});
    // Làm sạch danh sách cũ trước khi tải mới
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuongChiTietTheoPT?BaoDuong_Id=$listIds');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("dataPT:${decodedData}");
        if (decodedData != null) {
          _hangmucList = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();

          // _hangmucList2 = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện

          dialogSetState(() {
            // _selectedItems = List.from(_hangmucList ?? []);
            _loading = false;
          });
        }
      } else {
        _hangmucList = [];
        // Làm sạch danh sách cũ trước khi tải mới
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      print("error:${e.toString()}");
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> getListChiTietHangMuc2(String? phuongTien_Id, StateSetter dialogSetState) async {
    print("data999:${phuongTien_Id}");
    _isLoading = true;
    _hangmucList = [];
    dialogSetState(() {});
    // Làm sạch danh sách cũ trước khi tải mới
    try {
      final http.Response response = await requestHelper.getData('MMS_ThongTinTheoHangMuc/DSHangMucYeuCau?Id_PhuongTien=$phuongTien_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("dataPT:${decodedData}");
        if (decodedData != null) {
          _hangmucListnew = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
          // _hangmucList2 = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện

          dialogSetState(() {
            _selectedItems = List.from(_hangmucListnew!.where((item) => item.isDenHan == true));
            _loading = false;
          });
        }
      } else {
        _hangmucListnew = [];
        // Làm sạch danh sách cũ trước khi tải mới
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      print("error:${e.toString()}");
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> getDiaDiem() async {
    _dn = [];

    try {
      final http.Response response = await requestHelper.getData('MMS_DM_SuaChua');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => DiaDiemModel.fromJson(item)).toList();
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getListThayDoiKH(String? listIds, String? keyword) async {
    print("data:${listIds}");
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      _kehoachListold = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuongTheoPT?PhuongTien_Id=$listIds&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          // _kehoachList = (decodedData as List).map((item) => LichSuBaoDuongModel.fromJson(item)).toList();
          List<LichSuBaoDuongModel> allItems = (decodedData as List).map((item) => LichSuBaoDuongModel.fromJson(item)).toList();

          // Chia danh sách thành 2 phần
          _kehoachList = allItems.where((item) => item.isHoanThanh == false).toList();
          _kehoachListold = allItems.where((item) => item.isHoanThanh == true).toList();
          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
            selectedItems = List.filled(_kehoachList?.length ?? 0, false);
          });
        }
      } else {
        _kehoachList = [];
        _kehoachListold = [];
        // Làm sạch danh sách cũ trước khi tải mới
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      print("databienso3:${e..toString()}");
      notifyListeners();
    }
  }

  Future<void> postDataHuy(LichSuBaoDuongNewModel? scanData, String? liDo) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;

      var dataList = [newScanData];
      final http.Response response = await requestHelper.postData('MMS_BaoCao/HuyYeuCauBaoDuong?&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&LiDo=${liDo}', dataList.map((e) => e?.toJson()).toList());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("dataHuy: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: "Hủy xác nhận thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
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
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
            });
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postData(LichSuBaoDuongModel scanData, String? ngayDiBaoDuong, List<String> selectedIds) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.bienSo1 = newScanData.bienSo1 == 'null' ? null : newScanData.bienSo1;

      var dataList = [newScanData];
      print("idssss: ${selectedIds}");
      final http.Response response = await requestHelper.postData('MMS_BaoCao/XacNhanYeuCau?ids=${selectedIds.join("&ids=")}&NgayDiBaoDuong=$ngayDiBaoDuong&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}', dataList.map((e) => e.toJson()).toList());
      print("statusCode: ${response.statusCode}");

      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        print("text: ${_textController.text}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: "Xác nhận thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              if (_textController.text == "") {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
              if (_textController.text != "") {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                setState(() {
                  _textController.text = "";
                });
              }
            });
        _btnController.reset();
        await getListThayDoiKH(widget.id, soKhungController.text);
        body = "Bạn vừa được xác nhận 1 yêu cầu bảo dưỡng phương tiện";
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
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postDataList(
    List<LichSuBaoDuongModel> dataList,
    String? ngayDiBaoDuong,
  ) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('MMS_BaoCao/XacNhanYeuCau?NgayDiBaoDuong=$ngayDiBaoDuong&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}', dataList.map((item) => item.toJson()).toList());
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
            text: "Xác nhận thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              if (_textController.text == "") {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
              if (_textController.text != "") {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                setState(() {
                  _textController.text = "";
                });
              }
            });
        _btnController.reset();
        await getListThayDoiKH(widget.id, soKhungController.text);
        body = "Bạn vừa được xác nhận 1 yêu cầu bảo dưỡng phương tiện";
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
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
            });
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postDataFireBase(
    KeHoachModel? scanData,
    String? body,
    String? nguoiYeuCau,
    String? id,
  ) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      final http.Response response = await requestHelper.postData('MMS_Notification/PushThongBao?body=$body&listIds=$id&NguoiYeuCau=$nguoiYeuCau', newScanData?.toJson());
      print("statusCodefirebase: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("datafirebase: ${decodedData}");
        setState(() async {
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

  _onSave(int index, List<dynamic> selectedItems) async {
    setState(() {
      _loading = true;
    });
    List<String> selectedIds = selectedItems.map((e) => e.hangMuc_Id.toString()).toList();
    print("Danh sách ID đã chọn: $selectedIds");
    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    print("ngay = ${selectedDate}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.id;
    _data?.phuongTien_Id = item?.phuongTien_Id;
    _data?.soKM = item?.soKM;
    _data?.diaDiem_Id = DiaDiem_Id;
    // _data?.keHoachGiaoXe_Id = item?.keHoachGiaoXe_Id;
    // _data?.nguoiYeuCau = item?.nguoiYeuCau;

    // if (_IsXacNhan == true) {
    //   _data?.trangThai = "1";
    // }
    // if (_IsTuChoi == true) {
    //   _data?.trangThai = "2";
    // }

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
        postData(_data!, selectedDate, selectedIds).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            selectedIds = [];
            _qrDataController.text = '';
            getListThayDoiKH(widget.id, soKhungController.text);
            postDataFireBase(_thongbao, body ?? "", _data?.nguoiYeuCau ?? "", _data?.phuongTien_Id);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  _onSaveHuy(int index) async {
    setState(() {
      _loading = true;
    });

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data1 ??= LichSuBaoDuongNewModel();
    _data1?.id = item?.id;

    // _data?.keHoachGiaoXe_Id = item?.keHoachGiaoXe_Id;
    // _data?.nguoiYeuCau = item?.nguoiYeuCau;

    // if (_IsXacNhan == true) {
    //   _data?.trangThai = "1";
    // }
    // if (_IsTuChoi == true) {
    //   _data?.trangThai = "2";
    // }

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
        postDataHuy(_data1!, _textController.text).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;

            _qrDataController.text = '';
            getListThayDoiKH(widget.id, soKhungController.text);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogTuChoi(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
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
                      const Text(
                        'Vui lòng nhập lí do hủy của bạn?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        onChanged: (text) {
                          // Gọi setState để cập nhật giao diện khi giá trị TextField thay đổi
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Nhập lí do',
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
                              Navigator.of(context).pop();
                              _btnController.reset();
                            },
                            child: const Text(
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
                            onPressed: _textController.text.isNotEmpty ? () => _onSaveHuy(index) : null,
                            child: const Text(
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
      },
    );
  }

  void _showConfirmationDialogYeuCau(BuildContext context, String? bienSo1, int index) {
    final baoduongId = _kehoachList?[index].phuongTien_Id;
    DiaDiem_Id = _kehoachList?[index].diaDiem_Id;
    selectedDate = _kehoachList?[index].ngayDiBaoDuong;
    final image = _kehoachList?[index]?.hinhAnh;
    print("abc:${baoduongId}, ${_hangmucListnew}");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            if (_hangmucListnew == null || _hangmucListnew!.isEmpty) {
              getListChiTietHangMuc2(baoduongId ?? "", setStateDialog);
            }
            if (_previousPhuongTienId != baoduongId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = baoduongId;
              getListChiTietHangMuc2(baoduongId ?? "", setStateDialog);
            }
            TextEditingController _selectedController = TextEditingController(
              text: _selectedItems.map((e) => e.noiDungBaoDuong).join(', '),
            );
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            // Giúp text co giãn mà không làm tràn
                            child: Text(
                              'Duyệt phương tiện ${bienSo1}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              overflow: TextOverflow.ellipsis, // Cắt nếu quá dài
                              maxLines: 1, // Chỉ hiển thị 1 dòng
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Vị trí: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.location_on, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    insetPadding: EdgeInsets.zero, // Không chừa lề để full screen
                                    child: Scaffold(
                                      appBar: AppBar(
                                        automaticallyImplyLeading: false,
                                        title: Text(
                                          "Vị trí phương tiện ${bienSo1}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        actions: [
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                      body: QuanLyPhuongTienQLNewPage_Map(id: widget.id, tabIndex: 0),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                      TextField(
                        controller: _selectedController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Danh sách hạng mục",
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () {
                          _showHangMucPopup(context, setStateDialog, _selectedController);
                        },
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: MediaQuery.of(context).size.height < 600 ? 10.h : 6.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFFBC2925),
                            width: 1.5,
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
                              child: const Center(
                                child: Text(
                                  "TT Bảo dưỡng",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: AppConfig.textInput,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      items: _dn?.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item.id,
                                          child: Container(
                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                item.tenDiaDiem ?? "",
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
                                      }).toList(),
                                      value: DiaDiem_Id,
                                      onChanged: (newValue) {
                                        setStateDialog(() {
                                          DiaDiem_Id = newValue;
                                        });
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
                                              hintText: 'Tìm địa điểm',
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
                                            return _dn?.any((baiXe) => baiXe.id == itemId && baiXe.tenDiaDiem?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngày đi bảo dưỡng',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
                                lastDate: DateTime(2100),
                              );

                              if (picked != null) {
                                setStateDialog(() {
                                  // Cập nhật UI ngay lập tức
                                  selectedDate = DateFormat('dd/MM/yyyy').format(picked);
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFBC2925)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, color: Color(0xFFBC2925)),
                                  SizedBox(width: 8),
                                  Text(
                                    selectedDate ?? 'Chọn ngày',
                                    style: TextStyle(color: Color(0xFFBC2925)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (image != null)
                        Row(
                          children: [
                            const Text(
                              "Hình ảnh:",
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(child: _buildTableHinhAnh(image ?? "")),
                          ],
                        ),
                      Container(
                        width: 100.w,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            RoundedLoadingButton(
                              child: Text('Xác nhận',
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    color: AppConfig.textButton,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  )),
                              controller: _btnController,
                              onPressed: (selectedDate != null && DiaDiem_Id != null) ? () => _onSave(index, _selectedItems) : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showHangMucPopup(BuildContext context, StateSetter parentSetState, TextEditingController controller) {
    bool isExpanded = true; // trạng thái mở rộng danh sách
    bool isExpanded2 = true; // trạng thái mở rộng danh sách
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn bấm ra ngoài để đóng
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              insetPadding: EdgeInsets.all(10), // Giảm khoảng cách với viền màn hình
              child: Container(
                width: MediaQuery.of(context).size.width, // Full chiều rộng
                height: MediaQuery.of(context).size.height, // Full chiều cao
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với dấu X đóng
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              setStateDialog(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  "Chọn hạng mục bảo dưỡng",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    Divider(),

                    // Nội dung danh sách checkbox
                    if (isExpanded)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _hangmucListnew!.where((item) => item.isBaoDuong == true).map((item) {
                                bool isChecked = _selectedItems.any((e) => e.hangMuc_Id == item.hangMuc_Id);
                                return CheckboxListTile(
                                  title: Text(
                                    item.noiDungBaoDuong ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold, // Tiêu đề đậm
                                      color: Colors.blue, // Màu đen cho tiêu đề
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildRichText('Định mức:', item?.dinhMuc),
                                      buildRichText('Loại bảo dưỡng:', item?.loaiBaoDuong),
                                      buildRichText('Gía trị hiện tại:', item?.soKM),
                                      buildRichText('Gía trị ngày bảo dưỡng gần nhất:', item?.giaTriBaoDuong),
                                      buildRichText('Gía trị đã đi được/ngày bảo dương:', item?.soKM_DaDiDuoc),
                                      buildRichText('Gía trị còn lại :', item?.soKM_CanDenHan),
                                      buildRichText('Tiêu chí:', item?.tieuChi),
                                    ],
                                  ),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setStateDialog(() {
                                      if (value == true) {
                                        _selectedItems.add(item);
                                      } else {
                                        _selectedItems.removeWhere((e) => e.hangMuc_Id == item.hangMuc_Id);
                                      }
                                    });

                                    // Cập nhật UI của dialog chính
                                    parentSetState(() {
                                      controller.text = _selectedItems.map((e) => e.noiDungBaoDuong).join(', ');
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setStateDialog(() {
                                isExpanded2 = !isExpanded2;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  "Hạng mục sửa chữa",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  isExpanded2 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          if (_hangmucListnew!.where((item) => item.isBaoDuong == false).isNotEmpty && isExpanded2)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _hangmucListnew!.where((item) => item.isBaoDuong == false && item.isDenHan == true).map((item) {
                                bool isChecked = _selectedItems.any((e) => e.hangMuc_Id == item.hangMuc_Id);
                                return CheckboxListTile(
                                  title: Text(
                                    item.noiDungBaoDuong ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold, // Tiêu đề đậm
                                      color: Colors.blue, // Màu đen cho tiêu đề
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildRichText('Ghi chú:', item?.ghiChu ?? ""),
                                    ],
                                  ),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setStateDialog(() {
                                      if (value == true) {
                                        _selectedItems.add(item);
                                      } else {
                                        _selectedItems.removeWhere((e) => e.hangMuc_Id == item.hangMuc_Id);
                                      }
                                    });
                                    // Cập nhật UI của dialog chính
                                    parentSetState(() {
                                      controller.text = _selectedItems.map((e) => e.noiDungBaoDuong).join(', ');
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    // Nút Xong
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Xong", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, int index, List<HangMucModel> items) {
    final baoduongId = _kehoachList?[index].id; // Lấy ID của phương tiện

    bool isExpanded = true; // trạng thái mở rộng danh sách
    bool isExpanded2 = true; // trạng thái mở rộng danh sách
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // if (_hangmucList == null || _hangmucList!.isEmpty) {
            //   getListChiTietHangMuc(baoduongId ?? "", setState);
            // }
            if (_previousPhuongTienId != baoduongId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = baoduongId;
              getListChiTietHangMuc(baoduongId ?? "", setState);
            }
            return Dialog(
              insetPadding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'HẠNG MỤC BẢO DƯỠNG',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red, size: 30),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Danh sách hạng mục với checkbox
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const Text(
                                      "Hạng mục bảo dưỡng",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  // itemCount: _hangmucList?.length ?? 0,
                                  itemCount: _hangmucList?.where((item) => item?.isBaoDuong == true)?.length ?? 0,
                                  itemBuilder: (context, i) {
                                    final filteredItems = _hangmucList?.where((item) => item?.isBaoDuong == true).toList() ?? [];
                                    var item = filteredItems[i];
                                    // var item = _hangmucList?[i];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item?.noiDungBaoDuong ?? "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold, // Tiêu đề đậm
                                              color: Colors.blue, // Màu đen cho tiêu đề
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          buildRichText('Định mức:', item?.dinhMuc2),
                                          buildRichText('Loại bảo dưỡng:', item?.loaiBaoDuong),
                                          buildRichText('Ghi chú:', item?.ghiChu),
                                          buildRichText('Chi phí:', item?.chiPhi),
                                          Divider(height: 1, color: Color(0xFFDDDDDD)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isExpanded2 = !isExpanded2;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const Text(
                                      "Hạng mục sửa chữa",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      isExpanded2 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded2)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  // itemCount: _hangmucList?.length ?? 0,
                                  itemCount: _hangmucList?.where((item) => item?.isBaoDuong == false)?.length ?? 0,
                                  itemBuilder: (context, i) {
                                    final filteredItems2 = _hangmucList?.where((item) => item?.isBaoDuong == false).toList() ?? [];
                                    var item = filteredItems2[i];
                                    // var item = _hangmucList?[i];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item?.noiDungBaoDuong ?? "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold, // Tiêu đề đậm
                                              color: Colors.blue, // Màu đen cho tiêu đề
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          buildRichText('Ghi chú:', item?.ghiChu ?? ""),
                                          Divider(height: 1, color: Color(0xFFDDDDDD)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Button Xác nhận
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailsDialogold(BuildContext context, String? id, List<HangMucModel> items) {
    final baoduongId = id; // Lấy ID của phương tiện
    bool isExpanded = true; // trạng thái mở rộng danh sách
    bool isExpanded2 = true; // trạng thái mở rộng danh sách
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // if (_hangmucList == null || _hangmucList!.isEmpty) {
            //   getListChiTietHangMuc(baoduongId ?? "", setState);
            // }
            if (_previousPhuongTienId != baoduongId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = baoduongId;
              getListChiTietHangMuc(baoduongId ?? "", setState);
            }
            return Dialog(
              insetPadding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'HẠNG MỤC BẢO DƯỠNG',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red, size: 30),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Danh sách hạng mục với checkbox
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const Text(
                                      "Hạng mục bảo dưỡng",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _hangmucList?.where((item) => item?.isBaoDuong == true)?.length ?? 0,
                                  itemBuilder: (context, i) {
                                    final filteredItems = _hangmucList?.where((item) => item?.isBaoDuong == true).toList() ?? [];
                                    var item = filteredItems[i];
                                    // var item = _hangmucList?[i];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item?.noiDungBaoDuong ?? "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold, // Tiêu đề đậm
                                              color: Colors.blue, // Màu đen cho tiêu đề
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          buildRichText('Định mức:', item?.dinhMuc2),
                                          buildRichText('Loại bảo dưỡng:', item?.loaiBaoDuong),
                                          buildRichText('Ghi chú:', item?.ghiChu),
                                          buildRichText('Chi phí:', item?.chiPhi),
                                          Divider(height: 1, color: Color(0xFFDDDDDD)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isExpanded2 = !isExpanded2;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const Text(
                                      "Hạng mục sửa chữa",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      isExpanded2 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded2)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  // itemCount: _hangmucList?.length ?? 0,
                                  itemCount: _hangmucList?.where((item) => item?.isBaoDuong == false)?.length ?? 0,
                                  itemBuilder: (context, i) {
                                    final filteredItems2 = _hangmucList?.where((item) => item?.isBaoDuong == false).toList() ?? [];
                                    var item = filteredItems2[i];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item?.noiDungBaoDuong ?? "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold, // Tiêu đề đậm
                                              color: Colors.blue, // Màu đen cho tiêu đề
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          buildRichText('Ghi chú:', item?.ghiChu ?? ""),
                                          Divider(height: 1, color: Color(0xFFDDDDDD)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Button Xác nhận
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> postDataHoanThanh(LichSuBaoDuongModel? scanData, List<Map<String, dynamic>> danhSachChiPhi, int index, int? tongChiPhiBD, int? tongChiPhiSC, String? vatTu) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;
      Map<String, dynamic> requestBody = {
        "data": newScanData?.toJson() ?? {}, // Dữ liệu bảo dưỡng
        "chiPhis": danhSachChiPhi
            .map((chiPhi) => {
                  "hangMuc_Id": chiPhi["hangMuc_Id"],
                  "giaTri": chiPhi["chiPhi"], // Đảm bảo key trùng với backend
                })
            .toList(),
      };

      final http.Response response = await requestHelper.postData('MMS_BaoCao/HoanThanhBaoDuong?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&TongChiPhiBD=$tongChiPhiBD&TongChiPhiSC=$tongChiPhiSC&VatTuThayThe=$vatTu', requestBody);

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: "Xác nhận thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // Đóng dialog cũ (nếu cần)
              // if (Navigator.canPop(context)) {
              //   Navigator.pop(context); // Đóng dialog cũ (nếu cần)
              //   _showDetailsDialog(context, index); // Mở dialog với dữ liệu mới
              // }
            });
        _btnController.reset();
        await getListThayDoiKH(widget.id, soKhungController.text);
        body = "Bạn vừa được xác nhận 1 đề xuất hoàn thành bảo dưỡng phương tiện";
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

  _onSaveHoanThanh(int index, String? chiPhiBD, String? chiPhiSC, String? vatTu) async {
    setState(() {
      _loading = true;
    });
    List<String> imageUrls = [];

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
    int? tongChiPhiSC;

    int? tongChiPhiBD = int.parse(chiPhiBD!.replaceAll(RegExp(r'[.,]'), ""));

    if (chiPhiSC != "") {
      tongChiPhiSC = int.parse(chiPhiSC!.replaceAll(RegExp(r'[.,]'), ""));
    }

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.id;
    _data?.noiDung = textEditingController.text;
    _data?.ketQua = _ghiChu.text;
    _data?.hinhAnh = imageUrlsString;
    List<Map<String, dynamic>> danhSachChiPhi = [];
    for (var hangmuc in _hangmucList ?? []) {
      String chiPhiText = chiphiControllers[hangmuc.hangMuc_Id!]?.text ?? "0";
      int chiPhiValue = int.parse(chiPhiText.replaceAll(RegExp(r'[.,]'), ""));
      danhSachChiPhi.add({
        "hangMuc_Id": hangmuc.hangMuc_Id,
        "chiPhi": chiPhiValue,
      });
    }
    print("chiphi:${_chiphi.text}");

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
        postDataHoanThanh(_data!, danhSachChiPhi, index, tongChiPhiBD, tongChiPhiSC, vatTu).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            _textController.text = '';
            textEditingController.text = '';
            _ghiChu.text = '';
            getListThayDoiKH(widget.id, textEditingController.text);
            getAllHM(widget.id ?? "", setState);
            postDataFireBase(_thongbao, body ?? "", _data?.nguoiYeuCau ?? "", item?.phuongTien_Id);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogHoanThanh(BuildContext context, int index, String? chiphiBD, String? chiphiSC, String? vatTu) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn hoàn thành bảo dưỡng không?',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: const TextStyle(
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
          _onSaveHoanThanh(index, chiphiBD, chiphiSC, vatTu);
        });
  }

  void _showDetailsDialog2(BuildContext context, int index, String? ghiChu, String? soKM, String? tongChiPhi, String? chiPhiBD, String? chiPhiSC, String? vatTu) {
    final baoduongId = _kehoachList?[index].id;
    final image = _kehoachList?[index]?.hinhAnh;

    final TextEditingController _tongChiPhiBD = TextEditingController(text: chiPhiBD ?? "0");
    final TextEditingController _tongChiPhiSC = TextEditingController(text: chiPhiSC ?? "0");
    final TextEditingController _vatTu = TextEditingController(text: vatTu ?? "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_hangmucList == null || _hangmucList!.isEmpty) {
              getListChiTietHangMuc(baoduongId ?? "", setState);
            }
            if (_previousPhuongTienId != baoduongId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = baoduongId;
              getListChiTietHangMuc(baoduongId ?? "", setState);
            }
            _tongChiPhiBD.addListener(() {
              _updateTongChiPhi(setState, _tongChiPhiBD, _tongChiPhiSC);
            });
            _tongChiPhiSC.addListener(() {
              _updateTongChiPhi(setState, _tongChiPhiBD, _tongChiPhiSC);
            });

// Gọi ban đầu để hiển thị đúng
            Future.delayed(Duration.zero, () {
              _updateTongChiPhi(setState, _tongChiPhiBD, _tongChiPhiSC);
            });
            // Khởi tạo controller cho từng hạng mục
            // for (var hangmuc in _hangmucList ?? []) {
            //   // chiphiControllers[hangmuc.id!] = TextEditingController();
            //   // chiphiControllers[hangmuc.hangMuc_Id!] = TextEditingController(text: hangmuc.chiPhi?.toString() ?? "");
            //   chiphiControllers.putIfAbsent(
            //     hangmuc.hangMuc_Id!,
            //     () => TextEditingController(text: hangmuc.chiPhi?.toString() ?? ""),
            //   );
            //   Future.delayed(Duration.zero, () {
            //     _updateTongChiPhi(setState);
            //   });
            // }

            return Dialog(
              insetPadding: EdgeInsets.zero, // Loại bỏ khoảng cách viền
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                width: MediaQuery.of(context).size.width, // Full chiều rộng màn hình
                height: MediaQuery.of(context).size.height, // Full chiều cao màn hình
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'HOÀN THÀNH BẢO DƯỠNG',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
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
                              Container(
                                padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Column(
                                        children: [
                                          // ItemGhiChu(
                                          //   title: 'Nội dung bảo dưỡng: ',
                                          //   controller: textEditingController,
                                          // ),
                                          // const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemGhiChu(
                                            title: 'Ghi chú: ',
                                            content: ghiChu ?? "",
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemGhiChu(
                                            title: 'Nhập số KM hiện tại: ',
                                            content: soKM ?? "",
                                          ),

                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemNhapChiPhi(
                                            title: 'Vật tư thay thế: ',
                                            controller: _vatTu,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemNhapChiPhi(
                                            title: 'Chi phí bảo dưỡng: ',
                                            controller: _tongChiPhiBD,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemNhapChiPhi(
                                            title: 'Chi phí sửa chữa: ',
                                            controller: _tongChiPhiSC,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              "Tổng chi phí: ${NumberFormat("#,###", "vi_VN").format(_tongChiPhi)} VND",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          ExpansionTile(
                                            initiallyExpanded: true,
                                            title: const Text(
                                              "Hạng mục bảo dưỡng",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            tilePadding: const EdgeInsets.symmetric(horizontal: 0), // sát trái
                                            children: [
                                              ...?_hangmucList?.where((item) => item.isBaoDuong == true).map((hangmuc) {
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      title: RichText(
                                                        text: TextSpan(
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                                          children: [
                                                            TextSpan(text: "${hangmuc.noiDungBaoDuong}\n"),
                                                            const TextSpan(
                                                              text: "Ghi chú: ",
                                                              style: TextStyle(
                                                                fontFamily: 'Comfortaa',
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w700,
                                                                color: Color(0xFF818180),
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: hangmuc.ghiChu ?? '',
                                                              style: const TextStyle(
                                                                fontFamily: 'Comfortaa',
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w700,
                                                                color: AppConfig.primaryColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          ExpansionTile(
                                            initiallyExpanded: true,
                                            title: const Text(
                                              "Hạng mục sửa chữa",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                                            children: [
                                              ...?_hangmucList?.where((item) => item.isBaoDuong == false).map((hangmuc) {
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      title: RichText(
                                                        text: TextSpan(
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                                          children: [
                                                            TextSpan(text: "${hangmuc.noiDungBaoDuong}\n"),
                                                            const TextSpan(
                                                              text: "Ghi chú: ",
                                                              style: TextStyle(
                                                                fontFamily: 'Comfortaa',
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w700,
                                                                color: Color(0xFF818180),
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: hangmuc.ghiChu ?? '',
                                                              style: const TextStyle(
                                                                fontFamily: 'Comfortaa',
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w700,
                                                                color: AppConfig.primaryColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          // Container(
                                          //   padding: const EdgeInsets.all(10),
                                          //   // alignment: Alignment.centerRight,
                                          //   child: Text(
                                          //     "Tổng chi phí: ${tongChiPhi} VND",
                                          //     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                          //   ),
                                          // ),
                                          // Container(
                                          //   padding: const EdgeInsets.all(10),
                                          //   alignment: Alignment.centerRight,
                                          //   child: Text(
                                          //     "Tổng chi phí: ${formatter.format(_tongChiPhi)} VND",
                                          //     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                                          //   ),
                                          // ),

                                          // ...?_hangmucList?.where((item) => item.isBaoDuong == true).map((hangmuc) {
                                          //   return Column(
                                          //     children: [
                                          //       ListTile(
                                          //         title: Text(
                                          //           "${hangmuc.noiDungBaoDuong} - ${hangmuc.dinhMuc2}",
                                          //           style: TextStyle(fontWeight: FontWeight.bold),
                                          //         ),
                                          //       ),
                                          //       Padding(
                                          //         padding: const EdgeInsets.symmetric(horizontal: 10),
                                          //         child: TextField(
                                          //           controller: chiphiControllers[hangmuc.hangMuc_Id!],
                                          //           // controller: chiphiControllers.putIfAbsent(
                                          //           //   hangmuc.id!,
                                          //           //   () {
                                          //           //     print("Khởi tạo controller cho ${hangmuc.id!} với giá trị: ${hangmuc.chiPhi}");
                                          //           //     return TextEditingController(text: hangmuc.chiPhi?.toString() ?? "");
                                          //           //   },
                                          //           // ),
                                          //           keyboardType: TextInputType.number,
                                          //           onChanged: (value) => _updateTongChiPhi(setState),
                                          //           decoration: InputDecoration(
                                          //             labelText: "Chi phí bảo dưỡng",
                                          //             labelStyle: TextStyle(
                                          //               fontSize: 18, // 👈 chỉnh size ở đây
                                          //               fontWeight: FontWeight.bold, // tuỳ chọn nếu muốn đậm hơn
                                          //             ),
                                          //             border: OutlineInputBorder(),
                                          //           ),
                                          //         ),
                                          //       ),
                                          //       const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          //     ],
                                          //   );
                                          // }).toList(),
                                          // ...?_hangmucList?.where((item) => item.isBaoDuong == false).map((hangmuc) {
                                          //   return Column(
                                          //     children: [
                                          //       ListTile(
                                          //         title: Text(
                                          //           "${hangmuc.noiDungBaoDuong} - ${hangmuc.dinhMuc2}",
                                          //           style: TextStyle(fontWeight: FontWeight.bold),
                                          //         ),
                                          //       ),
                                          //       Padding(
                                          //         padding: const EdgeInsets.symmetric(horizontal: 10),
                                          //         child: TextField(
                                          //           controller: chiphiControllers[hangmuc.hangMuc_Id!],
                                          //           keyboardType: TextInputType.number,
                                          //           onChanged: (value) => _updateTongChiPhi(setState),
                                          //           decoration: InputDecoration(
                                          //             labelText: "Chi phí sửa chữa",
                                          //             labelStyle: TextStyle(
                                          //               fontSize: 18, // 👈 chỉnh size ở đây
                                          //               fontWeight: FontWeight.bold, // tuỳ chọn nếu muốn đậm hơn
                                          //             ),
                                          //             border: OutlineInputBorder(),
                                          //           ),
                                          //         ),
                                          //       ),
                                          //       const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          //     ],
                                          //   );
                                          // }).toList(),
                                          SizedBox(
                                            height: 10,
                                          ),

                                          if (image != null)
                                            Row(
                                              children: [
                                                const Text(
                                                  "Hình ảnh:",
                                                  style: TextStyle(
                                                    fontFamily: 'Comfortaa',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Expanded(child: _buildTableHinhAnh(image ?? "")),
                                              ],
                                            )
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
                      width: 100.w,
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          RoundedLoadingButton(
                            child: Text('Xác nhận',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  color: AppConfig.textButton,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                )),
                            controller: _btnController,
                            onPressed: () => _showConfirmationDialogHoanThanh(context, index, _tongChiPhiBD.text, _tongChiPhiSC.text, _vatTu.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailsDialogAll(BuildContext context, String? id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_kehoachListhm == null || _kehoachListhm!.isEmpty) {
              getAllHM(id ?? "", setState);
            }
            return Dialog(
              insetPadding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'HẠNG MỤC BẢO DƯỠNG',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red, size: 30),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Danh sách hạng mục với checkbox
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _kehoachListhm?.length ?? 0,
                                itemBuilder: (context, i) {
                                  var item = _kehoachListhm?[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item?.noiDungBaoDuong ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold, // Tiêu đề đậm
                                            color: Colors.blue, // Màu đen cho tiêu đề
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Lịch sử hạng mục:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold, // Tiêu đề đậm
                                                color: Colors.black, // Màu đen cho tiêu đề
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.info,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () => _showDetailsDialogChiTiet(context, item?.phuongTien_Id, item?.hangMuc_Id),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        buildRichText('Định mức:', item?.dinhMuc),
                                        buildRichText('Loại bảo dưỡng:', item?.loaiBaoDuong),
                                        buildRichText('Ghi chú:', item?.ghiChu),
                                        buildRichText('Tổng chi phí:', item?.tongChiPhi_TD),
                                        Divider(height: 1, color: Color(0xFFDDDDDD)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Button Xác nhận
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailsDialogChiTiet(BuildContext context, String? phuongTien_Id, String? hangMuc_Id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // if (_hangmucList2 == null || _hangmucList2!.isEmpty) {
            //   getChiTietHM(phuongTien_Id ?? "", hangMuc_Id ?? "", setState);
            // }

            if (_previousPhuongTienId != hangMuc_Id) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = hangMuc_Id;
              getChiTietHM(phuongTien_Id ?? "", hangMuc_Id ?? "", setState);
            }

            return Dialog(
              insetPadding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'HẠNG MỤC BẢO DƯỠNG',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red, size: 30),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),

                    // Danh sách hạng mục với checkbox
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _hangmucList2?.length ?? 0,
                                itemBuilder: (context, i) {
                                  var item = _hangmucList2?[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item?.noiDungBaoDuong ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold, // Tiêu đề đậm
                                            color: Colors.blue, // Màu đen cho tiêu đề
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        buildRichText('Định mức:', item?.dinhMuc),
                                        buildRichText('Loại bảo dưỡng:', item?.loaiBaoDuong),
                                        buildRichText('Ghi chú:', item?.ghiChu),
                                        buildRichText('Chi phí:', item?.chiPhi),
                                        Divider(height: 1, color: Color(0xFFDDDDDD)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Button Xác nhận
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0;
    const String defaultDate = "1970-01-01 ";
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 9.3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.2),
                2: FlexColumnWidth(0.2),
                3: FlexColumnWidth(0.2),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
                7: FlexColumnWidth(0.3),
                8: FlexColumnWidth(0.3),
                9: FlexColumnWidth(0.3),
                10: FlexColumnWidth(0.3),
                11: FlexColumnWidth(0.3),
                12: FlexColumnWidth(0.3),
                13: FlexColumnWidth(0.3),
                14: FlexColumnWidth(0.3),
                15: FlexColumnWidth(0.3),
                16: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Trạng thái', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Biển số 1', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Biển số 2', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Danh sách hạng mục', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nơi bảo dưỡng', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nội dung chi tiết', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Chi phí (VND)', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Hình ảnh', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người yêu cầu', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người xác nhận', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người đi bảo dưỡng', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người đề xuất hoàn thành', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người xác nhận hoàn thành', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày đi bảo dưỡng', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày đề xuất hoàn thành', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày hoàn thành', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Giá trị bảo dưỡng ', textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.45, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.3),
                    1: FlexColumnWidth(0.2),
                    2: FlexColumnWidth(0.2),
                    3: FlexColumnWidth(0.2),
                    4: FlexColumnWidth(0.3),
                    5: FlexColumnWidth(0.3),
                    6: FlexColumnWidth(0.3),
                    7: FlexColumnWidth(0.3),
                    8: FlexColumnWidth(0.3),
                    9: FlexColumnWidth(0.3),
                    10: FlexColumnWidth(0.3),
                    11: FlexColumnWidth(0.3),
                    12: FlexColumnWidth(0.3),
                    13: FlexColumnWidth(0.3),
                    14: FlexColumnWidth(0.3),
                    15: FlexColumnWidth(0.3),
                    16: FlexColumnWidth(0.3),
                  },
                  children: [
                    // Chiều cao cố định
                    ..._kehoachListold?.map((item) {
                          // index++; // Tăng số thứ tự sau mỗi lần lặp
                          return TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white, // Nền đỏ nếu đủ điều kiện
                            ),
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              _buildTableCell(item.tinhTrang ?? ""),

                              _buildTableCell(item.bienSo1 ?? ""),
                              _buildTableCell(item.bienSo2 ?? ""),
                              _buildTableCell(item.danhSachHangMuc ?? ""),
                              _buildTableCell(item.tenDiaDiem ?? ""),
                              IconButton(
                                icon: const Icon(
                                  Icons.info,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _showDetailsDialogold(context, item.id ?? "", item.lichSu ?? []);
                                },
                              ),
                              _buildTableCell(item.chiPhi_TD ?? ""),
                              _buildTableHinhAnh(item.hinhAnh ?? ""),
                              _buildTableCell(item.nguoiYeuCau ?? ""),
                              _buildTableCell(item.nguoiXacNhan ?? ""),
                              _buildTableCell(item.nguoiDiBaoDuong ?? ""),
                              _buildTableCell(item.nguoiDeXuatHoanThanh ?? ""),
                              _buildTableCell(item.nguoiXacNhanHoanThanh ?? ""),
                              _buildTableCell(item.ngayDiBaoDuong ?? ""),
                              _buildTableCell(item.ngayDeXuatHoanThanh ?? ""),
                              _buildTableCell(item.ngayHoanThanh ?? ""),
                              _buildTableCell(item.soKM ?? ""),
                            ],
                          );
                        }).toList() ??
                        [],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String content, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SelectableText(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTableHinhAnh(String content, {Color textColor = Colors.black}) {
    List<String> imageUrls = content.split(',');

    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          String imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () {
              _showFullImageDialog(imageUrls, index); // Truyền danh sách ảnh và index hiện tại
            },
            child: Container(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullImageDialog(List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          child: Container(
            // width: screenSize.width * 1,
            height: screenSize.height * 0.7,
            child: PhotoViewGallery.builder(
              itemCount: imageUrls.length,
              pageController: PageController(initialPage: initialIndex),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(imageUrls[index]),
                  // minScale: PhotoViewComputedScale.contained, // Đảm bảo ảnh hiển thị đầy đủ
                  // maxScale: PhotoViewComputedScale.covered, // Cho phép phóng to vừa đủ nếu cần
                  // initialScale: PhotoViewComputedScale.covered,
                  // backgroundDecoration: BoxDecoration(color: Colors.black),
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getListThayDoiKH(widget.id, soKhungController.text);
      },
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      // color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Lịch sử: ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${(_kehoachList?.length ?? 0) + (_kehoachListold?.length ?? 0)}",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.info,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showDetailsDialogAll(context, widget.id ?? ""),
                                ),
                              ],
                            ),
                            ListView.builder(
                              shrinkWrap: true, // Đảm bảo danh sách nằm gọn trong SingleChildScrollView
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _kehoachList?.where((item) => item.isHoanThanh == false).length ?? 0,
                              itemBuilder: (context, index) {
                                final filteredList = _kehoachList?.where((item) => item.isHoanThanh == false).toList();
                                final item = filteredList?[index];
                                // final item = _kehoachList?[index];
                                _hangmucList = item?.lichSu ?? [];
                                _selectedItems = List.from(item?.lichSu ?? []);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    // color: Color.fromARGB(255, 226, 167, 187),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InfoColumn(
                                        danhSachHangMuc: item?.danhSachHangMuc ?? "",
                                        isLenhHoanThanh: item?.isLenhHoanThanh ?? false,
                                        isHoanThanh: item?.isHoanThanh ?? false,
                                        noiDung: item?.noiDung ?? "",
                                        ketQua: item?.ketQua ?? "",
                                        soKM: item?.soKM ?? "",
                                        tenDiaDiem: item?.tenDiaDiem ?? "",
                                        isYeuCau: item?.isYeuCau ?? false,
                                        tinhTrang: item?.tinhTrang ?? "",
                                        bienSo1: item?.bienSo1 ?? "",
                                        ngay: item?.ngay ?? "",
                                        chiPhi: item?.chiPhi ?? "",
                                        ngayDeXuatHoanThanh: item?.ngayDeXuatHoanThanh ?? "",
                                        nguoiDeXuatHoanThanh: item?.nguoiDeXuatHoanThanh ?? "",
                                        ngayXacNhan: item?.ngayXacNhan ?? "",
                                        ngayDiBaoDuong: item?.ngayDiBaoDuong ?? "",
                                        ngayHoanThanh: item?.ngayHoanThanh ?? "",
                                        nguoiYeuCau: item?.nguoiYeuCau ?? "",
                                        nguoiXacNhan: item?.nguoiXacNhan ?? "",
                                        nguoiDiBaoDuong: item?.nguoiDiBaoDuong ?? "",
                                        nguoiXacNhanHoanThanh: item?.nguoiXacNhanHoanThanh ?? "",
                                        isDuyet: item?.isDuyet ?? false,
                                        isBaoDuong: item?.isBaoDuong ?? false,
                                        onDongY: () {
                                          _IsXacNhan = true;
                                          _showConfirmationDialogYeuCau(context, item?.bienSo1, index); // Hành động ĐỒNG Ý
                                        },
                                        onDongYHoanThanh: () {
                                          _showDetailsDialog2(context, index, item?.ketQua, item?.soKM, item?.tongChiPhi, item?.chiPhiBD2, item?.chiPhiSC2, item?.vatTuThayThe); // Hành động ĐỒNG Ý
                                        },
                                        onTuChoi: () {
                                          _IsTuChoi = true;
                                          _showConfirmationDialogTuChoi(context, index); // Hành động TỪ CHỐI
                                        },
                                        isChiTiet: () {
                                          _showDetailsDialog(context, index, item?.lichSu ?? []); // Hành động TỪ CHỐI
                                        },
                                        isSelected: selectedItems[index],
                                        onLongPress: () {
                                          setState(() {
                                            selectedItems[index] = !selectedItems[index];
                                          });
                                          print(selectedItems);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if ((_kehoachListold?.isNotEmpty ?? false)) _buildTableOptions(context)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 11,
              padding: EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppConfig.bottom,
              ),
              child: Center(
                child: customTitle(
                  'LỊCH SỬ BẢO DƯỠNG',
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
  final String content; // Chuyển từ controller sang content (chuỗi văn bản)

  const ItemGhiChu({
    Key? key,
    required this.title,
    required this.content,
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
            const SizedBox(width: 10), // Khoảng cách giữa title và nội dung
            Expanded(
              child: Text(
                content.isNotEmpty ? content : "", // Hiển thị mặc định nếu rỗng
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                overflow: TextOverflow.ellipsis, // Giới hạn text dài, tránh tràn
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileItem {
  bool? uploaded = false;
  String? file;
  bool? local = true;
  bool? isRemoved = false;

  FileItem({
    required this.uploaded,
    required this.file,
    required this.local,
    required this.isRemoved,
  });
}

class InfoColumn extends StatelessWidget {
  final String bienSo1, danhSachHangMuc;
  final String ngay; // Thời gian yêu cầu
  final String ngayXacNhan, chiPhi; // Lý do đổi
  final String ngayDiBaoDuong, tinhTrang, ngayDeXuatHoanThanh, nguoiDeXuatHoanThanh; // Nhà xe
  final String ngayHoanThanh, nguoiYeuCau, nguoiXacNhan, nguoiDiBaoDuong, nguoiXacNhanHoanThanh, noiDung, ketQua, soKM, tenDiaDiem;
  final VoidCallback onDongY; // Hành động khi bấm ĐỒNG Ý
  final bool isSelected, isBaoDuong, isDuyet, isYeuCau, isLenhHoanThanh, isHoanThanh; // Trạng thái tích chọn
  final VoidCallback onLongPress; // Xử lý khi nhấn giữ
  final VoidCallback isChiTiet; // Xử lý khi nhấn giữ
  final VoidCallback onTuChoi; // Hành động khi bấm TỪ CHỐI
  final VoidCallback onDongYHoanThanh; // Hành động khi bấm TỪ CHỐI

  const InfoColumn({
    Key? key,
    required this.onDongY,
    required this.bienSo1,
    required this.ngay,
    required this.noiDung,
    required this.ketQua,
    required this.soKM,
    required this.tenDiaDiem,
    required this.ngayXacNhan,
    required this.ngayDiBaoDuong,
    required this.ngayHoanThanh,
    required this.nguoiYeuCau,
    required this.nguoiXacNhan,
    required this.nguoiDiBaoDuong,
    required this.nguoiXacNhanHoanThanh,
    required this.tinhTrang,
    required this.isBaoDuong,
    required this.isDuyet,
    required this.isHoanThanh,
    required this.isYeuCau,
    required this.isSelected,
    required this.onLongPress,
    required this.isChiTiet,
    required this.onTuChoi,
    required this.ngayDeXuatHoanThanh,
    required this.nguoiDeXuatHoanThanh,
    required this.onDongYHoanThanh,
    required this.isLenhHoanThanh,
    required this.chiPhi,
    required this.danhSachHangMuc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !isDuyet ? onLongPress : null,
      child: Container(
        padding: const EdgeInsets.all(8.0), // Padding cho toàn bộ cột lớn
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.5) : Colors.white, // Màu nền cho cột lớn
          border: Border.all(color: Colors.grey.shade300), // Viền
          borderRadius: BorderRadius.circular(8), // Bo tròn góc
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  ngay,
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dòng dưới cùng: Lý do đổi
                SelectableText(
                  bienSo1, // Nội dung TD
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red, // Màu xám cho nội dung YC
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 30,
                  ),
              ],
            ),
            const SizedBox(height: 3),
            InfoRow(
              title: "Người yêu cầu:",
              contentYC: nguoiYeuCau,
            ),
            if (isDuyet) ...[
              InfoRow(
                title: "Ngày xác nhận:",
                contentYC: ngayXacNhan,
              ),
              InfoRow(
                title: "Người xác nhận:",
                contentYC: nguoiXacNhan,
              ),
            ],
            if (isBaoDuong) ...[
              InfoRow(
                title: "Ngày đi bảo dưỡng:",
                contentYC: ngayDiBaoDuong,
              ),
              InfoRow(
                title: "Người đi bảo dưỡng:",
                contentYC: nguoiDiBaoDuong,
              ),
            ],
            if (isLenhHoanThanh)
              InfoRow(
                title: "Ngày đề xuất hoàn thành:",
                contentYC: ngayDeXuatHoanThanh,
              ),
            if (isHoanThanh) ...[
              InfoRow(
                title: "Ngày hoàn thành:",
                contentYC: ngayHoanThanh,
              ),
              InfoRow(
                title: "Người xác nhận hoàn thành:",
                contentYC: nguoiXacNhanHoanThanh,
              ),
              InfoRow(
                title: "Ghi chú:",
                contentYC: ketQua,
              ),
              InfoRow(
                title: "Số KM hiện tại:",
                contentYC: soKM,
              ),
            ],
            if (isLenhHoanThanh)
              InfoRow(
                title: "Chi phí:",
                contentYC: chiPhi,
              ),
            CustomRichText(
              title: "Trạng thái",
              content: tinhTrang,
            ),
            InfoRow(
              title: "Danh sách hạng mục:",
              contentYC: danhSachHangMuc,
            ),
            Row(
              children: [
                // Dòng dưới cùng: Lý do đổi
                const Text(
                  "Nội dung bảo dưỡng:", // Nội dung YC
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black, // Màu xám cho nội dung YC
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.info,
                    color: Colors.blue,
                  ),
                  onPressed: isChiTiet,
                ),
              ],
            ),
            if (isYeuCau && !isDuyet)
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Căn sát phải
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor, // Màu nền
                        foregroundColor: AppConfig.textButton, // Màu chữ
                        textStyle: const TextStyle(
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13), // Bo góc
                        ),
                      ),
                      onPressed: onTuChoi, // Hành động TỪ CHỐI
                      child: const Text("TỪ CHỐI"),
                    ),
                  ),
                  const SizedBox(width: 10), // Khoảng cách giữa hai nút
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.popup, // Màu nền
                        foregroundColor: AppConfig.textButton, // Màu chữ
                        textStyle: const TextStyle(
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13), // Bo góc
                        ),
                      ),
                      onPressed: onDongY, // Hành động ĐỒNG Ý
                      child: const Text("DUYỆT"),
                    ),
                  ),
                ],
              ),
            if (isLenhHoanThanh && !isHoanThanh)
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Căn sát phải
                children: [
                  // Expanded(
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppConfig.primaryColor, // Màu nền
                  //       foregroundColor: AppConfig.textButton, // Màu chữ
                  //       textStyle: const TextStyle(
                  //         fontFamily: 'Comfortaa',
                  //         fontWeight: FontWeight.w700,
                  //         fontSize: 15,
                  //       ),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(13), // Bo góc
                  //       ),
                  //     ),
                  //     onPressed: onTuChoi, // Hành động TỪ CHỐI
                  //     child: const Text("TỪ CHỐI"),
                  //   ),
                  // ),
                  // const SizedBox(width: 10), // Khoảng cách giữa hai nút
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.popup, // Màu nền
                        foregroundColor: AppConfig.textButton, // Màu chữ
                        textStyle: const TextStyle(
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13), // Bo góc
                        ),
                      ),
                      onPressed: onDongYHoanThanh, // Hành động ĐỒNG Ý
                      child: const Text("DUYỆT"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title; // Tiêu đề: "Nhà xe:", "Biển số:", "Tài xế:"
  final String contentYC; // Nội dung yêu cầu (YC): item?.nhaXeYC, item?.bienSoYC, item?.taiXeYC

  const InfoRow({
    Key? key,
    required this.title,
    required this.contentYC,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần Tiêu đề và nội dung YC
        RichText(
          text: TextSpan(
            text: "$title ", // Tiêu đề
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black, // Màu đen cho tiêu đề
            ),
            children: [
              TextSpan(
                text: contentYC, // Nội dung YC
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey, // Màu xám cho nội dung YC
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3),
      ],
    );
  }
}

class CustomRichText extends StatelessWidget {
  final String title; // Tiêu đề (ví dụ: Người yêu cầu, Người xác nhận)
  final String content; // Nội dung (ví dụ: tên người yêu cầu, xác nhận)

  const CustomRichText({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "$title: ", // Hiển thị tiêu đề
        style: const TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black, // Màu đen cho tiêu đề
        ),
        children: [
          TextSpan(
            text: content, // Hiển thị nội dung
            style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                // color: title != "Lý do từ chối" ? Colors.grey : Colors.red, // Màu xám cho nội dung
                color: Colors.green),
          ),
        ],
      ),
    );
  }
}

Widget buildRichText(String title, String? data) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '🔹 $title ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold, // Tiêu đề đậm
            color: Colors.black, // Màu đen cho tiêu đề
          ),
        ),
        TextSpan(
          text: data ?? 'N/A',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold, // Dữ liệu bình thường
            color: Colors.blue, // Màu xanh cho dữ liệu
          ),
        ),
      ],
    ),
  );
}

class ItemNhapChiPhi extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const ItemNhapChiPhi({
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
            const SizedBox(width: 10), // Khoảng cách giữa title và text field
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
