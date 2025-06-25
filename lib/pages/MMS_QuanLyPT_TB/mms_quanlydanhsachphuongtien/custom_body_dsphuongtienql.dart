import 'dart:async';
import 'dart:convert';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../../blocs/user_bloc.dart';
import '../../../config/config.dart';
import '../../../models/diadiem.dart';
import '../../../models/kehoach.dart';
import '../../../models/kehoachgiaoxe_ls.dart';
import '../../../models/mms/baoduong.dart';
import '../../../models/mms/donvi.dart';
import '../../../models/mms/dsphuongtien.dart';
import '../../../models/mms/hangmuc.dart';
import '../../../models/mms/lichsubaoduong.dart';
import '../../../models/mms/tinhtrang.dart';
import '../../../services/app_service.dart';
import '../../../services/request_helper_mms.dart';
import '../../../widgets/loading.dart';
import '../quanlyphuongtien/quanlyphuongtien.dart';
import '../quanlyphuongtien_QLNew/quanlyphuongtien_map.dart';
import '../quanlyphuongtien_QLNew/quanlyphuongtien_qlnew.dart';

class CustomBodyDanhSachPhuongTienQL extends StatelessWidget {
  CustomBodyDanhSachPhuongTienQL();
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDanhSachPhuongTienQLScreen());
  }
}

class BodyDanhSachPhuongTienQLScreen extends StatefulWidget {
  const BodyDanhSachPhuongTienQLScreen({
    super.key,
  });

  @override
  _BodyDanhSachPhuongTienQLScreenState createState() => _BodyDanhSachPhuongTienQLScreenState();
}

