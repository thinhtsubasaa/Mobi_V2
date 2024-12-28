import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/kehoachgiaoxe.dart';
import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/pages/lichsuyeucaucanhandigap/dsx_yeucaucanhandigap.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/user_bloc.dart';
import '../../config/config.dart';
import '../../models/dongxe.dart';
import '../../models/kehoach.dart';
import '../../models/kehoachgiaoxe_ls.dart';
import '../../widgets/custom_title.dart';

class CustomBodyThayDoiXeDiGap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyThayDoiXeDiGapScreen());
  }
}

class BodyThayDoiXeDiGapScreen extends StatefulWidget {
  const BodyThayDoiXeDiGapScreen({super.key});

  @override
  _BodyThayDoiXeDiGapScreenState createState() => _BodyThayDoiXeDiGapScreenState();
}

class _BodyThayDoiXeDiGapScreenState extends State<BodyThayDoiXeDiGapScreen> with TickerProviderStateMixin, ChangeNotifier {
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
  final TextEditingController soKhungController = TextEditingController();

  bool _IsTuChoi = false;
  bool _IsXacNhan = false;

  late UserBloc? _ub;
  String? bienSo;
  KeHoachModel? _thongbao;

  List<KeHoachGiaoXeModel>? _kehoachList;
  List<KeHoachGiaoXeModel>? get kehoachList => _kehoachList;
  List<KeHoachGiaoXeLSModel>? _kehoachlsList;
  List<KeHoachGiaoXeLSModel>? get kehoachlsList => _kehoachlsList;
  List<DongXeModel>? _dongxeList;
  List<DongXeModel>? get dongxeList => _dongxeList;

