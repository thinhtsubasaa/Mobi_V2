import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/kpi/DanhGiaKPI.dart';
import 'package:Thilogi/models/kpi/ghichu.dart';
import 'package:Thilogi/models/kpi/phongban.dart';
import 'package:Thilogi/services/request_helper_kpi.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../../blocs/user_bloc.dart';
import '../../../models/checksheet.dart';
import '../../../models/kpi/TraPhieuKPI.dart';
import '../../../models/kpi/config.dart';
import '../../../models/kpi/donvi.dart';
import '../../../models/kpi/kydanhgia.dart';
import '../../../models/kpi/lichsukpi.dart';
import '../../../models/kpi/user.dart';
import '../../../widgets/loading.dart';
import '../PheDuyetKPI/ChiTietGiaoChiTieuKPI_CaNhan/ChitietGiaoChiTieuKPI.dart';
import 'ChinhSuaGiaoKPI/ChinhSuaGiaoChiTieuKPI.dart';

class CustomBodyGiaoKPI extends StatelessWidget {
  CustomBodyGiaoKPI();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyGiaoKPIScreen(
      lstFiles: [],
    ));
  }
}

class BodyGiaoKPIScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyGiaoKPIScreen({super.key, required this.lstFiles});

  @override
  _BodyGiaoKPIScreenState createState() => _BodyGiaoKPIScreenState();
}

