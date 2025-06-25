import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Thilogi/blocs/xeracong_bloc.dart';

import 'package:Thilogi/services/app_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../../blocs/user_bloc.dart';
import '../../../config/config.dart';
import '../../../models/checksheet.dart';
import '../../../models/kehoach.dart';
import '../../../models/mms/lichsubaoduong.dart';
import '../../../services/request_helper_mms.dart';
import '../../../widgets/custom_title.dart';

class CustomBodyBaoDuongQL extends StatelessWidget {
  CustomBodyBaoDuongQL();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyBaoDuongQLScreen(
      lstFiles: [],
    ));
  }
}

class BodyBaoDuongQLScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyBaoDuongQLScreen({super.key, required this.lstFiles});

  @override
  _BodyBaoDuongQLScreenState createState() => _BodyBaoDuongQLScreenState();
}

class _BodyBaoDuongQLScreenState extends State<BodyBaoDuongQLScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();

  String _qrData = '';
  final _qrDataController = TextEditingController();
  LichSuBaoDuongModel? _data;

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
  bool _IsTuChoi = false;
  bool _IsXacNhan = false;

  late UserBloc? _ub;
  String? bienSo;
  KeHoachModel? _thongbao;
  List<LichSuBaoDuongModel>? _kehoachList;
  List<LichSuBaoDuongModel>? get kehoachList => _kehoachList;
  List<bool> selectedItems = [];
  bool selectAll = false;
  String? body;
  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    getListThayDoiKH(soKhungController.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    _ghiChu.dispose();
    super.dispose();
  }

  Future<void> getListThayDoiKH(String? keyword) async {
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuong?keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
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
        await getListThayDoiKH(soKhungController.text);
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
        await getListThayDoiKH(soKhungController.text);
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

            _qrDataController.text = '';
            getListThayDoiKH(soKhungController.text);

            postDataFireBase(_thongbao, body ?? "", _data?.nguoiYeuCau ?? "");
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

            _qrDataController.text = '';
            // _textController.text = "";
            getListThayDoiKH(soKhungController.text);

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
        await getListThayDoiKH(soKhungController.text);
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
                            // Text.rich(
                            //   TextSpan(
                            //     children: [
                            //       const TextSpan(
                            //         text: "Lịch sử: ",
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
                                          hintText: 'Tìm theo biển số',
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
                                      getListThayDoiKH(soKhungController.text);
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
                                if ((_kehoachList?.any((item) => (item?.isYeuCau == true && item?.isDuyet == false)) ?? false))
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

                            // if (_kehoachList != null)
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
                                        isYeuCau: item?.isYeuCau ?? false,
                                        tinhTrang: item?.tinhTrang ?? "",
                                        bienSo1: item?.bienSo1 ?? "",
                                        ngay: item?.ngay ?? "",
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
                        // Expanded(
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       // Xử lý từ chối tất cả các mục đã chọn
                        //       List<int> selectedIndexes = [];
                        //       for (int i = 0; i < selectedItems.length; i++) {
                        //         if (selectedItems[i]) {
                        //           selectedIndexes.add(i); // Thêm chỉ mục vào danh sách nếu được chọn
                        //         }
                        //       }
                        //       _IsTuChoi = true;
                        //       // Gọi hàm xử lý với danh sách các chỉ mục
                        //       _showConfirmationDialogTuChoiList(context, selectedIndexes);
                        //       // Reset lại selectedItems sau khi xử lý
                        //       selectedItems = List.filled(selectedItems.length, false);
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppConfig.primaryColor, // Màu nền
                        //       foregroundColor: AppConfig.textButton, // Màu chữ
                        //       textStyle: const TextStyle(
                        //         fontFamily: 'Comfortaa',
                        //         fontWeight: FontWeight.w700,
                        //         fontSize: 13,
                        //       ),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(13), // Bo góc
                        //       ),
                        //     ),
                        //     child: const Text("TỪ CHỐI TẤT CẢ"),
                        //   ),
                        // ),
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
  final String bienSo1;
  final String ngay; // Thời gian yêu cầu
  final String ngayXacNhan; // Lý do đổi
  final String ngayDiBaoDuong, tinhTrang; // Nhà xe
  final String ngayHoanThanh, nguoiYeuCau, nguoiXacNhan, nguoiDiBaoDuong, nguoiXacNhanHoanThanh;
  final VoidCallback onDongY; // Hành động khi bấm ĐỒNG Ý
  final bool isSelected, isBaoDuong, isDuyet, isYeuCau; // Trạng thái tích chọn
  final VoidCallback onLongPress; // Xử lý khi nhấn giữ

  const InfoColumn({
    Key? key,
    required this.onDongY,
    required this.bienSo1,
    required this.ngay,
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
    required this.isYeuCau,
    required this.isSelected,
    required this.onLongPress,
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
            // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
            // InfoRow(
            //   title: "Ngày yêu cầu:",
            //   contentYC: ngay,
            // ),
            const SizedBox(height: 3),
            InfoRow(
              title: "Người yêu cầu:",
              contentYC: nguoiYeuCau,
            ),
            const SizedBox(height: 3),
            InfoRow(
              title: "Ngày xác nhận:",
              contentYC: ngayXacNhan,
            ),
            const SizedBox(height: 3),
            InfoRow(
              title: "Người xác nhận:",
              contentYC: nguoiXacNhan,
            ),
            const SizedBox(height: 3),
            InfoRow(
              title: "Ngày đi bảo dưỡng:",
              contentYC: ngayDiBaoDuong,
            ),
            const SizedBox(height: 3),
            InfoRow(
              title: "Người đi bảo dưỡng:",
              contentYC: nguoiDiBaoDuong,
            ),
            const SizedBox(height: 3),
            InfoRow(
              title: "Ngày hoàn thành:",
              contentYC: ngayHoanThanh,
            ),
            const SizedBox(height: 3),
            InfoRow(
              title: "Người xác nhận hoàn thành:",
              contentYC: nguoiXacNhanHoanThanh,
            ),
            const SizedBox(height: 3),
            CustomRichText(
              title: "Trạng thái",
              content: tinhTrang,
            ),
            if (isYeuCau && !isDuyet)
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
                        child: const Text("ĐỒNG Ý"),
                      ),
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