  List<bool> selectedItems = [];
  bool selectAll = false;
  String? DongXeId;
  String? body;
  @override
  void initState() {
    super.initState();
    // getListThayDoiKH(DongXeId ?? "", soKhungController.text);
    getDataDongXe();
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void getDataDongXe() async {
    try {
      final http.Response response = await requestHelper.getData('Xe_DongXe');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _dongxeList = (decodedData["datalist"] as List).map((item) => DongXeModel.fromJson(item)).toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          DongXeId = "d30a8f59-9e44-4e11-a3b9-440b1ef45f1d";
          _loading = false;
        });
        getListThayDoiKH(DongXeId ?? "", soKhungController.text);
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getListThayDoiKH(String? dongXe_Id, String? keyword) async {
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('XeDiGap/GetXeDiGap?&DongXe_Id=$dongXe_Id&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachList = (decodedData as List).map((item) => KeHoachGiaoXeModel.fromJson(item)).where((item) => item.isYeuCau == false).toList();
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

    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      final http.Response response = await requestHelper.postData('FireBase/XeDiGap?body=$body', newScanData?.toJson());
      print("statusCode: ${response.body}");
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

  Future<void> getListThayDoiKHDiGap() async {
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('XeDiGap/GetThongTinYeuCauThayDoiKHDiGap');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachlsList = (decodedData as List).map((item) => KeHoachGiaoXeLSModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
            selectedItems = List.filled(_kehoachlsList?.length ?? 0, false);
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

  Future<void> postData(KeHoachGiaoXeModel scanData) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;

      var dataList = [newScanData];
      final http.Response response = await requestHelper.postData('XeDiGap/YeuCauThayDoiKHDiGap', dataList.map((e) => e.toJson()).toList());

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
        await getListThayDoiKHDiGap();
        body = "Bạn đã có ${_kehoachlsList?.length.toString() ?? ""} yêu cầu thay đổi xe trung chuyển đi gấp";
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

  Future<void> postDataList(List<KeHoachGiaoXeModel> dataList) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('XeDiGap/YeuCauThayDoiKHDiGap', dataList.map((item) => item.toJson()).toList());
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
        await getListThayDoiKHDiGap();
        body = "Bạn đã có ${_kehoachlsList?.length.toString() ?? ""} yêu cầu thay đổi xe trung chuyển đi gấp";
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
    _data?.keHoachGiaoXe_Id = item?.id;

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
            _IsTuChoi = false;
            _IsXacNhan = false;
            barcodeScanResult = null;
            _qrData = '';
            _qrDataController.text = '';
            getListThayDoiKH(DongXeId ?? "", soKhungController.text);
            postDataFireBase(_thongbao, body ?? "");
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
    List<KeHoachGiaoXeModel> selectedItemsData = [];
    for (int index in selectedIndexes) {
      final item = _kehoachList?[index];
      if (item != null) {
        KeHoachGiaoXeModel requestData = KeHoachGiaoXeModel(
          id: item.id,
          keHoachGiaoXe_Id: item.id,
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
        postDataList(selectedItemsData).then((_) {
          setState(() {
            _data = null;
            _IsTuChoi = false;
            _IsXacNhan = false;
            barcodeScanResult = null;
            _qrData = '';
            _qrDataController.text = '';
            getListThayDoiKH(DongXeId, soKhungController.text);
            for (var item in selectedItemsData) {
              postDataFireBase(
                _thongbao,
                body ?? "",
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
        await getListThayDoiKH(DongXeId, soKhungController.text);
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
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Danh sách xe : ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${_kehoachList?.length.toString() ?? ""}",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    nextScreen(context, DSYCCaNhanDiGapPage());
                                  },
                                ),
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
                                        "Dòng xe",
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
                                            items: _dongxeList?.map((item) {
                                              return DropdownMenuItem<String>(
                                                value: item.id,
                                                child: Container(
                                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Text(
                                                      item.tenDongXe ?? "",
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
                                            value: DongXeId,
                                            onChanged: (newValue) {
                                              setState(() {
                                                DongXeId = newValue;
                                                // doiTac_Id = null;
                                              });

                                              if (newValue != null) {
                                                getListThayDoiKH(newValue, soKhungController.text);
                                                print("objectcong : ${newValue}");
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
                                                    hintText: 'Tìm dòng xe',
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
                                                  return _dongxeList?.any((baiXe) => baiXe.id == itemId && baiXe.tenDongXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                              height: 4,
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
                                          hintText: 'Tìm theo số khung',
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
                                      getListThayDoiKH(DongXeId ?? "", soKhungController.text);
                                      setState(() {
                                        _loading = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (_kehoachList != null)
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
                                          ngaytao: item?.ngayTao ?? "",
                                          soKhung: item?.soKhung ?? "",
                                          lyDo: item?.lyDo ?? "",
                                          mauXe: item?.mauXe ?? "",
                                          noidi: item?.noidi ?? "",
                                          noiden: item?.noiden ?? "",
                                          benvanchuyen: item?.benVanChuyen ?? "",
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
                        'YÊU CẦU THAY ĐỔI KẾ HOẠCH',
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
  final String soKhung;
  final String mauXe; // Thời gian yêu cầu
  final String lyDo; // Lý do đổi
  final String noidi, noiden; // Nhà xe
  final String benvanchuyen;
  final VoidCallback onDongY; // Hành động khi bấm ĐỒNG Ý
  final bool isSelected; // Trạng thái tích chọn
  final VoidCallback onLongPress; // Xử lý khi nhấn giữ
  final String ngaytao;

  const InfoColumn({
    Key? key,
    required this.soKhung,
    required this.mauXe,
    required this.lyDo,
    required this.noidi,
    required this.noiden,
    required this.benvanchuyen,
    required this.onDongY,
    required this.ngaytao,
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
            Align(
              alignment: Alignment.topRight,
              child: Text(
                ngaytao,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dòng dưới cùng: Lý do đổi

                SelectableText(
                  soKhung, // Nội dung TD
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

            const SizedBox(height: 4),
            // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
            InfoRow(
              title: "Màu xe:",
              contentYC: mauXe,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Nơi đi:",
              contentYC: noidi,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Nơi đến:",
              contentYC: noiden,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Bên vận chuyển:",
              contentYC: benvanchuyen,
            ),

            // Hàng nút bấm: TỪ CHỐI và ĐỒNG Ý
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn sát phải
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0), // Khoảng cách trên nút
                  child: Container(
                    width: 45.w,
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
                      child: const Text("YÊU CẦU ĐI GẤP"),
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
