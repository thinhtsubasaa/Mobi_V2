import 'dart:convert';
import 'dart:io';
import 'package:Thilogi/services/request_helper_kpi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../../blocs/user_bloc.dart';
import '../../../../config/config.dart';
import '../../../../models/checksheet.dart';
import '../../../../models/kpi/chitietdanhgiakpi.dart';
import '../../../../widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomBodyDanhGiaChiTietKPI2 extends StatelessWidget {
  final String? id;
  CustomBodyDanhGiaChiTietKPI2({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyDanhGiaChiTietKPIScreen2(
      id: id,
      lstFiles: [],
    ));
  }
}

class _PickOb {
  _PickOb({this.vptq_kpi_KetQuaTuDanhGia_Id, this.diem, this.kqTH});
  String? vptq_kpi_KetQuaTuDanhGia_Id;
  int? diem;
  double? kqTH;
}

class BodyDanhGiaChiTietKPIScreen2 extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyDanhGiaChiTietKPIScreen2({super.key, required this.id, required this.lstFiles});

  @override
  _BodyDanhGiaChiTietKPIScreen2State createState() => _BodyDanhGiaChiTietKPIScreen2State();
}

class _BodyDanhGiaChiTietKPIScreen2State extends State<BodyDanhGiaChiTietKPIScreen2> with TickerProviderStateMixin, ChangeNotifier {
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
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnControllerduyet = RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController soKMController = TextEditingController();

  ChiTietDanhGiaKPIModel? _data;
  final Set<String> _expanded = {};

  // state form cho từng PI (key = KPICaNhanChiTiet_Id)
  final Map<String, TextEditingController> _txtThucHien = {};
  final Map<String, TextEditingController> _txtNhanXet = {};
  final Map<String, TextEditingController> _txtNguyenNhan = {};
  final Map<String, TextEditingController> _txtGiaiPhap = {};
  final Map<String, bool> _khongHopLe = {};
  List<File> _selectedFiles = []; // Lưu các file đã chọn
  List<File> _filesToDelete = []; // Lưu các file cần xóa (nếu có)

  // tiện ích lấy/khởi tạo controller
  TextEditingController _get(Map<String, TextEditingController> m, String key) => m.putIfAbsent(key, () => TextEditingController());

