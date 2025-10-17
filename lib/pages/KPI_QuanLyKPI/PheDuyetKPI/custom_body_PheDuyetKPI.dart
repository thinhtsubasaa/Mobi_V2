import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/kpi/phongban.dart';
import 'package:Thilogi/services/request_helper_kpi.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../../blocs/user_bloc.dart';
import '../../../models/checksheet.dart';
import '../../../models/kpi/PheDuyetKPI.dart';
import '../../../models/kpi/TraPhieuKPI.dart';
import '../../../models/kpi/config.dart';
import '../../../models/kpi/donvi.dart';
import '../../../models/kpi/ghichu.dart';
import '../../../models/kpi/kydanhgia.dart';
import '../../../models/kpi/user.dart';
import '../../../widgets/loading.dart';
import '../DanhGiaKPI/XemChiTiet/ChitietKPI.dart';
import 'ChiTietGiaoChiTieuKPI_CaNhan/ChitietGiaoChiTieuKPI.dart';
import 'ChiTietGiaoChiTieuKPI_Donvi/ChitietGiaoChiTieuKPI.dart';
import 'ChiTietPheDuyetKetQuaKPICaNhan/ChitietPheDuyetKetQuaKPI.dart';
import 'XemChiTietDanhGiaKPI_DonVi/ChitietKPI.dart';
import 'XemChiTietDanhMucPi/ChitietDanhMucPi.dart';
import 'package:open_filex/open_filex.dart';

class CustomBodyPheDuyetKPI extends StatelessWidget {
  CustomBodyPheDuyetKPI();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyPheDuyetKPIScreen(
      lstFiles: [],
    ));
  }
}

class BodyPheDuyetKPIScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyPheDuyetKPIScreen({super.key, required this.lstFiles});

  @override
  _BodyPheDuyetKPIScreenState createState() => _BodyPheDuyetKPIScreenState();
}

class _BodyPheDuyetKPIScreenState extends State<BodyPheDuyetKPIScreen> with TickerProviderStateMixin, ChangeNotifier {
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
  final RoundedLoadingButtonController _btnControllerDuyet = RoundedLoadingButtonController();
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
  List<PheDuyetItem>? _danhGiaKPIList;
  List<PheDuyetItem>? get danhGiaKPIList => _danhGiaKPIList;
  PheDuyetItem? _data;
  String? BienSo;
  String? DonViId;
  String? PhongBanId;
  String? UserId;
  String? KyDanhGiaId;
  String? ThangDiemXepLoaiId;
  int? _selectedTpnsId;
  int? chuKyId;
  int? loaiPhieuId;
  bool _showFilters = false;
  String? selectedFromDate;
  String? selectedToDate;
  int? _activeTab = null;
  List<TabFilter> _tabs = [];
  Set<String> _selectedIds = {}; // lưu id các phiếu được chọn
  bool _selectAll = false;
  List<Approver> _viTriTraList = [];
  List<Approver> _luongDuyetList = [];
  List<GhiChuModel> _ghiChuList = [];

  (Color, Color) _statusColor(int? trangThaiOrNull) {
    if (trangThaiOrNull == null) return (const Color(0xFFB91C1C), Colors.white); // Tổng cộng
    switch (trangThaiOrNull) {
      case 5:
        return (const Color(0xFFDDEAFE), const Color(0xFF2563EB)); // Chưa đánh giá
      case 1:
        return (const Color(0x1A0000FF), const Color(0xFF0000FF)); // Chờ bạn duyệt
      case 2:
        return (const Color(0xFFFFF1C2), const Color(0xFFB45309)); // Đang xử lý
      case 3:
        return (const Color(0xFFE9FFF5), const Color(0xFF047857)); // Hoàn thành
      case 4:
        return (const Color(0xFFFFE4E4), const Color(0xFFB91C1C)); // Trả lại
      default:
        return (const Color(0xFFF3F4F6), Colors.black87);
    }
  }

  final List<(Color, Color)> _gradeColors = const [
    (Color(0xFFFFF3C4), Color(0xFF92400E)), // Xuất sắc
    (Color(0xFFE6F0FF), Color(0xFF1D4ED8)), // Vượt yêu cầu
    (Color(0xFFEFFAF1), Color(0xFF166534)), // Đạt yêu cầu
    (Color(0xFFE9F7FF), Color(0xFF0369A1)), // Đạt yêu cầu tối thiểu
    (Color(0xFFF8E7F1), Color(0xFF9D174D)), // Không đạt yêu cầu
    (Color(0xFFFFE4E4), Color(0xFFB91C1C)), // Không đánh giá
  ];

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    setState(() {
      selectedFromDate = DateFormat('dd/MM/yyyy').format(DateTime(DateTime.now().year, DateTime.now().month, 1));
      selectedToDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _refreshByCurrentTab();
    });

