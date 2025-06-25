import 'dart:convert';

import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/services/request_helper_mms.dart';
import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../../models/kehoach.dart';
import '../../../models/kehoachgiaoxe_ls.dart';
import '../../../models/mms/lichsubaoduong.dart';
import '../../../models/mms/lichsubaoduong_LS.dart';
import '../../../services/app_service.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_title.dart';

class DSBaoDuongPage extends StatefulWidget {
  const DSBaoDuongPage({super.key});

  @override
  State<DSBaoDuongPage> createState() => _DSBaoDuongPage();
}

class _DSBaoDuongPage extends State<DSBaoDuongPage> with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();
  TabController? _tabController;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? _errorCode;
  String? get errorCode => _errorCode;

  List<LichSuBaoDuongModel>? _kehoachList;
  List<LichSuBaoDuongModel>? get kehoachList => _kehoachList;
  List<LichSuBaoDuongLSModel>? _kehoachlsList;
  List<LichSuBaoDuongLSModel>? get kehoachlsList => _kehoachlsList;
  bool _loading = false;
  final _qrDataController = TextEditingController();
  LichSuBaoDuongModel? _data;
  KeHoachGiaoXeLSModel? _datals;

  String? barcodeScanResult;
  String? viTri;

  String? id;

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  bool _IsTuChoi = false;
  bool _IsXacNhan = false;
  List<String> noiDenList = [];

  String? bienSo;

  List<bool> selectedItems = [];
  bool selectAll = false;
  KeHoachModel? _thongbao;
  late UserBloc? _ub;
  String? body;

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    _tabController = TabController(vsync: this, length: 2);
    _tabController!.addListener(_handleTabChange);
    getLichSuThayDoiKH();
    getListThayDoiKH();
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {}
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _textController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getLichSuThayDoiKH() async {
    setState(() {
      _isLoading = true;
      _kehoachlsList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuong');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachlsList = (decodedData as List).map((item) => LichSuBaoDuongLSModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
          });
        }
      } else {
        _kehoachlsList = [];
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

  Future<void> getListThayDoiKH() async {
    print("databaocao");
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
          print("📊 Dữ liệu nhận được từ API: $decodedData");
          _kehoachList = (decodedData as List).map((item) => LichSuBaoDuongModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
            selectedItems = List.filled(_kehoachList?.length ?? 0, false);
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
      print("❌ Lỗi chuyển đổi JSON sang model: $e");
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> postData(LichSuBaoDuongModel scanData, String? trangThai, String? liDo) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.bienSo1 = newScanData.bienSo1 == 'null' ? null : newScanData.bienSo1;

      var dataList = [newScanData];
      final http.Response response = await requestHelper.postData('MMS_BaoCao/XacNhanYeuCau?TrangThai=$trangThai&LyDo=$liDo&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}', dataList.map((e) => e.toJson()).toList());
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
              if (_textController.text == "") {
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
        await getLichSuThayDoiKH();
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

  Future<void> postDataHuy(KeHoachGiaoXeLSModel scanData) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;

      final http.Response response = await requestHelper.postData('XeDiGap/HuyThayDoiXacNhanKHDiGap', newScanData.toJson());
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

  Future<void> postDataList(List<LichSuBaoDuongModel> dataList, String? trangThai, String? liDo) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('MMS_BaoCao/XacNhanYeuCau?TrangThai=$trangThai&LyDo=$liDo&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}', dataList.map((item) => item.toJson()).toList());
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
                Navigator.of(context).pop();
                setState(() {
                  _textController.text = "";
                });
              }
            });
        _btnController.reset();
        await getLichSuThayDoiKH();
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

  Future<void> postDataFireBase(KeHoachModel? scanData, String? body, String? nguoiYeuCau) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      final http.Response response = await requestHelper.postData('MMS_Notification/PushThongBao?body=$body&NguoiYeuCau=$nguoiYeuCau', newScanData?.toJson());
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

  _onSave(int index) async {
    setState(() {
      _loading = true;
    });

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.id;
    _data?.phuongTien_Id = item?.phuongTien_Id;
    _data?.soKM = item?.soKM;
    // _data?.keHoachGiaoXe_Id = item?.keHoachGiaoXe_Id;
    // _data?.nguoiYeuCau = item?.nguoiYeuCau;

    if (_IsXacNhan == true) {
      _data?.trangThai = "1";
    }
    if (_IsTuChoi == true) {
      _data?.trangThai = "2";
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
        postData(_data!, _data?.trangThai ?? "", _textController.text).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            barcodeScanResult = null;
            _qrDataController.text = '';
            getListThayDoiKH();
            getLichSuThayDoiKH();
            postDataFireBase(_thongbao, body ?? "", _data?.nguoiYeuCau ?? "");
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
    print("data kehoach555 = ${index}");
    final item = _kehoachlsList?[index];
    print("data kehoach = ${item?.id}");
    _datals ??= KeHoachGiaoXeLSModel();
    _datals?.id = item?.id;
    // _datals?.keHoachGiaoXe_Id = item?.keHoachGiaoXe_Id;
    // _datals?.nhaXeThayDoi_Id = item?.nhaXeThayDoi_Id;
    // _datals?.phuongTienThayDoi_Id = item?.phuongTienThayDoi_Id;
    // _datals?.taiXeThayDoi_Id = item?.taiXeThayDoi_Id;

    // _datals?.taiXeYeuCau_Id = item?.taiXeYeuCau_Id;
    // _datals?.nhaXeYeuCau_Id = item?.nhaXeYeuCau_Id;
    // _datals?.phuongTienYeuCau_Id = item?.phuongTienYeuCau_Id;

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
        postDataHuy(_datals!).then((_) {
          setState(() {
            _data = null;
            _IsTuChoi = false;
            _IsXacNhan = false;
            barcodeScanResult = null;

            _qrDataController.text = '';
            getListThayDoiKH();
            getLichSuThayDoiKH();

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
        LichSuBaoDuongModel requestData = LichSuBaoDuongModel(id: item.id, soKM: item.soKM, phuongTien_Id: item.phuongTien_Id, trangThai: _IsXacNhan ? "1" : (_IsTuChoi ? "2" : null));

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
        postDataList(selectedItemsData, _IsXacNhan ? "1" : "2", _textController.text).then((_) {
          setState(() {
            _data = null;
            _IsTuChoi = false;
            _IsXacNhan = false;
            barcodeScanResult = null;
            _qrDataController.text = '';
            // _textController.text = "";
            getListThayDoiKH();
            getLichSuThayDoiKH();
            for (var item in selectedItemsData) {
              postDataFireBase(
                _thongbao,
                body ?? "",
                item.nguoiYeuCau ?? "",
              );
            }
            _loading = false;
            selectAll = false;
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
                            onPressed: _textController.text.isNotEmpty ? () => _onSave(index) : null,
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

  void _showConfirmationDialogTuChoiList(BuildContext context, List<int> selectedIndexes) {
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
                            onPressed: _textController.text.isNotEmpty ? () => _onSaveList(selectedIndexes) : null,
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

  void _showConfirmationDialog(BuildContext context, int index) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có chắc chắn xác nhận không?',
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
          _onSave(index);
        });
  }

  void _showConfirmationDialogHuy(BuildContext context, int index) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có chắc chắn hủy xác nhận không?',
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

  void _showConfirmationDialogList(BuildContext context, List<int> selectedIndexes) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có chắc chắn xác nhận không?',
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
          _onSaveList(selectedIndexes);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context),
      body: Stack(
        children: [
          Column(
            children: [
              CustomCard(),
              // Expanded(
              //   child: Container(
              //     width: 100.w,
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).colorScheme.onPrimary,
              //     ),
              //     child: CustomBodyDSChoXacNhan(),
              //   ),
              // ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h),
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      RefreshIndicator(
                        onRefresh: () async {
                          await getListThayDoiKH();
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
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // if ((_kehoachList?.any((item) => (item?.isThayDoi == true)) ?? false))
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Tất cả",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        value: selectAll, // Trạng thái của checkbox
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectAll = value ?? false;
                                                            selectedItems = List.filled(
                                                              _kehoachList?.length ?? 0,
                                                              selectAll,
                                                            );
                                                            print(selectedItems);
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              // const SizedBox(height: 5),
                                              ListView.builder(
                                                shrinkWrap: true, // Đảm bảo danh sách nằm gọn trong SingleChildScrollView
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: _kehoachList?.length,
                                                itemBuilder: (context, index) {
                                                  final item = _kehoachList?[index];
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
                                                          nguoiYeuCau: item?.nguoiYeuCau ?? "",
                                                          ngay: item?.ngayXacNhan ?? "",
                                                          bienSo1: item?.bienSo1 ?? "",
                                                          soKM: item?.soKM ?? "",
                                                          giaTri: item?.giaTri ?? "",
                                                          lyDo: "Đến hạn bảo dưỡng",
                                                          model: item?.model ?? "",
                                                          model_Option: item?.model_Option ?? "",
                                                          soKM_Adsun: item?.soKM_Adsun ?? "",
                                                          isYeuCau: item?.isYeuCau ?? false,
                                                          isThayDoi: item?.isThayDoi ?? false,
                                                          isVenDer: item?.isVenDer ?? false,
                                                          onTuChoi: () {
                                                            _IsTuChoi = true;
                                                            _showConfirmationDialogTuChoi(context, index); // Hành động TỪ CHỐI
                                                          },
                                                          onDongY: () {
                                                            _IsXacNhan = true;
                                                            _showConfirmationDialog(context, index); // Hành động ĐỒNG Ý
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
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              selectedItems.contains(true)
                                  ? Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Xử lý từ chối tất cả các mục đã chọn
                                                List<int> selectedIndexes = [];
                                                for (int i = 0; i < selectedItems.length; i++) {
                                                  if (selectedItems[i]) {
                                                    selectedIndexes.add(i); // Thêm chỉ mục vào danh sách nếu được chọn
                                                  }
                                                }
                                                _IsTuChoi = true;
                                                // Gọi hàm xử lý với danh sách các chỉ mục
                                                _showConfirmationDialogTuChoiList(context, selectedIndexes);
                                                // Reset lại selectedItems sau khi xử lý
                                                selectedItems = List.filled(selectedItems.length, false);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppConfig.primaryColor, // Màu nền
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
                                              child: const Text("TỪ CHỐI TẤT CẢ"),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Xử lý từ chối tất cả các mục đã chọn
                                                List<int> selectedIndexes = [];
                                                for (int i = 0; i < selectedItems.length; i++) {
                                                  if (selectedItems[i]) {
                                                    selectedIndexes.add(i); // Thêm chỉ mục vào danh sách nếu được chọn
                                                  }
                                                }
                                                _IsXacNhan = true;
                                                // Gọi hàm xử lý với danh sách các chỉ mục
                                                _showConfirmationDialogList(context, selectedIndexes);

                                                // Reset lại selectedItems sau khi xử lý
                                                selectedItems = List.filled(selectedItems.length, false);
                                              },
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
                                              child: const Text("ĐỒNG Ý TẤT CẢ"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height / 11,
                                      padding: EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: AppConfig.bottom,
                                      ),
                                      child: Center(
                                        child: customTitle(
                                          'DANH SÁCH CHỜ XÁC NHẬN BẢO DƯỠNG',
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      RefreshIndicator(
                        onRefresh: () async {
                          await getLichSuThayDoiKH();
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
                                              const Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [],
                                              ),
                                              const SizedBox(height: 5),
                                              ListView.builder(
                                                shrinkWrap: true, // Đảm bảo danh sách nằm gọn trong SingleChildScrollView
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: _kehoachlsList?.length,
                                                itemBuilder: (context, index) {
                                                  final item = _kehoachlsList?[index];
                                                  return Container(
                                                    margin: const EdgeInsets.only(bottom: 5),
                                                    decoration: BoxDecoration(
                                                      // color: Color.fromARGB(255, 226, 167, 187),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        InfoColumn1(
                                                          lyDo: item?.lyDo ?? "",
                                                          trangThai: item?.trangThai ?? "",
                                                          nguoiXacNhan: item?.nguoiXacNhan ?? "",
                                                          nguoiYeuCau: item?.nguoiYeuCau ?? "",
                                                          bienSo1: item?.bienSo1 ?? "",
                                                          soKM: item?.soKM ?? "",
                                                          giaTri: item?.giaTri ?? "",
                                                          model: item?.model ?? "",
                                                          model_Option: item?.model_Option ?? "",
                                                          soKM_Adsun: item?.soKM_Adsun ?? "",
                                                          ngay: item?.ngay ?? "",
                                                          isYeuCau: item?.isYeuCau ?? false,
                                                          isThayDoi: item?.isThayDoi ?? false,
                                                          onHuy: () {
                                                            _showConfirmationDialogHuy(context, index); // Hành động ĐỒNG Ý
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
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
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 11,
                                padding: EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppConfig.bottom,
                                ),
                                child: Center(
                                  child: customTitle(
                                    'DANH SÁCH ĐÃ XÁC NHẬN',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // BottomContent(),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomCard(),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Chờ xác nhận (${_kehoachList?.length.toString() ?? ""})'),
                      Tab(text: 'Đã xác nhận (${_kehoachlsList?.length.toString() ?? ""})'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'DANH SÁCH CHỜ XÁC NHẬN',
        ),
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  final String bienSo1, nguoiYeuCau;
  final String model; // Thời gian yêu cầu
  final String lyDo; // Lý do đổi
  final String model_Option, ngay; // Nhà xe
  final String soKM_Adsun, soKM, giaTri;
  final VoidCallback onTuChoi; // Hành động khi bấm TỪ CHỐI
  final VoidCallback onDongY; // Hành động khi bấm ĐỒNG Ý
  final bool isSelected; // Trạng thái tích chọn
  final VoidCallback onLongPress; // Xử lý khi nhấn giữ
  final bool isYeuCau;
  final bool isThayDoi;
  final bool isVenDer;

  const InfoColumn({
    Key? key,
    required this.nguoiYeuCau,
    required this.ngay,
    required this.lyDo,
    required this.onDongY,
    required this.bienSo1,
    required this.model,
    required this.model_Option,
    required this.soKM_Adsun,
    required this.soKM,
    required this.giaTri,
    required this.onTuChoi,
    required this.isSelected,
    required this.onLongPress,
    required this.isYeuCau,
    required this.isThayDoi,
    required this.isVenDer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: onLongPress,
      onTap: onLongPress,

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
            // Góc trên bên phải: Thời gian yêu cầu
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

            RichText(
              text: TextSpan(
                text: "Người yêu cầu: ", // Tiêu đề
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // Màu đen cho tiêu đề
                ),
                children: [
                  TextSpan(
                    text: nguoiYeuCau, // Nội dung YC
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
            const SizedBox(height: 4),
            // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
            InfoRow(
              title: "Tên loại bảo dưỡng:",
              contentYC: model,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Option_bảo dưỡng:",
              contentYC: model_Option,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Số KM theo Adsun:",
              contentYC: soKM_Adsun,
            ),
            InfoRow(
              title: "Số KM theo xe:",
              contentYC: soKM,
            ),
            InfoRow(
              title: "Số KM đến hạn:",
              contentYC: giaTri,
            ),

            // if (isThayDoi)
            // Hàng nút bấm: TỪ CHỐI và ĐỒNG Ý
            Padding(
              padding: const EdgeInsets.only(top: 12.0), // Khoảng cách trên nút
              child: Row(
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
                      child: const Text("ĐỒNG Ý"),
                    ),
                  ),
                ],
              ),
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
      ],
    );
  }
}

class InfoColumn1 extends StatelessWidget {
  final String nguoiXacNhan, trangThai;
  final String nguoiYeuCau;
  final String bienSo1;
  final String model; // Thời gian yêu cầu
  final String lyDo; // Lý do đổi
  final String model_Option, ngay; // Nhà xe
  final String soKM_Adsun, soKM, giaTri;
  final bool isYeuCau;
  final bool isThayDoi;
  final VoidCallback onHuy; // Hành động khi bấm ĐỒNG Ý

  const InfoColumn1({
    Key? key,
    required this.nguoiXacNhan,
    required this.nguoiYeuCau,
    required this.lyDo,
    required this.ngay,
    required this.bienSo1,
    required this.model,
    required this.model_Option,
    required this.soKM_Adsun,
    required this.soKM,
    required this.giaTri,
    required this.trangThai,
    required this.isYeuCau,
    required this.isThayDoi,
    required this.onHuy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0), // Padding cho toàn bộ cột lớn
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền cho cột lớn
        // border: Border.all(color: Colors.grey.shade300), // Viền
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8), // Bo tròn góc
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Góc trên bên phải: Thời gian yêu cầu
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
              SelectableText(
                bienSo1, // Nội dung TD
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.red, // Màu xám cho nội dung YC
                ),
              ),
              if (isThayDoi) // Nếu là yêu cầu, hiện icon thay ra
                // IconButton(
                //   onPressed: onHuy, // Gọi hàm onHuy khi nhấn vào nút,
                //   icon: const Icon(Icons.undo),
                //   color: Colors.green,
                //   iconSize: 24,
                //   padding: EdgeInsets.all(0), // Xóa padding mặc định
                //   constraints: const BoxConstraints(),
                // ),
                GestureDetector(
                  onTap: onHuy,
                  child: const Icon(
                    Icons.undo,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
              // if (isThayDoi && isLock) // Nếu là yêu cầu, hiện icon thay ra
              const Icon(Icons.lock, color: Colors.green, size: 24),
            ],
          ),
          CustomRichText(
            title: "Người yêu cầu",
            content: nguoiYeuCau,
          ),
          const SizedBox(height: 4),
          CustomRichText(
            title: "Người xác nhận",
            content: nguoiXacNhan,
          ),
          const SizedBox(height: 4),
          // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
          InfoRow(
            title: "Tên loại bảo dưỡng:",
            contentYC: model,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Option_bảo dưỡng:",
            contentYC: model_Option,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Số KM theo Adsun:",
            contentYC: soKM_Adsun,
          ),
          InfoRow(
            title: "Số KM theo xe:",
            contentYC: soKM,
          ),
          InfoRow(
            title: "Số KM đến hạn:",
            contentYC: giaTri,
          ),

          SizedBox(
            height: 4,
          ),
          CustomRichText(
            title: "Trạng thái",
            content: trangThai,
          ),
          SizedBox(
            height: 4,
          ),
          if (trangThai == "Đã từ chối")
            CustomRichText(
              title: "Lý do từ chối",
              content: lyDo,
            ),

          // Hàng nút bấm: TỪ CHỐI và ĐỒNG Ý
        ],
      ),
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
            style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                // color: title != "Lý do từ chối" ? Colors.grey : Colors.red, // Màu xám cho nội dung
                color: content != "Đã duyệt" ? Colors.red : Colors.green),
          ),
        ],
      ),
    );
  }
}
