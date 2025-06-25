import 'dart:async';
import 'dart:convert';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
import '../../../services/app_service.dart';
import '../../../services/request_helper_mms.dart';
import '../../../widgets/loading.dart';
import '../quanlyphuongtien/quanlyphuongtien.dart';
import '../quanlyphuongtien_QLNew/quanlyphuongtien_qlnew.dart';

class CustomBodyNoiDungBaoDuongQL extends StatelessWidget {
  final String? id;
  CustomBodyNoiDungBaoDuongQL({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyNoiDungBaoDuongQLScreen(
      id: id,
    ));
  }
}

class BodyNoiDungBaoDuongQLScreen extends StatefulWidget {
  final String? id;
  const BodyNoiDungBaoDuongQLScreen({super.key, required this.id});

  @override
  _BodyNoiDungBaoDuongQLScreenState createState() => _BodyNoiDungBaoDuongQLScreenState();
}

class _BodyNoiDungBaoDuongQLScreenState extends State<BodyNoiDungBaoDuongQLScreen> with TickerProviderStateMixin, ChangeNotifier {
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

  List<HangMucModel>? _kehoachList;
  List<HangMucModel>? get kehoachList => _kehoachList;
  LichSuBaoDuongNewModel? _data;
  List<bool> selectedItems = [];
  bool selectAll = false;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController soKhungController = TextEditingController();
  String? body;
  List<KeHoachGiaoXeLSModel>? _kehoachlsList;
  List<KeHoachGiaoXeLSModel>? get kehoachlsList => _kehoachlsList;
  KeHoachModel? _thongbao;
  String? selectedDate;
  List<DiaDiemModel>? _dn;
  List<DiaDiemModel>? get dn => _dn;
  List<DonViModel>? _donvi;
  List<DonViModel>? get donvi => _donvi;
  List<HangMucModel>? _hangmuc;
  List<HangMucModel>? get hangmuc => _hangmuc;
  String? DiaDiem_Id;
  String? HangMuc_Id;

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    print("Id: ${widget.id} - Type: ${widget.id.runtimeType}");
    getHangMuc();
    getBienSo(widget.id ?? "", HangMuc_Id ?? "", soKhungController.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getHangMuc() async {
    _hangmuc = [];
    try {
      final http.Response response = await requestHelper.getData('MMS_DM_HangMuc/HangMuc');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _hangmuc = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
          _hangmuc!.insert(0, HangMucModel(id: '', noiDungBaoDuong: 'Tất cả'));
          setState(() {
            HangMuc_Id = '';
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getBienSo(String? phuongTien_Id, String? hangMuc_Id, String? keyword) async {
    _loading = true;
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuongChiTiet?PhuongTien_Id=$phuongTien_Id&HangMuc_Id=$hangMuc_Id&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _kehoachList = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("databienso2:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0;
    const String defaultDate = "1970-01-01 ";

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 2.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(0.2),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nội dung bảo dưỡng', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Định mức bảo dưỡng', textColor: Colors.white),
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
                      child: _buildTableCell('Loại bảo dưỡng', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ghi chú', textColor: Colors.white),
                    ),
                  ],
                ),
                // Chiều cao cố định
                ..._kehoachList?.map((item) {
                      index++; // Tăng số thứ tự sau mỗi lần lặp

                      return TableRow(
                        children: [
                          // _buildTableCell(index.toString()), // Số thứ tự

                          _buildTableCell(item.ngay ?? ""),
                          _buildTableCell(item.noiDungBaoDuong ?? ""),
                          _buildTableCell(item.dinhMuc2 ?? ""),
                          _buildTableCell(item.bienSo1 ?? ""),
                          _buildTableCell(item.bienSo2 ?? ""),
                          _buildTableCell(item.loaiBaoDuong ?? ""),
                          _buildTableCell(item.ghiChu ?? ""),
                        ],
                      );
                    }).toList() ??
                    [],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
      lastDate: DateTime(2100), // Giới hạn ngày trong tương lai nếu cần
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(picked); // Chỉ lấy ngày
        print("Ngày được chọn: $selectedDate");
        _loading = false; // Dừng loading nếu cần
      });
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

  _onSave(String? id, String? baoduong_Id, String? soKM) async {
    setState(() {
      _loading = true;
    });
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
        postData(_data!, selectedDate).then((_) {
          setState(() {
            _IsXacNhan = false;
            getBienSo(widget.id ?? "", HangMuc_Id ?? "", soKhungController.text);
            postDataFireBase(_thongbao, body ?? "", _data?.nguoiYeuCau ?? "");
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

  Future<void> postData(LichSuBaoDuongNewModel? scanData, String? ngay) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;

      var dataList = [newScanData];
      final http.Response response = await requestHelper.postData('MMS_BaoCao/YeuCauBaoDuong_QuanLy?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&NgayDiBaoDuong=$ngay', dataList.map((e) => e?.toJson()).toList());
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

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : RefreshIndicator(
            onRefresh: () async {
              await getBienSo(widget.id ?? "", HangMuc_Id ?? "", soKhungController.text);
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
                                    height: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h,
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
                                              "Hạng mục",
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
                                                  items: _hangmuc?.map((item) {
                                                    return DropdownMenuItem<String>(
                                                      value: item.id,
                                                      child: Container(
                                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                        child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: Text(
                                                            item.noiDungBaoDuong ?? "",
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
                                                  value: HangMuc_Id,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      HangMuc_Id = newValue;
                                                    });
                                                    if (newValue != null) {
                                                      if (newValue == '') {
                                                        getBienSo(widget.id ?? "", "", soKhungController.text);
                                                      } else {
                                                        getBienSo(widget.id ?? "", newValue, soKhungController.text);
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
                                                          hintText: 'Tìm hạng mục',
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
                                                        return _hangmuc?.any((baiXe) => baiXe.id == itemId && baiXe.noiDungBaoDuong?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                            getBienSo(widget.id ?? "", HangMuc_Id ?? "", soKhungController.text);
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
                                              text: "Danh sách hạng mục: ",
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
                                  _buildTableOptions(context),
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