    getDonVi();
    getKyDanhGia();
  }

  bool get _canSelectAll {
    if (_danhGiaKPIList == null) return false;
    final userId = _ub?.id; // giống INFO.id bên React
    return _danhGiaKPIList!.any((item) => (item.nguoiDuyetHienTai_Id == userId && item.trangThai == 1) || (item.isThucHienDuyetKPICVDV == true));
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedIds = _danhGiaKPIList!.where((e) => (e.nguoiDuyetHienTai_Id == _ub?.id && e.trangThai == 1) || e.isThucHienDuyetKPICVDV == true).map((e) => e.id!).toSet();
      } else {
        _selectedIds.clear();
      }
    });
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
      loaiPhieuId,
      DonViId,
      t.trangThai,
      selectedFromDate,
      selectedToDate,
      _textController.text,
      PhongBanId,
      _selectedTpnsId,
      KyDanhGiaId,
    );
  }

  Map<String, dynamic> _toBackend(PheDuyetItem e) {
    DateTime? _parseDate(String? s) {
      if (s == null || s.isEmpty) return null;
      // ưu tiên ISO, nếu không thì dd/MM/yyyy
      final iso = DateTime.tryParse(s);
      if (iso != null) return iso.toUtc();
      try {
        final ddmmyyyy = DateFormat('dd/MM/yyyy').parse(s);
        return ddmmyyyy.toUtc();
      } catch (_) {
        return null;
      }
    }

    return {
      "Id": e.id,
      "NguoiDuyetHienTai_Id": e.nguoiDuyetHienTai_Id,
      "LoaiPhieuDuyet": e.loaiPhieuDuyet, // enum/int
      "TenLoaiPhieuDuyet": e.tenLoaiPhieuDuyet,
      "DoiTuong": e.doiTuong,
      "TenNguoiTao": e.tenNguoiTao,
      "TenDonViKPI": e.tenDonViKPI,
      "TenChucDanh": e.tenChucDanh,
      "TenPhongBan": e.tenPhongBan,
      "ThoiDiem": e.thoiDiem,
      "NgayTao": e.ngayTao,
      "ViTriDuyet": e.viTriDuyet,
      "CreatedDate": _parseDate(e.createdDate)?.toIso8601String(),
      "IsFirst": e.isFirst ?? false,
      "IsUyQuyen": e.isUyQuyen ?? false,
      "IsCVKPI": e.isCVKPI ?? false,
      "IsThucHienDuyetKPICVDV": e.isThucHienDuyetKPICVDV ?? false,
      "TrangThai": e.trangThai, // enum/int
    };
  }

  void _onSendApproval() async {
    try {
      setState(() => _isLoading = true);
      if (_danhGiaKPIList == null) return;
      final selected = _danhGiaKPIList!.where((e) => _selectedIds.contains(e.id)).toList();
      if (selected.isEmpty) return;

      final payload = selected.map(_toBackend).toList();

      final res = await requestHelper.putData(
        'vptq_kpi_Duyet/gui-duyet-cap-tren',
        payload, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Gửi duyệt thành công',
          confirmBtnText: 'Đồng ý',
          // onConfirmBtnTap: () {
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

  Future<void> saveData(
    int? loaiPhieuDuyet,
    String? id,
    String? ghiChu,
    int? viTriTra,
  ) async {
    try {
      setState(() => _isLoading = true);
      final payload = {
        "loaiPhieuDuyet": loaiPhieuDuyet,
        "id": id,
        "ghiChu": ghiChu,
        "viTriTra": viTriTra,
      };
      print("payload:$payload");
      final res = await requestHelper.putData(
        'vptq_kpi_Duyet/tra-cap-duoi/$id',
        payload, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Từ chối phiếu thành công',
          confirmBtnText: 'Đồng ý',
          onConfirmBtnTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
        _btnControllerDuyet.reset();
        await _refreshByCurrentTab();
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: res.body.replaceAll('"', ''),
          confirmBtnText: 'Đồng ý',
        );
        _btnControllerDuyet.reset();
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

  void _showConfirmationDialogTuChoi(
    BuildContext context,
    int? loaiPhieuDuyet,
    String? id,
    String? ghiChu,
    int? viTriTra,
  ) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Xác nhận từ chối duyệt?',
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
          _btnControllerDuyet.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          saveData(
            loaiPhieuDuyet,
            id,
            ghiChu,
            viTriTra,
          );
        });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn gửi duyệt không?',
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
          _onSendApproval();
        });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 1)),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedFromDate = DateFormat('dd/MM/yyyy').format(picked.start);
        selectedToDate = DateFormat('dd/MM/yyyy').format(picked.end);
        _loading = false;
      });
      print("TuNgay: $selectedFromDate");
      print("DenNgay: $selectedToDate");
      await _refreshByCurrentTab();
    }
  }

  String buildQuery(Map<String, dynamic> params) {
    // loại bỏ null / rỗng
    params.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
    // tất cả value -> String
    final qp = params.map((k, v) => MapEntry(k, v.toString()));
    return Uri(queryParameters: qp).query; // "a=1&b=x"
  }

  Future<void> getListData(
    int? loaiPhieuDuyet,
    String? vptq_kpi_DonViKPI_Id,
    int? trangThai,
    String? tuNgay,
    String? denNgay,
    String? keyword,
    String? phongBanThaco_Id,
    int? isLanhDaoTiemNang, // 2:true, 1:false, khác:null
    String? vptq_kpi_KyDanhGiaKPI_Id,
  ) async {
    try {
      print("tuNgay:$tuNgay, denNgay:$denNgay");
      bool? isLDTNBool;
      if (isLanhDaoTiemNang == 2)
        isLDTNBool = true;
      else if (isLanhDaoTiemNang == 1) isLDTNBool = false;

      final q = buildQuery({
        'loaiPhieuDuyet': loaiPhieuDuyet,
        'vptq_kpi_DonViKPI_Id': vptq_kpi_DonViKPI_Id,
        'trangThai': trangThai,
        'page': -1,
        'tuNgay': tuNgay,
        'denNgay': denNgay,
        'keyword': keyword,
        'phongBanThaco_Id': phongBanThaco_Id,
        'isLanhDaoTiemNang': isLDTNBool,
        'vptq_kpi_KyDanhGiaKPI_Id': vptq_kpi_KyDanhGiaKPI_Id,
      });
      final http.Response response = await requestHelper.getData('vptq_kpi_Duyet${q.isEmpty ? '' : '?$q'}');
      if (response.statusCode == 200) {
        final map = jsonDecode(response.body);

        // page=-1: data ở top-level; page>=1: data nằm trong datalist.data
        List listJson = (map['data'] as List?) ?? (map['datalist']?['data'] as List?) ?? const [];
        final dl = map as Map<String, dynamic>; // page=-1 thì map ở top-level
        print("data: $dl");

        final st = <TabFilter>[
          (() {
            final (bg, fg) = _statusColor(null);
            return TabFilter(label: 'Tổng cộng', count: dl['soLuong'] ?? 0, bg: bg, fg: fg, trangThai: null);
          })(),
          (() {
            final (bg, fg) = _statusColor(1);
            return TabFilter(label: 'Chờ bạn duyệt', count: dl['soLuongChoBanDuyet'] ?? 0, bg: bg, fg: fg, trangThai: 1);
          })(),
          (() {
            final (bg, fg) = _statusColor(2);
            return TabFilter(label: 'Đang xử lý', count: dl['soLuongDangXuLy'] ?? 0, bg: bg, fg: fg, trangThai: 3);
          })(),
          (() {
            final (bg, fg) = _statusColor(3);
            return TabFilter(label: 'Hoàn thành', count: dl['soLuongHoanThanh'] ?? 0, bg: bg, fg: fg, trangThai: 4);
          })(),
          (() {
            final (bg, fg) = _statusColor(4);
            return TabFilter(label: 'Trả lại', count: dl['soLuongTraLai'] ?? 0, bg: bg, fg: fg, trangThai: 2);
          })(),
        ];

        // // các tab “xếp loại” (key = vptq_kpi_ThangDiemXepLoaiChiTiet_Id)
        // final grades = (dl['tyTrongXepLoais'] as List?) ?? const [];
        // final gTabs = <TabFilter>[];
        // for (var i = 0; i < grades.length; i++) {
        //   final g = grades[i] as Map<String, dynamic>;
        //   final id = g['vptq_kpi_ThangDiemXepLoaiChiTiet_Id']?.toString();
        //   final label = g['phanTram'] == null ? g['xepLoai'] : '${g['xepLoai']} (${g['phanTram']}%)';
        //   final soLuong = g['soLuong'] ?? 0;
        //   final (bg, fg) = _gradeColors[i % _gradeColors.length];
        //   gTabs.add(TabFilter(label: label, count: soLuong, bg: bg, fg: fg, gradeId: id));
        // }
        final items = listJson.map((e) => PheDuyetItem.fromJson(e as Map<String, dynamic>)).toList();
        setState(() {
          _tabs = [...st];
          _danhGiaKPIList = items;
          _loading = false;
        });

        print("body: $items");
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getLuongDuyet_TuChoi(
    int? loaiPhieuDuyet,
    String? id,
  ) async {
    try {
      final url = loaiPhieuDuyet == 7
          ? 'vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan/luong-duyet?id'
          : loaiPhieuDuyet == 8
              ? 'vptq_kpi_DeXuatPheDuyetKetQuaKPIDonVi/luong-duyet?id'
              : loaiPhieuDuyet == 3
                  ? 'vptq_kpi_KPICaNhan/luong-duyet?vptq_kpi_KPICaNhan_Id'
                  : loaiPhieuDuyet == 4
                      ? 'vptq_kpi_KPIDonVi/luong-duyet?vptq_kpi_KPIDonVi_Id'
                      : loaiPhieuDuyet == 5
                          ? 'vptq_kpi_DanhGiaKPICaNhan/luong-duyet?vptq_kpi_KPICaNhan_Id'
                          : loaiPhieuDuyet == 6
                              ? 'vptq_kpi_DanhGiaKPIDonVi/luong-duyet?vptq_kpi_KPIDonVi_Id'
                              : 'vptq_kpi_DanhMucPI/luong-duyet?vptq_kpi_DanhMucPI_Id';
      final http.Response response = await requestHelper.getData('$url=$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded as List).map((e) => Approver.fromJson(e as Map<String, dynamic>)).where((e) => e.isDuyet).toList();
        setState(() => _viTriTraList = list);
      } else {
        setState(() => _viTriTraList = []);
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getLuongDuyet(
    int? loaiPhieuDuyet,
    String? id,
  ) async {
    try {
      final url = loaiPhieuDuyet == 7
          ? 'vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan/luong-duyet?id'
          : loaiPhieuDuyet == 8
              ? 'vptq_kpi_DeXuatPheDuyetKetQuaKPIDonVi/luong-duyet?id'
              : loaiPhieuDuyet == 3
                  ? 'vptq_kpi_KPICaNhan/luong-duyet?vptq_kpi_KPICaNhan_Id'
                  : loaiPhieuDuyet == 4
                      ? 'vptq_kpi_KPIDonVi/luong-duyet?vptq_kpi_KPIDonVi_Id'
                      : loaiPhieuDuyet == 5
                          ? 'vptq_kpi_DanhGiaKPICaNhan/luong-duyet?vptq_kpi_KPICaNhan_Id'
                          : loaiPhieuDuyet == 6
                              ? 'vptq_kpi_DanhGiaKPIDonVi/luong-duyet?vptq_kpi_KPIDonVi_Id'
                              : 'vptq_kpi_DanhMucPI/luong-duyet?vptq_kpi_DanhMucPI_Id';
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

  Future<void> getGhiChu(
    int? loaiPhieuDuyet,
    String? id,
  ) async {
    try {
      final url = loaiPhieuDuyet == 3
          ? 'vptq_kpi_KPICaNhan/ghi-chu?isDanhGia=false&vptq_kpi_KPICaNhan_Id'
          : loaiPhieuDuyet == 4
              ? 'vptq_kpi_KPIDonVi/ghi-chu?isDanhGia=false&vptq_kpi_KPIDonVi_Id'
              : loaiPhieuDuyet == 5
                  ? 'vptq_kpi_KPICaNhan/ghi-chu?isDanhGia=true&vptq_kpi_KPICaNhan_Id'
                  : loaiPhieuDuyet == 6
                      ? 'vptq_kpi_KPIDonVi/ghi-chu?isDanhGia=true&vptq_kpi_KPIDonVi_Id'
                      : 'vptq_kpi_DanhMucPI/ghi-chu?vptq_kpi_DanhMucPI_Id';
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

  Future<void> exportPDFPI(
    int? loaiPhieuDuyet,
    String? id,
    String? doiTuong,
  ) async {
    try {
      final url = loaiPhieuDuyet == 1 || loaiPhieuDuyet == 2
          ? 'vptq_kpi_DanhMucPI/export-pdf?id=$id'
          : loaiPhieuDuyet == 3
              ? 'vptq_kpi_KPICaNhan/export-pdf?id=$id'
              : loaiPhieuDuyet == 4
                  ? 'vptq_kpi_KPIDonVi/export-pdf?id=$id'
                  : loaiPhieuDuyet == 5
                      ? 'vptq_kpi_DanhGiaKPICaNhan/export-pdf?id=$id'
                      : loaiPhieuDuyet == 6
                          ? 'vptq_kpi_DanhGiaKPIDonVi/export-pdf?id=$id'
                          : loaiPhieuDuyet == 7
                              ? 'vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan/export-pdf?id=$id'
                              : 'vptq_kpi_DeXuatPheDuyetKetQuaKPIDonVi/export-pdf?id=$id';
      final http.Response res = await requestHelper.postData(url, null);
      if (res.statusCode != 200) return;

      final root = jsonDecode(res.body);
      // React dùng res.data.datapdf → lấy linh hoạt:
      final String? b64 = (root['data']?['datapdf'] ?? root['datapdf'])?.toString();

      if (b64 == null || b64.isEmpty) return;

      final bytes = base64Decode(b64);
      final fileName = '${(doiTuong ?? 'file').trim().isEmpty ? 'file' : doiTuong}.pdf';

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

  Future<void> _onPickTab(int i) async {
    setState(() => _activeTab = i);

    await _refreshByCurrentTab();
  }

  final _fmt = DateFormat('dd/MM/yyyy');

  DateTime? _parseDDMMYYYY(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return _fmt.parseStrict(s);
    } catch (_) {
      return null;
    }
  }

  String _strOrEmpty(String? s) => s ?? '';

// 2) initState: giữ nguyên phần set selectedFromDate/selectedToDate như bạn đang làm

// 3) _selectDate: (date range picker) — bạn đã cập nhật đúng rồi, giữ nguyên

// 4) Nếu vẫn dùng 2 ô “Từ ngày/Đến ngày” riêng lẻ: thay _pickDate dùng String
  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final now = DateTime.now();
    final currentFrom = _parseDDMMYYYY(selectedFromDate);
    final currentTo = _parseDDMMYYYY(selectedToDate);
    final initial = isFrom ? (currentFrom ?? currentTo ?? now) : (currentTo ?? currentFrom ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isFrom ? 'Chọn TỪ NGÀY' : 'Chọn ĐẾN NGÀY',
    );
    if (picked == null) return;

    setState(() {
      final pickedStr = _fmt.format(picked);
      if (isFrom) {
        selectedFromDate = pickedStr;
        // đảm bảo from <= to
        final to = _parseDDMMYYYY(selectedToDate);
        if (to != null && to.isBefore(picked)) selectedToDate = pickedStr;
      } else {
        selectedToDate = pickedStr;
        final from = _parseDDMMYYYY(selectedFromDate);
        if (from != null && picked.isBefore(from)) selectedFromDate = pickedStr;
      }
    });

    await _refreshByCurrentTab();
  }

// 5) UI hint text nếu cần:
  String _fmtOrEmpty(DateTime? _) => _strOrEmpty(null); // không còn dùng DateTime
// hoặc đổi nơi gọi sang dùng _strOrEmpty(selectedFromDate/selectedToDate)

  InputDecoration _dateDeco(String hint) => InputDecoration(
        hintText: hint,
        suffixIcon: const Icon(Icons.calendar_month_outlined),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      );
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

  Future<void> getKyDanhGia() async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_KyDanhGiaKPI?page=-1');
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

  Widget _buildFilterPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft, // Căn sát lề trái
          padding: EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
          child: const Text(
            "Loại phiếu:",
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
                items: AppConfig.LIST_LOAIPHIEU_DANHGIA?.map((item) {
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
                value: loaiPhieuId,
                hint: const Text(
                  'Chọn loại phiếu',
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF), // xám nhạt
                  ),
                ),
                onChanged: (newValue) async {
                  setState(() {
                    loaiPhieuId = newValue;
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
                        hintText: 'Tìm loại phiếu',
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
                      return AppConfig.LIST_LOAIPHIEU_DANHGIA?.any((viTri) => viTri.id == itemId && viTri.name?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
        const SizedBox(height: 5),
        Container(
          alignment: Alignment.centerLeft, // Căn sát lề trái
          padding: const EdgeInsets.symmetric(horizontal: 8), // Thêm padding nếu cần
          child: const Text(
            "Ngày:",
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConfig.textInput,
            ),
          ),
        ),
        // GestureDetector(
        //   onTap: () => _selectDate(context),
        //   child: Container(
        //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        //     decoration: BoxDecoration(
        //       border: Border.all(color: Colors.blue),
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(Icons.calendar_today, color: Colors.blue),
        //         SizedBox(width: 8),
        //         Text(
        //           selectedFromDate != null && selectedToDate != null ? '${DateFormat('dd/MM/yyyy').format(DateFormat('dd/MM/yyyy').parse(selectedFromDate!))} - ${DateFormat('dd/MM/yyyy').format(DateFormat('dd/MM/yyyy').parse(selectedToDate!))}' : 'Chọn ngày',
        //           style: TextStyle(color: Colors.blue),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _pickDate(context, isFrom: true),
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: selectedFromDate ?? ''),
                    decoration: _dateDeco('Từ ngày'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickDate(context, isFrom: false),
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: selectedToDate ?? ''),
                    decoration: _dateDeco('Đến ngày'),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                        fontSize: 13,
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
                            hintText: 'Tìm cđns',
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
                    hint: const Text(
                      'Chọn kỳ đánh giá',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF), // xám nhạt
                      ),
                    ),
                    value: KyDanhGiaId,
                    onChanged: (newValue) async {
                      setState(() {
                        KyDanhGiaId = newValue ?? "";
                      });
                      if (newValue != null) {
                        // final t = _tabs[_activeTab ?? 0];

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
      ],
    );
  }

  void _onTapSearch() async {
    FocusScope.of(context).unfocus(); // đóng bàn phím
    await _refreshByCurrentTab(); // gọi API theo tab hiện tại
  }

  Future<void> openRejectDialog({
    required int loaiPhieuDuyet,
    required String id,
  }) async {
    final ghiChuCtl = TextEditingController();
    int? viTriTra;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: StatefulBuilder(
          // local setState cho dialog
          builder: (ctx, setSt) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // header: tiêu đề giữa, nút X sát phải
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Từ chối phiếu',
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
                  const SizedBox(height: 10),

                  // Lý do
                  TextFormField(
                    controller: ghiChuCtl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Lý do từ chối *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Color(0xFFE53935), width: 1.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Lý do từ chối là bắt buộc' : null,
                    onChanged: (_) => setSt(() {}), // để bật/tắt nút nếu cần
                  ),
                  const SizedBox(height: 12),

                  // Cấp trả
                  DropdownButtonFormField<int>(
                    value: viTriTra,
                    items: _viTriTraList
                        .map((e) => DropdownMenuItem<int>(
                              // dùng đúng field từ API: viTriDuyetDanhGia
                              value: e.viTriDuyet,
                              child: Text(e.tenNguoiDuyet),
                            ))
                        .toList(),
                    onChanged: (v) => setSt(() => viTriTra = v),
                    decoration: InputDecoration(
                      labelText: 'Cấp trả *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (v) => v == null ? 'Cấp trả là bắt buộc' : null,
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                  const SizedBox(height: 16),

                  // Nút Từ chối
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return; // hiện lỗi dưới field
                        final note = ghiChuCtl.text.trim();
                        _showConfirmationDialogTuChoi(ctx, loaiPhieuDuyet, id, note, viTriTra);
                      },
                      child: const Text('Từ chối', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    );
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

  Future<void> _handleAction(FilterAction action, PheDuyetItem e) async {
    switch (action) {
      case FilterAction.xemChiTiet:
        if (e.loaiPhieuDuyet == 1 || e.loaiPhieuDuyet == 2) {
          // danh mục PI
          nextScreen(context, ChiTietDanhMucPiPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: true));
        } else if (e.loaiPhieuDuyet == 5) {
          //đánh giá KPI cá nhân
          nextScreen(context, ChiTietKPIPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: true));
        } else if (e.loaiPhieuDuyet == 7 || e.loaiPhieuDuyet == 8) {
          // đề xuất phê duyệt
          nextScreen(context, ChiTietPheDuyetKetQuaKPIPage(id: e.id, isCaNhan: e.loaiPhieuDuyet == 7, tenDonViKPI: e.tenDonViKPI, isChiTiet: true));
        } else if (e.loaiPhieuDuyet == 3) {
          // Giao KPI cá nhân
          nextScreen(context, ChiTietGiaoChiTieuKPIPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: true));
        } else if (e.loaiPhieuDuyet == 4) {
          nextScreen(context, ChiTietGiaoChiTieuKPI_DonViPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: true));
          // Giao KPI đơn vị
        } else {
          nextScreen(context, ChiTietDanhGiaKPI_DonViPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: true));

          // Đánh giá KPI đơn vị
        }
        break;

      case FilterAction.taiPdf:
        await exportPDFPI(e.loaiPhieuDuyet, e.id, e.doiTuong);
        break;

      case FilterAction.duyet:
        // ...
        if (e.loaiPhieuDuyet == 1 || e.loaiPhieuDuyet == 2) {
          // danh mục PI
          nextScreen(context, ChiTietDanhMucPiPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: false));
        } else if (e.loaiPhieuDuyet == 5) {
          //đánh giá KPI cá nhân
          nextScreen(context, ChiTietKPIPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: false));
        } else if (e.loaiPhieuDuyet == 7 || e.loaiPhieuDuyet == 8) {
          // đề xuất phê duyệt
          nextScreen(context, ChiTietPheDuyetKetQuaKPIPage(id: e.id, isCaNhan: e.loaiPhieuDuyet == 7, tenDonViKPI: e.tenDonViKPI, isChiTiet: false));
        } else if (e.loaiPhieuDuyet == 3) {
          // Giao KPI cá nhân
          nextScreen(context, ChiTietGiaoChiTieuKPIPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: false));
        } else if (e.loaiPhieuDuyet == 4) {
          nextScreen(context, ChiTietGiaoChiTieuKPI_DonViPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: false));
          // Giao KPI đơn vị
        } else {
          nextScreen(context, ChiTietDanhGiaKPI_DonViPage(id: e.id, kyDanhGia: e.thoiDiem ?? '', isChiTiet: false));

          // Đánh giá KPI đơn vị
        }
        break;

      case FilterAction.tuChoi:
        await getLuongDuyet_TuChoi(e.loaiPhieuDuyet, e.id);
        if (!mounted) break;
        await openRejectDialog(
          loaiPhieuDuyet: e.loaiPhieuDuyet!,
          id: e.id!,
        );
        // ...
        break;

      case FilterAction.xemGhiChu:
        await getGhiChu(e.loaiPhieuDuyet, e.id);
        if (!mounted) break;
        await openGhiChuDialog();
        // ...
        break;

      case FilterAction.luongDuyet:
        await getLuongDuyet(e.loaiPhieuDuyet, e.id);
        if (!mounted) break;

        await openLuongDuyetDialog();
        // ...
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: () async {
                // await getListData(DonViId ?? "", PhongBanId ?? "", _textController.text ?? "", KyDanhGiaId ?? "", _activeTab ?? null, UserId ?? "", chuKyId ?? 1, _selectedTpnsId ?? 0, ThangDiemXepLoaiId);
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

                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.black, width: 0.3),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 7),
                                          const Expanded(
                                            child: Text(
                                              'Chọn tất cả',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Checkbox(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4), // radius 8px
                                            ),
                                            checkColor: Colors.white, // màu icon check
                                            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                              if (states.contains(MaterialState.selected)) {
                                                return Colors.red; // nền đỏ khi tick
                                              }
                                              return Colors.transparent;
                                            }),
                                            side: BorderSide(
                                              color: _selectAll
                                                  ? Colors.red // khi tick chọn
                                                  : (_canSelectAll
                                                      ? Colors.red // trạng thái 1, chưa chọn -> viền xanh
                                                      : const Color(0xFF999999)), // mặc định xám
                                              width: 2,
                                            ),
                                            value: _selectAll,
                                            onChanged: _canSelectAll ? (_) => _toggleSelectAll() : null,
                                          ),
                                        ],
                                      ),
                                    ),
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
                                          final canRate = true;
                                          // final canRate = (e.isThucHienTuDanhGia == true) && (e.isKhongDanhGia == false);
                                          return KpiCard(
                                            item: e,
                                            onRate: canRate
                                                ? () {
                                                    // nextScreen(context, DanhGiaChiTietKPIPage(id: e.id, kyDanhGia: e.thoiDiem ?? ''));
                                                  }
                                                : null,
                                            selected: _selectedIds.contains(e.id),
                                            onSelect: (val) {
                                              setState(() {
                                                if (val) {
                                                  _selectedIds.add(e.id!);
                                                } else {
                                                  _selectedIds.remove(e.id);
                                                  _selectAll = false; // bỏ tick chọn tất cả nếu có cái bỏ chọn
                                                }
                                              });
                                            },
                                            menuPressed: () async {
                                              final action = await showFilterSheet(context, e, _ub?.id);
                                              if (!context.mounted || action == null) return;
                                              _handleAction(action, e); // <-- gọi chung
                                            },

                                            // 2) Nút "XEM CHI TIẾT" bắn trực tiếp action
                                            onAction: (action) => _handleAction(action, e),
                                            // menuPressed: () async {
                                            //   final action = await showFilterSheet(context, e, _ub?.id); // <-- dùng bottom sheet ở đây

                                            //   if (!context.mounted) return;
                                            //   if (action == null) return;
                                            //   switch (action) {
                                            //     case FilterAction.xemChiTiet:
                                            //       if (e.loaiPhieuDuyet == 1 || e.loaiPhieuDuyet == 2) {
                                            //         nextScreen(
                                            //           context,
                                            //           ChiTietDanhMucPiPage(id: e.id, kyDanhGia: e.thoiDiem ?? ''),
                                            //         );
                                            //       } else if (e.loaiPhieuDuyet == 5) {
                                            //         nextScreen(
                                            //           context,
                                            //           ChiTietKPIPage(id: e.id, kyDanhGia: e.thoiDiem ?? ''),
                                            //         );
                                            //       } else if (e.loaiPhieuDuyet == 7 || e.loaiPhieuDuyet == 8) {
                                            //         // đề xuất phê duyệt
                                            //       } else if (e.loaiPhieuDuyet == 3) {
                                            //         //Giao KPI Cá nhân
                                            //       } else if (e.loaiPhieuDuyet == 4) {
                                            //         // Giao KPI Đơn vị
                                            //       } else {
                                            //         //đánh giá KPI Đơn vị
                                            //         print("đánh giá KPI Đơn vị");
                                            //       }

                                            //       break;
                                            //     case FilterAction.taiPdf:
                                            //       // ...
                                            //       break;
                                            //     case FilterAction.duyet:
                                            //       // ...
                                            //       break;
                                            //     case FilterAction.tuChoi:
                                            //       // nextScreen(context, ChiTietKPIPage(id: e.id, kyDanhGia: e.thoiDiem ?? ''));
                                            //       break;
                                            //     case FilterAction.xemGhiChu:
                                            //       // ...
                                            //       break;
                                            //     case FilterAction.luongDuyet:
                                            //       // ...
                                            //       break;
                                            //   }
                                            // }
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
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _PrimaryButton(
                text: 'DUYỆT PHIẾU',
                controller: _btnController,
                onTap: _selectedIds.isEmpty ? null : () => _showConfirmationDialog(context),
              ),
            ),
          );
  }
}