class _BodyDanhSachPhuongTienQLScreenState extends State<BodyDanhSachPhuongTienQLScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();
  bool _loading = false;
  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  late UserBloc? _ub;
  bool _IsXacNhan = false;
  List<PhuongTienModel>? _kehoachList;
  List<PhuongTienModel>? get kehoachList => _kehoachList;
  LichSuBaoDuongNewModel? _data;
  List<bool> selectedItems = [];
  bool selectAll = false;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController soKhungController = TextEditingController();
  final TextEditingController _ghiChu = TextEditingController();
  final TextEditingController _chiphi = TextEditingController();
  Map<String, TextEditingController> chiphiControllers = {};
  String? body;
  List<KeHoachGiaoXeLSModel>? _kehoachlsList;
  List<KeHoachGiaoXeLSModel>? get kehoachlsList => _kehoachlsList;
  KeHoachModel? _thongbao;
  String? selectedDate;
  List<DiaDiemModel>? _dn;
  List<DiaDiemModel>? get dn => _dn;
  List<DonViModel>? _donvi;
  List<DonViModel>? get donvi => _donvi;
  List<TinhTrangModel>? _tinhtrang;
  List<TinhTrangModel>? get tinhtrang => _tinhtrang;
  String? DiaDiem_Id;
  String? DonVi_Id;
  String? TinhTrang_Id;
  List<HangMucModel>? _hangmucList;
  List<HangMucModel>? get hangmucList => _hangmucList;
  List<HangMucModel>? _hangmucListnew;
  List<HangMucModel>? get hangmucListnew => _hangmucListnew;
  List<HangMucModel>? _hangmucListall;
  List<HangMucModel>? get hangmucListall => _hangmucListall;
  List<HangMucModel>? _hangmucList2;
  List<HangMucModel>? get hangmucList2 => _hangmucList2;
  List<dynamic> _selectedItems = [];
  List<dynamic> _selectedItemsnew = [];
  bool _IsTuChoi = false;
  String? _previousPhuongTienId;
  double _tongChiPhi = 0.0;
  final formatter = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    getDonVi();
    getDiaDiem();
    getTinhTrang();
    getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);
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

  Future<void> getListChiTietHangMuc(String? listIds, StateSetter dialogSetState) async {
    print("data:${listIds}");
    _isLoading = true;
    dialogSetState(() {});
    // Làm sạch danh sách cũ trước khi tải mới
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuongChiTietTheoPT?BaoDuong_Id=$listIds');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          _hangmucList = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
          // Gọi setState để cập nhật giao diện

          dialogSetState(() {
            _selectedItems = List.from(_hangmucList ?? []);
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
    print("datamms:${phuongTien_Id}");
    _isLoading = true;
    dialogSetState(() {});
    // Làm sạch danh sách cũ trước khi tải mới
    try {
      final http.Response response = await requestHelper.getData('MMS_ThongTinTheoHangMuc/DSHangMucYeuCau?Id_PhuongTien=$phuongTien_Id');
      print("datamms5:${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          _hangmucListnew = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
          // Gọi setState để cập nhật giao diện

          dialogSetState(() {
            _selectedItemsnew = List.from(_hangmucListnew!.where((item) => item.isDenHan == true));
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

  Future<void> getHangMuc(String? phuongTien_Id, StateSetter dialogSetState) async {
    print("datahangmuchang");
    _loading = true;
    dialogSetState(() {});
    try {
      final http.Response response = await requestHelper.getData('MMS_ThongTinTheoHangMuc/DSHangMuc?Id_PhuongTien=$phuongTien_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _hangmucListall = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
        setState(() {
          _selectedItems = List.from(_hangmucListall!.where((item) => item.isDenHan == true));
          _loading = false;
        });
        dialogSetState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("datahangmuc:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> getTinhTrang() async {
    _tinhtrang = [];
    try {
      final http.Response response = await requestHelper.getData('MMS_DM_TinhTrang/TinhTrang');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          print("DataTinhTrang:${decodedData}");
          _tinhtrang = (decodedData as List).map((item) => TinhTrangModel.fromJson(item)).toList();
          _tinhtrang!.insert(0, TinhTrangModel(id: '', name: 'Tất cả'));
          setState(() {
            TinhTrang_Id = '';
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getDonVi() async {
    _donvi = [];
    try {
      final http.Response response = await requestHelper.getData('MMS_DM_DonVi/DonViMaster');
      print("DataDonVi:${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("DataDonVi:${decodedData}");
        if (decodedData != null) {
          _donvi = (decodedData as List).map((item) => DonViModel.fromJson(item)).toList();
          _donvi!.insert(0, DonViModel(id: '', tenDonVi: 'Tất cả'));
          setState(() {
            DonVi_Id = "";
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
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

  Future<void> getListThayDoiKHDiGap() async {
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/DanhSachYeuCau');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachlsList = (decodedData as List).map((item) => KeHoachGiaoXeLSModel.fromJson(item)).toList();

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

  Future<void> getBienSo(String? donVi_Id, String? tinhTrang_Id, String? keyword) async {
    _loading = true;
    try {
      final http.Response response = await requestHelper.getData('MMS_DS_PhuongTien/All?DonVi_Id=$donVi_Id&TinhTrang_Id=$tinhTrang_Id&keyword=$keyword');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _kehoachList = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).toList();
        setState(() {
          selectedItems = List.filled(_kehoachList?.length ?? 0, false);
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("databienso2:${e.toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> postDataDuyet(LichSuBaoDuongNewModel scanData, String? ngayDiBaoDuong, List<String> selectedIds) async {
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
        // await getListThayDoiKH(widget.id, soKhungController.text);
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

  Future<void> postDataHuyDuyet(LichSuBaoDuongNewModel? scanData, String? baoDuong_Id, String? liDo) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;
      var dataList = newScanData;
      final http.Response response = await requestHelper.postData('MMS_BaoCao/HuyXacNhanYeuCau?id=$baoDuong_Id&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}', dataList?.toJson());
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

  Future<void> postDataList(
    List<LichSuBaoDuongModel> dataList,
  ) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('MMS_BaoCao/XacNhanYeuCauList?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}', dataList.map((item) => item.toJson()).toList());
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
              }
              if (_textController.text != "") {
                Navigator.of(context).pop();
                setState(() {
                  _textController.text = "";
                });
              }
            });
        _btnController.reset();
        // await getListThayDoiKH(widget.id, soKhungController.text);
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

  _onSaveXacNhan(int index, List<dynamic> selectedItems) async {
    setState(() {
      _loading = true;
    });
    List<String> selectedIds = selectedItems.map((e) => e.hangMuc_Id.toString()).toList();
    print("Danh sách ID đã chọn: $selectedIds");
    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    print("ngay = ${selectedDate}");
    _data ??= LichSuBaoDuongNewModel();
    _data?.id = item?.lichSuBaoDuong_Id;
    _data?.phuongTien_Id = item?.id;
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
        postDataDuyet(_data!, selectedDate, selectedIds).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            selectedIds = [];
            getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);
            postDataFireBase(_thongbao, body ?? "", _data?.nguoiYeuCau ?? "", item?.id);
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
    _data ??= LichSuBaoDuongNewModel();
    _data?.id = item?.lichSuBaoDuong_Id;

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
        postDataHuy(_data!, _textController.text).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  _onSaveHuyDuyet(int index) async {
    setState(() {
      _loading = true;
    });

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongNewModel();
    _data?.id = item?.lichSuBaoDuong_Id;

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
        postDataHuyDuyet(_data!, item?.lichSuBaoDuong_Id ?? "", _textController.text).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  _onSaveList(List<int> selectedIndexes) async {
    setState(() {
      _loading = true;
    });

    if (selectedIndexes.isEmpty) {
      return;
    }
    // Lặp qua từng chỉ mục đã chọn
    List<LichSuBaoDuongModel> selectedItemsData = [];
    for (int index in selectedIndexes) {
      final item = _kehoachList?[index];
      if (item != null) {
        LichSuBaoDuongModel requestData = LichSuBaoDuongModel(id: item.lichSuBaoDuong_Id, soKM: item.soKM, phuongTien_Id: item.id, diaDiem_Id: DiaDiem_Id);
        selectedItemsData.add(requestData);
      }
    }
    print("so luong = ${selectedItemsData.length}");

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
        postDataList(selectedItemsData).then((_) {
          setState(() {
            _data = null;
            _IsTuChoi = false;
            _IsXacNhan = false;
            getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);

            // _textController.text = "";
            // getListThayDoiKH(widget.id, soKhungController.text);
            for (var item in selectedItemsData) {
              postDataFireBase(_thongbao, body ?? "", item.nguoiYeuCau ?? "", item.phuongTien_Id ?? "");
            }
            _loading = false;
            selectAll = false;
          });
        });
      }
    });
  }

  void _approveSelectedItems() {
    print("test");
    List<int> selectedIds = [];
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        selectedIds.add(i);
      }
    }
    if (selectedIds.isNotEmpty) {
      print("test2 ${selectedIds}");
      // Gọi API duyệt
      _showConfirmationDialog(context, selectedIds);
    }
  }

  void _showConfirmationDialog(BuildContext context, List<int> selectedIds) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có chắc chắn duyệt danh sách này không?',
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
          _onSaveList(selectedIds);
        });
  }

  Future<void> postDataHoanThanh(LichSuBaoDuongNewModel? scanData, List<Map<String, dynamic>> danhSachChiPhi, int? tongChiPhiBD, int? tongChiPhiSC) async {
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

      final http.Response response = await requestHelper.postData('MMS_BaoCao/HoanThanhBaoDuong?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&TongChiPhiBD=$tongChiPhiBD&TongChiPhiSC=$tongChiPhiSC', requestBody);

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
              Navigator.pop(context);
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
        );
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  _onSaveHoanThanh(String? id, String? phuongTien_Id, String? chiPhiBD, String? chiPhiSC) async {
    setState(() {
      _loading = true;
    });
    List<String> imageUrls = [];
    int? tongChiPhiSC;

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
    int? tongChiPhiBD = int.parse(chiPhiBD!.replaceAll(RegExp(r'[.,]'), ""));

    if (chiPhiSC != "") {
      tongChiPhiSC = int.parse(chiPhiSC!.replaceAll(RegExp(r'[.,]'), ""));
    }

    // final item = _kehoachList?[index];
    print("data kehoach = ${id}");
    _data ??= LichSuBaoDuongNewModel();
    _data?.id = id;
    _data?.noiDung = textEditingController.text;
    _data?.ketQua = _ghiChu.text;
    _data?.hinhAnh = imageUrlsString;
    List<Map<String, dynamic>> danhSachChiPhi = [];
    for (var hangmuc in _hangmucList ?? []) {
      String chiPhiText = chiphiControllers[hangmuc.hangMuc_Id!]?.text ?? "0";
      int chiPhiValue = int.parse(chiPhiText.replaceAll(RegExp(r'[.,]'), ""));
      // int chiPhiValue = int.parse(chiPhiText);
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
        postDataHoanThanh(_data!, danhSachChiPhi, tongChiPhiBD, tongChiPhiSC).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            _textController.text = '';
            textEditingController.text = '';
            _ghiChu.text = '';
            getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);
            postDataFireBase(_thongbao, body ?? "", _data?.nguoiYeuCau ?? "", phuongTien_Id ?? "");
            _data = null;
            _hangmucList = [];
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogHoanThanh(BuildContext context, String? id, String? phuongTien_Id, String? chiphiBD, String? chiphiSC) {
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
          _onSaveHoanThanh(id, phuongTien_Id ?? "", chiphiBD, chiphiSC);
        });
  }

  void _showDetailsDialog2(BuildContext context, String? id, String? ghiChu, String? soKM, String? phuongTien_Id, String? tongChiPhi, String? chiPhiBD, String? chiPhiSC, String? vatTu) {
    final baoduongId = id;
    final TextEditingController _tongChiPhiBD = TextEditingController(text: chiPhiBD ?? "0");
    final TextEditingController _tongChiPhiSC = TextEditingController(text: chiPhiSC ?? "0");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_hangmucList == null || _hangmucList!.isEmpty) {
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
            //     _updateTongChiPhi(setState,_tongChiPhiBD,_tongChiPhiSC);
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
                              _hangmucList = [];
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                          ItemGhiChu(
                                            title: 'Vật tư thay thế: ',
                                            content: vatTu ?? "",
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
                                          //           decoration: const InputDecoration(
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
                            onPressed: () => _showConfirmationDialogHoanThanh(context, id, phuongTien_Id, _tongChiPhiBD.text, _tongChiPhiSC.text),
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

  void _showConfirmationDialogHuy(BuildContext context, String? bienSo1, int index) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn huỷ yêu cầu ${bienSo1} này không?',
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
          _onSaveHuy(index);
        });
  }

  void _showConfirmationDialogHuyDuyet(BuildContext context, String? bienSo1, int index) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn huỷ duyệt phương tiện ${bienSo1} không?',
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
          _onSaveHuyDuyet(index);
        });
  }

  void _showConfirmationDialogYeuCau2(BuildContext context, int index) {
    final baoduongId = _kehoachList?[index].id;
    final bienSo1 = _kehoachList?[index].bienSo1;
    final image = _kehoachList?[index]?.hinhAnh;

    DiaDiem_Id = _kehoachList?[index].diaDiem_Id;
    selectedDate = _kehoachList?[index].ngayDiBaoDuong;
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
              text: _selectedItemsnew.map((e) => e.noiDungBaoDuong).join(', '),
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
                            onPressed: () => {Navigator.pop(context)},
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
                                      body: QuanLyPhuongTienQLNewPage_Map(id: baoduongId, tabIndex: 0),
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
                          _showHangMucPopup2(context, setStateDialog, _selectedController);
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
                              onPressed: (selectedDate != null && DiaDiem_Id != null) ? () => _onSaveXacNhan(index, _selectedItemsnew) : null,
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

  Widget _buildTableOptions(BuildContext context) {
    int index = 0;
    const String defaultDate = "1970-01-01 ";
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedItems.contains(true))
              ElevatedButton(
                onPressed: () {
                  int selectedCount = selectedItems.where((item) => item).length;
                  int selectedIndex = selectedItems.indexWhere((item) => item);
                  if (selectedCount == 1) {
                    _showConfirmationDialogYeuCau2(context, selectedIndex); // Gọi hàm khác nếu chỉ có 1 item được chọn
                  } else {
                    _approveSelectedItems(); // Gọi hàm này nếu có từ 2 item trở lên
                  }
                },
                child: Text("Duyệt (${selectedItems.where((item) => item).length})"),
              ),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(0.2),
                1: FlexColumnWidth(0.15),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.2),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
                7: FlexColumnWidth(0.3),
                8: FlexColumnWidth(0.3),
                9: FlexColumnWidth(0.3),
                10: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Hành động', textColor: Colors.white),
                    ),
                    // Container(color: Colors.red, child: _buildTableCell('Duyệt', textColor: Colors.white)),
                    // Container(color: Colors.red, child: _buildTableCell('Duyệt hoàn thành', textColor: Colors.white)),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Chi tiết', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Trạng thái', textColor: Colors.white),
                    ),

                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Biến số 1', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Biến số 2', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Số khung', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Model', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Model_Option', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người phụ trách', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Mã nhân viên', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Đơn vị', textColor: Colors.white),
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
                    0: FlexColumnWidth(0.2),
                    1: FlexColumnWidth(0.15),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.2),
                    5: FlexColumnWidth(0.3),
                    6: FlexColumnWidth(0.3),
                    7: FlexColumnWidth(0.3),
                    8: FlexColumnWidth(0.3),
                    9: FlexColumnWidth(0.3),
                    10: FlexColumnWidth(0.3),
                  },
                  children: [
                    // Chiều cao cố định
                    ..._kehoachList?.asMap().entries.map((entry) {
                          // index++; // Tăng số thứ tự sau mỗi lần lặp
                          int index = entry.key; // Lấy chỉ mục chính xác
                          var item = entry.value;
                          bool isEligible = item.isDenHan == true && item.isYeuCau == false;
                          bool isDuyet = item.isYeuCau == true && item.isDuyet == false;
                          bool isDuyet2 = item.isDuyet == true;
                          bool isDaDuyet = item.isBaoDuong == false;
                          bool isDuyetHoanThanh = item.isLenhHoanThanh == true && item.isHoanThanh == false;
                          bool isHoanThanh = item.isHoanThanh == true;
                          return TableRow(
                            decoration: BoxDecoration(
                              color: isEligible ? Colors.red.withOpacity(0.3) : null, // Nền đỏ nếu đủ điều kiện
                            ),
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự

                              Container(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  children: [
                                    if (isEligible)
                                      Checkbox(
                                        value: item.isYeuCau ?? false,
                                        onChanged: isEligible
                                            ? (bool? newValue) {
                                                setState(() {
                                                  _showConfirmationDialogYeuCau(context, item.id, item.model_Id, item.soKM, item.bienSo1);
                                                });
                                              }
                                            : null, // Nếu không đủ điều kiện, disable checkbox
                                        activeColor: item.isYeuCau == true
                                            ? Colors.green // Nếu đã duyệt, màu xanh
                                            : Colors.grey, // Nếu chưa chọn, màu xám
                                      ),
                                    if (isDaDuyet)
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: isHoanThanh && isEligible
                                                  ? false // Nếu đã hoàn thành, checkbox trống (không tick)
                                                  // : (isDuyet2 ? true : (index < selectedItems.length ? selectedItems[index] : false)),
                                                  : (isDuyet2 ? true : (index < selectedItems.length ? selectedItems[index] : false)),

                                              onChanged: isDaDuyet
                                                  ? (bool? newValue) {
                                                      if (isDuyet2) {
                                                        // Nếu đã duyệt (màu xanh), bỏ tick thì hỏi xác nhận hủy
                                                        if (newValue == false) {
                                                          _showConfirmationDialogHuyDuyet(context, item.bienSo1, index);
                                                        }
                                                      } else {
                                                        // Nếu chưa duyệt (màu đỏ), cho phép tick/bỏ tick ngay lập tức
                                                        setState(() {
                                                          // selectedItems[index] = newValue!;
                                                          _showConfirmationDialogYeuCau2(context, index);
                                                        });
                                                      }
                                                    }
                                                  : null,
                                              activeColor: isDuyet2
                                                  ? Colors.green // Nếu đã duyệt, màu xanh
                                                  : selectedItems[index]
                                                      ? Colors.blue // Nếu đang chọn mà chưa duyệt, màu đỏ
                                                      : Colors.grey, // Nếu chưa chọn, màu xám
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close, color: isDuyet ? Colors.red : Colors.grey),
                                              onPressed: isDuyet
                                                  ? () {
                                                      _showConfirmationDialogHuy(context, item.bienSo1, index); // Hàm mở popup
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (isDuyetHoanThanh)
                                      Checkbox(
                                        value: isHoanThanh && isEligible ? false : (isHoanThanh ? true : false),
                                        onChanged: isDuyetHoanThanh
                                            ? (bool? newValue) {
                                                setState(() {
                                                  _showDetailsDialog2(context, item.lichSuBaoDuong_Id, item.ghiChu, item.soKM, item.id, item.tongChiPhi, item.chiPhiBD2, item.chiPhiSC2, item.vatTuThayThe);
                                                });
                                              }
                                            : null, // Nếu không đủ điều kiện, disable checkbox
                                        activeColor: item.isHoanThanh == true
                                            ? Colors.green // Nếu đã duyệt, màu xanh
                                            : Colors.grey, // Nếu chưa chọn, màu xám
                                      ),
                                  ],
                                ),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.info,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  nextScreen(context, QuanLyPhuongTienQLNewPage(id: item.id, tabIndex: 2));
                                },
                              ),
                              _buildTableCell(item.tinhTrang ?? ""),
                              _buildTableCell(
                                item.bienSo1 ?? "",
                              ),
                              _buildTableCell(item.bienSo2 ?? ""),
                              _buildTableCell(item.soKhung ?? ""),
                              _buildTableCell(item.model ?? ""),
                              _buildTableCell(item.model_Option ?? ""),
                              _buildTableCell(item.nguoiPhuTrach ?? ""),
                              _buildTableCell(item.maNhanVien ?? ""),
                              _buildTableCell(item.donViSuDung ?? ""),
                              // _buildTableCell2(item.tinhTrang ?? "", item.id ?? ""),
                              // _buildTableCell2(item.bienSo1 ?? "", item.id ?? ""),
                              // _buildTableCell2(item.bienSo2 ?? "", item.id ?? ""),
                              // _buildTableCell2(item.soKhung ?? "", item.id ?? ""),
                              // _buildTableCell2(item.model ?? "", item.id ?? ""),
                              // _buildTableCell2(item.model_Option ?? "", item.id ?? ""),
                              // _buildTableCell2(item.nguoiPhuTrach ?? "", item.id ?? ""),
                              // _buildTableCell2(item.maNhanVien ?? "", item.id ?? ""),
                              // _buildTableCell2(item.donViSuDung ?? "", item.id ?? ""),
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

  Future<void> postDataFireBase(KeHoachModel? scanData, String? body, String? nguoiYeuCau, String? id) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      final http.Response response = await requestHelper.postData('MMS_Notification/PushThongBao?body=$body&NguoiYeuCau=$nguoiYeuCau&listIds=$id', newScanData?.toJson());
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

  _onSave(String? id, String? baoduong_Id, String? soKM, List<dynamic> selectedItems) async {
    setState(() {
      _loading = true;
    });
    List<String> selectedIds = selectedItems.map((e) => e.hangMuc_Id.toString()).toList();
    print("Danh sách ID đã chọn: $selectedIds");
    print("data kehoach = ${id}");
    print("ngay = ${selectedDate}");
    _data ??= LichSuBaoDuongNewModel();
    _data?.id = id;
    _data?.phuongTien_Id = id;
    _data?.baoDuong_Id = baoduong_Id;
    _data?.soKM = soKM;

    _data?.diaDiem_Id = DiaDiem_Id;

    if (_IsXacNhan == true) {
      _data?.trangThai = "1";
    }

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
        postData(_data!, selectedIds, selectedDate).then((_) {
          setState(() {
            _IsXacNhan = false;
            getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);
            postDataFireBase(_thongbao, body ?? "", _data?.nguoiYeuCau ?? "", _data?.phuongTien_Id ?? "");
            _data = null;
            DiaDiem_Id = null;
            id = null;
            baoduong_Id = null;
            soKM = null;
            _loading = false;
          });
        });
      }
    });
  }

  Future<void> postData(LichSuBaoDuongNewModel? scanData, List<String> selectedIds, String? ngay) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;

      var dataList = [newScanData];
      final http.Response response = await requestHelper.postData('MMS_BaoCao/YeuCauBaoDuong_QuanLy?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&NgayDiBaoDuong=$ngay&ids=${selectedIds.join("&ids=")}', dataList.map((e) => e?.toJson()).toList());
      print("statusCode: ${response.statusCode}");
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
        _btnController.reset();
        // await getListThayDoiKH(widget.id, soKhungController.text);
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

  void _showConfirmationDialogYeuCau(BuildContext context, String? id, String? baoduong_Id, String? soKM, String? bienSo1) {
    final phuongTienId = id;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            if (_hangmucListall == null || _hangmucListall!.isEmpty) {
              getHangMuc(phuongTienId ?? "", setStateDialog);
            }

            if (_previousPhuongTienId != phuongTienId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = phuongTienId;
              getHangMuc(phuongTienId ?? "", setStateDialog);
            }
            TextEditingController _selectedController = TextEditingController(
              text: _selectedItems.map((e) => e.noiDungBaoDuong).join(', '),
            );
            // Sử dụng StateSetter để cập nhật UI trong dialog
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yêu cầu bảo dưỡng phương tiện ${bienSo1}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
                              color: Colors.blue,
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
                            onPressed: (selectedDate != null && DiaDiem_Id != null) ? () => _onSave(id, baoduong_Id, soKM, _selectedItems) : null,
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

  void _showHangMucPopup(BuildContext context, StateSetter parentSetState, TextEditingController controller) {
    String searchTerm2 = '';
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn bấm ra ngoài để đóng
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            final filteredList2 = _hangmucListall!.where((item) => searchTerm2.isEmpty || (item.noiDungBaoDuong?.toLowerCase().contains(searchTerm2.toLowerCase()) ?? false)).toList();
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
                          const Text(
                            "Chọn hạng mục bảo dưỡng",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm hạng mục...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          searchTerm2 = value;
                        });
                      },
                    ),
                    Divider(),
                    // Nội dung danh sách checkbox
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: filteredList2!.map((item) {
                              bool isChecked = _selectedItems.any((e) => e.hangMuc_Id == item.hangMuc_Id);
                              return CheckboxListTile(
                                title: Text(item.noiDungBaoDuong ?? ""),
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

  Widget _buildPaginatedTable(BuildContext context) {
    final list = _kehoachList ?? <PhuongTienModel>[];
    final dataSource = KeHoachDataSource(
      list,
      selectedItems,
      (index) {
        nextScreen(context, QuanLyPhuongTienQLNewPage(id: _kehoachList?[index].id, tabIndex: 2));
      },
      (index) {
        _showConfirmationDialogYeuCau(context, _kehoachList?[index].id, _kehoachList?[index].model_Id, _kehoachList?[index].soKM, _kehoachList?[index].bienSo1);
      },
      (index) {
        _showConfirmationDialogYeuCau2(context, index);
      },
      (index) {
        _showConfirmationDialogHuy(context, _kehoachList?[index].bienSo1, index);
      },
      (index) {
        final item = _kehoachList?[index];
        _showDetailsDialog2(context, item?.lichSuBaoDuong_Id, item?.ghiChu, item?.soKM, item?.id, item?.tongChiPhi, item?.chiPhiBD2, item?.chiPhiSC2, item?.vatTuThayThe);
      },
      (index) {
        _showConfirmationDialogHuyDuyet(context, _kehoachList?[index].bienSo1, index);
      },
    );

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(surface: Colors.white),
        dataTableTheme: DataTableThemeData(
          // header nền đỏ, chữ trắng
          headingRowColor: MaterialStateProperty.all(Colors.red),
          headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          // body nền trắng, chữ đen
          dataRowColor: MaterialStateProperty.all(Colors.white),
          dataTextStyle: TextStyle(color: Colors.black),
          // kẻ ngang giữa các row
          dividerThickness: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedItems.contains(true))
            ElevatedButton(
              onPressed: () {
                int selectedCount = selectedItems.where((item) => item).length;
                int selectedIndex = selectedItems.indexWhere((item) => item);
                if (selectedCount == 1) {
                  _showConfirmationDialogYeuCau2(context, selectedIndex);
                } else {
                  _approveSelectedItems();
                }
              },
              child: Text("Duyệt (${selectedItems.where((item) => item).length})"),
            ),
          PaginatedDataTable(
            columns: const [
              DataColumn(label: Text('STT')),
              DataColumn(label: Text('Hành động')),
              DataColumn(label: Text('Chi tiết')),
              DataColumn(label: Text('Trạng thái')),
              DataColumn(label: Text('Biển số 1')),
              DataColumn(label: Text('Biển số 2')),
              DataColumn(label: Text('Số khung')),
              DataColumn(label: Text('Model')),
              DataColumn(label: Text('Model_Option')),
              DataColumn(label: Text('Người phụ trách')),
              DataColumn(label: Text('Mã nhân viên')),
              DataColumn(label: Text('Đơn vị')),
            ],
            source: dataSource,
            rowsPerPage: 10,
            showCheckboxColumn: false,
            columnSpacing: 20,
          ),
        ],
      ),
    );
  }

  void _showHangMucPopup2(BuildContext context, StateSetter parentSetState, TextEditingController controller) {
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
                            icon: Icon(Icons.close, color: Colors.black),
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
                                bool isChecked = _selectedItemsnew.any((e) => e.hangMuc_Id == item.hangMuc_Id);
                                return CheckboxListTile(
                                  title: Text(item.noiDungBaoDuong ?? "",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold, // Tiêu đề đậm
                                          color: Colors.blue)), // Màu đen cho tiêu đề),
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
                                        _selectedItemsnew.add(item);
                                      } else {
                                        _selectedItemsnew.removeWhere((e) => e.hangMuc_Id == item.hangMuc_Id);
                                      }
                                    });

                                    // Cập nhật UI của dialog chính
                                    parentSetState(() {
                                      controller.text = _selectedItemsnew.map((e) => e.noiDungBaoDuong).join(', ');
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
                                bool isChecked = _selectedItemsnew.any((e) => e.hangMuc_Id == item.hangMuc_Id);
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
                                        _selectedItemsnew.add(item);
                                      } else {
                                        _selectedItemsnew.removeWhere((e) => e.hangMuc_Id == item.hangMuc_Id);
                                      }
                                    });

                                    // Cập nhật UI của dialog chính
                                    parentSetState(() {
                                      controller.text = _selectedItemsnew.map((e) => e.noiDungBaoDuong).join(', ');
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

  Widget _buildTableCell2(String content, String? id, {Color textColor = Colors.black}) {
    return TableCell(
      child: InkWell(
        onTap: () {
          debugPrint('Tapped:');
          nextScreen(context, QuanLyPhuongTienQLNewPage(id: id));
        },
        child: Container(
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : RefreshIndicator(
            onRefresh: () async {
              await getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);
            },
            child: Container(
              child: Column(
                children: [
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
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                              "Đơn vị sử dụng",
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
                                                  items: _donvi?.map((item) {
                                                    return DropdownMenuItem<String>(
                                                      value: item.id,
                                                      child: Container(
                                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                        child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Text(
                                                            item.tenDonVi ?? "",
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
                                                  value: DonVi_Id,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      DonVi_Id = newValue;
                                                    });
                                                    if (newValue != null) {
                                                      if (newValue == '') {
                                                        getBienSo("", TinhTrang_Id ?? "", soKhungController.text);
                                                      } else {
                                                        getBienSo(newValue, TinhTrang_Id ?? "", soKhungController.text);
                                                        print("objectcong : ${newValue}");
                                                      }
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
                                                          hintText: 'Tìm đơn vị',
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
                                                        return _donvi?.any((baiXe) => baiXe.id == itemId && baiXe.tenDonVi?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                  SizedBox(
                                    height: 5,
                                  ),
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
                                              "Tình trạng",
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
                                                  items: _tinhtrang?.map((item) {
                                                    return DropdownMenuItem<String>(
                                                      value: item.id,
                                                      child: Container(
                                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                        child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Text(
                                                            item.name ?? "",
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
                                                  value: TinhTrang_Id,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      TinhTrang_Id = newValue;
                                                    });
                                                    if (newValue != null) {
                                                      if (newValue == '') {
                                                        getBienSo(DonVi_Id ?? "", "", soKhungController.text);
                                                      } else {
                                                        getBienSo(DonVi_Id ?? "", newValue, soKhungController.text);
                                                        print("objectcong : ${newValue}");
                                                      }
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
                                                          hintText: 'Tìm tình trạng',
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
                                                        return _tinhtrang?.any((baiXe) => baiXe.id == itemId && baiXe.name?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                  SizedBox(
                                    height: 5,
                                  ),
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
                                          child: const Center(
                                            child: Text(
                                              "Tìm kiếm",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppConfig.textInput,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                            child: TextField(
                                              controller: soKhungController,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: 'Tìm theo biển số, nhân viên',
                                                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                              ),
                                              style: const TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.search),
                                          onPressed: () {
                                            setState(() {
                                              _loading = true;
                                            });
                                            // Gọi API với từ khóa tìm kiếm
                                            getBienSo(DonVi_Id ?? "", TinhTrang_Id ?? "", soKhungController.text);
                                            setState(() {
                                              _loading = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Danh sách phương tiện: ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "${_kehoachList?.length.toString() ?? ""}",
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // _buildTableOptions(context),
                                  _buildPaginatedTable(context)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

class InfoColumn extends StatelessWidget {
  final String bienSo1, soKhung;
  final String model; // Thời gian yêu cầu
  final String lyDo; // Lý do đổi
  final String model_Option; // Nhà xe
  final String soKM_Adsun, soKM, giaTri, id;
  final bool isDenHan, isYeuCau;
  final VoidCallback onDongY;

  const InfoColumn({
    Key? key,
    required this.isDenHan,
    required this.soKhung,
    required this.lyDo,
    required this.bienSo1,
    required this.model,
    required this.model_Option,
    required this.soKM_Adsun,
    required this.soKM,
    required this.id,
    required this.isYeuCau,
    required this.giaTri,
    required this.onDongY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0), // Padding cho toàn bộ cột lớn
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền cho cột lớn
        border: Border.all(
          color: isDenHan && !isYeuCau ? Colors.red : Colors.grey.shade300,
          width: isDenHan && !isYeuCau ? 2.0 : 1.0,
        ), // Viền
        borderRadius: BorderRadius.circular(8), // Bo tròn góc
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  nextScreen(context, QuanLyPhuongTienPage(id: id));
                },
              ),
            ],
          ),

          // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
          InfoRow(
            title: "Số khung:",
            contentYC: soKhung,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Model:",
            contentYC: model,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Model_Option:",
            contentYC: model_Option,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Số KM theo Adsun:",
            contentYC: soKM_Adsun,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Số KM theo xe:",
            contentYC: soKM,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Số KM đến hạn:",
            contentYC: giaTri,
          ),
          if (isDenHan && !isYeuCau)
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn sát phải
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0), // Khoảng cách trên nút
                  child: Container(
                    width: 55.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.popup, // Màu nền
                        foregroundColor: AppConfig.textButton, // Màu chữ
                        textStyle: const TextStyle(
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13), // Bo góc
                        ),
                      ),
                      onPressed: onDongY, // Hành động ĐỒNG Ý
                      child: const Text("YÊU CẦU BẢO DƯỠNG"),
                    ),
                  ),
                ),
              ],
            ),
        ],
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
      ],
    );
  }
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

class KeHoachDataSource extends DataTableSource {
  final List<PhuongTienModel> keHoachList;
  final List<bool> selectedItems;
  final Function(int index) onChiTietClick;
  final Function(int index) onDuyet1;
  final Function(int index) onDuyet2;
  final Function(int index) onHuy;
  final Function(int index) onHoanThanh;
  final Function(int index) onHuyDuyet;

  KeHoachDataSource(
    this.keHoachList,
    this.selectedItems,
    this.onChiTietClick,
    this.onDuyet1,
    this.onDuyet2,
    this.onHuy,
    this.onHoanThanh,
    this.onHuyDuyet,
  );

  @override
  DataRow getRow(int index) {
    final item = keHoachList[index];
    bool isEligible = item.isDenHan == true && item.isYeuCau == false;
    bool isDuyet = item.isYeuCau == true && item.isDuyet == false;
    bool isDuyet2 = item.isDuyet == true;
    bool isDaDuyet = item.isBaoDuong == false;
    bool isDuyetHoanThanh = item.isLenhHoanThanh == true && item.isHoanThanh == false;
    bool isHoanThanh = item.isHoanThanh == true;
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(
          (index + 1).toString(),
          textAlign: TextAlign.center,
        )), // STT
        DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEligible)
              Checkbox(
                value: item.isYeuCau ?? false,
                onChanged: (val) => onDuyet1(index),
                activeColor: item.isYeuCau == true ? Colors.green : Colors.grey,
              ),
            if (isDaDuyet)
              Row(
                children: [
                  Checkbox(
                    value: isHoanThanh && isEligible ? false : (isDuyet2 ? true : selectedItems[index]),
                    onChanged: (val) {
                      if (isDuyet2 && val == false) {
                        onHuyDuyet(index);
                      } else {
                        onDuyet2(index);
                      }
                    },
                    activeColor: isDuyet2
                        ? Colors.green
                        : selectedItems[index]
                            ? Colors.blue
                            : Colors.grey,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDuyet ? Colors.red : Colors.grey),
                    onPressed: isDuyet ? () => onHuy(index) : null,
                  ),
                ],
              ),
            if (isDuyetHoanThanh)
              Checkbox(
                value: isHoanThanh,
                onChanged: (val) => onHoanThanh(index),
                activeColor: isHoanThanh ? Colors.green : Colors.grey,
              ),
          ],
        )),
        DataCell(IconButton(
          icon: Icon(Icons.info, color: Colors.blue),
          onPressed: () => onChiTietClick(index),
        )),
        DataCell(Text(item.tinhTrang ?? '')),
        DataCell(Text(item.bienSo1 ?? '')),
        DataCell(Text(item.bienSo2 ?? '')),
        DataCell(Text(item.soKhung ?? '')),
        DataCell(Text(item.model ?? '')),
        DataCell(Text(item.model_Option ?? '')),
        DataCell(Text(item.nguoiPhuTrach ?? '')),
        DataCell(Text(item.maNhanVien ?? '')),
        DataCell(Text(item.donViSuDung ?? '')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => keHoachList.length;

  @override
  int get selectedRowCount => selectedItems.where((e) => e).length;
}

Widget _cellWithBorder(Widget child) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      border: Border(
        right: BorderSide(color: Colors.black, width: 1), // viền đen
      ),
    ),
    child: child,
  );
}