  bool _getBool(Map<String, bool> m, String key) => m.putIfAbsent(key, () => false);

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    getListData(widget.id);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _pickFiles() async {
    // Thực hiện chọn file ở đây
    // Dùng thư viện như file_picker để chọn file
    // Ví dụ: dùng file_picker để chọn file
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files.map((e) => File(e.path!)));
      });
    }
  }

  // Hàm xóa file
  void _deleteFile(File file) {
    setState(() {
      _selectedFiles.remove(file);
      _filesToDelete.add(file); // Đánh dấu file cần xóa
    });
  }

  Future<File> copyFileToDocuments(File originalFile) async {
    final directory = await getApplicationDocumentsDirectory(); // Lấy thư mục Documents
    final newPath = '${directory.path}/${originalFile.uri.pathSegments.last}'; // Tạo đường dẫn mới

    // Sao chép file vào thư mục Documents
    return originalFile.copy(newPath);
  }

  // Hàm gửi file lên server khi người dùng nhấn lưu
  Future<void> _uploadFiles() async {
    try {
      _selectedFiles.forEach((file) {
        print("File Path: ${file.path}"); // In ra đường dẫn của từng file
      });
      List<File> localFiles = [];
      for (File file in _selectedFiles) {
        localFiles.add(await copyFileToDocuments(file));
      }
      await requestHelper.uploadListFile(localFiles);
    } catch (e) {
      print("Error during file upload: $e");
    }
    // Chỉ khi nhấn "Lưu" mới gửi file lên server
    // await requestHelper.uploadListFile(_selectedFiles);
  }

  void _syncFormIntoModel() {
    final d = _data;
    if (d == null) return;

    for (final kn in d.kiemNhiems ?? const []) {
      for (final np in kn.nhomPIs ?? const []) {
        for (final ct in np.chiTiets ?? const []) {
          final id = ct.vptq_kpi_KPICaNhanChiTiet_Id ?? '';
          final vTh = _txtThucHien[id]?.text.trim() ?? '';
          final vNx = _txtNhanXet[id]?.text.trim() ?? '';
          final vNn = _txtNguyenNhan[id]?.text.trim() ?? '';
          final vGp = _txtGiaiPhap[id]?.text.trim() ?? '';
          final vKhl = _khongHopLe[id] ?? false;

          if (ct.isNoiDung == true) {
            ct.noiDungChiTieuDanhGia = vTh.isEmpty ? null : vTh;
            ct.dienGiaiDanhGia = vNx.isEmpty ? null : vNx;
          } else {
            ct.giaTriChiTieuDanhGia = vTh.isEmpty ? null : double.tryParse(vTh);
            ct.dienGiaiDanhGia = vNx.isEmpty ? null : vNx;
          }

          if (vKhl) {
            ct.isKhongThucHien = true;
            ct.nguyenNhan = vNn.isEmpty ? null : vNn;
            ct.giaiPhap = vGp.isEmpty ? null : vGp;
          }

          // children (nếu có)
          for (final c in ct.chiTietCons ?? const []) {
            final cid = c.vptq_kpi_KPICaNhanChiTietCon_Id ?? '';
            final cTh = _txtThucHien[cid]?.text.trim() ?? '';
            final cNx = _txtNhanXet[cid]?.text.trim() ?? '';
            final cKhl = _khongHopLe[cid] ?? false;

            if (c.isNoiDung == true) {
              c.noiDungChiTieuDanhGia = cTh.isEmpty ? null : cTh;
              c.dienGiaiDanhGia = cNx.isEmpty ? null : cNx;
            } else {
              c.giaTriChiTieuDanhGia = cTh.isEmpty ? null : double.tryParse(cTh);
              c.dienGiaiDanhGia = cNx.isEmpty ? null : cNx;
            }

            if (cKhl) {
              c.isKhongThucHien = true;
            }
          }
        }
      }
    }
  }

  static const _ZERO_ID = '00000000-0000-0000-0000-000000000000';

  Map<String, dynamic> _buildSavePayload() {
    final d = _data!;
    return {
      'id': d.id ?? widget.id,
      'kiemNhiems': (d.kiemNhiems ?? []).map((kn) {
        return {
          'vptq_kpi_KPICaNhanKiemNhiem_Id': kn.vptq_kpi_KPICaNhanKiemNhiem_Id,
          'vptq_kpi_DonViKPI_Id': kn.vptq_kpi_DonViKPI_Id,
          'chucVu_Id': kn.chucVu_Id,
          'chucDanh_Id': kn.chucDanh_Id,
          'nhiemVu': kn.nhiemVu,
          'tenDonViKPI': kn.tenDonViKPI,
          'tenPhongBan': kn.tenPhongBan,
          'tenChucDanh': kn.tenChucDanh,
          'tenChucVu': kn.tenChucVu,
          'tyTrong': kn.tyTrong,
          'diemTuDanhGia': kn.diemTuDanhGia,
          'diemLanhDao': kn.diemLanhDao,
          'nhomPIs': (kn.nhomPIs ?? []).map((np) {
            return {
              'vptq_kpi_NhomPI_Id': np.vptq_kpi_NhomPI_Id,
              'tenNhomPI': np.tenNhomPI,
              'thuTuNhom': np.thuTuNhom,
              'tongTyTrong': np.tongTyTrong,
              'chiTiets': (np.chiTiets ?? []).map((ct) {
                // map thủ công các field cần thiết (tránh gửi rác)
                final base = {
                  'vptq_kpi_KPICaNhanChiTiet_Id': ct.vptq_kpi_KPICaNhanChiTiet_Id,
                  'vptq_kpi_NhomPI_Id': ct.vptq_kpi_NhomPI_Id_Mobi,
                  'vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id': ct.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id,
                  'vptq_kpi_DanhMucPIChiTietPhienBan_Id': ct.vptq_kpi_DanhMucPIChiTietPhienBan_Id,
                  'vptq_kpi_DanhMucPIChiTiet_Id': ct.vptq_kpi_DanhMucPIChiTiet_Id,
                  'vptq_kpi_KPICaNhanChiTietCon_Id': ct.vptq_kpi_KPICaNhanChiTietCon_Id,
                  'maSoPI': ct.maSoPI,
                  'noiDungChiTieuDanhGia': ct.noiDungChiTieuDanhGia,
                  'chiSoDanhGia': ct.chiSoDanhGia,
                  'chiSoDanhGiaChiTiet': ct.chiSoDanhGiaChiTiet,
                  'tenDonViTinh': ct.tenDonViTinh,
                  'isNoiDung': ct.isNoiDung,
                  'isKetQuaThucHien': ct.isKetQuaThucHien,
                  'isTang': ct.isTang,
                  'giaTriChiTieu': ct.giaTriChiTieu,
                  'giaTriChiTieuDanhGia': ct.giaTriChiTieuDanhGia,
                  'noiDungChiTieu': ct.noiDungChiTieu,
                  'dienGiai': ct.dienGiai,
                  'dienGiaiDanhGia': ct.dienGiaiDanhGia,
                  'tyTrong': ct.tyTrong,
                  'chuKy': ct.chuKy,
                  'isKhongThucHien': ct.isKhongThucHien,
                  'nguyenNhan': ct.nguyenNhan,
                  'giaiPhap': ct.giaiPhap,
                  'diemTrongSoTuDanhGia': ct.diemTrongSoTuDanhGia,
                  'diemKetQuaTuDanhGia': ct.diemKetQuaTuDanhGia,
                };

                // ép KetQuaTuDanhGia_Id về 0000 nếu không thực hiện
                base['vptq_kpi_KetQuaTuDanhGia_Id'] = (ct.isKhongThucHien == true) ? _ZERO_ID : ct.vptq_kpi_KetQuaTuDanhGia_Id;
                base['isNguyenNhanChuQuan'] = (ct.isNguyenNhanChuQuanFE == 'Nguyên nhân chủ quan') ? true : false;

                // children
                base['chiTietCons'] = (ct.chiTietCons ?? []).map((c) {
                  final child = {
                    'vptq_kpi_KPICaNhanChiTiet_Id': c.vptq_kpi_KPICaNhanChiTiet_Id,
                    'vptq_kpi_KPICaNhanChiTietCon_Id': c.vptq_kpi_KPICaNhanChiTietCon_Id,
                    'maSoPI': c.maSoPI,
                    'chiSoDanhGia': c.chiSoDanhGia,
                    'tenDonViTinh': c.tenDonViTinh,
                    'isNoiDung': c.isNoiDung,
                    'isKetQuaThucHien': c.isKetQuaThucHien,
                    'isTang': c.isTang,
                    'giaTriChiTieu': c.giaTriChiTieu,
                    'giaTriChiTieuDanhGia': c.giaTriChiTieuDanhGia,
                    'noiDungChiTieu': c.noiDungChiTieu,
                    'dienGiai': c.dienGiai,
                    'dienGiaiDanhGia': c.dienGiaiDanhGia,
                    'tyTrong': c.tyTrong,
                    'chuKy': c.chuKy,
                    'isKhongThucHien': c.isKhongThucHien,
                    'diemTrongSoTuDanhGia': c.diemTrongSoTuDanhGia,
                    'diemKetQuaTuDanhGia': c.diemKetQuaTuDanhGia,
                  };

                  final khongThucHienCon = (c.isKhongThucHien == true) || (ct.isKhongThucHien == true);
                  child['vptq_kpi_KetQuaTuDanhGia_Id'] = khongThucHienCon ? _ZERO_ID : c.vptq_kpi_KetQuaTuDanhGia_Id;

                  return child;
                }).toList();

                return base;
              }).toList(),
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  Future<void> _saveKPIAndMaybeSend({required bool sendApproval}) async {
    print('_saveKPIAndMaybeSend: sendApproval=$sendApproval');
    if (_data == null) return;

    try {
      setState(() => _isLoading = true);

      // 1) gom form về model
      // _syncFormIntoModel();

      // 2) (tuỳ chọn) upload file nếu có và “thay” đường dẫn vào model trước khi build payload
      // await _uploadAllFilesIfAnyAndPatchModel();

      // 3) build payload giống React
      final payload = _buildSavePayload();
      print("payload: $payload");

      // 4) PUT lưu tự đánh giá
      final saveRes = await requestHelper.putData(
        'vptq_kpi_DanhGiaKPICaNhan/tu-danh-gia?id=${widget.id}',
        payload,
      );

      if (saveRes.statusCode == 200) {
        if (sendApproval) {
          // 5) nếu là "GỬI DUYỆT" → gọi API duyệt
          final approveRes = await requestHelper.putData(
            'vptq_kpi_DanhGiaKPICaNhan/gui-duyet-cap-tren/${widget.id}',
            null,
          );

          if (approveRes.statusCode == 200) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Thành công',
              text: 'Gửi duyệt đánh giá KPI thành công',
              confirmBtnText: 'Đồng ý',
              onConfirmBtnTap: () {
                Navigator.pop(context); // đóng alert
                Navigator.pop(context); // quay về
                getListData(widget.id);
              },
            );
            _btnControllerduyet.reset();
          } else {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Thất bại',
              text: approveRes.body.replaceAll('"', ''),
              confirmBtnText: 'Đồng ý',
            );
            _btnControllerduyet.reset();
          }
        } else {
          // chỉ LƯU
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: 'Đánh giá KPI thành công',
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.pop(context); // đóng alert
              Navigator.pop(context);
              getListData(widget.id); // reload lại màn (giống React gọi getInfo)
            },
          );
          _btnController.reset();
          _btnControllerduyet.reset();
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: saveRes.body.replaceAll('"', ''),
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
        _btnControllerduyet.reset();
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: e.toString(),
        confirmBtnText: 'Đồng ý',
      );
      _btnController.reset();
      _btnControllerduyet.reset();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          _btnControllerduyet.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _saveKPIAndMaybeSend(sendApproval: true);
        });
  }

  void _showConfirmationDialogSave(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn lưu không?',
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
          _saveKPIAndMaybeSend(sendApproval: false);
        });
  }

  void _handleToggleKhongThucHien(
    ChiTietPIModel current,
    ChiTietPIModel? parent,
    bool value,
  ) {
    setState(() {
      toggleKhongThucHienCha(
        current,
        value,
      );
    });
  }

  void onToggleKhongThucHienAtParent(ChiTietPIModel current, ChiTietPIModel? parentCt, bool value) {
    print("parentCt: $parentCt");
    setState(() {
      if (parentCt == null) {
        // toggle CHA
        toggleKhongThucHienCha(current, value);
      } else {
        // toggle CON
        toggleKhongThucHienCon(
          parent: parentCt,
          child: current,
          checked: value,
          ketQuas: parentCt.ketQuas,
        );
      }
    });
  }

  double _tinhTongDiemTrongSo(ChiTietDanhGiaKPIModel m) {
    // fallback: cộng tất cả điểmTrongSoTuDanhGia
    double sum = 0;
    for (final kn in (m.kiemNhiems ?? [])) {
      for (final n in (kn.nhomPIs ?? [])) {
        for (final ct in (n.chiTiets ?? [])) {
          sum += (ct.diemTrongSoTuDanhGia ?? 0);
        }
      }
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  String _toRoman(int n) {
    const romans = {
      1000: 'M',
      900: 'CM',
      500: 'D',
      400: 'CD',
      100: 'C',
      90: 'XC',
      50: 'L',
      40: 'XL',
      10: 'X',
      9: 'IX',
      5: 'V',
      4: 'IV',
      1: 'I',
    };
    var num = n;
    var res = '';
    romans.forEach((value, symbol) {
      while (num >= value) {
        res += symbol;
        num -= value;
      }
    });
    return res;
  }

  String buildQuery(Map<String, dynamic> params) {
    // loại bỏ null / rỗng
    params.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
    // tất cả value -> String
    final qp = params.map((k, v) => MapEntry(k, v.toString()));
    return Uri(queryParameters: qp).query; // "a=1&b=x"
  }

  Future<void> getListData(
    String? id,
  ) async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_DanhGiaKPICaNhan/$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _data = ChiTietDanhGiaKPIModel.fromJson(decoded);
        } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
          _data = ChiTietDanhGiaKPIModel.fromJson(
            decoded.first as Map<String, dynamic>,
          );
        } else {
          _data = null;
        }
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

// Xác định 1 record là PI CHA? (suy từ việc có mã số PI cha hay không)
  bool _isPICha(ChiTietPIModel r) {
    final parent = r.maSoPICha_Mobi;
    print("_isPICha: $parent");
    return parent == null || parent.isEmpty;
  }

// Kết quả theo khoảng (port từ React)

  _PickKQ _tinhKetQuaTheoKhoang(List<KetQuaModel>? arr, double value) {
    for (final kq in arr ?? const []) {
      final nhon = kq.nhoHon;
      final lon = kq.lonHonHoacBang;
      final ok = (nhon != null && lon != null && lon <= value && value < nhon) || (nhon == null && lon != null && lon <= value) || (lon == null && nhon != null && value < nhon);
      if (ok) {
        return _PickKQ(kq.diem ?? 0, kq.vptq_kpi_KetQuaDanhGia_Id ?? '00000000-0000-0000-0000-000000000000');
      }
    }
    return _PickKQ(0, '00000000-0000-0000-0000-000000000000');
  }

// Trường hợp đăng ký = 0 (port từ React: tinhKetQuaTuDanhGiaDangKyBang0)
  _PickKQ _tinhKetQuaDangKyBang0(List<KetQuaModel>? arr, {bool isMin = false, bool isMax = false}) {
    String? id;
    int? diem;
    for (final kq in arr ?? const []) {
      if (isMin) {
        if (kq.lonHonHoacBang == null && kq.nhoHon != null) {
          id = kq.vptq_kpi_KetQuaDanhGia_Id;
          diem = kq.diem;
        }
      } else if (isMax) {
        if (kq.diem == 4 || kq.diem == 3 || kq.diem == 2 || kq.diem == 1) {
          id = kq.vptq_kpi_KetQuaDanhGia_Id;
          diem = kq.diem;
        }
      } else {
        const v = 100.0;
        final nhon = kq.nhoHon, lon = kq.lonHonHoacBang;
        final ok = (nhon != null && lon != null && lon <= v && v < nhon) || (nhon == null && lon != null && lon <= v) || (lon == null && nhon != null && v < nhon);
        if (ok) {
          id = kq.vptq_kpi_KetQuaDanhGia_Id;
          diem = kq.diem;
        }
      }
    }
    return _PickKQ(diem ?? 0, id ?? '00000000-0000-0000-0000-000000000000');
  }

// Tính phần trăm + pick điểm theo QUY TẮC REACT
  _PickOb tinhPhanTramKetQuaThucHien(double value, ChiTietPIModel record) {
    double kqTH = 0;
    String? id;
    int? diem;

    final isTang = record.isTang == true;
    final target = record.giaTriChiTieu ?? 0;
    final isPICha = _isPICha(record);

    if (isTang) {
      if (target == 0) {
        if (isPICha) {
          if (value < 0) {
            final ob = _tinhKetQuaDangKyBang0(record.ketQuas, isMin: true);
            id = ob.id;
            diem = ob.diem;
          } else if (value > 0) {
            final ob = _tinhKetQuaDangKyBang0(record.ketQuas, isMax: true);
            id = ob.id;
            diem = ob.diem;
          } else {
            final ob = _tinhKetQuaDangKyBang0(record.ketQuas);
            id = ob.id;
            diem = ob.diem;
          }
        } else {
          kqTH = (value == 0) ? 100 : 0;
        }
      } else {
        kqTH = ((value / target) * 100).roundToDouble();
        final ob = _tinhKetQuaTheoKhoang(record.ketQuas, kqTH);
        id = ob.id;
        diem = ob.diem;
      }
    } else {
      if (target == 0) {
        if (isPICha) {
          if (value < 0) {
            final ob = _tinhKetQuaDangKyBang0(record.ketQuas, isMax: true);
            id = ob.id;
            diem = ob.diem;
          } else if (value > 0) {
            final ob = _tinhKetQuaDangKyBang0(record.ketQuas, isMin: true);
            id = ob.id;
            diem = ob.diem;
          } else {
            final ob = _tinhKetQuaDangKyBang0(record.ketQuas);
            id = ob.id;
            diem = ob.diem;
          }
        } else {
          kqTH = (value == 0) ? 100 : 0;
        }
      } else {
        kqTH = ((1 - (value - target) / target) * 100).roundToDouble();
        final ob = _tinhKetQuaTheoKhoang(record.ketQuas, kqTH);
        id = ob.id;
        diem = ob.diem;
      }
    }

    return _PickOb(
      vptq_kpi_KetQuaTuDanhGia_Id: id,
      diem: diem,
      kqTH: kqTH,
    );
  }

// gán text cho field nội dung/diễn giải (cha/con)
  void _setField(dynamic ct, String key, String value) {
    switch (key) {
      case 'noiDungChiTieuDanhGia':
        ct.noiDungChiTieuDanhGia = value.isEmpty ? null : value;
        break;
      case 'dienGiaiDanhGia':
        ct.dienGiaiDanhGia = value.isEmpty ? null : value;
        break;
      case 'nguyenNhan':
        ct.nguyenNhan = value.isEmpty ? null : value;
        break;
      case 'giaiPhap':
        ct.giaiPhap = value.isEmpty ? null : value;
    }
    print('_setField: $key =  ${ct.dienGiaiDanhGia} ');
  }

  void _setNumber(dynamic ct, String key, double value) {
    if (key == 'giaTriChiTieuDanhGia') ct.giaTriChiTieuDanhGia = value;
    print('_setNumber[$key] -> ${ct.vptq_kpi_KPICaNhanChiTietCon_Id ?? ct.maSoPI} = ${ct.giaTriChiTieuDanhGia}');
  }

// Optional: nếu muốn giữ các *FE* để debug/đồng bộ hiển thị
  void _setNumberFE(dynamic ct, String key, double value) {
    // ví dụ: ct.giaTriChiTieuDanhGiaFE = value;
  }

  double _sumDiemTrongSo(List<ChiTietPIModel>? list) {
    double s = 0;
    for (final ct in list ?? const []) {
      s += (ct.diemTrongSoTuDanhGia ?? 0).toDouble();
    }
    print("_sumDiemTrongSo = $s");
    return s;
  }

// ==== INPUT TEXT (nội dung, diễn giải) ====
  void _onChangeInputChiTieuNam(String v, ChiTietPIModel record, String key) {
    for (final kn in _data?.kiemNhiems ?? const []) {
      for (final np in kn.nhomPIs ?? const []) {
        if (np.vptq_kpi_NhomPI_Id != record.vptq_kpi_NhomPI_Id_Mobi) continue;

        for (final ct in np.chiTiets ?? const []) {
          if (_isPICha(record)) {
            if (ct.maSoPI == record.maSoPI) {
              _setField(ct, key, v);
            }
          } else {
            if (ct.maSoPI == record.maSoPICha_Mobi) {
              for (final cct in ct.chiTietCons ?? const []) {
                if (cct.maSoPI == record.maSoPI) {
                  _setField(cct, key, v);
                  // React có set FE tại cha khi sửa con (tuỳ dùng)
                  _setField(cct, '${key}FE', v);
                }
              }
            }
          }
        }
      }
    }

    // cập nhật trực tiếp record người dùng đang gõ
    _setField(record, key, v);
    setState(() {});
  }

  void _onChangeInputNumber(String sv, ChiTietPIModel record, String key) {
    final value = double.tryParse(sv.replaceAll(',', '')) ?? 0;

    if (record.isKetQuaThucHien == true) {
      setState(() {
        // Đảm bảo cập nhật ngay lập tức
        // Tính toán và cập nhật điểm
        String? pickId;
        int? pickDiem;
        for (final kq in record.ketQuas ?? const []) {
          final nhoHon = kq.nhoHon;
          final lonHonBang = kq.lonHonHoacBang;
          final ok = (nhoHon != null && lonHonBang != null && lonHonBang <= value && value < nhoHon) || (nhoHon == null && lonHonBang != null && lonHonBang <= value) || (lonHonBang == null && nhoHon != null && value < nhoHon);
          if (ok) {
            pickId = kq.vptq_kpi_KetQuaDanhGia_Id;
            pickDiem = kq.diem;
          }
        }

        for (final kn in _data?.kiemNhiems ?? const []) {
          double tyTrongSum = 0;
          for (final np in kn.nhomPIs ?? const []) {
            if (np.vptq_kpi_NhomPI_Id != record.vptq_kpi_NhomPI_Id_Mobi) continue;

            for (final ct in np.chiTiets ?? const []) {
              if (_isPICha(record)) {
                if (ct.maSoPI == record.maSoPI) {
                  _setNumber(ct, key, value);
                  _setNumberFE(ct, key, value);

                  ct.vptq_kpi_KetQuaTuDanhGia_Id = pickId;
                  ct.diemKetQuaTuDanhGia = pickDiem;
                  ct.diemTrongSoTuDanhGia = double.parse((((pickDiem ?? 0) * (ct.tyTrong ?? 0)) / 100).toStringAsFixed(2));
                  ct.diemTrongSoTuDanhGiaFE = ct.diemTrongSoTuDanhGia;

                  if ((ct.diemKetQuaTuDanhGia ?? 0) > 2) {
                    ct.giaiPhap = null;
                    ct.nguyenNhan = null;
                  }
                  ct.diemKetQuaTuDanhGiaFE = ct.diemKetQuaTuDanhGia;
                }
              } else {
                if (ct.maSoPI == record.maSoPICha_Mobi) {
                  for (final cct in ct.chiTietCons ?? const []) {
                    if (cct.maSoPI == record.maSoPI) {
                      _setNumber(cct, key, value);
                      _setNumberFE(cct, key, value); // React set FE tại cha
                    }
                  }
                }
              }
            }

            // cập nhật "nhóm tổng"
            if (np.isTong == true) {
              np.diemTrongSoTuDanhGia = double.parse(tyTrongSum.toStringAsFixed(2));
            } else {
              tyTrongSum += _sumDiemTrongSo(np.chiTiets);
            }
          }
        }
      });
    } else {
      // Trường hợp KPI “theo % hoàn thành”
      final ob = tinhPhanTramKetQuaThucHien(value, record);

      setState(() {
        // Cập nhật ngay
        for (final kn in _data?.kiemNhiems ?? const []) {
          double tyTrongSum = 0;
          for (int i = 0; i < (kn.nhomPIs?.length ?? 0); i++) {
            final np = kn.nhomPIs![i];
            print("found parent2: ${np.vptq_kpi_NhomPI_Id}, ${record.vptq_kpi_NhomPI_Id_Mobi}");
            if (np.vptq_kpi_NhomPI_Id != record.vptq_kpi_NhomPI_Id_Mobi) continue;

            for (final ct in np.chiTiets ?? const []) {
              if (_isPICha(record)) {
                if (ct.maSoPI == record.maSoPI) {
                  ct.vptq_kpi_KetQuaTuDanhGia_Id = ob.vptq_kpi_KetQuaTuDanhGia_Id;
                  ct.diemKetQuaTuDanhGia = ob.diem;
                  if ((ct.diemKetQuaTuDanhGia ?? 0) > 2) {
                    ct.giaiPhap = null;
                    ct.nguyenNhan = null;
                  }
                  ct.diemTrongSoTuDanhGia = double.parse((((ct.diemKetQuaTuDanhGia ?? 0) * (ct.tyTrong ?? 0)) / 100).toStringAsFixed(2));
                  ct.diemTrongSoTuDanhGiaFE = ct.diemTrongSoTuDanhGia;

                  _setNumber(ct, key, value);
                  _setNumberFE(ct, key, value);
                  ct.diemKetQuaTuDanhGiaFE = ct.diemKetQuaTuDanhGia;
                }
              } else {
                if (ct.maSoPI == record.maSoPICha_Mobi) {
                  for (final cct in ct.chiTietCons ?? const []) {
                    if (cct.maSoPI == record.maSoPI) {
                      _setNumber(cct, key, value);
                      _setNumberFE(cct, key, value);

                      final kqTH = (ob.kqTH ?? 0);
                      cct.phanTramKetQuaTuDanhGia = (kqTH > 200 ? 200 : (kqTH < 0 ? 0 : kqTH)).toDouble();
                      cct.phanTramKetQuaTuDanhGiaFE = cct.phanTramKetQuaTuDanhGia;
                    }
                  }

                  // tính lại cha từ con
                  ct.phanTramKetQuaTuDanhGia = tinhDiemTrongSoCha(ct.chiTietCons ?? const [], ct.tyTrong ?? 0);
                  ct.phanTramKetQuaTuDanhGiaFE = ct.phanTramKetQuaTuDanhGia;

                  final ob1 = _tinhKetQuaTheoKhoang(record.ketQuas, ct.phanTramKetQuaTuDanhGia ?? 0);
                  ct.vptq_kpi_KetQuaTuDanhGia_Id = ob1.id;
                  ct.diemKetQuaTuDanhGia = ob1.diem;

                  if ((ct.diemKetQuaTuDanhGia ?? 0) > 2) {
                    ct.giaiPhap = null;
                    ct.nguyenNhan = null;
                  }
                  ct.diemKetQuaTuDanhGiaFE = ct.diemKetQuaTuDanhGia;

                  ct.diemTrongSoTuDanhGia = double.parse((((ct.diemKetQuaTuDanhGia ?? 0) * (ct.tyTrong ?? 0)) / 100).toStringAsFixed(2));
                  ct.diemTrongSoTuDanhGiaFE = ct.diemTrongSoTuDanhGia;
                }
              }
            }

            // cuối vòng: update "nhóm tổng"
            if (i + 1 == (kn.nhomPIs?.length ?? 0)) {
              np.diemTrongSoTuDanhGia = double.parse(tyTrongSum.toStringAsFixed(2));
            } else {
              tyTrongSum += _sumDiemTrongSo(np.chiTiets);
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data; // ngắn gọn
    if (_loading) return LoadingWidget(context);
    if (_hasError) return Center(child: Text('Lỗi: $_errorCode'));
    // if (data == null) return const Center(child: Text(''));
    if (data == null) {
      return const Center(
        child: CircularProgressIndicator(), // icon xoay
      );
    }

    // lấy tổng điểm hiển thị: ưu tiên server trả, fallback tính tổng
    // final tongDiem = data.diemKetQuaCuoiCung ?? data.diemKetQuaTuDanhGia ?? data.diemKetQuaTamThoi ?? _tinhTongDiemTrongSo(data);
    final tongDiem = _tinhTongDiemTrongSo(data);

    final kiemNhiem = (data.kiemNhiems ?? []);
    final nhomPIs = kiemNhiem.isNotEmpty ? (kiemNhiem.first.nhomPIs ?? []) : <NhomPIModel>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _TongDiemCard(diem: tongDiem),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => getListData(widget.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Thẻ TỔNG ĐIỂM

                    // Các NHÓM chỉ tiêu
                    for (int i = 0; i < nhomPIs.length; i++) ...[
                      _NhomPISection(
                        sttLaMa: _toRoman(i + 1),
                        nhom: nhomPIs[i],
                        expanded: _expanded,
                        onToggle: (id) => setState(() {
                          _expanded.contains(id) ? _expanded.remove(id) : _expanded.add(id);
                        }),
                        // form states
                        getCtrl: (map, id) => _get(map, id),
                        khongHopLeOf: (id) => _getBool(_khongHopLe, id),
                        setKhongHopLe: (id, v) => setState(() => _khongHopLe[id] = v),
                        txtThucHien: _txtThucHien,
                        txtNhanXet: _txtNhanXet,
                        txtNguyenNhan: _txtNguyenNhan,
                        txtGiaiPhap: _txtGiaiPhap,
                        onToggleKhongThucHienAtParent: _handleToggleKhongThucHien,
                        onToggleKhongThucHienAtChild: onToggleKhongThucHienAtParent,
                        onChangeText: (v, rec, key) => _onChangeInputChiTieuNam(v, rec, key),
                        onChangeNumber: (v, rec, key) => _onChangeInputNumber(v, rec, key),
                        pickFiles: _pickFiles,
                        deleteFile: _deleteFile,
                        uploadFiles: _uploadFiles,
                        selectedFiles: _selectedFiles,
                        onScoreChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Thanh nút dưới cùng
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
        child: Row(
          children: [
            Expanded(
              child: _PrimaryButton(
                text: 'LƯU',
                controller: _btnController,
                onTap: () => _showConfirmationDialogSave(context),
                // onTap: () => _saveKPIAndMaybeSend(sendApproval: false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PrimaryButton(
                text: 'GỬI DUYỆT',
                controller: _btnControllerduyet,
                onTap: () => _showConfirmationDialog(context),
                // onTap: () => _saveKPIAndMaybeSend(sendApproval: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatNumber(num? v, {int fractionDigits = 1}) {
  if (v == null) return '';
  final s = v.toStringAsFixed(fractionDigits);
  // chèn dấu phẩy nghìn
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return parts.length > 1 && int.parse(parts[1]) != 0 ? '$intPart.${parts[1]}' : intPart;
}

/// chỉ gán 1 lần để không ghi đè khi user sửa
void initOnceText(TextEditingController c, String? value) {
  if (c.text.isEmpty && (value?.isNotEmpty ?? false)) c.text = value!;
}

bool hasChildKhongThucHien(ChiTietPIModel p) => p.chiTietCons?.any((c) => c.isKhongThucHien == true) ?? false;

void _persistFE(ChiTietPIModel ct) {
  ct.diemTrongSoTuDanhGiaFE ??= ct.diemTrongSoTuDanhGia;
  ct.diemKetQuaTuDanhGiaFE ??= ct.diemKetQuaTuDanhGia;
  ct.phanTramKetQuaTuDanhGiaFE ??= ct.phanTramKetQuaTuDanhGia;
  ct.giaTriChiTieuDanhGiaFE ??= ct.giaTriChiTieuDanhGia;
  ct.nguyenNhanFE ??= ct.nguyenNhan ?? '';
  ct.giaiPhapFE ??= ct.giaiPhap ?? '';
}

double tinhDiemTrongSoCha(List<ChiTietPIModel>? cons, int? tyTrongCha) {
  if (cons == null || cons.isEmpty || (tyTrongCha ?? 0) == 0) return 0.0;
  double tong = 0.0;
  for (final c in cons) {
    final pctCon = (c.phanTramKetQuaTuDanhGia ?? 0.0);
    final wCon = (c.tyTrong ?? 0);
    tong += pctCon * wCon;
  }
  final v = tong / (tyTrongCha ?? 1);
  // React dùng .toFixed(0) -> làm tròn như vậy
  return double.parse(v.toStringAsFixed(0));
}

class _PickKQ {
  _PickKQ(this.diem, this.id);
  final int diem;
  final String id;
}

_PickKQ tinhKetQuaTuDanhGia(List<KetQuaModel>? kqs, double value) {
  for (final k in kqs ?? const []) {
    final nhon = k.nhoHon; // double?
    final lonHonBang = k.lonHonHoacBang; // double?
    final match = (nhon != null && lonHonBang != null && lonHonBang <= value && value < nhon) || (nhon == null && lonHonBang != null && lonHonBang <= value) || (lonHonBang == null && nhon != null && value < nhon);
    if (match) {
      return _PickKQ((k.diem ?? 0), k.vptq_kpi_KetQuaDanhGia_Id ?? '');
    }
  }
  return _PickKQ(0, '00000000-0000-0000-0000-000000000000');
}

void toggleKhongThucHienCha(ChiTietPIModel ct, bool checked) {
  _persistFE(ct);

  ct.isKhongThucHien = checked;

  if (checked) {
    ct.diemTrongSoTuDanhGia = 0.0;
    ct.diemKetQuaTuDanhGia = 0;
    ct.phanTramKetQuaTuDanhGia = 0.0;
    ct.giaTriChiTieuDanhGia = null;
    ct.nguyenNhan = ct.nguyenNhanFE;
    ct.giaiPhap = ct.giaiPhapFE;
  } else {
    ct.diemTrongSoTuDanhGia = (ct.diemTrongSoTuDanhGiaFE ?? 0.0);
    ct.diemKetQuaTuDanhGia = (ct.diemKetQuaTuDanhGiaFE ?? 0);
    ct.phanTramKetQuaTuDanhGia = (ct.phanTramKetQuaTuDanhGiaFE ?? 0.0);
    ct.giaTriChiTieuDanhGia = ct.giaTriChiTieuDanhGiaFE;
    ct.nguyenNhan = '';
    ct.giaiPhap = '';
  }

  // Lock/unlock check ở CON
  ct.chiTietCons?.forEach((c) => c.isDisableKhongThucHien = checked);
}

void toggleKhongThucHienCon(
    {required ChiTietPIModel parent, // ct ở React (CHA)
    required ChiTietPIModel child, // cct ở React (CON)
    required bool checked,
    required List<KetQuaModel>? ketQuas // dùng record.ketQuas (khoảng điểm)
    }) {
  _persistFE(child);

  // 4.1 cập nhật CON
  child.isKhongThucHien = checked;
  if (checked) {
    child.diemTrongSoTuDanhGia = 0.0;
    child.diemKetQuaTuDanhGia = 0;
    child.phanTramKetQuaTuDanhGia = 0.0;
    child.giaTriChiTieuDanhGia = null;
  } else {
    child.phanTramKetQuaTuDanhGia = (child.phanTramKetQuaTuDanhGiaFE ?? 0.0);
    child.diemTrongSoTuDanhGia = (child.diemTrongSoTuDanhGiaFE ?? 0.0);
    child.diemKetQuaTuDanhGia = (child.diemKetQuaTuDanhGiaFE ?? 0);
    child.giaTriChiTieuDanhGia = child.giaTriChiTieuDanhGiaFE;
  }

  // 4.2 tính lại % CHA (toFixed(0) như React)
  parent.phanTramKetQuaTuDanhGia = tinhDiemTrongSoCha(parent.chiTietCons, parent.tyTrong);
  parent.phanTramKetQuaTuDanhGiaFE = parent.phanTramKetQuaTuDanhGia;

  // 4.3 pick lại kết quả CHA theo khoảng
  final pick = tinhKetQuaTuDanhGia(ketQuas, parent.phanTramKetQuaTuDanhGia ?? 0.0);
  parent.vptq_kpi_KetQuaTuDanhGia_Id = pick.id;
  parent.diemKetQuaTuDanhGia = pick.diem;
  parent.diemKetQuaTuDanhGiaFE = parent.diemKetQuaTuDanhGia;

  // 4.4 tính điểm trọng số CHA
  final tyTrongCha = (parent.tyTrong ?? 0);
  parent.diemTrongSoTuDanhGia = ((parent.diemKetQuaTuDanhGia ?? 0) * tyTrongCha) / 100.0;
  parent.diemTrongSoTuDanhGiaFE = parent.diemTrongSoTuDanhGia;

  // 4.5 nếu điểm CHA = 0, set GUID 0 như React
  if ((parent.diemKetQuaTuDanhGia ?? 0) == 0) {
    parent.vptq_kpi_KetQuaTuDanhGia_Id = '00000000-0000-0000-0000-000000000000';
  } else {
    // tuỳ nếu muốn map lại id theo điểm (giống đoạn React cuối)
    final match = (ketQuas ?? []).firstWhere(
      (k) => (k.diem ?? -1) == (parent.diemKetQuaTuDanhGia ?? -2),
      orElse: () => KetQuaModel(),
    );
    if ((match.vptq_kpi_KetQuaDanhGia_Id ?? '').isNotEmpty) {
      parent.vptq_kpi_KetQuaTuDanhGia_Id = match.vptq_kpi_KetQuaDanhGia_Id!;
    }
  }
}

class _TongDiemCard extends StatelessWidget {
  final double? diem;
  const _TongDiemCard({required this.diem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8), // hồng nhạt như ảnh
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF2E71FF).withOpacity(0.5), width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.assignment, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tổng điểm trọng số',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            (diem ?? 0).toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFFB71C1C),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NhomPISection extends StatelessWidget {
  final String sttLaMa;
  final NhomPIModel nhom;

  final Set<String> expanded;
  final void Function(String id) onToggle;

  // form handlers
  final TextEditingController Function(Map<String, TextEditingController>, String) getCtrl;
  final bool Function(String id) khongHopLeOf;
  final void Function(String id, bool v) setKhongHopLe;
  final Map<String, TextEditingController> txtThucHien, txtNhanXet, txtNguyenNhan, txtGiaiPhap;
  final void Function(ChiTietPIModel current, ChiTietPIModel? parent, bool value) onToggleKhongThucHienAtParent;
  final void Function(ChiTietPIModel current, ChiTietPIModel? parent, bool value) onToggleKhongThucHienAtChild;
  final void Function(String value, ChiTietPIModel record, String key) onChangeText;
  final void Function(String value, ChiTietPIModel record, String key) onChangeNumber;
  final VoidCallback pickFiles; // Hàm chọn file
  final Function(File) deleteFile; // Hàm xóa file
  final Future<void> Function() uploadFiles; // Hàm upload file
  final List<File> selectedFiles; // Danh sách file đã chọn
  final VoidCallback onScoreChanged;

  const _NhomPISection({
    required this.sttLaMa,
    required this.nhom,
    required this.expanded,
    required this.onToggle,
    required this.getCtrl,
    required this.khongHopLeOf,
    required this.setKhongHopLe,
    required this.txtThucHien,
    required this.txtNhanXet,
    required this.txtNguyenNhan,
    required this.txtGiaiPhap,
    required this.onToggleKhongThucHienAtParent,
    required this.onToggleKhongThucHienAtChild,
    required this.onChangeText,
    required this.onChangeNumber,
    required this.pickFiles,
    required this.deleteFile,
    required this.uploadFiles,
    required this.selectedFiles,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final chiTiets = nhom.chiTiets ?? [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề nhóm
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
              children: [
                TextSpan(text: '$sttLaMa. ${nhom.tenNhomPI ?? ''}\n'),
                const TextSpan(
                  text: '(Tỷ trọng: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red),
                ),
                TextSpan(
                  text: '${nhom.tongTyTrong ?? 0}%)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          for (int i = 0; i < chiTiets.length; i++) ...[
            _PiItem(
              index: i + 1,
              ct: chiTiets[i],
              isExpanded: expanded.contains(chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id),
              onToggle: () => onToggle(chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              // form states (per-id)
              ctrlThucHien: getCtrl(txtThucHien, chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              ctrlNhanXet: getCtrl(txtNhanXet, chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              ctrlNguyenNhan: getCtrl(txtNguyenNhan, chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              ctrlGiaiPhap: getCtrl(txtGiaiPhap, chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              khongHopLe: khongHopLeOf(chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              setKhongHopLe: (v) => setKhongHopLe(chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? '', v),
              onToggleKhongThucHien: (value) {
                final current = chiTiets[i];
                ChiTietPIModel? parentCt;
                for (final p in chiTiets) {
                  final has = (p.chiTietCons?.any((c) => c.vptq_kpi_KPICaNhanChiTiet_Id == current.vptq_kpi_KPICaNhanChiTiet_Id)) ?? false;
                  if (has) {
                    parentCt = p;
                    break;
                  }
                }
                onToggleKhongThucHienAtParent(current, parentCt, value);
              },

              getCtrlById: getCtrl,
              mapThucHien: txtThucHien,
              mapNhanXet: txtNhanXet,
              mapNguyenNhan: txtNguyenNhan,
              mapGiaiPhap: txtGiaiPhap,
              khongHopLeOfId: khongHopLeOf,
              setKhongHopLeId: setKhongHopLe,
              onToggleKhongThucHienChild: onToggleKhongThucHienAtChild,
              onChangeText: onChangeText,
              onChangeNumber: onChangeNumber,
              pickFiles: pickFiles,
              deleteFile: deleteFile,
              uploadFiles: uploadFiles,
              selectedFiles: selectedFiles,
              onScoreChanged: onScoreChanged,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

void _showPiInfo(BuildContext context, ChiTietPIModel ct, int? tyTrong, ChiTietPIModel ct2) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => _PiInfoSheet(ct: ct, tyTrong: tyTrong ?? 0, scroll: controller, ct2: ct2),
    ),
  );
}

class _PiInfoSheet extends StatelessWidget {
  final ChiTietPIModel ct;
  final ChiTietPIModel ct2;
  final int tyTrong;
  final ScrollController scroll;
  const _PiInfoSheet({required this.ct, required this.ct2, required this.tyTrong, required this.scroll});

  String get _duoi => (ct.isKetQuaThucHien == true) ? (ct.tenDonViTinh ?? '') : '%';

  String _fmt(num v) => v.toStringAsFixed(0);

  // map 5..1 -> nhãn
  static const _labels = {5: 'Vượt trội (5)', 4: 'Hoàn thành tốt (4)', 3: 'Hoàn thành (3)', 2: 'Hạn chế (2)', 1: 'Không đạt (1)'};

  // diễn đạt rule từ KetQuaModel
  // String _rule(KetQuaModel k) {
  //   final gte = k.lonHonHoacBang;
  //   final dvt = ct.tenDonViTinh;
  //   final lt = k.nhoHon;
  //   final hasGte = gte != null;
  //   final hasLt = lt != null;
  //   if (hasGte && hasLt) return '${_fmtPct(gte, dvt)}  đến  < ${_fmtPct(lt, dvt)}';
  //   if (hasGte && !hasLt) return '≥ ${_fmtPct(gte, dvt)}';
  //   if (!hasGte && hasLt) return 'dưới ${_fmtPct(lt, dvt)}';
  //   return '';
  // }
  // render rule theo đúng case của React
  String _rule(KetQuaModel k) {
    final gte = k.lonHonHoacBang; // >=
    final lt = k.nhoHon; //  <

    if (gte == null && lt == null) {
      // React: dùng kq.noiDung
      return k.noiDung ?? '';
    } else if (gte == null && lt != null) {
      // React: nếu lt === 1 => "0 duoi", else "dưới lt duoi"
      if (lt == 1) return '${_fmt(lt - 1)} ${_duoi}';
      return 'dưới ${_fmt(lt)} ${_duoi}';
    } else if (gte != null && lt == null) {
      // React: ">= gte duoi"
      return '≥ ${_fmt(gte)} ${_duoi}';
    } else {
      // gte != null && lt != null
      // React: nếu (lt - gte === 1) => "gte duoi"
      if ((lt! - gte!) == 1) return '${_fmt(gte)} ${_duoi}';
      // else: "gte - dưới lt duoi"
      return '${_fmt(gte)} - dưới ${_fmt(lt)} ${_duoi}';
    }
  }

  // chọn rule theo điểm
  KetQuaModel? _byScore(int s) {
    return ct.ketQuas?.firstWhere((e) => (e.diem ?? -1) == s, orElse: () => KetQuaModel());
  }

  // “Chỉ tiêu cần đạt”
  String get _chiTieuCanDat {
    if (ct.isNoiDung == true) return '${ct?.noiDungChiTieu}';
    if (ct.giaTriChiTieu != null) {
      final so = ct.giaTriChiTieu;
      final dv = (ct.tenDonViTinh?.isNotEmpty ?? false) ? ' ${ct.tenDonViTinh}' : '';
      return '$so$dv';
    }
    return '';
  }

  String formatCurrency(
    num value,
    num? chia,
    dynamic soThapPhan, // false hoặc int
    bool isFormat,
  ) {
    // B1: xử lý chia và số thập phân
    num base = chia != null ? value / chia : value;
    String newValue;
    if (soThapPhan == false) {
      newValue = base.toString();
    } else if (soThapPhan is int) {
      newValue = base.toStringAsFixed(soThapPhan);
    } else {
      newValue = base.toString();
    }

    // B2: tách phần nguyên / thập phân
    List<String> parts = newValue.split(isFormat ? "," : ".");
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // B3: thêm dấu phân cách nghìn
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String formattedInteger = integerPart.replaceAllMapped(reg, (m) => isFormat ? "," : ".");

    // B4: trả về kết quả
    if (decimalPart != null && decimalPart.isNotEmpty) {
      return "$formattedInteger${isFormat ? "," : "."}$decimalPart";
    } else {
      return formattedInteger;
    }
  }

  String fmt(num? v, String? unit) {
    if (v != null || v == 0) {
      final so = formatCurrency(v ?? 0, 1, false, true); // chia=1, soThapPhan=false, isFormat=true
      final dv = (unit?.isNotEmpty ?? false) ? ' $unit' : '';
      return '$so$dv';
    }
    return '';
  }

  String? get ketQuaThucHien {
    final bool isChiTietCon = ct.hasCon == true ? false : (ct.isNoiDung == true ? false : (ct.chiTietCons != null && (ct.chiTietCons!.isNotEmpty)));
    // isChiTietCon -> chỉ hiển thị diễn giải
    if (isChiTietCon == true) {
      return ct.dienGiaiDanhGia ?? '';
    }
    // isNoiDung -> nội dung chỉ tiêu + (diễn giải)
    else if (ct.isNoiDung == true) {
      return ct.noiDungChiTieu ?? '';
    }
    // Mặc định -> giá trị + đơn vị (kể cả = 0) + (diễn giải)
    else {
      return fmt(ct.giaTriChiTieuDanhGia, ct.tenDonViTinh);
    }
  }

  Widget _fileDinhKemPill(ChiTietPIModel ct) {
    final v = ct.fileDinhKem;
    if (v == null) return const Text('File đính kèm:', style: const TextStyle(fontWeight: FontWeight.w800));

    // React có 2 case: {name, fileLoad} (file mới) hoặc string path.
    // Flutter: hỗ trợ cả 2
    String? href;
    String label = 'File';
    if (v is String) {
      href = '${AppConfig.BASE_URL_API_KPI}$v';
    } else if (v is Map) {
      // v['fileLoad'] là dataURL/base64, v['name'] là tên
      // href = v['fileLoad'] as String?;
      // label = (v['name'] as String?) ?? 'File';
    }

    if (href == null || href.isEmpty) return const SizedBox.shrink();

    return _labelAndPill(
      label: 'File đính kèm:',
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(href!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.insert_drive_file, size: 18, color: Color(0xFF2E71FF)),
          ],
        ),
      ),
    );
  }

  Widget _pill(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDF2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
// helper dùng cùng style với các pill
  Widget _labelAndPill({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        _pill(child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: ListView(
        controller: scroll,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Chi tiết chỉ tiêu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 6),

          // --- Thông tin PI ---
          _section(
            title: 'Thông tin PI',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Mã số PI:', ct.maSoPI),
                _row('Chỉ số đánh giá:', ct.chiSoDanhGia),
                const SizedBox(height: 6),
                _row('Chi tiết chỉ số đánh giá:', ct.chiSoDanhGiaChiTiet),

                const SizedBox(height: 10),
                // mức điểm
                for (final s in [5, 4, 3, 2, 1]) ...[
                  Builder(builder: (_) {
                    final k = _byScore(s);
                    final text = (k == null || (k.diem == null)) ? null : _rule(k);
                    return _row(_labels[s]!, text);
                  }),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // --- Thông tin đăng ký ---
          _section(
            title: 'Thông tin đăng ký',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Tỷ trọng:', '$tyTrong'),
                _row('Chỉ tiêu cần đạt:', _chiTieuCanDat),
                const SizedBox(height: 4),
                _row('Diễn giải:', ct.dienGiai ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Kết quả thực hiện',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Kết quả:', ct2?.diemTrongSoTuDanhGia?.toString()),

                // _row('Kết quả thực hiện:', (ct.isNoiDung == true ? ct.noiDungChiTieuDanhGia : "${ct.giaTriChiTieuDanhGia?.toString() ?? ''} ${ct.tenDonViTinh ?? ''}") ?? ''),
                _row(
                  'Kết quả thực hiện:',
                  buildNdText(
                    isNoiDung: ct.isNoiDung ?? false,
                    noiDungChiTieuDanhGia: ct.noiDungChiTieuDanhGia,
                    dienGiaiDanhGia: ct.dienGiaiDanhGia,
                    giaTriChiTieuDanhGia: ct.giaTriChiTieuDanhGia,
                    tenDonViTinh: ct.tenDonViTinh,
                  ),
                ),

                _row('Diễn giải:', ct.dienGiaiDanhGia ?? ''),
                _fileDinhKemPill(ct),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFC6D2)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.35),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: (value == null || value.isEmpty) ? '' : value),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String s) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.w800)),
          Expanded(child: Text(s, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

String _fmtCurrency(num? v) {
  if (v == null) return '';
  // giống formatCurrency(..., 1, false, true) ⇒ bạn chỉnh decimals nếu cần
  return NumberFormat.decimalPattern('vi_VN').format(v);
}

String buildNdText({
  required bool isNoiDung,
  String? noiDungChiTieuDanhGia,
  String? dienGiaiDanhGia,
  num? giaTriChiTieuDanhGia,
  String? tenDonViTinh,
}) {
  if (isNoiDung) {
    final line1 = (noiDungChiTieuDanhGia ?? '').trim();
    final line2 = (dienGiaiDanhGia ?? '').trim();
    return [
      if (line1.isNotEmpty) line1,
      if (line2.isNotEmpty) '($line2)',
    ].join('\n');
  } else {
    final v = giaTriChiTieuDanhGia;
    final unit = (tenDonViTinh ?? '').trim();
    final line1 = v == null ? '' : _fmtCurrency(v) + (unit.isNotEmpty ? ' $unit' : '');
    final line2 = (dienGiaiDanhGia ?? '').trim();
    return [
      if (line1.isNotEmpty) line1,
      if (line2.isNotEmpty) '($line2)',
    ].join('\n');
  }
}

class _PiItem extends StatefulWidget {
  final int index;
  final ChiTietPIModel ct;
  final bool isExpanded;
  final VoidCallback onToggle;

  // form controllers
  final TextEditingController ctrlThucHien;
  final TextEditingController ctrlNhanXet;
  final TextEditingController ctrlNguyenNhan;
  final TextEditingController ctrlGiaiPhap;
  final bool khongHopLe;
  final ValueChanged<bool> setKhongHopLe;
  final ValueChanged<bool> onToggleKhongThucHien;
  final TextEditingController Function(Map<String, TextEditingController>, String) getCtrlById;
  final Map<String, TextEditingController> mapThucHien, mapNhanXet, mapNguyenNhan, mapGiaiPhap;
  final bool Function(String id) khongHopLeOfId;
  final void Function(String id, bool v) setKhongHopLeId;
  final void Function(ChiTietPIModel current, ChiTietPIModel? parent, bool value) onToggleKhongThucHienChild;
  final void Function(String value, ChiTietPIModel record, String key) onChangeText;
  final void Function(String value, ChiTietPIModel record, String key) onChangeNumber;
  final VoidCallback pickFiles; // Hàm chọn file
  final Function(File) deleteFile; // Hàm xóa file
  final Future<void> Function() uploadFiles; // Hàm upload file
  final List<File> selectedFiles; // Danh sách file đã chọn
  final VoidCallback onScoreChanged;

  const _PiItem({
    required this.index,
    required this.ct,
    required this.isExpanded,
    required this.onToggle,
    required this.ctrlThucHien,
    required this.ctrlNhanXet,
    required this.ctrlNguyenNhan,
    required this.ctrlGiaiPhap,
    required this.khongHopLe,
    required this.setKhongHopLe,
    required this.onToggleKhongThucHien,
    required this.getCtrlById,
    required this.mapThucHien,
    required this.mapNhanXet,
    required this.mapNguyenNhan,
    required this.mapGiaiPhap,
    required this.khongHopLeOfId,
    required this.setKhongHopLeId,
    required this.onToggleKhongThucHienChild,
    required this.onChangeText,
    required this.onChangeNumber,
    required this.pickFiles,
    required this.deleteFile,
    required this.uploadFiles,
    required this.selectedFiles,
    required this.onScoreChanged,
  });
  @override
  State<_PiItem> createState() => _PiItemState();
}

class _PiItemState extends State<_PiItem> {
  static const _ZERO_ID = '00000000-0000-0000-0000-000000000000';
  int _minDiem(ChiTietPIModel ct) {
    final kqs = ct.ketQuas ?? const [];
    if (kqs.isEmpty) return 0;
    return kqs.map((e) => (e.diem ?? 0)).reduce((a, b) => a < b ? a : b);
  }

  int _maxDiem(ChiTietPIModel ct) {
    final kqs = ct.ketQuas ?? const [];
    if (kqs.isEmpty) return 5;
    return kqs.map((e) => (e.diem ?? 0)).reduce((a, b) => a > b ? a : b);
  }

  // void _changeDiem(int v) {
  //   // cập nhật ngay lập tức UI của item này
  //   setState(() {
  //     // đảm bảo kiểu double cho tính trọng số
  //     widget.ct.diemKetQuaTuDanhGia = v;
  //     widget.ct.diemTrongSoTuDanhGia = ((widget.ct.tyTrong ?? 0) * (widget.ct.diemKetQuaTuDanhGia ?? 0)) / 100.0;
  //   });
  // }
  void _changeDiem(int v) {
    setState(() {
      widget.ct.diemKetQuaTuDanhGia = v;

      // Tính lại điểm trọng số
      widget.ct.diemTrongSoTuDanhGia = ((widget.ct.tyTrong ?? 0) * v) / 100.0;

      // Cập nhật ID kết quả dựa trên điểm
      final match = (widget.ct.ketQuas ?? []).firstWhere(
        (k) => (k.diem ?? -1) == v,
        orElse: () => KetQuaModel(),
      );

      // Cập nhật ID kết quả theo điểm
      if (v == 0) {
        widget.ct.vptq_kpi_KetQuaTuDanhGia_Id = _ZERO_ID; // ID cho điểm 0
      } else if ((match.vptq_kpi_KetQuaDanhGia_Id ?? '').isNotEmpty) {
        widget.ct.vptq_kpi_KetQuaTuDanhGia_Id = match.vptq_kpi_KetQuaDanhGia_Id!; // Lấy ID từ match
      }

      // Cập nhật các giá trị liên quan
      if ((widget.ct.diemKetQuaTuDanhGia ?? 0) > 2) {
        widget.ct.giaiPhap = null;
        widget.ct.nguyenNhan = null;
      } else {
        // Trả lại các giá trị FE nếu có
        widget.ct.giaiPhap = (widget.ct.giaiPhapFE ?? '');
        widget.ct.nguyenNhan = (widget.ct.nguyenNhanFE ?? '');
      }
      widget.onScoreChanged();
      // In thông tin debug nếu cần
      print('tyTrong: ${widget.ct.tyTrong}, v: $v');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.ct;
    final tyTrong = ct.tyTrong ?? 0;
    final bool isNoiDung = ct.isNoiDung == true;
    final bool isChiTietCon = ct.hasCon == true ? false : (ct.isNoiDung == true ? false : (ct.chiTietCons != null && (ct.chiTietCons!.isNotEmpty)));
    final bool disabled = ct.isKhongThucHien == true;
    final enableReasonParent = ct.isKhongThucHien == true || hasChildKhongThucHien(ct);
    ;

    final hasChildren = ct.chiTietCons?.isNotEmpty == true;
    final editableScore = (((ct.isKetQuaThucHien ?? false) && hasChildren) || (ct.isNoiDung == true));
    print("ct.diemKetQuaTuDanhGia : ${ct.diemKetQuaTuDanhGia}");

    // ... PHẦN HEADER của bạn giữ nguyên

    // === CHỖ "Điểm đánh giá" -> thay RichText bằng điều kiện nhập/hiển thị ===
    final minD = _minDiem(ct);
    final maxD = _maxDiem(ct);
    final current = (ct.diemKetQuaTuDanhGia ?? 0).toInt();

    final diemWidget = editableScore
        ? _NumberStepper(
            value: current,
            min: minD,
            max: maxD,
            disabled: disabled,
            onChanged: _changeDiem,
          )
        : Text(
            '${ct.diemKetQuaTuDanhGia?.toInt() ?? 0}',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
          );
// ================== CHỈ TIÊU CẦN ĐẠT ==================
    String noiDungCanDat;
    if (isChiTietCon) {
      noiDungCanDat = ct.dienGiai ?? '';
    } else if (isNoiDung) {
      final base = ct.noiDungChiTieu ?? '';
      final extra = (ct.dienGiai?.isNotEmpty ?? false) ? '\n(${ct.dienGiai})' : '';
      noiDungCanDat = '$base$extra';
    } else {
      final so = (ct.giaTriChiTieu != null || ct.giaTriChiTieu == 0) ? '${formatNumber(ct.giaTriChiTieu, fractionDigits: 1)}${ct.tenDonViTinh?.isNotEmpty == true ? ' ${ct.tenDonViTinh}' : ''}' : '';
      final extra = (ct.dienGiai?.isNotEmpty ?? false) ? '\n(${ct.dienGiai})' : '';
      noiDungCanDat = '$so$extra';
    }
    final diemRow = RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
        children: [
          const TextSpan(text: 'Điểm đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
          // chèn WidgetSpan để nhúng widget nhập số
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: diemWidget,
            ),
          ),
          const TextSpan(text: '- Điểm trọng số: ', style: TextStyle(fontWeight: FontWeight.w700)),
          TextSpan(
            text: (ct.diemTrongSoTuDanhGia ?? 0).toStringAsFixed(2),
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onToggle, // toggle ở mọi khoảng trống trong card
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
            border: Border.all(
              color: widget.isExpanded ? const Color(0xFF2E71FF) : const Color(0xFFE7E8EC),
              width: widget.isExpanded ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // --- header (thu gọn) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 0, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 4,
                            children: [
                              Text('${widget.index}. Mã số PI: ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              // Text(ct.maSoPI ?? '', style: const TextStyle(color: Color(0xFF2E71FF), decoration: TextDecoration.underline, fontWeight: FontWeight.w700)),
                              InkWell(
                                onTap: () => _showPiInfo(context, ct, tyTrong, ct),
                                child: Text(
                                  ct.maSoPI ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF2E71FF),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text('  (Tỷ trọng: $tyTrong%)', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                              children: [
                                const TextSpan(text: 'Chỉ số đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: ct.chiSoDanhGia ?? ''),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // RichText(
                          //   text: TextSpan(
                          //     style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                          //     children: [
                          //       const TextSpan(text: 'Điểm đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                          //       TextSpan(text: '${ct.diemKetQuaTuDanhGia ?? 0}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                          //       const TextSpan(text: '  -  Điểm trọng số: ', style: TextStyle(fontWeight: FontWeight.w700)),
                          //       TextSpan(text: (ct.diemTrongSoTuDanhGia ?? 0).toStringAsFixed(2), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                          //     ],
                          //   ),
                          // ),
                          diemRow,
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(widget.isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.red),
                  ],
                ),
              ),

              // --- body (mở rộng) ---
              if (widget.isExpanded) const Divider(height: 1),
              if (widget.isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Chỉ tiêu cần đạt:'),
                      const SizedBox(height: 6),
                      _pill(
                        Container(
                          width: double.infinity,
                          child: Text(noiDungCanDat, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _label('Kết quả thực hiện:'),
                      const SizedBox(height: 6),

                      if (isNoiDung) ...[
                        // map đúng React: 2 ô Mentions tương đương 2 TextField
                        Builder(builder: (_) {
                          initOnceText(widget.ctrlThucHien, ct.noiDungChiTieuDanhGia); // dùng ctrlThucHien cho "noiDungChiTieuDanhGia"
                          return _input(
                            widget.ctrlThucHien,
                            hint: 'Nhập nội dung kết quả',
                            enabled: !disabled,
                            maxLines: 3,
                            onChanged: (v) => widget.onChangeText(v, ct, 'noiDungChiTieuDanhGia'),
                          );
                        }),
                        const SizedBox(height: 8),
                        Builder(builder: (_) {
                          initOnceText(widget.ctrlNhanXet, ct.dienGiaiDanhGia); // dùng ctrlNhanXet cho "dienGiaiDanhGia"
                          return _input(
                            widget.ctrlNhanXet,
                            hint: 'Nhập diễn giải',
                            enabled: !disabled,
                            maxLines: 2,
                            onChanged: (v) => widget.onChangeText(v, ct, 'dienGiaiDanhGia'),
                          );
                        }),
                      ] else ...[
                        // PI số liệu: input số + đơn vị
                        Row(
                          children: [
                            Expanded(
                              child: Builder(builder: (_) {
                                initOnceText(
                                  widget.ctrlThucHien,
                                  ct.giaTriChiTieuDanhGia == null ? '' : (ct.giaTriChiTieuDanhGia?.toStringAsFixed(0)),
                                );
                                return _input(
                                  widget.ctrlThucHien,
                                  hint: 'Nhập kết quả (số)',
                                  keyboard: TextInputType.number,
                                  enabled: !disabled,
                                  onChanged: (v) => widget.onChangeNumber(v, ct, 'giaTriChiTieuDanhGia'),
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: _pill(
                                Center(
                                  child: Text(
                                    ct.tenDonViTinh ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // dòng mô tả kết quả (dienGiaiDanhGia)
                        Builder(builder: (_) {
                          initOnceText(widget.ctrlNhanXet, ct.dienGiaiDanhGia);
                          return _input(
                            widget.ctrlNhanXet,
                            hint: 'Nhập diễn giải...',
                            enabled: !disabled,
                            maxLines: 2,
                            onChanged: (v) => widget.onChangeText(v, ct, 'dienGiaiDanhGia'),
                          );
                        }),
                      ],

                      // _input(ctrlNhanXet, hint: 'Nhập nhận xét...'),
                      // const SizedBox(height: 10),

                      // _uploadButton(),
                      // Row(
                      //   children: [
                      //     // Nút chọn file
                      //     ElevatedButton(
                      //       onPressed: widget.pickFiles,
                      //       child: Text("Chọn File"),
                      //     ),
                      //     // Hiển thị các file đã chọn
                      //     Expanded(
                      //       child: ListView.builder(
                      //         shrinkWrap: true,
                      //         itemCount: widget.selectedFiles.length,
                      //         itemBuilder: (context, index) {
                      //           return ListTile(
                      //             title: Text(widget.selectedFiles[index].path.split('/').last),
                      //             trailing: IconButton(
                      //               icon: Icon(Icons.delete),
                      //               onPressed: () => widget.deleteFile(widget.selectedFiles[index]),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //     // Nút Lưu
                      //     // ElevatedButton(
                      //     //   onPressed: widget.uploadFiles,
                      //     //   child: Text("Lưu"),
                      //     // ),
                      //   ],
                      // ),

                      const SizedBox(height: 12),
                      // RichText(
                      //   text: TextSpan(
                      //     style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
                      //     children: const [
                      //       TextSpan(text: 'Điểm đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                      //       TextSpan(text: '0', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                      //       TextSpan(text: '  -  Điểm trọng số: ', style: TextStyle(fontWeight: FontWeight.w700)),
                      //       TextSpan(text: '0', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 10),

                      // Không hợp lệ
                      Row(
                        children: [
                          Expanded(child: _pill(const Text('Không thực hiện'))),
                          const SizedBox(width: 8),
                          GestureDetector(
                            // onTap: () => setKhongHopLe(!khongHopLe),
                            onTap: () {
                              final next = !widget.khongHopLe;
                              widget.setKhongHopLe(next); // cập nhật flag hiển thị
                              widget.onToggleKhongThucHien(next); // cha sẽ setState + cập nhật điểm/y giá trị
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: widget.khongHopLe ? const Color(0xFF00BC7E) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFBFC6D2)),
                              ),
                              child: widget.khongHopLe ? const Icon(Icons.check, color: Colors.white) : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      _label('Nguyên nhân:'),
                      const SizedBox(height: 6),
                      _input(widget.ctrlNguyenNhan,
                          hint: 'Nhập nguyên nhân',
                          onChanged: (v) => widget.onChangeText(v, ct, 'nguyenNhan'),
                          enabled:
                              // ((ct.diemKetQuaTuDanhGia ?? 0) <= 2 || ct.diemKetQuaTuDanhGia == 0)
                              (ct.diemKetQuaTuDanhGia != null && ((ct.diemKetQuaTuDanhGia ?? 0) <= 2 || ct.diemKetQuaTuDanhGia == 0)),
                          maxLines: 3),

                      const SizedBox(height: 10),
                      _label('Giải pháp:'),
                      const SizedBox(height: 6),
                      _input(widget.ctrlGiaiPhap,
                          hint: 'Nhập giải pháp',
                          onChanged: (v) => widget.onChangeText(v, ct, 'giaiPhap'),
                          enabled:
                              // ((ct.diemKetQuaTuDanhGia ?? 0) <= 2 || ct.diemKetQuaTuDanhGia == 0)
                              (ct.diemKetQuaTuDanhGia != null && ((ct.diemKetQuaTuDanhGia ?? 0) <= 2 || ct.diemKetQuaTuDanhGia == 0)),
                          maxLines: 2),
                      if ((ct.chiTietCons?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 14),
                        _label('Chi tiết con:'),
                        const SizedBox(height: 8),
                        for (int j = 0; j < ct.chiTietCons!.length; j++)
                          _ChildPiCard(
                            index: '${widget.index}.${j + 1}',
                            childCt: ct.chiTietCons![j],
                            parentCt: ct,
                            // controllers/flags theo ID
                            getCtrlById: widget.getCtrlById,
                            mapThucHien: widget.mapThucHien,
                            mapNhanXet: widget.mapNhanXet,
                            mapNguyenNhan: widget.mapNguyenNhan,
                            mapGiaiPhap: widget.mapGiaiPhap,
                            khongHopLeOfId: widget.khongHopLeOfId,
                            setKhongHopLeId: widget.setKhongHopLeId,

                            // tick “không hợp lệ” ở CON → cập nhật CHA
                            onToggleKhongThucHienChild: widget.onToggleKhongThucHienChild,
                            onChangeNumber: widget.onChangeNumber,
                            onChangeText: widget.onChangeText,
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI helpers nhỏ gọn ---

  Widget _label(String s) => Text(s, style: const TextStyle(fontWeight: FontWeight.w800));

  Widget _pill(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDF2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _input(
    TextEditingController c, {
    String? hint,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboard,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: c,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9DCE2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9DCE2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E71FF))),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _uploadButton() => SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('TẢI LÊN FILE ĐÍNH KÈM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      );
}

class _NumberStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final bool disabled;
  final ValueChanged<int> onChanged;

  const _NumberStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final canDec = !disabled && value > min;
    final canInc = !disabled && value < max;

    Widget box(String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFFF3F4F6) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD9DCE2)),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: disabled ? Colors.black45 : Colors.red,
            ),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: canDec ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        box('$value'),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: canInc ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _ChildPiCard extends StatefulWidget {
  final String index; // ví dụ: "1.1"
  final ChiTietPIModel childCt;
  final ChiTietPIModel parentCt;

  final TextEditingController Function(Map<String, TextEditingController>, String) getCtrlById;
  final Map<String, TextEditingController> mapThucHien, mapNhanXet, mapNguyenNhan, mapGiaiPhap;
  final bool Function(String id) khongHopLeOfId;
  final void Function(String id, bool v) setKhongHopLeId;
  final void Function(ChiTietPIModel current, ChiTietPIModel? parent, bool value) onToggleKhongThucHienChild;
  final void Function(String value, ChiTietPIModel record, String key) onChangeNumber;
  final void Function(String value, ChiTietPIModel record, String key) onChangeText;

  const _ChildPiCard({
    super.key,
    required this.index,
    required this.childCt,
    required this.parentCt,
    required this.getCtrlById,
    required this.mapThucHien,
    required this.mapNhanXet,
    required this.mapNguyenNhan,
    required this.mapGiaiPhap,
    required this.khongHopLeOfId,
    required this.setKhongHopLeId,
    required this.onToggleKhongThucHienChild,
    required this.onChangeNumber,
    required this.onChangeText,
  });

  @override
  State<_ChildPiCard> createState() => _ChildPiCardState();
}

class _ChildPiCardState extends State<_ChildPiCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final ct = widget.childCt;
    final ct2 = widget.parentCt;
    final id = ct.vptq_kpi_KPICaNhanChiTietCon_Id ?? ct.vptq_kpi_KPICaNhanChiTiet_Id ?? '';

    final tyTrong = ct.tyTrong ?? 0;
    final disabled = (ct.isKhongThucHien == true);
    final khongHopLe = widget.khongHopLeOfId(id);
    final bool isNoiDung = ct.isNoiDung == true;

    // controllers theo id
    final cTh = widget.getCtrlById(widget.mapThucHien, id);
    final cNx = widget.getCtrlById(widget.mapNhanXet, id);
    final cNg = widget.getCtrlById(widget.mapNguyenNhan, id);
    final cGp = widget.getCtrlById(widget.mapGiaiPhap, id);

    // nội dung “Chỉ tiêu cần đạt”
    final so = (ct.giaTriChiTieu != null || ct.giaTriChiTieu == 0) ? '${formatNumber(ct.giaTriChiTieu, fractionDigits: 1)}${ct.tenDonViTinh?.isNotEmpty == true ? ' ${ct.tenDonViTinh}' : ''}' : '';
    final extra = (ct.dienGiai?.isNotEmpty ?? false) ? '\n(${ct.dienGiai})' : '';
    final noiDungCanDat = '$so$extra';
    final showScores = ct.isKhongThucHien == true || ct.diemKetQuaTuDanhGia != null || ct.diemTrongSoTuDanhGia != null;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAF3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE9DD)),
      ),
      child: Column(
        children: [
          // --- HEADER con ---
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('${widget.index} Mã số PI: ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            // Text(ct.maSoPI ?? '',
                            //     style: const TextStyle(
                            //       color: Color(0xFF2E71FF),
                            //       decoration: TextDecoration.underline,
                            //       fontWeight: FontWeight.w700,
                            //     )),
                            InkWell(
                              onTap: () => _showPiInfo(context, ct, tyTrong, ct2),
                              child: Text(
                                ct.maSoPI ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF2E71FF),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text('  (Tỷ trọng: $tyTrong%)', style: const TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                            children: [
                              const TextSpan(text: 'Chỉ số đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: ct.chiSoDanhGia ?? ''),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                            children: const [
                              TextSpan(text: 'Điểm đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(
                                // text: '${ct.isKhongThucHien == true ? 0 : (ct.diemKetQuaTuDanhGia ?? 0)}',
                                text: '',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                              ),
                              TextSpan(text: '  - Điểm trọng số: ', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(
                                // text: (ct.isKhongThucHien == true ? 0 : (ct.diemTrongSoTuDanhGia ?? 0)).toStringAsFixed(2),
                                text: '',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(_open ? Icons.expand_less : Icons.expand_more, color: Colors.green),
                ],
              ),
            ),
          ),

          if (_open) const Divider(height: 1),

          // --- BODY con ---
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Chỉ tiêu cần đạt:'),
                  const SizedBox(height: 6),
                  _pill(Text(noiDungCanDat, style: const TextStyle(fontWeight: FontWeight.w700))),
                  const SizedBox(height: 12),
                  _label('Kết quả thực hiện:'),
                  const SizedBox(height: 6),
                  if (isNoiDung) ...[
                    // map đúng React: 2 ô Mentions tương đương 2 TextField
                    Builder(builder: (_) {
                      initOnceText(cTh, ct.noiDungChiTieuDanhGia); // dùng ctrlThucHien cho "noiDungChiTieuDanhGia"
                      return _input(
                        cTh,
                        hint: 'Nhập nội dung kết quả',
                        enabled: !disabled,
                        maxLines: 3,
                        onChanged: (v) => widget.onChangeText(v, ct, 'noiDungChiTieuDanhGia'),
                      );
                    }),
                    const SizedBox(height: 8),
                    Builder(builder: (_) {
                      initOnceText(cNx, ct.dienGiaiDanhGia); // dùng ctrlNhanXet cho "dienGiaiDanhGia"
                      return _input(
                        cNx,
                        hint: 'Nhập diễn giải',
                        enabled: !disabled,
                        maxLines: 2,
                        onChanged: (v) => widget.onChangeText(v, ct, 'dienGiaiDanhGia'),
                      );
                    }),
                  ] else ...[
                    // PI số liệu: input số + đơn vị
                    Row(
                      children: [
                        Expanded(
                          child: Builder(builder: (_) {
                            initOnceText(
                              cTh,
                              ct.giaTriChiTieuDanhGia == null ? '' : (ct.giaTriChiTieuDanhGia?.toStringAsFixed(0)),
                            );
                            return _input(
                              cTh,
                              hint: 'Nhập kết quả',
                              keyboard: TextInputType.number,
                              enabled: !disabled,
                              onChanged: (v) => widget.onChangeNumber(v, ct, 'giaTriChiTieuDanhGia'),
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: _pill(Center(
                            child: Text(ct.tenDonViTinh ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                          )),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),
                  Builder(builder: (_) {
                    initOnceText(cNx, ct.dienGiaiDanhGia);
                    return _input(
                      cNx,
                      hint: 'Nhập nhận xét...',
                      enabled: !disabled,
                      maxLines: 2,
                      onChanged: (v) => widget.onChangeText(v, ct, 'dienGiaiDanhGia'),
                    );
                  }),
                  // const SizedBox(height: 10),
                  // _uploadButton(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _pill(const Text('Không thực hiện'))),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final next = !khongHopLe;
                          widget.setKhongHopLeId(id, next);
                          widget.onToggleKhongThucHienChild(ct, widget.parentCt, next);
                          setState(() {}); // refresh màu nút
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: khongHopLe ? const Color(0xFF00BC7E) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFC6D2)),
                          ),
                          child: khongHopLe ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 10),
                  // _label('Nguyên nhân:'),
                  // const SizedBox(height: 6),
                  // _input(widget.getCtrlById(widget.mapNguyenNhan, id), hint: 'Nhập nguyên nhân', enabled: khongHopLe, maxLines: 3),
                  // const SizedBox(height: 10),
                  // _label('Giải pháp:'),
                  // const SizedBox(height: 6),
                  // _input(widget.getCtrlById(widget.mapGiaiPhap, id), hint: 'Nhập giải pháp', enabled: khongHopLe, maxLines: 2),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // === helpers nhỏ (copy từ _PiItem) ===
  Widget _label(String s) => Text(s, style: const TextStyle(fontWeight: FontWeight.w800));
  Widget _pill(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFE9EDF2), borderRadius: BorderRadius.circular(12)),
        child: child,
      );
  Widget _input(
    TextEditingController c, {
    String? hint,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboard,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: c,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9DCE2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD9DCE2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E71FF))),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _uploadButton() => SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: () {/* TODO */},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('TẢI LÊN FILE ĐÍNH KÈM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      );
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
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
        onPressed: onTap,
        controller: controller,
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
