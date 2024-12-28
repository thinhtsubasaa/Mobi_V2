import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/kehoachgiaoxe.dart';
import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../blocs/user_bloc.dart';
import '../../config/config.dart';
import '../../models/kehoach.dart';
import '../../models/kehoachgiaoxe_ls.dart';
import '../../widgets/custom_title.dart';

class CustomBodyDSChoXacNhan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSChoXacNhanScreen());
  }
}

class BodyDSChoXacNhanScreen extends StatefulWidget {
  const BodyDSChoXacNhanScreen({super.key});

  @override
  _BodyDSChoXacNhanScreenState createState() => _BodyDSChoXacNhanScreenState();
}

class _BodyDSChoXacNhanScreenState extends State<BodyDSChoXacNhanScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String _qrData = '';
  final _qrDataController = TextEditingController();
  KeHoachGiaoXeModel? _data;

  bool _loading = false;

  String? barcodeScanResult;
  String? viTri;
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

  bool _IsTuChoi = false;
  bool _IsXacNhan = false;
  List<String> noiDenList = [];
  List<NoiDenModel>? _noidenList;
  List<NoiDenModel>? get noidenList => _noidenList;
  List<LyDoModel>? _lydoList;
  List<LyDoModel>? get lydoList => _lydoList;
  List<XeRaCongModel>? _xeracongList;
  List<XeRaCongModel>? get xeracongList => _xeracongList;
  late UserBloc? _ub;
  String? bienSo;

  List<KeHoachGiaoXeModel>? _kehoachList;
  List<KeHoachGiaoXeModel>? get kehoachList => _kehoachList;
  List<KeHoachGiaoXeLSModel>? _kehoachlsList;
  List<KeHoachGiaoXeLSModel>? get kehoachlsList => _kehoachlsList;
  List<bool> selectedItems = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    getListThayDoiKH();
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getListLSThayDoiKH() async {
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('Kho/LichSuThongTinYeuCauThayDoiKH');
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
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> postDataFireBase(KeHoachModel? scanData, String? body) async {
    _isLoading = true;
    print("Kết quả postData thành công. Chuẩn bị gọi postDataFireBase");
    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print dataabcsfsfgsg: ${newScanData?.soKhung}");
      final http.Response response = await requestHelper.postData('FireBase?body=$body', newScanData?.toJson());
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

  Future<void> postData(KeHoachGiaoXeModel scanData, String? trangThai, String? liDo) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;

      var dataList = [newScanData];
      final http.Response response = await requestHelper.postData('Kho/XacNhanYeuCauThayDoiKH?TrangThai=$trangThai&LyDo=$liDo', dataList.map((e) => e.toJson()).toList());

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

  Future<void> postDataList(List<KeHoachGiaoXeModel> dataList, String? trangThai, String? liDo) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('Kho/XacNhanYeuCauThayDoiKH?TrangThai=$trangThai&LyDo=$liDo', dataList.map((item) => item.toJson()).toList());
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

  _onSave(int index) async {
    setState(() {
      _loading = true;
    });

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data ??= KeHoachGiaoXeModel();
    _data?.id = item?.id;
    _data?.keHoachGiaoXe_Id = item?.keHoachGiaoXe_Id;
    _data?.nhaXeThayDoi_Id = item?.nhaXeThayDoi_Id;
    _data?.phuongTienThayDoi_Id = item?.phuongTienThayDoi_Id;
    _data?.taiXeThayDoi_Id = item?.taiXeThayDoi_Id;

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
            _data = null;
            _IsTuChoi = false;
            _IsXacNhan = false;
            barcodeScanResult = null;
            _qrData = '';
            _qrDataController.text = '';

            getListThayDoiKH();

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
    List<KeHoachGiaoXeModel> selectedItemsData = [];
    for (int index in selectedIndexes) {
      final item = _kehoachList?[index];
      if (item != null) {
        KeHoachGiaoXeModel requestData = KeHoachGiaoXeModel(
          id: item.id,
          keHoachGiaoXe_Id: item.keHoachGiaoXe_Id,
          nhaXeThayDoi_Id: item.nhaXeThayDoi_Id,
          phuongTienThayDoi_Id: item.phuongTienThayDoi_Id,
          taiXeThayDoi_Id: item.taiXeThayDoi_Id,
          trangThai: _IsXacNhan ? "1" : (_IsTuChoi ? "2" : null),
        );
        selectedItemsData.add(requestData);
      }
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
        postDataList(selectedItemsData, _IsXacNhan ? "1" : "2", _textController.text).then((_) {
          setState(() {
            _data = null;
            _IsTuChoi = false;
            _IsXacNhan = false;
            barcodeScanResult = null;
            _qrData = '';
            _qrDataController.text = '';
            getListThayDoiKH();
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
    return RefreshIndicator(
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
                                // Text.rich(
                                //   TextSpan(
                                //     children: [
                                //       const TextSpan(
                                //         text: "Tổng yêu cầu: ",
                                //         style: TextStyle(
                                //           color: Colors.black,
                                //           fontSize: 15,
                                //           fontWeight: FontWeight.w600,
                                //         ),
                                //       ),
                                //       TextSpan(
                                //         text: "${_kehoachList?.length.toString() ?? ""}",
                                //         style: TextStyle(
                                //           color: Colors.red,
                                //           fontSize: 15,
                                //           fontWeight: FontWeight.w600,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
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
                                        soKhung: item?.soKhung ?? "",
                                        ngayYeuCau: item?.ngayYeuCau ?? "",
                                        lyDo: item?.lyDo ?? "",
                                        nhaXeYC: item?.nhaXeYC ?? '',
                                        nhaXeTD: item?.nhaXeTD ?? '',
                                        bienSoYC: item?.bienSoYC ?? '',
                                        bienSoTD: item?.bienSoTD ?? '',
                                        taiXeYC: item?.taiXeYC ?? '',
                                        taiXeTD: item?.taiXeTD ?? '',
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
                    padding: const EdgeInsets.all(8.0),
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
                        'DANH SÁCH CHỜ XÁC NHẬN',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  final String nguoiYeuCau;
  final String soKhung;
  final String ngayYeuCau; // Thời gian yêu cầu
  final String lyDo; // Lý do đổi
  final String nhaXeYC, nhaXeTD; // Nhà xe
  final String bienSoYC, bienSoTD; // Biển số
  final String taiXeYC, taiXeTD; // Tài xế
  final VoidCallback onTuChoi; // Hành động khi bấm TỪ CHỐI
  final VoidCallback onDongY; // Hành động khi bấm ĐỒNG Ý
  final bool isSelected; // Trạng thái tích chọn
  final VoidCallback onLongPress; // Xử lý khi nhấn giữ

  const InfoColumn({
    Key? key,
    required this.nguoiYeuCau,
    required this.soKhung,
    required this.ngayYeuCau,
    required this.lyDo,
    required this.nhaXeYC,
    required this.nhaXeTD,
    required this.bienSoYC,
    required this.bienSoTD,
    required this.taiXeYC,
    required this.taiXeTD,
    required this.onTuChoi,
    required this.onDongY,
    required this.isSelected,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                  ngayYeuCau,
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SelectableText(
              soKhung, // Nội dung TD
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey, // Màu xám cho nội dung YC
              ),
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
              title: "Nhà xe:",
              contentYC: nhaXeYC,
              contentTD: nhaXeTD,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Biển số:",
              contentYC: bienSoYC,
              contentTD: bienSoTD,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Tài xế:",
              contentYC: taiXeYC,
              contentTD: taiXeTD,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dòng dưới cùng: Lý do đổi
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RichText(
                    text: TextSpan(
                      text: "Lý do đổi: ", // Tiêu đề
                      style: const TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Màu đen cho tiêu đề
                      ),
                      children: [
                        TextSpan(
                          text: lyDo, // Nội dung
                          style: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red, // Màu đỏ cho lý do
                          ),
                        ),
                      ],
                    ),
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
  final String contentTD; // Nội dung thực tế (TD): item?.nhaXeTD, item?.bienSoTD, item?.taiXeTD

  const InfoRow({
    Key? key,
    required this.title,
    required this.contentYC,
    required this.contentTD,
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
        Row(
          children: [
            Container(
              width: 20, // Độ rộng khung vuông
              height: 20, // Độ cao khung vuông
              decoration: BoxDecoration(
                color: Colors.transparent, // Hoặc màu nền bạn muốn
                border: Border.all(color: Colors.green, width: 1), // Viền
                borderRadius: BorderRadius.circular(4), // Góc bo tròn
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward, // Icon mũi tên
                  color: Colors.green,
                  size: 16, // Kích thước icon
                ),
              ),
            ),
            const SizedBox(width: 3), // Khoảng cách giữa icon và text
            Text(
              contentTD, // Nội dung TD
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