class _BodyGiaoKPIScreenState extends State<BodyGiaoKPIScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperKPI requestHelper = RequestHelperKPI();

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

  bool selectAll = false;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  String? doiTac_Id;
  List<DonViKPIModel>? _donviList;
  List<DonViKPIModel>? get donviList => _donviList;
  List<PhongBanKPIModel>? _phongbanList;
  List<PhongBanKPIModel>? get phongbanList => _phongbanList;
  List<UserKPIModel>? _userList;
  List<UserKPIModel>? get userList => _userList;
  List<KyDanhGiaModel>? _kyDanhGiaList;
  List<KyDanhGiaModel>? get kyDanhGiaList => _kyDanhGiaList;
  List<DanhGiaKPIModel>? _danhGiaKPIList;
  List<DanhGiaKPIModel>? get danhGiaKPIList => _danhGiaKPIList;
  String? BienSo;
  String? DonViId;
  String? PhongBanId;
  String? UserId;
  String? KyDanhGiaId;
  String? ThangDiemXepLoaiId;
  int? _selectedTpnsId;
  int? chuKyId;
  bool _showFilters = false;
  int? _activeTab = null;
  List<TabFilter> _tabs = [];
  List<Approver> _luongDuyetList = [];
  List<GhiChuModel> _ghiChuList = [];
  List<LichSuModel> _lichSuList = [];

  (Color, Color) _statusColor(int? trangThaiOrNull) {
    if (trangThaiOrNull == null) return (const Color(0xFFB91C1C), Colors.white); // Tổng cộng
    switch (trangThaiOrNull) {
      case 1:
        return (const Color(0x1A0000FF), const Color(0xFF0000FF)); // Chờ bạn duyệt
      case 2:
        return (const Color(0xFFFFF1C2), const Color(0xFFB45309)); // Đang xử lý
      case 3:
        return (const Color(0xFFE9FFF5), const Color(0xFF047857)); // Hoàn thành
      case 4:
        return (const Color(0xFFFFE4E4), const Color(0xFFB91C1C)); // Trả lại
      case 5:
        return (const Color(0xFFFFE4E4), const Color(0xFFB91C1C)); // Trả lại
      default:
        return (const Color(0xFFF3F4F6), Colors.black87);
    }
  }

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    setState(() {
      chuKyId = AppConfig.LIST_CHU_KY_DANHGIA.first.id;
      _loadKyTheoChuKy(chuKyId);
    });
    getDonVi();
  }

  Future<void> _loadKyTheoChuKy(int? chuKy) async {
    await getKyDanhGia(chuKy); // Hàm của bạn: sau call, _kyDanhGiaList được gán
    _selectDefaultKy(); // -> chọn kỳ theo thời điểm hiện tại
  }

  TabFilter get _currentTab => _tabs.isNotEmpty
      ? _tabs[_activeTab ?? 0]
      : const TabFilter(
          label: 'Tổng cộng',
          count: 0,
          bg: const Color(0xFFF3F4F6),
          fg: Colors.black87,
          trangThai: null,
        );

  Future<void> _refreshByCurrentTab() {
    final t = _currentTab;
    return getListData(
      DonViId,
      PhongBanId,
      _textController.text,
      KyDanhGiaId,
      t.trangThai, // <- có thể null (OK)
      UserId,
      chuKyId,
      _selectedTpnsId,
      t.gradeId, // <- có thể null (OK)
    );
  }

  /// Chọn kỳ mặc định theo tháng/năm hiện tại
  void _selectDefaultKy() {
    final list = _kyDanhGiaList ?? [];
    if (list.isEmpty) return;

    final now = DateTime.now();

    String target;
    if (chuKyId == 2) {
      // Năm
      target = '${now.year}';
    } else {
      // Tháng (mặc định)
      final mm = now.month.toString().padLeft(2, '0');
      target = '$mm/${now.year}';
    }

    String? foundId;
    for (final k in list) {
      if (k.thoiDiem == target) {
        foundId = k.id;
        break;
      }
    }

    setState(() {
      KyDanhGiaId = foundId ?? list.first.id; // nếu không có tháng hiện tại thì lấy phần tử đầu
      getListData(DonViId ?? "", PhongBanId ?? "", _textController.text ?? "", KyDanhGiaId ?? "", _activeTab ?? null, UserId ?? "", chuKyId ?? 1, _selectedTpnsId ?? 0, ThangDiemXepLoaiId);
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _textController.dispose();
    super.dispose();
  }

  String buildQuery(Map<String, dynamic> params) {
    // loại bỏ null / rỗng
    params.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
    // tất cả value -> String
    final qp = params.map((k, v) => MapEntry(k, v.toString()));
    return Uri(queryParameters: qp).query; // "a=1&b=x"
  }

  Future<void> getListData(
    String? vptqKpiDonViKpiId,
    String? phongBanThacoId,
    String? keyword,
    String? vptqKpiKyDanhGiaKpiId,
    int? trangThai,
    String? userId,
    int? chuKy,
    int? isLanhDaoTiemNang, // 2:true, 1:false, khác:null
    String? vptqKpiThangDiemXepLoaiChiTietId,
  ) async {
    try {
      bool? isLDTNBool;
      if (isLanhDaoTiemNang == 2)
        isLDTNBool = true;
      else if (isLanhDaoTiemNang == 1) isLDTNBool = false;

      final q = buildQuery({
        'vptq_kpi_DonViKPI_Id': vptqKpiDonViKpiId,
        'phongBanThaco_Id': phongBanThacoId,
        'keyword': keyword,
        'page': -1,
        'vptq_kpi_KyDanhGiaKPI_Id': vptqKpiKyDanhGiaKpiId,
        'trangThai': trangThai,
        'user_Id': userId,
        'chuKy': chuKy,
        'isLanhDaoTiemNang': isLDTNBool,
        'vptq_kpi_ThangDiemXepLoaiChiTiet_Id': vptqKpiThangDiemXepLoaiChiTietId,
      });
      final http.Response response = await requestHelper.getData('vptq_kpi_KPICaNhan${q.isEmpty ? '' : '?$q'}');
      if (response.statusCode == 200) {
        final map = jsonDecode(response.body);

        // page=-1: data ở top-level; page>=1: data nằm trong datalist.data
        List listJson = (map['data'] as List?) ?? (map['datalist']?['data'] as List?) ?? const [];
        final dl = map as Map<String, dynamic>; // page=-1 thì map ở top-level
        print("data: $dl");

        final st = <TabFilter>[
          (() {
            final (bg, fg) = _statusColor(null);
            return TabFilter(label: 'Thực hiện', count: dl['soLuong'] ?? 0, bg: bg, fg: fg, trangThai: null);
          })(),
          (() {
            final (bg, fg) = _statusColor(1);
            return TabFilter(label: 'Chờ bạn duyệt', count: dl['soLuongChoBanDuyet'] ?? 0, bg: bg, fg: fg, trangThai: 1);
          })(),
          (() {
            final (bg, fg) = _statusColor(2);
            return TabFilter(label: 'Đang xử lý', count: dl['soLuongDangXuLy'] ?? 0, bg: bg, fg: fg, trangThai: 2);
          })(),
          (() {
            final (bg, fg) = _statusColor(3);
            return TabFilter(label: 'Hoàn thành', count: dl['soLuongHoanThanh'] ?? 0, bg: bg, fg: fg, trangThai: 3);
          })(),
          (() {
            final (bg, fg) = _statusColor(4);
            return TabFilter(label: 'Trả lại', count: dl['soLuongTraLai'] ?? 0, bg: bg, fg: fg, trangThai: 4);
          })(),
          (() {
            final (bg, fg) = _statusColor(5);
            return TabFilter(label: 'Không thực hiện', count: dl['soLuongKhongThucHien'] ?? 0, bg: bg, fg: fg, trangThai: 5);
          })(),
        ];

        final items = listJson.map((e) => DanhGiaKPIModel.fromJson(e as Map<String, dynamic>)).toList();
        setState(() {
          _tabs = [...st];
          _danhGiaKPIList = items;
          _loading = false;
        });

        print("body: $items");
        // setState(() {
        //   _danhGiaKPIList = items;
        //   _tabs = builtTabs;
        //   _loading = false;
        // });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> _onPickTab(int i) async {
    setState(() => _activeTab = i);
    // final f = _tabs[i];
    // print("Pick tab: $i, ${f.label}, trạng thái=${f.trangThai}, xếp loại=${f.gradeId}");
    // getListData(
    //   DonViId,
    //   PhongBanId,
    //   _textController.text,
    //   KyDanhGiaId,
    //   f.trangThai, // <<< key tình trạng
    //   UserId,
    //   chuKyId,
    //   _selectedTpnsId,
    //   f.gradeId, // <<< key xếp loại
    // );
    await _refreshByCurrentTab();
  }

  void getDonVi() async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_Duyet/filter-don-vi-kpi');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _donviList = (decodedData as List).map((item) => DonViKPIModel.fromJson(item)).toList();
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getPhongBan(String? donVi_Id) async {
    print("DonVi_Id = $donVi_Id");
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_DonViKPI/phong-ban-co-nguoi?vptq_kpi_DonViKPI_Id=$donVi_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _phongbanList = (decodedData as List).map((item) => PhongBanKPIModel.fromJson(item)).toList();

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

  Future<void> getKyDanhGia(int? chuky) async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_KyDanhGiaKPI?chuKy=$chuky&page=-1');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _kyDanhGiaList = (decodedData as List).map((item) => KyDanhGiaModel.fromJson(item)).toList();
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

  Future<void> getUser(String? donVi_Id, String? phongBan_Id, String? keyword) async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_DonViKPI/user-by-don-vi-kpi?vptq_kpi_DonViKPI_Id=$donVi_Id&phongBanThaco_Id=$phongBan_Id&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _userList = (decodedData as List).map((item) => UserKPIModel.fromJson(item)).toList();
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

  Widget _buildFilterPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft, // Căn sát lề trái
          padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
          child: const Text(
            "Đơn vị:",
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
                color: Color(0x99DDDDDD),
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                items: _donviList?.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.vptq_kpi_DonViKPI_Id,
                    child: Container(
                      child: Text(
                        item.tenDonViKPI ?? "",
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
                hint: const Text(
                  'Chọn đơn vị',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF), // xám nhạt
                  ),
                ),
                value: DonViId,
                onChanged: (newValue) async {
                  setState(() {
                    DonViId = newValue ?? "";
                  });
                  if (newValue != null) {
                    getPhongBan(newValue);
                    // getListData(newValue, PhongBanId ?? "", _textController.text ?? "", KyDanhGiaId ?? "", _activeTab ?? null, UserId ?? "", chuKyId ?? 1, _selectedTpnsId ?? 0, ThangDiemXepLoaiId);

                    await _refreshByCurrentTab();
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
                      return _donviList?.any((viTri) => viTri.vptq_kpi_DonViKPI_Id == itemId && viTri.tenDonViKPI?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
            "Phòng ban:",
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
                color: Color(0x99DDDDDD),
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                items: _phongbanList?.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.phongBanThaco_Id,
                    child: Container(
                      child: Text(
                        item.tenPhongBan ?? "",
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
                hint: const Text(
                  'Chọn phòng ban',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF), // xám nhạt
                  ),
                ),
                value: PhongBanId,
                onChanged: (newValue) async {
                  setState(() {
                    PhongBanId = newValue ?? "";
                  });
                  if (newValue != null) {
                    getUser(DonViId, newValue, "");
                    // getListData(DonViId, newValue, _textController.text ?? "", KyDanhGiaId ?? "", _activeTab ?? null, UserId ?? "", chuKyId ?? 1, _selectedTpnsId ?? 0, ThangDiemXepLoaiId);
                    await _refreshByCurrentTab();
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
                        hintText: 'Tìm phòng ban',
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
                      return _phongbanList?.any((viTri) => viTri.phongBanThaco_Id == itemId && viTri.tenPhongBan?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
        const SizedBox(
          height: 5,
        ),
        Row(children: [
          Expanded(
              child: Column(children: [
            Container(
              alignment: Alignment.centerLeft, // Căn sát lề trái
              padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
              child: const Text(
                "Chu kỳ:",
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
                    color: Color(0x99DDDDDD),
                    width: 1.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    isExpanded: true,
                    items: AppConfig.LIST_CHU_KY_DANHGIA?.map((item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Container(
                          child: Text(
                            item.name ?? "",
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
                    value: chuKyId,
                    onChanged: (newValue) {
                      setState(() {
                        chuKyId = newValue;
                      });
                      if (newValue != 0) {
                        getKyDanhGia(newValue);
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
                            hintText: 'Tìm chu kỳ',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        if (item is DropdownMenuItem<int>) {
                          // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                          int itemId = item.value ?? 0;
                          // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                          return AppConfig.LIST_CHU_KY_DANHGIA?.any((viTri) => viTri.id == itemId && viTri.name?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                ))
          ])),
          SizedBox(width: 5),
          Expanded(
              child: Column(children: [
            Container(
              alignment: Alignment.centerLeft, // Căn sát lề trái
              padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
              child: const Text(
                "Kỳ đánh giá:",
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
                    color: Color(0x99DDDDDD),
                    width: 1.5,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    items: _kyDanhGiaList?.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.id,
                        child: Container(
                          child: Text(
                            item.thoiDiem ?? "",
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
                    value: KyDanhGiaId,
                    onChanged: (newValue) async {
                      setState(() {
                        KyDanhGiaId = newValue ?? "";
                      });
                      if (newValue != null) {
                        final t = _tabs[_activeTab ?? 0];

                        // getListData(DonViId ?? "", PhongBanId ?? "", _textController.text ?? "", newValue, t.trangThai, UserId ?? "", chuKyId ?? 1, _selectedTpnsId ?? 0, t.gradeId);
                        await _refreshByCurrentTab();
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
                            hintText: 'Tìm kỳ đánh giá',
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
                          return _kyDanhGiaList?.any((viTri) => viTri.id == itemId && viTri.thoiDiem?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                ))
          ]))
        ]),
        Container(
          alignment: Alignment.centerLeft, // Căn sát lề trái
          padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
          child: const Text(
            "Cấp độ nhân sự:",
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
                color: Color(0x99DDDDDD),
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<int>(
                isExpanded: true,
                items: AppConfig.TPNS_LIST?.map((item) {
                  return DropdownMenuItem<int>(
                    value: item.id,
                    child: Container(
                      child: Text(
                        item.name ?? "",
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
                value: _selectedTpnsId,
                hint: const Text(
                  'Chọn cấp độ nhân sự',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF), // xám nhạt
                  ),
                ),
                onChanged: (newValue) async {
                  setState(() {
                    _selectedTpnsId = newValue;
                  });
                  if (newValue != 0) {
                    // getListData(DonViId, KyDanhGiaId, _textController.text ?? "", KyDanhGiaId ?? "", _activeTab ?? null, UserId ?? "", chuKyId ?? 1, newValue, ThangDiemXepLoaiId);
                    await _refreshByCurrentTab();
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
                        hintText: 'Tìm nhân viên',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    if (item is DropdownMenuItem<int>) {
                      // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                      int itemId = item.value ?? 0;
                      // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                      return AppConfig.TPNS_LIST?.any((viTri) => viTri.id == itemId && viTri.name?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
        Container(
          alignment: Alignment.centerLeft, // Căn sát lề trái
          padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
          child: const Text(
            "Nhân viên:",
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
                color: Color(0x99DDDDDD),
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                items: _userList?.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.id,
                    child: Container(
                      child: Text(
                        "${item.maNhanVien} - ${item.fullName}" ?? "",
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
                value: UserId,
                hint: const Text(
                  'Chọn nhân viên',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF), // xám nhạt
                  ),
                ),
                onChanged: (newValue) async {
                  setState(() {
                    UserId = newValue ?? "";
                  });
                  if (newValue != null) {
                    // getListData(DonViId, KyDanhGiaId, _textController.text ?? "", KyDanhGiaId ?? "", _activeTab ?? null, newValue, chuKyId ?? 1, _selectedTpnsId ?? 1, ThangDiemXepLoaiId);
                    await _refreshByCurrentTab();
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
                        hintText: 'Tìm nhân viên',
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
                      return _userList?.any((viTri) => viTri.id == itemId && '${viTri.maNhanVien ?? ''} - ${viTri.fullName ?? ''}'.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
      ],
    );
  }

  void _onTapSearch() async {
    FocusScope.of(context).unfocus(); // đóng bàn phím
    await _refreshByCurrentTab(); // gọi API theo tab hiện tại
  }

  Future<void> exportPDFPI(
    String? id,
    String? doiTuong,
  ) async {
    try {
      final url = 'vptq_kpi_KPICaNhan/export-pdf?id=$id';
      final http.Response res = await requestHelper.postData(url, null);
      if (res.statusCode != 200) return;

      final root = jsonDecode(res.body);
      // React dùng res.data.datapdf → lấy linh hoạt:
      final String? b64 = (root['data']?['datapdf'] ?? root['datapdf'])?.toString();

      if (b64 == null || b64.isEmpty) return;

      final bytes = base64Decode(b64);
      final fileName = 'KPICaNhan_$doiTuong.pdf';

      await openPdfOnMobile(bytes, fileName);
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> exportExcel(
    String? id,
    String? doiTuong,
  ) async {
    try {
      final url = 'vptq_kpi_KPICaNhan/export-excel?id=$id';
      final http.Response res = await requestHelper.postData(url, null);
      if (res.statusCode != 200) return;

      final root = jsonDecode(res.body);
      print("root:${res.statusCode}");
      // React dùng res.data.datapdf → lấy linh hoạt:
      String? b64 = root['dataexcel']?.toString();

      if (b64 == null || b64.isEmpty) return;

      final bytes = base64Decode(b64);
      final fileName = 'KPICaNhan_$doiTuong.xlsx';

      await openPdfOnMobile(bytes, fileName);
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> openPdfOnMobile(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$fileName';
    final f = File(path);
    await f.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(f.path); // mở bằng app đọc PDF mặc định
  }

  Future<void> getLuongDuyet(
    String? id,
  ) async {
    try {
      const url = 'vptq_kpi_KPICaNhan/luong-duyet?vptq_kpi_KPICaNhan_Id';
      final http.Response response = await requestHelper.getData('$url=$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded as List).map((e) => Approver.fromJson(e as Map<String, dynamic>)).toList();
        setState(() => _luongDuyetList = list);
      } else {
        setState(() => _luongDuyetList = []);
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getLichSu(
    String? id,
  ) async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_KPICaNhan/lich-su-cap-nhat/$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded as List).map((e) => LichSuModel.fromJson(e as Map<String, dynamic>)).toList();
        setState(() => _lichSuList = list);
      } else {
        setState(() => _lichSuList = []);
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getGhiChu(
    String? id,
  ) async {
    try {
      const url = 'vptq_kpi_KPICaNhan/ghi-chu?isDanhGia=false&vptq_kpi_KPICaNhan_Id';

      final http.Response response = await requestHelper.getData('$url=$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded as List).map((e) => GhiChuModel.fromJson(e as Map<String, dynamic>)).toList();
        setState(() => _ghiChuList = list);
      } else {
        setState(() => _ghiChuList = []);
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> openLuongDuyetDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white, // màu nền trắng
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: StatefulBuilder(
          builder: (ctx, setSt) {
            return Container(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Luồng duyệt',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      splashRadius: 20,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                _buildPaginatedTable(ctx),
              ]),
            );
          },
        ),
      ),
    );
  }

  Future<void> openLichSuDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white, // màu nền trắng
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        child: StatefulBuilder(
          builder: (ctx, setSt) {
            return Container(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Lịch sử cập nhật chỉ tiêu KPI',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      splashRadius: 20,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 0.9, // 90% chiều rộng
                    child: _buildPaginatedTable2(ctx),
                  ),
                )
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaginatedTable(BuildContext context) {
    final items = _luongDuyetList;

    final dataSource = KeHoachDataSource(items);

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
          PaginatedDataTable(
            columns: const [
              DataColumn(label: Text('STT')),
              DataColumn(label: Text('Người thực hiện')),
              DataColumn(label: Text('Trạng thái')),
              DataColumn(label: Text('Ngày thực hiện')),
            ],
            source: dataSource,
            rowsPerPage: 5,
            showCheckboxColumn: false,
            columnSpacing: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginatedTable2(BuildContext context) {
    final items = _lichSuList;

    final dataSource = KeHoachDataSource2(items);

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
          PaginatedDataTable(
            columns: const [
              DataColumn(label: Text('STT')),
              DataColumn(label: Text('Thời gian')),
              DataColumn(label: Text('Người thực hiện')),
            ],
            source: dataSource,
            rowsPerPage: 5,
            showCheckboxColumn: false,
            columnSpacing: 30,
          ),
        ],
      ),
    );
  }

  Widget _line(String k, String? v) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text.rich(TextSpan(children: [
          TextSpan(text: '$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: (v == null || v.isEmpty) ? '—' : v),
        ])),
      );
  Future<void> openGhiChuDialog(
      // lọc theo thứ tự nếu cần
      ) async {
    // lọc + sort mới nhất trước
    final data = _ghiChuList.reversed.toList();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: StatefulBuilder(
          builder: (ctx, setSt) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text('Ghi chú', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 22),
                        splashRadius: 20,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 420, minWidth: 480),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (_, i) {
                        final item = data[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.tenNguoiDuyet,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB91C1C), fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            _line('Ghi chú', item.ghiChu),
                            _line('Phòng ban', item.tenPhongBan ?? '—'),
                            _line('Thời gian phản hồi', item.ngayTao),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> saveData(
    String? id,
  ) async {
    try {
      setState(() => _isLoading = true);

      final res = await requestHelper.deleteData(
        'vptq_kpi_KPICaNhan/$id',
        null, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Xác nhận xoá giao chỉ tiêu KPI cá nhân thành công',
          confirmBtnText: 'Đồng ý',
          // onConfirmBtnTap: () {
          //   Navigator.pop(context);
          //   Navigator.pop(context);
          // },
        );
        _btnController.reset();
        await _refreshByCurrentTab();
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: res.body.replaceAll('"', ''),
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: e.toString(),
        confirmBtnText: 'Đồng ý',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfirmationDialogDeleted(
    BuildContext context,
    String? id,
    String? tenUser,
  ) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn sẽ xoá giao chỉ tiêu KPI cá nhân $tenUser ?',
        title: '',
        confirmBtnText: 'Xác nhận',
        cancelBtnText: 'Huỷ',
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
          saveData(id);
        });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : RefreshIndicator(
            onRefresh: () async {
              await _refreshByCurrentTab();
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: Column(
                                children: [
                                  // Search + Filter
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _textController,
                                          onSubmitted: (_) => _onTapSearch(),
                                          decoration: InputDecoration(
                                            hintText: 'Tìm kiếm.......',
                                            prefixIcon: IconButton(
                                              icon: const Icon(Icons.search),
                                              onPressed: _onTapSearch,
                                              tooltip: 'Tìm kiếm',
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF3F4F6),
                                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(24),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      FilledButton.tonalIcon(
                                        onPressed: () => setState(() => _showFilters = !_showFilters),
                                        icon: Icon(_showFilters ? Icons.expand_less : Icons.tune),
                                        label: const Text('Bộ lọc'),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AnimatedCrossFade(
                                    duration: const Duration(milliseconds: 200),
                                    crossFadeState: _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                    firstChild: const SizedBox.shrink(), // Ẩn
                                    secondChild: _buildFilterPanel(context), // Hiện
                                  ),
                                  const SizedBox(height: 10),

                                  // Tabs (pills)
                                  SizedBox(
                                    height: 44, // cao của pill, chỉnh tùy bạn
                                    child: Row(
                                      children: [
                                        // phần tab cuộn ngang
                                        Expanded(
                                          child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.only(right: 8), // chừa chút khoảng với nút "..."
                                              child: Row(
                                                children: List.generate(_tabs.length, (i) {
                                                  final selected = _activeTab == i;
                                                  final t = _tabs[i];
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      shape: const StadiumBorder(),
                                                      clipBehavior: Clip.antiAlias,
                                                      child: Ink(
                                                        decoration: BoxDecoration(
                                                          color: t.bg,
                                                          borderRadius: BorderRadius.circular(999),
                                                          boxShadow: selected ? [BoxShadow(color: t.bg.withOpacity(.35), blurRadius: 12, offset: Offset(0, 3))] : [],
                                                        ),
                                                        child: InkWell(
                                                          borderRadius: BorderRadius.circular(999),
                                                          onTap: () => _onPickTab(i),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                                                              Text(t.label, style: TextStyle(color: t.fg, fontWeight: FontWeight.w700)),
                                                              const SizedBox(width: 4),
                                                              Text('(${t.count})', style: TextStyle(color: t.fg, fontWeight: FontWeight.bold)),
                                                            ]),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              )),
                                        ),

                                        // nút "..." GHIM BÊN PHẢI
                                        const SizedBox(width: 6),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(999),
                                            onTap: () async {
                                              final picked = await showModalBottomSheet<int>(
                                                context: context,
                                                useSafeArea: true,
                                                barrierColor: Colors.black.withOpacity(0.15),
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                                ),
                                                builder: (ctx) {
                                                  const spacing = 12.0;
                                                  int localActive = _activeTab ?? 0;

                                                  return StatefulBuilder(
                                                    builder: (ctx, setSheetState) {
                                                      return Padding(
                                                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              width: 44,
                                                              height: 4,
                                                              margin: const EdgeInsets.only(bottom: 16),
                                                              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
                                                            ),
                                                            LayoutBuilder(builder: (context, c) {
                                                              final itemW = (c.maxWidth - spacing) / 2;
                                                              return ConstrainedBox(
                                                                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
                                                                child: SingleChildScrollView(
                                                                  child: Wrap(
                                                                      spacing: spacing,
                                                                      runSpacing: spacing,
                                                                      children: List.generate(_tabs.length, (i) {
                                                                        final t = _tabs[i]; // <-- lấy object
                                                                        final selected = _activeTab == i; // <-- đang chọn?

                                                                        return SizedBox(
                                                                          width: itemW,
                                                                          child: _StatusPill(
                                                                            label: t.label,
                                                                            count: t.count,
                                                                            bg: t.bg, // <-- dùng màu từ object
                                                                            fg: t.fg,
                                                                            selected: selected,
                                                                            // onTap: () => Navigator.pop(ctx, i),
                                                                            onTap: () {
                                                                              // 1) Đổi tab + gọi API ở màn chính
                                                                              _onPickTab(i);
                                                                              // 2) Cập nhật tick trong sheet, KHÔNG pop
                                                                              setSheetState(() => localActive = i);
                                                                            },
                                                                          ),
                                                                        );
                                                                      })),
                                                                ),
                                                              );
                                                            }),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                              // if (picked != null) setState(() => _activeTab = picked);
                                              if (picked != null) _onPickTab(picked);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: const BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.more_horiz, size: 20, color: Colors.black87),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  if (_danhGiaKPIList != null && _danhGiaKPIList!.isNotEmpty)
                                    ListView.separated(
                                      shrinkWrap: true, // <<<
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                      itemCount: _danhGiaKPIList!.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (_, i) {
                                        final e = _danhGiaKPIList![i];
                                        // final canRate = !(e.isHoanThanhDanhGia ?? false); // tuỳ logic bạn
                                        final canRate = ((e.isDong == false) && (e.user_Id == _ub?.id) && (e.nguoiDuyetDanhGia1Id == null)) || (e.isCoQuyenChuyenVienKPI == true && (e.isHoanThanh == true || (e.isThucHienChinhSuaCVKPI == true && e.viTriDuyet == 0)));
                                        final canDelete = ((e.isDong == false && e.user_Id == _ub?.id && e.nguoiDuyetDanhGia1Id == null && e.isThucHienChinhSuaCVKPI == false) || (e.isCoQuyenChuyenVienKPI == true && e.isHoanThanh == false));

                                        return KpiCard(
                                            item: e,
                                            onRate: canRate
                                                ? () {
                                                    nextScreen(context, ChinhSuaGiaoChiTieuKPIPage(id: e.id, kyDanhGia: e.vptqKpiKyDanhGiaKpiId ?? '', isChiTiet: true));
                                                  }
                                                : null,
                                            menuPressed: () async {
                                              final action = await showFilterSheet(context, canRate: canRate, canDelete: canDelete); // <-- dùng bottom sheet ở đây

                                              if (!context.mounted) return;
                                              if (action == null) return;
                                              switch (action) {
                                                case FilterAction.danhGia:
                                                  nextScreen(context, ChinhSuaGiaoChiTieuKPIPage(id: e.id, kyDanhGia: e.vptqKpiKyDanhGiaKpiId ?? '', isChiTiet: true));
                                                  break;
                                                case FilterAction.xoa:
                                                  _showConfirmationDialogDeleted(context, e.id, e.tenUser);
                                                  break;
                                                case FilterAction.taiExcel:
                                                  await exportExcel(e.id, e.tenUser);
                                                  break;
                                                case FilterAction.taiPdf:
                                                  await exportPDFPI(e.id, e.tenUser);
                                                  break;
                                                case FilterAction.xemChiTiet:
                                                  nextScreen(context, ChiTietGiaoChiTieuKPIPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: true));
                                                  break;
                                                case FilterAction.lichSu:
                                                  await getLichSu(e.id);
                                                  await openLichSuDialog();
                                                  break;

                                                case FilterAction.xemGhiChu:
                                                  await getGhiChu(e.id);
                                                  if (!mounted) break;
                                                  await openGhiChuDialog();
                                                  break;
                                                case FilterAction.luongDuyet:
                                                  await getLuongDuyet(e.id);
                                                  if (!mounted) break;

                                                  await openLuongDuyetDialog();
                                                  break;
                                              }
                                            });
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
                ],
              ),
            ),
          );
  }
}

enum FilterAction { danhGia, taiExcel, taiPdf, xemChiTiet, xemGhiChu, luongDuyet, xoa, lichSu }

Future<FilterAction?> showFilterSheet(BuildContext context, {required bool canRate, required bool canDelete}) {
  return showModalBottomSheet<FilterAction>(
    context: context,
    useSafeArea: true,
    barrierColor: Colors.black.withOpacity(0.15),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
              ),
              // items
              _SheetItem(
                icon: Icons.edit_outlined,
                label: 'Chỉnh sửa',
                onTap: canRate ? () => Navigator.pop(ctx, FilterAction.danhGia) : null,
                // onTap: () => Navigator.pop(ctx, FilterAction.danhGia),
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.delete_outlined,
                label: 'Xoá',
                onTap: canDelete ? () => Navigator.pop(ctx, FilterAction.xoa) : null,
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.file_download_outlined,
                label: 'Tải file excel',
                onTap: () => Navigator.pop(ctx, FilterAction.taiExcel),
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Tải file PDF',
                onTap: () => Navigator.pop(ctx, FilterAction.taiPdf),
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.visibility_outlined,
                label: 'Xem chi tiết',
                onTap: () => Navigator.pop(ctx, FilterAction.xemChiTiet),
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.history_outlined,
                label: 'Lịch sử',
                onTap: () => Navigator.pop(ctx, FilterAction.lichSu),
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.chat_bubble_outline,
                label: 'Xem ghi chú',
                onTap: () => Navigator.pop(ctx, FilterAction.xemGhiChu),
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.sync_outlined,
                label: 'Luồng duyệt',
                onTap: () => Navigator.pop(ctx, FilterAction.luongDuyet),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _SheetItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color fg = enabled ? Colors.black87 : Theme.of(context).disabledColor;
    return InkWell(
      onTap: enabled ? onTap : null,
      splashColor: enabled ? null : Colors.transparent,
      highlightColor: enabled ? null : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final int count;
  final Color bg, fg;
  final bool selected;
  final VoidCallback onTap;

  const _StatusPill({
    required this.label,
    required this.count,
    required this.bg,
    required this.fg,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: bg, // luôn theo màu trạng thái
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? (fg) : Colors.transparent,
              width: selected ? 2 : 0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max, // chiếm full chiều ngang pill
            mainAxisAlignment: MainAxisAlignment.center, // nhìn cân giữa
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 16, color: Colors.green),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '($count)',
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ==== Widgets ==== */

class KpiCard extends StatefulWidget {
  const KpiCard({
    super.key,
    required this.item,
    required this.menuPressed,
    this.onRate,
  });

  final DanhGiaKPIModel item;
  final VoidCallback? onRate;
  final VoidCallback menuPressed;

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  bool _expanded = false; // mở mặc định
  static const kHPad = 16.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = BorderRadius.circular(14);
    final st = _statusOf(widget.item); // label + màu

    return Material(
      color: cs.surface,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: border,
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: border,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: tên + trạng thái (sát trái theo kHPad)
              Container(
                color: const Color(0xFFF3F3F5),
                padding: const EdgeInsets.fromLTRB(kHPad, 12, kHPad, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.item.tenUser ?? '—',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB91C1C),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => setState(() => _expanded = !_expanded),
                            child: Icon(
                              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 22,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: st.bg, borderRadius: BorderRadius.circular(20)),
                      child: Text(st.label, style: TextStyle(color: st.fg, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),

              // Body: chỉ hiện khi _expanded (đúng hình 3 khi thu gọn)

              Container(
                color: const Color(0xFFF3F3F5),
                padding: const EdgeInsets.fromLTRB(kHPad, 6, kHPad, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('1. Thông tin nhân sự'),
                    _line('Mã nhân viên', widget.item.maUser),
                    _line('Chức danh', widget.item.tenChucDanh),
                    if (_expanded) ...[
                      _line('Cấp độ nhân sự', widget.item.capDoNhanSu),
                      const SizedBox(height: 8),
                      _sectionTitle('2. Kỳ & mốc thời gian'),
                      _line('Năm', (widget.item.nam ?? '').toString()),
                      _line('Chu kỳ đánh giá', _chuKyLabel(widget.item.chuKy)),
                      _line('Kỳ đánh giá', widget.item.thoiDiem),
                      _line('Thời gian tạo', widget.item.ngayTao),
                      _line('Thời gian hoàn thành', widget.item.thoiGianHoanThanh ?? '—'),
                      const SizedBox(height: 8),
                      _sectionTitle('3. Quy trình thẩm định/phê duyệt'),
                      _line('Đánh giá', widget.item.tenNguoiDuyet1),
                      _line('Xem xét 1', widget.item.tenNguoiDuyet2 ?? '—'),
                      _line('Xem xét 2', widget.item.tenNguoiDuyet3 ?? '—'),
                      _line('Phòng QT KPI', widget.item.tenNguoiDuyet4 ?? '—'),
                      _line('Lãnh đạo Phê duyệt', widget.item.tenNguoiDuyet5 ?? '—'),
                      const SizedBox(height: 8),
                      _sectionTitle('4. Điểm số & kết quả'),
                      _line('Kết quả đánh giá', _numToText(widget.item.diemKetQuaTamThoi)),
                      _line('Điểm cộng', _numToText(widget.item.diemCong)),
                      _line('Điểm trừ', _numToText(widget.item.diemTru)),
                      _line('Kết quả cuối cùng', _numToText(widget.item.diemKetQua ?? widget.item.diemKetQuaTamThoi)),
                      _lineEmphasize('Xếp loại', widget.item.xepLoai),
                    ]
                  ],
                ),
              ),

              // Footer luôn hiện (đúng hình 3)
              Container(
                color: const Color(0xFFF3F3F5),
                padding: const EdgeInsets.fromLTRB(kHPad, 12, kHPad, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: widget.onRate,
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.onRate != null ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('CHỈNH SỬA', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .3)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: widget.menuPressed,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: const Icon(Icons.more_horiz),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- helpers ----------
  Widget _sectionTitle(String s) => Text(
        s,
        style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
      );

  Widget _line(String k, String? v) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text.rich(TextSpan(children: [
          TextSpan(text: '$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: (v == null || v.isEmpty) ? '—' : v),
        ])),
      );

  Widget _lineEmphasize(String k, String? v) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(text: '$k: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(
              text: (v == null || v.isEmpty) ? '—' : v,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      );

  String _chuKyLabel(int? chuKy) {
    switch (chuKy) {
      case 2:
        return 'Năm';
      case 1:
      default:
        return 'Tháng';
    }
  }

  String _numToText(num? n) => n == null ? '—' : n.toString();

  _Status _statusOf(DanhGiaKPIModel e) {
    // Ưu tiên flags nếu có
    if (e.isTraLaiDanhGia == true) {
      return const _Status('Trả lại', Color(0xFFFFE4E4), Color(0xFFB91C1C));
    }
    if (e.isHoanThanhDanhGia == true) {
      return const _Status('Hoàn thành', Color(0xFFE9FFF5), Color(0xFF047857));
    }
    // Theo mã trạng thái (tùy bạn map lại cho đúng backend)
    switch (e.trangThai) {
      case 1:
        return const _Status('Chờ duyệt', Color(0x1A0000FF), Color(0xFF0000FF));
      case 2:
        return const _Status('Đang xử lý', Color(0xFFFFF1C2), Color(0xFFB45309));
      case 3:
        return const _Status('Hoàn thành', Color(0xFFE9FFF5), Color(0xFF047857));
      case 4:
        return const _Status('Trả lại', Color(0xFFFFE4E4), Color(0xFFB91C1C));
      case 5:
        return const _Status('Không thực hiện', Color(0xFFFFE4E4), Color(0xFFB91C1C));
      default:
        return const _Status('Không thực hiện', Color(0xFFFFE4E4), Color(0xFFB91C1C));
    }
  }
}

class _Status {
  final String label;
  final Color bg;
  final Color fg;
  const _Status(this.label, this.bg, this.fg);
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 13.5,
          height: 1.2,
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.count, required this.fg, required this.bg});
  final int count;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(fontWeight: FontWeight.w700, color: fg),
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

class KeHoachDataSource extends DataTableSource {
  final List<Approver> rows;

  KeHoachDataSource(this.rows);

  @override
  DataRow getRow(int index) {
    final r = rows[index];

    DataCell cellC(String? v) => DataCell(Center(child: Text(v ?? '', textAlign: TextAlign.center)));
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        cellC(r.tenNguoiDuyet),
        cellC(r.thoiGianDuyet != null ? "Đã duyệt" : "Chưa duyệt"),
        cellC(r.thoiGianDuyet),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => rows.length;
  @override
  int get selectedRowCount => 0;
}

class KeHoachDataSource2 extends DataTableSource {
  final List<LichSuModel> rows;

  KeHoachDataSource2(this.rows);

  @override
  DataRow getRow(int index) {
    final r = rows[index];

    DataCell cellC(String? v) => DataCell(Center(child: Text(v ?? '', textAlign: TextAlign.center)));
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        cellC(r.thoiGian),
        cellC(r.tenNguoiChinhSua),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => rows.length;
  @override
  int get selectedRowCount => 0;
}