bool canViewApprove(PheDuyetItem i, String userId) {
  // nút “Duyệt”
  final isCurrentApprover = i.nguoiDuyetHienTai_Id == userId && i.trangThai == 1;
  final isFlowKPI = i.isThucHienDuyetKPICVDV == true;
  final isDG_KPI = (i.loaiPhieuDuyet == 5 || i.loaiPhieuDuyet == 6) && i.isUyQuyen == true && i.trangThai == 3;
  return isCurrentApprover || isFlowKPI || isDG_KPI;
}

bool canReject(PheDuyetItem i, String userId) {
  if (i.loaiPhieuDuyet == 7 || i.loaiPhieuDuyet == 8) return false; // ẩn/disable như React
  final base = (i.nguoiDuyetHienTai_Id == userId && i.trangThai == 1 && (i.isFirst != true));
  final special = (i.viTriDuyet == 5 && i.loaiPhieuDuyet == 3 && i.nguoiDuyetHienTai_Id == userId);
  return base || special || (i.isCVKPI == true);
}

bool canNotes(PheDuyetItem i) {
  // React cho xem ghi chú trừ loại 7,8
  return !(i.loaiPhieuDuyet == 7 || i.loaiPhieuDuyet == 8);
}

enum FilterAction { xemChiTiet, taiPdf, duyet, tuChoi, xemGhiChu, luongDuyet }

