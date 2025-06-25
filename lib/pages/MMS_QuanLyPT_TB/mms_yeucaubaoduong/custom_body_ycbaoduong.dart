import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/kehoachgiaoxe.dart';

import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/utils/next_screen.dart';
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
import '../../../models/kehoach.dart';
import '../../../models/kehoachgiaoxe_ls.dart';
import '../../../models/mms/dsphuongtien.dart';
import '../../../models/mms/lichsubaoduong.dart';
import '../../../services/request_helper_mms.dart';
import '../../../widgets/custom_title.dart';
import '../lichsuyeucaucanhan/dsx_yeucaucanhanbaoduong.dart';

class CustomBodyYeuCauBaoDuong extends StatelessWidget {
  final String? listIds;
  CustomBodyYeuCauBaoDuong({required this.listIds});
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyYeuCauBaoDuongScreen(listIds: listIds));
  }
}

class BodyYeuCauBaoDuongScreen extends StatefulWidget {
  final String? listIds;
  const BodyYeuCauBaoDuongScreen({super.key, required this.listIds});

  @override
  _BodyYeuCauBaoDuongScreenState createState() => _BodyYeuCauBaoDuongScreenState();
}

class _BodyYeuCauBaoDuongScreenState extends State<BodyYeuCauBaoDuongScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();

  String _qrData = '';
  final _qrDataController = TextEditingController();
  LichSuBaoDuongModel? _data;

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

  List<PhuongTienModel>? _kehoachList;
  List<PhuongTienModel>? get kehoachList => _kehoachList;
  List<KeHoachGiaoXeLSModel>? _kehoachlsList;
  List<KeHoachGiaoXeLSModel>? get kehoachlsList => _kehoachlsList;

  List<bool> selectedItems = [];
  bool selectAll = false;
  String? DongXeId;
  String? body;
  @override
  void initState() {
    super.initState();
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);
    print("Id: ${widget.listIds} - Type: ${widget.listIds.runtimeType}");
    if (widget.listIds?.isNotEmpty ?? false) {
      getListThayDoiKH(widget.listIds, textEditingController.text);
    } else {
      print("theo ca nhan");
      getListThayDoiKHBaoDuong(_ub?.id ?? "", textEditingController.text);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getListThayDoiKHBaoDuong(String? listIds, String? keyword) async {
    print("dataUser:${listIds}");
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      // String listIdsQuery = listIds.map((id) => "PhuongTien_Id=$id").join("&");

      final http.Response response = await requestHelper.getData('MMS_DS_PhuongTien/GetListCanBaoDuongTheoCaNhan?User_Id=$listIds&keyword=$keyword');
      print("data3:${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          _kehoachList = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).where((item) => item.isDenHan == true && item.isYeuCau == false).toList();
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

  Future<void> getListThayDoiKH(String? listIds, String? keyword) async {
    print("data:${listIds}");
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      // String listIdsQuery = listIds.map((id) => "PhuongTien_Id=$id").join("&");

      final http.Response response = await requestHelper.getData('MMS_DS_PhuongTien/List?PhuongTien_Id=$listIds&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          _kehoachList = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).where((item) => item.isYeuCau == false).toList();
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
    print("datathongbaois");
    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      final http.Response response = await requestHelper.postData('MMS_Notification/PushThongBao?body=$body', newScanData?.toJson());
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
      final http.Response response = await requestHelper.getData('MMS_BaoCao/DanhSachYeuCau');
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

  Future<void> postData(LichSuBaoDuongModel scanData) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.bienSo1 = newScanData.bienSo1 == 'null' ? null : newScanData.bienSo1;
      var dataList = [newScanData];
      final http.Response response = await requestHelper.postData('MMS_BaoCao/YeuCauBaoDuong?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}', dataList.map((e) => e.toJson()).toList());

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
        body = "Bạn đã có ${_kehoachlsList?.length.toString() ?? ""} yêu cầu bảo dưỡng phương tiện";
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
        body = "Bạn đã có ${_kehoachlsList?.length.toString() ?? ""} yêu cầu bảo dưỡng phương tiện";
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
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.id;
    _data?.phuongTien_Id = item?.id;
    _data?.baoDuong_Id = item?.model_Id;
    _data?.soKM = item?.soKM_Adsun;

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
            if (widget.listIds?.isNotEmpty ?? false) {
              getListThayDoiKH(widget.listIds, textEditingController.text);
            } else {
              getListThayDoiKHBaoDuong(_ub?.id ?? "", textEditingController.text);
            }
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
            if (widget.listIds?.isNotEmpty ?? false) {
              getListThayDoiKH(widget.listIds, textEditingController.text);
            } else {
              getListThayDoiKHBaoDuong(_ub?.id ?? "", textEditingController.text);
            }
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
        await getListThayDoiKH(widget.listIds, soKhungController.text);
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
                                        text: "Danh sách phương tiện: ",
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
                                    nextScreen(context, DSYCCaNhanBaoDuongPage());
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
                                      getListThayDoiKH(widget.listIds, soKhungController.text);
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
                                          bienSo1: item?.bienSo1 ?? "",
                                          soKM: item?.soKM ?? "",
                                          giaTri: item?.giaTri ?? "",
                                          lyDo: "Đến hạn bảo dưỡng",
                                          model: item?.model ?? "",
                                          model_Option: item?.model_Option ?? "",
                                          soKM_Adsun: item?.soKM_Adsun ?? "",
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
                        'YÊU CẦU KẾ HOẠCH BẢO DƯỠNG',
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
  final String bienSo1;
  final String model; // Thời gian yêu cầu
  final String lyDo; // Lý do đổi
  final String model_Option; // Nhà xe
  final String soKM_Adsun, soKM, giaTri;
  final VoidCallback onDongY; // Hành động khi bấm ĐỒNG Ý
  final bool isSelected; // Trạng thái tích chọn
  final VoidCallback onLongPress; // Xử lý khi nhấn giữ

  const InfoColumn({
    Key? key,
    required this.lyDo,
    required this.onDongY,
    required this.bienSo1,
    required this.model,
    required this.model_Option,
    required this.soKM_Adsun,
    required this.soKM,
    required this.giaTri,
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
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Text(
            //     ngaytao,
            //     style: const TextStyle(
            //       fontFamily: 'Comfortaa',
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),

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

            // Hàng nút bấm: TỪ CHỐI và ĐỒNG Ý
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