Future<FilterAction?> showFilterSheet(
  BuildContext context,
  PheDuyetItem item,
  String? currentUserId,
) {
  final _canApprove = canViewApprove(item, currentUserId ?? "");
  final _canReject = canReject(item, currentUserId ?? "");
  final _canNotes = canNotes(item);

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
                icon: Icons.visibility_outlined,
                label: 'Xem chi tiết',
                onTap: () => Navigator.pop(ctx, FilterAction.xemChiTiet),
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Tải file PDF',
                onTap: () => Navigator.pop(ctx, FilterAction.taiPdf),
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.check_circle_outline,
                label: 'Duyệt',
                onTap: _canApprove ? () => Navigator.pop(ctx, FilterAction.duyet) : null,
              ),
              const Divider(height: 1),
              _SheetItem(
                icon: Icons.cancel_outlined,
                label: 'Từ chối',
                onTap: _canReject ? () => Navigator.pop(ctx, FilterAction.tuChoi) : null,
              ),

              const Divider(height: 1),

              _SheetItem(
                icon: Icons.chat_bubble_outline,
                label: 'Xem ghi chú',
                onTap: _canNotes ? () => Navigator.pop(ctx, FilterAction.xemGhiChu) : null,
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
                const Icon(Icons.check, size: 16, color: Colors.white),
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
    required this.selected,
    required this.onSelect,
    required this.onAction,
    this.onRate,
  });

  final PheDuyetItem item;
  final VoidCallback? onRate;
  final VoidCallback menuPressed;
  final bool selected;
  final ValueChanged<bool> onSelect;
  final ValueChanged<FilterAction> onAction;

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  static const kHPad = 16.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = BorderRadius.circular(14);
    final st = _statusOf(widget.item); // label + màu
    final UserBloc ub = context.watch<UserBloc>();

    return Material(
      color: cs.surface,
      child: Container(
        // decoration: BoxDecoration(
        //   color: cs.surface,
        //   borderRadius: border,
        //   boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2))],
        // ),
        decoration: BoxDecoration(
          color: widget.item.trangThai == 1
              ? const Color(0xFFFEE6E6) // nền hồng nhạt khi trạng thái == 1
              : const Color(0xFFD0D5DD),
          borderRadius: border,
          border: Border.all(
            color: widget.selected ? Colors.red : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: border,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                // color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(kHPad, 12, kHPad, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center, // canh giữa dọc
                  children: [
                    // Tiêu đề trái
                    Expanded(
                      child: Text(
                        widget.item.doiTuong ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB91C1C),
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Cụm trạng thái + checkbox bên phải
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: st.bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            st.label,
                            style: TextStyle(color: st.fg, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 24,
                          height: 24, // ép checkbox gọn và thẳng hàng
                          child: Checkbox(
                            value: widget.selected,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4), // radius 8px
                            ),
                            checkColor: Colors.white, // màu icon check
                            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.red; // nền đỏ khi tick
                              }
                              return Colors.transparent;
                            }),
                            side: BorderSide(
                              color: widget.selected
                                  ? Colors.red // khi tick chọn
                                  : (widget.item.trangThai == 1
                                      ? Colors.red // trạng thái 1, chưa chọn -> viền xanh
                                      : const Color(0xFF999999)), // mặc định xám
                              width: 2,
                            ),
                            onChanged: ((widget.item.nguoiDuyetHienTai_Id == ub?.id && widget.item.trangThai == 1) || widget.item.isThucHienDuyetKPICVDV == true) ? (v) => widget.onSelect(v!) : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Body: chỉ hiện khi _expanded (đúng hình 3 khi thu gọn)

              Container(
                // color: const Color(0xFFF3F3F5),
                padding: const EdgeInsets.fromLTRB(kHPad, 6, kHPad, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // _sectionTitle('1. Thông tin nhân sự'),
                  _line('Loại phiếu ', widget.item.tenLoaiPhieuDuyet),
                  _line('Kỳ đánh giá', widget.item.thoiDiem),
                  // if (_expanded) ...[
                  _line('Người tạo', widget.item.tenNguoiTao),
                  // const SizedBox(height: 8),
                  // _sectionTitle('2. Kỳ & mốc thời gian'),
                  _line('Đơn vị', (widget.item.tenDonViKPI ?? '').toString()),
                  _line('Ngày tạo', widget.item.ngayTao),
                ]
                    // ],
                    ),
              ),

              // Footer luôn hiện (đúng hình 3)
              Container(
                // color: const Color(0xFFF3F3F5),
                padding: const EdgeInsets.fromLTRB(kHPad, 12, kHPad, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => widget.onAction(FilterAction.xemChiTiet),
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.onRate != null ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('XEM CHI TIẾT', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .3)),
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

  Widget _line(String k, String? v) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text.rich(TextSpan(children: [
          TextSpan(text: '$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: (v == null || v.isEmpty) ? '—' : v),
        ])),
      );

  _Status _statusOf(PheDuyetItem e) {
    // Ưu tiên flags nếu có
    // if (e.isTraLaiDanhGia == true) {
    //   return const _Status('Trả lại', Color(0xFFFFE4E4), Color(0xFFB91C1C));
    // }
    // if (e.isHoanThanhDanhGia == true) {
    //   return const _Status('Hoàn thành', Color(0xFFE9FFF5), Color(0xFF047857));
    // }
    // Theo mã trạng thái (tùy bạn map lại cho đúng backend)
    switch (e.trangThai) {
      case 1:
        return const _Status('Chờ bạn duyệt', Color(0x1A0000FF), Color(0xFF0000FF));
      case 2:
        return const _Status('Trả lại', Color(0xFFFFE4E4), Color(0xFFB91C1C));
      case 3:
        return const _Status('Đang xử lý', Color(0xFFFFF1C2), Color(0xFFB45309));
      case 4:
        return const _Status('Hoàn thành', Color(0xFFE2F5F0), Color(0xFF0E766E));
      default:
        return const _Status('Trả lại', Color(0xFFFFE4E4), Color(0xFFB91C1C));
    }
  }
}

class _Status {
  final String label;
  final Color bg;
  final Color fg;
  const _Status(this.label, this.bg, this.fg);
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

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final RoundedLoadingButtonController controller;
  const _PrimaryButton({
    required this.text,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: RoundedLoadingButton(
        controller: controller,
        onPressed: onTap,
        color: const Color(0xFFB71C1C),
        borderRadius: 12,
        elevation: 0,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
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
