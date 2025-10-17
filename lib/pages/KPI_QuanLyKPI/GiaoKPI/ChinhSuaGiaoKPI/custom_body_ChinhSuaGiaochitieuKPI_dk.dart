import 'dart:convert';

import 'package:Thilogi/services/request_helper_kpi.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../../../blocs/user_bloc.dart';
import '../../../../models/checksheet.dart';
import '../../../../models/kpi/chitietdanhgiakpi.dart';
import '../../../../models/kpi/kydanhgia.dart';
import '../../../../widgets/loading.dart';

class BodyCSGiaoChiTieuKPIScreen2 extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  final bool isChiTiet;
  final String? kyDanhGia;
  const BodyCSGiaoChiTieuKPIScreen2({super.key, required this.id, required this.lstFiles, required this.isChiTiet, required this.kyDanhGia});

  @override
  _BodyCSGiaoChiTieuKPIScreen2State createState() => _BodyCSGiaoChiTieuKPIScreen2State();
}

class _BodyCSGiaoChiTieuKPIScreen2State extends State<BodyCSGiaoChiTieuKPIScreen2> with TickerProviderStateMixin, ChangeNotifier {
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
  final RoundedLoadingButtonController _btnControllerDuyet = RoundedLoadingButtonController();

  ChiTietDanhGiaKPIModel? _data;

  KyDanhGiaModel? _selectedKy;
  List<KyDanhGiaModel> _listKy = [];
  final Set<String> _expanded = {};

  // state form cho từng PI (key = KPICaNhanChiTiet_Id)
  final Map<String, TextEditingController> _txtThucHien = {};
  final Map<String, TextEditingController> _txtNhanXet = {};
  final Map<String, TextEditingController> _txtNguyenNhan = {};
  final Map<String, TextEditingController> _txtGiaiPhap = {};
  final Map<String, bool> _khongHopLe = {};

  // tiện ích lấy/khởi tạo controller
  TextEditingController _get(Map<String, TextEditingController> m, String key) => m.putIfAbsent(key, () => TextEditingController());

  bool _getBool(Map<String, bool> m, String key) => m.putIfAbsent(key, () => false);

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    getListData(widget.id);
    getListKy(widget.kyDanhGia);
  }

  @override
  void dispose() {
    super.dispose();
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
      // final http.Response response = await requestHelper.getData('vptq_kpi_DanhGiaKPICaNhan/$id');
      final http.Response response = await requestHelper.getData('vptq_kpi_KPICaNhan/chinh-sua/$id');
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

  Future<void> getListData2(
    String? id,
  ) async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_KPICaNhan/chinh-sua/$id');
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

  Future<void> getListKy(
    String? id,
  ) async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_KyDanhGiaKPI/$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          _listKy = decoded.map((e) => KyDanhGiaModel.fromJson(e as Map<String, dynamic>)).toList();
          if (_listKy.isNotEmpty) _selectedKy = _listKy.first;
        } else if (decoded is Map<String, dynamic>) {
          final one = KyDanhGiaModel.fromJson(decoded);
          _listKy = [one];
          _selectedKy = one;
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

  Widget _buildKyDanhGiaDropdown() {
    if (_loading) {
      return const CircularProgressIndicator();
    }
    if (_listKy.isEmpty) {
      return const Text("Không có kỳ đánh giá");
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E8EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: const [
              Icon(Icons.apartment, color: Color(0xFFFF9800)), // icon cam
              SizedBox(width: 6),
              Text(
                "Kỳ đánh giá:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<KyDanhGiaModel>(
            value: _selectedKy,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _listKy.map((ky) {
              final text = "${ky.thoiDiem} (${ky.tuNgay} - ${ky.denNgay})";
              return DropdownMenuItem(
                value: ky,
                child: Text(text),
              );
            }).toList(),
            onChanged: null, // disable select
          ),
        ],
      ),
    );
  }

  Future<void> openRejectDialog(
    String? id,
  ) async {
    final ghiChuCtl = TextEditingController();
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
        final nhoms = kn.nhomPIs ?? [];
        return {
          'vptq_kpi_KPICaNhanKiemNhiem_Id': kn.vptq_kpi_KPICaNhanKiemNhiem_Id,
          // các field thông tin thêm giữ nguyên nếu bạn cần:
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

          'nhomPIs': nhoms.asMap().entries.map((eN) {
            final np = eN.value;
            final chiTiets = np.chiTiets ?? [];
            return {
              'vptq_kpi_NhomPI_Id': np.vptq_kpi_NhomPI_Id,
              'tenNhomPI': np.tenNhomPI,
              'thuTuNhom': eN.key + 1, // <== Chuẩn React
              'tongTyTrong': np.tongTyTrong,

              'chiTiets': chiTiets.asMap().entries.map((eC) {
                final ct = eC.value;
                final base = {
                  'vptq_kpi_KPICaNhanChiTiet_Id': ct.vptq_kpi_KPICaNhanChiTiet_Id,
                  'vptq_kpi_NhomPI_Id': ct.vptq_kpi_NhomPI_Id_Mobi,
                  'vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id': ct.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id,
                  'vptq_kpi_DanhMucPIChiTietPhienBan_Id': ct.vptq_kpi_DanhMucPIChiTietPhienBan_Id,
                  'vptq_kpi_DanhMucPIChiTiet_Id': ct.vptq_kpi_DanhMucPIChiTiet_Id,
                  'maSoPI': ct.maSoPI,
                  'isNoiDung': ct.isNoiDung,
                  'isKetQuaThucHien': ct.isKetQuaThucHien,
                  'tenDonViTinh': ct.tenDonViTinh,
                  'chiSoDanhGia': ct.chiSoDanhGia,
                  'chiSoDanhGiaChiTiet': ct.chiSoDanhGiaChiTiet,
                  'giaTriChiTieu': ct.giaTriChiTieu,
                  'noiDungChiTieu': ct.noiDungChiTieu,
                  'dienGiai': ct.dienGiai,
                  'giaTriChiTieuDanhGia': ct.giaTriChiTieuDanhGia,
                  'dienGiaiDanhGia': ct.dienGiaiDanhGia,
                  'tyTrong': ct.tyTrong,
                  'chuKy': ct.chuKy,
                  'isKhongThucHien': ct.isKhongThucHien,
                  'nguyenNhan': ct.nguyenNhan,
                  'giaiPhap': ct.giaiPhap,
                  'diemTrongSoTuDanhGia': ct.diemTrongSoTuDanhGia,
                  'diemKetQuaTuDanhGia': ct.diemKetQuaTuDanhGia,
                  'thuTu': eC.key + 1, // <== Chuẩn React
                };

                base['vptq_kpi_KetQuaTuDanhGia_Id'] = (ct.isKhongThucHien == true) ? _ZERO_ID : ct.vptq_kpi_KetQuaTuDanhGia_Id;
                base['isNguyenNhanChuQuan'] = (ct.isNguyenNhanChuQuanFE == 'Nguyên nhân chủ quan') ? true : false;

                base['chiTietCons'] = (ct.chiTietCons ?? []).asMap().entries.map((eChild) {
                  final c = eChild.value;
                  final khongThucHienCon = (c.isKhongThucHien == true) || (ct.isKhongThucHien == true);
                  return {
                    'vptq_kpi_KPICaNhanChiTiet_Id': c.vptq_kpi_KPICaNhanChiTiet_Id,
                    'vptq_kpi_KPICaNhanChiTietCon_Id': c.vptq_kpi_KPICaNhanChiTietCon_Id,
                    'vptq_kpi_DanhMucPIChiTietPhienBanCon_Id': c.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id, // <== BẮT BUỘC
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
                    'vptq_kpi_KetQuaTuDanhGia_Id': khongThucHienCon ? _ZERO_ID : c.vptq_kpi_KetQuaTuDanhGia_Id,
                    'thuTu': eChild.key + 1, // <== Chuẩn React
                  };
                }).toList();

                return base;
              }).toList(),
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  String _putUrl() {
    final info = _data; // hoặc object info tương đương
    final isCVKPI = (info?.isHoanThanh == true) || ((info?.isThucHienChinhSuaCVKPI == true) && ((info?.viTriDuyet ?? -1) == 0));
    return isCVKPI ? 'vptq_kpi_KPICaNhan/chuyen-vien-kpi/${widget.id}' : 'vptq_kpi_KPICaNhan/${widget.id}';
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

      // 4) PUT lưu tự đánh giá
      final saveRes = await requestHelper.putData(_putUrl(), payload);

      if (saveRes.statusCode == 200) {
        if (sendApproval) {
          // 5) nếu là "GỬI DUYỆT" → gọi API duyệt
          final approveRes = await requestHelper.putData(
            'vptq_kpi_KPICaNhan/gui-duyet-cap-tren/${widget.id}',
            null,
          );

          if (approveRes.statusCode == 200) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Thành công',
              text: 'Gửi duyệt giao KPI thành công',
              confirmBtnText: 'Đồng ý',
              onConfirmBtnTap: () {
                Navigator.pop(context); // đóng alert
                Navigator.pop(context); // quay về
                getListData(widget.id);
              },
            );
            _btnControllerDuyet.reset();
          } else {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Thất bại',
              text: approveRes.body.replaceAll('"', ''),
              confirmBtnText: 'Đồng ý',
            );
            _btnControllerDuyet.reset();
          }
        } else {
          // chỉ LƯU
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: 'Giao KPI thành công',
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.pop(context); // đóng alert
              Navigator.pop(context);
              getListData(widget.id); // reload lại màn (giống React gọi getInfo)
            },
          );
          _btnController.reset();
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
          _btnControllerDuyet.reset();
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

  void _openAddPiForm() async {
    final d = _data;
    if (d == null || (d.kiemNhiems?.isEmpty ?? true)) return;

    // danh sách nhóm đang đăng ký + danh mục ban hành
    final nhomDangKy = d.kiemNhiems!.first.nhomPIs ?? <NhomPIModel>[];
    final nhomBanHanh = d.kiemNhiems!.first.kpiCaNhanNhomPIs ?? <NhomPIModel>[];

    final added = await showModalBottomSheet<ChiTietPIModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // builder: (_) => Padding(
      //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      //   child: _PiAddSheet(
      //     listNhomDangKy: nhomDangKy,
      //     listNhomBanHanh: nhomBanHanh,
      //   ),
      // ),
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.95,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1,
            maxChildSize: 1,
            minChildSize: .4,
            builder: (_, scroll) => SingleChildScrollView(
              controller: scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _PiAddSheet(
                listNhomDangKy: nhomDangKy,
                listNhomBanHanh: nhomBanHanh,
              ),
            ),
          ),
        ),
      ),
    );

    if (added == null) return;

    // chèn vào đúng nhóm đã chọn (added.vptq_kpi_NhomPI_Id_Mobi)
    final gid = added.vptq_kpi_NhomPI_Id_Mobi;
    final group = nhomDangKy.firstWhere(
      (g) => (g.vptq_kpi_NhomPI_Id ?? '') == (gid ?? ''),
      orElse: () => NhomPIModel(),
    );

    if ((group.vptq_kpi_NhomPI_Id ?? '').isEmpty) return; // không có nhóm tương ứng

    group.chiTiets ??= [];
    group.chiTiets!.add(added);

    // cập nhật ty trọng cha & nhóm giống React
    _recalcTyTrongForGroup(group);

    setState(() {});
  }

  int _sumChild(List<ChiTietPIModel> xs) => xs.fold<int>(0, (s, e) => s + (e.tyTrong ?? 0));

  void _recalcTyTrongForGroup(NhomPIModel g) {
    for (final ct in (g.chiTiets ?? const [])) {
      if (ct.chiTietCons != null && ct.chiTietCons!.isNotEmpty) {
        ct.tyTrong = _sumChild(ct.chiTietCons!);
      }
    }
    g.tongTyTrong = (g.chiTiets ?? const []).fold<int>(0, (s, e) => s + (e.tyTrong ?? 0));
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
    final kiemNhiem = (data.kiemNhiems ?? []);
    final nhomPIs = kiemNhiem.isNotEmpty ? (kiemNhiem.first.nhomPIs ?? []) : <NhomPIModel>[];
    final nhomBanHanh = kiemNhiem.first.kpiCaNhanNhomPIs ?? [];
    ;
    final isCVKPI = (data?.isHoanThanh == true) || ((data?.isThucHienChinhSuaCVKPI == true) && ((data?.viTriDuyet ?? -1) == 0));

    return Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: RefreshIndicator(
          onRefresh: () async => getListData(widget.id),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thẻ TỔNG ĐIỂM
                _buildKyDanhGiaDropdown(),
                const SizedBox(height: 10),
                _PrimaryButton2(
                  text: 'THÊM MỚI CHỈ TIÊU KPI',

                  onTap: _openAddPiForm, // <-- thay vì _showConfirmationDialogSave
                ),
                const SizedBox(height: 10),
                // Các NHÓM chỉ tiêu
                for (int i = 0; i < nhomPIs.length; i++) ...[
                  _NhomPISection(
                    sttLaMa: _toRoman(i + 1),
                    nhom: nhomPIs[i],
                    listNhomDangKy: nhomPIs, // <-- mới
                    listNhomBanHanh: nhomBanHanh,
                    expanded: _expanded,
                    onToggle: (id) => setState(() {
                      _expanded.contains(id) ? _expanded.remove(id) : _expanded.add(id);
                    }),
                    onMutate: () => setState(() {}),
                    // form states
                    getCtrl: (map, id) => _get(map, id),
                    khongHopLeOf: (id) => _getBool(_khongHopLe, id),
                    setKhongHopLe: (id, v) => setState(() => _khongHopLe[id] = v),
                    txtThucHien: _txtThucHien,
                    txtNhanXet: _txtNhanXet,
                    txtNguyenNhan: _txtNguyenNhan,
                    txtGiaiPhap: _txtGiaiPhap,
                  ),
                  const SizedBox(height: 12),
                ],
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
              if (!isCVKPI)
                Expanded(
                  child: _PrimaryButton(
                    text: 'GỬI DUYỆT',
                    controller: _btnControllerDuyet,
                    onTap: () => _showConfirmationDialog(context),
                    // onTap: () => _saveKPIAndMaybeSend(sendApproval: true),
                  ),
                ),
            ],
          ),
        ));
  }
}

class _PiAddSheet extends StatefulWidget {
  final List<NhomPIModel> listNhomDangKy; // đang đăng ký (để disable PI trùng)
  final List<NhomPIModel> listNhomBanHanh; // danh mục PI ban hành
  const _PiAddSheet({
    required this.listNhomDangKy,
    required this.listNhomBanHanh,
  });
  @override
  State<_PiAddSheet> createState() => _PiAddSheetState();
}

class _PiAddSheetState extends State<_PiAddSheet> {
  final _formKey = GlobalKey<FormState>();
  NhomPIModel? _selectedGroup;
  List<ChiTietPIModel> _piOptions = [];
  Set<String> _disabledPiIds = {};

  ChiTietPIModel? _selectedPi;
  bool _isNoiDung = false;
  bool _hasChild = false;
  String _dv = '';

  final _tyTrongCtl = TextEditingController();
  final _giaTriCtl = TextEditingController();
  final _noiDungCtl = TextEditingController();
  final _dienGiaiCtl = TextEditingController();

  @override
  void dispose() {
    _tyTrongCtl.dispose();
    _giaTriCtl.dispose();
    _noiDungCtl.dispose();
    _dienGiaiCtl.dispose();
    super.dispose();
  }

  void _onGroupChanged(NhomPIModel g) {
    setState(() {
      _selectedGroup = g;

      // options = chiTiets của nhóm ban hành tương ứng
      final bh = widget.listNhomBanHanh.firstWhere(
        (x) => (x.vptq_kpi_NhomPI_Id ?? '') == (g.vptq_kpi_NhomPI_Id ?? ''),
        orElse: () => NhomPIModel(),
      );
      _piOptions = bh.chiTiets ?? [];

      // disable PI đã đăng ký ở nhóm này
      final dk = widget.listNhomDangKy.firstWhere(
        (x) => (x.vptq_kpi_NhomPI_Id ?? '') == (g.vptq_kpi_NhomPI_Id ?? ''),
        orElse: () => NhomPIModel(),
      );
      _disabledPiIds = (dk.chiTiets ?? []).map((e) => e.vptq_kpi_DanhMucPIChiTiet_Id ?? '').where((e) => e.isNotEmpty).toSet();

      // reset PI + fields
      _selectedPi = null;
      _isNoiDung = false;
      _hasChild = false;
      _dv = '';
      _tyTrongCtl.text = '';
      _giaTriCtl.text = '';
      _noiDungCtl.text = '';
      _dienGiaiCtl.text = '';
    });
  }

  void _onPiChanged(ChiTietPIModel p) {
    setState(() {
      _selectedPi = p;
      _isNoiDung = p.isNoiDung == true;
      _hasChild = p.chiTietCons?.isNotEmpty == true;
      _dv = p.tenDonViTinh ?? '';
      // reset nội dung/giá trị theo loại
      _noiDungCtl.text = _isNoiDung ? (p.noiDungChiTieu ?? '') : '';
      _giaTriCtl.text = (!_isNoiDung && !_hasChild && p.giaTriChiTieu != null) ? '${p.giaTriChiTieu}' : '';
    });
  }

  String? _validateTyTrong(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final n = int.tryParse(v);
    if (n == null || n < 1) return 'Tối thiểu 1';
    if (n % 5 != 0) return 'Tỷ trọng phải là bội của 5';
    return null;
  }

  String? _validateGiaTri(String? v) {
    if (_hasChild || _isNoiDung) return null;
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final d = double.tryParse(v);
    if (d == null || d < 0) return 'Phải là số ≥ 0';
    return null;
  }

  String? _validateNoiDung(String? v) {
    if (!_isNoiDung) return null;
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    if (v.length > 2000) return 'Tối đa 2000 ký tự';
    return null;
  }

  void _onSave() {
    if (_selectedGroup == null || _selectedPi == null) return;
    if (!_formKey.currentState!.validate()) return;

    final p = _selectedPi!;
    final ct = ChiTietPIModel();
    ct.tyTrong = int.tryParse(_tyTrongCtl.text.trim());
    ct.dienGiai = _dienGiaiCtl.text.trim().isEmpty ? null : _dienGiaiCtl.text.trim();

    if (_isNoiDung) {
      ct.noiDungChiTieu = _noiDungCtl.text.trim();
      ct.giaTriChiTieu = null;
    } else if (!_hasChild) {
      ct.giaTriChiTieu = double.tryParse(_giaTriCtl.text.trim());
      ct.noiDungChiTieu = null;
    }

    // map các khóa/thuộc tính cố định theo PI đã chọn (y như ModalThemChiTieu)
    ct.vptq_kpi_NhomPI_Id_Mobi = _selectedGroup!.vptq_kpi_NhomPI_Id; // quan trọng để build payload
    ct.vptq_kpi_DanhMucPIChiTiet_Id = p.vptq_kpi_DanhMucPIChiTiet_Id;
    ct.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id = p.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id;
    ct.vptq_kpi_DanhMucPIChiTietPhienBan_Id = p.vptq_kpi_DanhMucPIChiTietPhienBan_Id;
    ct.vptq_kpi_DanhMucPI_Id = p.vptq_kpi_DanhMucPI_Id;
    ct.maSoPI = p.maSoPI;
    ct.isNoiDung = p.isNoiDung;
    ct.isKetQuaThucHien = p.isKetQuaThucHien;
    ct.tenDonViTinh = p.tenDonViTinh;
    ct.chiSoDanhGia = p.chiSoDanhGia;

    Navigator.pop(context, ct);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Expanded(child: Center(child: Text('Thêm mới chỉ tiêu KPI', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 10),

            // Nhóm PI
            _Field(
              label: 'Nhóm PI *',
              child: DropdownButtonFormField<NhomPIModel>(
                decoration: InputDecoration(
                  hintText: 'Chọn nhóm PI',
                  isDense: true, // field gọn hơn
                  filled: true,
                  fillColor: Colors.white, // nền xám nhạt như React
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                isExpanded: true,
                value: _selectedGroup,
                items: widget.listNhomBanHanh
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.tenNhomPI ?? ''),
                        ))
                    .toList(),
                onChanged: (g) => _onGroupChanged(g!),
                validator: (v) => v == null ? 'Bắt buộc' : null,
              ),
            ),

            // Mã PI
            _Field(
              label: 'Mã số PI *',
              child: DropdownButtonFormField<ChiTietPIModel>(
                isExpanded: true,
                value: _selectedPi,

                menuMaxHeight: 40.h, // <-- giới hạn chiều cao menu (px)

                decoration: InputDecoration(
                  hintText: 'Chọn PI',
                  isDense: true, // field gọn hơn
                  filled: true,
                  fillColor: Colors.white, // nền xám nhạt như React
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _piOptions.map((pi) {
                  final id = pi.vptq_kpi_DanhMucPIChiTiet_Id ?? '';
                  final disabled = _disabledPiIds.contains(id);
                  return DropdownMenuItem<ChiTietPIModel>(
                    value: disabled ? null : pi,
                    enabled: !disabled,
                    child: Row(
                      children: [
                        Expanded(child: Text('${pi.maSoPI ?? ''} - ${pi.chiSoDanhGia ?? ''}')),
                        if (disabled) const Icon(Icons.block, size: 14),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (pi) => pi == null ? null : _onPiChanged(pi),
                validator: (v) => v == null ? 'Bắt buộc' : null,
              ),
            ),

            // Chỉ số đánh giá (readonly)
            _ReadOnly(label: 'Chỉ số đánh giá', value: _selectedPi?.chiSoDanhGia ?? 'Nhập chỉ số đánh giá'),
            const SizedBox(height: 8),

            // Tỷ trọng
            _Field(
              label: 'Tỷ trọng *',
              child: TextFormField(
                controller: _tyTrongCtl,
                // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                keyboardType: TextInputType.number,
                validator: _validateTyTrong,
                decoration: InputDecoration(
                  hintText: 'Nhập tỷ trọng (bội số của 5)',
                  isDense: true, // field gọn hơn
                  filled: true,
                  fillColor: Colors.white, // nền xám nhạt như React
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Chỉ tiêu cần đạt
            if (!_hasChild && !_isNoiDung)
              _Field(
                label: 'Chỉ tiêu cần đạt *' + (_dv.isNotEmpty ? ' ($_dv)' : ''),
                child: TextFormField(
                  controller: _giaTriCtl,
                  // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateGiaTri,
                  decoration: InputDecoration(
                    hintText: 'Nhập chỉ tiêu cần đạt (số)',
                    isDense: true, // field gọn hơn
                    filled: true,
                    fillColor: Colors.white, // nền xám nhạt như React
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_isNoiDung)
              _Field(
                label: 'Chỉ tiêu cần đạt *',
                child: TextFormField(
                  controller: _noiDungCtl,
                  // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  maxLines: 3,
                  validator: _validateNoiDung,
                  decoration: InputDecoration(
                    hintText: 'Nhập chỉ tiêu cần đạt',
                    isDense: true, // field gọn hơn
                    filled: true,
                    fillColor: Colors.white, // nền xám nhạt như React
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Diễn giải (optional)
            _Field(
              label: 'Diễn giải',
              child: TextFormField(
                controller: _dienGiaiCtl,
                // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập diễn giải (tối đa 2000 ký tự)',
                  isDense: true, // field gọn hơn
                  filled: true,
                  fillColor: Colors.white, // nền xám nhạt như React
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('LƯU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 6),
          ]),
        ),
      ),
    );
  }
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

class _PrimaryButton2 extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _PrimaryButton2({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C1C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
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

class _NhomPISection extends StatelessWidget {
  final String sttLaMa;
  final NhomPIModel nhom;
  final List<NhomPIModel> listNhomDangKy;
  final List<NhomPIModel> listNhomBanHanh;

  final Set<String> expanded;
  final void Function(String id) onToggle;

  // form handlers
  final TextEditingController Function(Map<String, TextEditingController>, String) getCtrl;
  final bool Function(String id) khongHopLeOf;
  final void Function(String id, bool v) setKhongHopLe;
  final Map<String, TextEditingController> txtThucHien, txtNhanXet, txtNguyenNhan, txtGiaiPhap;
  final VoidCallback onMutate;

  const _NhomPISection({
    required this.sttLaMa,
    required this.nhom,
    required this.onMutate,
    required this.listNhomDangKy,
    required this.listNhomBanHanh,
    required this.expanded,
    required this.onToggle,
    required this.getCtrl,
    required this.khongHopLeOf,
    required this.setKhongHopLe,
    required this.txtThucHien,
    required this.txtNhanXet,
    required this.txtNguyenNhan,
    required this.txtGiaiPhap,
  });

  @override
  Widget build(BuildContext context) {
    final chiTiets = nhom.chiTiets ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
              listNhomDangKy: listNhomDangKy,
              listNhomBanHanh: listNhomBanHanh,
              nhom: nhom,
              isExpanded: expanded.contains(chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id),
              onToggle: () => onToggle(chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              onMutate: onMutate,
              // form states (per-id)
              ctrlThucHien: getCtrl(txtThucHien, chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              ctrlNhanXet: getCtrl(txtNhanXet, chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              ctrlNguyenNhan: getCtrl(txtNguyenNhan, chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              ctrlGiaiPhap: getCtrl(txtGiaiPhap, chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              khongHopLe: khongHopLeOf(chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? ''),
              setKhongHopLe: (v) => setKhongHopLe(chiTiets[i].vptq_kpi_KPICaNhanChiTiet_Id ?? '', v),

              getCtrlById: getCtrl,
              mapThucHien: txtThucHien,
              mapNhanXet: txtNhanXet,
              mapNguyenNhan: txtNguyenNhan,
              mapGiaiPhap: txtGiaiPhap,
              khongHopLeOfId: khongHopLeOf,
              setKhongHopLeId: setKhongHopLe,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

Future<ChiTietPIModel?> _fetchPiDetail(String? id) async {
  RequestHelperKPI requestHelper = RequestHelperKPI();
  final http.Response res = await requestHelper.getData('vptq_kpi_DanhGiaKPICaNhan/$id');
  if (res.statusCode != 200) return null;
  final decoded = jsonDecode(res.body);
  if (decoded is Map<String, dynamic>) return ChiTietPIModel.fromJson(decoded);
  if (decoded is List && decoded.isNotEmpty && decoded.first is Map<String, dynamic>) {
    return ChiTietPIModel.fromJson(decoded.first as Map<String, dynamic>);
  }
  return null;
}

Future<ChiTietPIModel?> _fetchPiConfigByParent(String parentId) async {
  RequestHelperKPI requestHelper = RequestHelperKPI();
  final res = await requestHelper.getData('vptq_kpi_DanhMucPI/thong-tin-pi/$parentId');
  if (res.statusCode != 200) return null;
  final decoded = jsonDecode(res.body);
  if (decoded is Map<String, dynamic>) return ChiTietPIModel.fromJson(decoded);
  if (decoded is List && decoded.isNotEmpty && decoded.first is Map<String, dynamic>) {
    return ChiTietPIModel.fromJson(decoded.first as Map<String, dynamic>);
  }
  return null;
}

void _showPiInfo(BuildContext context, ChiTietPIModel ct, int? tyTrong, {ChiTietPIModel? parentCt}) {
  final parentId = ct.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id ?? parentCt?.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id;
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
      // builder: (_, controller) => _PiInfoSheet(
      //   ct: ct,
      //   tyTrong: tyTrong ?? 0,
      //   scroll: controller,
      // ),
      builder: (_, controller) => FutureBuilder<ChiTietPIModel?>(
        future: parentId == null ? Future.value(null) : _fetchPiConfigByParent(parentId),
        builder: (ctx, snap) {
          final ketQuas = snap.data?.ketQuas; // <-- CHỈ lấy ketQuas
          return _PiInfoSheet(
            ct: ct, // giữ nguyên dữ liệu đang xem
            tyTrong: tyTrong ?? 0,
            scroll: controller,
            ketQuasOverride: ketQuas, // truyền ketQuas từ API cha
          );
        },
      ),
    ),
  );
}
// void _showPiInfo(BuildContext context, ChiTietPIModel ct, int? tyTrong) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (_) => DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.90,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       builder: (_, controller) => FutureBuilder<ChiTietPIModel?>(
//         future: _fetchPiDetail(ct.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id ?? ct.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id), // <-- gọi API ở đây
//         builder: (ctx, snap) {
//           if (snap.connectionState != ConnectionState.done) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snap.hasData || snap.data == null) {
//             return const Center(child: Text('Không tải được dữ liệu PI'));
//           }
//           return _PiInfoSheet(ct: snap.data!, tyTrong: tyTrong ?? 0, scroll: controller);
//         },
//       ),
//     ),
//   );
//}

class _PiInfoSheet extends StatelessWidget {
  final ChiTietPIModel ct;

  final int tyTrong;
  final ScrollController scroll;
  final List<KetQuaModel>? ketQuasOverride;
  const _PiInfoSheet({
    required this.ct,
    required this.tyTrong,
    required this.scroll,
    this.ketQuasOverride,
  });

  String get _duoi => (ct.isKetQuaThucHien == true) ? (ct.tenDonViTinh ?? '') : '%';

  String _fmt(num v) => v.toStringAsFixed(0);

  // map 5..1 -> nhãn
  static const _labels = {5: 'Vượt trội (5)', 4: 'Hoàn thành tốt (4)', 3: 'Hoàn thành (3)', 2: 'Hạn chế (2)', 1: 'Không đạt (1)'};

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
  // KetQuaModel? _byScore(int s) {
  //   return ct.ketQuas?.firstWhere((e) => (e.diem ?? -1) == s, orElse: () => KetQuaModel());
  // }
  KetQuaModel? _byScore(int s) {
    final list = ketQuasOverride ?? ct.ketQuas; // ưu tiên ketQuas từ cha
    if (list == null) return null;
    try {
      return list.firstWhere((e) => (e.diem ?? -1) == s);
    } catch (_) {
      return null;
    }
  }

  // “Chỉ tiêu cần đạt”
  String get _chiTieuCanDat {
    if (ct.isNoiDung == true) return '${ct?.noiDungChiTieu}';
    if (ct.giaTriChiTieu != null) {
      // final so = formatNumber(ct.giaTriChiTieu, fractionDigits: 0);
      final so = ct.giaTriChiTieu;
      final dv = (ct.tenDonViTinh?.isNotEmpty ?? false) ? ' ${ct.tenDonViTinh}' : '';
      return '$so$dv';
    }
    return '';
  }
  // String? get chiTieuCanDat {
  //   final bool isChiTietCon = ct.hasCon == true ? false : (ct.isNoiDung == true ? false : (ct.chiTietCons != null && (ct.chiTietCons!.isNotEmpty)));

  //   final String dienGiai = (ct.dienGiai?.isNotEmpty ?? false) ? '(${ct.dienGiai})' : '';

  //   // isChiTietCon -> chỉ hiển thị diễn giải
  //   if (isChiTietCon == true) {
  //     return ct.dienGiai ?? '';
  //   }

  //   // isNoiDung -> nội dung chỉ tiêu + (diễn giải)
  //   if (ct.isNoiDung == true) {
  //     final String noiDung = ct.noiDungChiTieu ?? '';
  //     return noiDung + (dienGiai.isNotEmpty ? '\n$dienGiai' : '');
  //   }

  //   // Mặc định -> giá trị + đơn vị (kể cả = 0) + (diễn giải)
  //   String left = '';
  //   if (ct.giaTriChiTieu != null) {
  //     // final so = formatNumber(ct.giaTriChiTieu, fractionDigits: 0);
  //     final so = ct.giaTriChiTieu;
  //     final dv = (ct.tenDonViTinh?.isNotEmpty ?? false) ? ' ${ct.tenDonViTinh}' : '';
  //     left = '$so$dv';
  //   }

  //   return left + (dienGiai.isNotEmpty ? '\n$dienGiai' : '');
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: ListView(
        controller: scroll,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Cấu hình PI chi tiết', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
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
}

// Trong widget render 1 PI (record)
Widget _PiActions({
  required Map<String, dynamic> item,
  required String type, // 'new' | 'edit' | 'detail'
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final canEdit = (item['isKhongDuocSuaXoa'] != true) && type != 'detail';
  final canDelete = type != 'detail' && item['isDaGuiDuyet'] != true;

  return Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: canEdit ? onEdit : null,
          icon: const Icon(Icons.edit, size: 18, color: Colors.white),
          label: const Text(
            'Hiệu chỉnh',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2), // xanh dương
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      ElevatedButton.icon(
        onPressed: canDelete ? onDelete : null,
        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
        label: const Text(
          'Xóa',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935), // đỏ
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ],
  );
}

// ===== 3) Form hiệu chỉnh (logic giống React ModalThemChiTieu) =====
class _PiEditSheet extends StatefulWidget {
  final ChiTietPIModel ct;
  final List<ChiTietPIModel> piOptions;
  final List<String> disabledPiIds;
  const _PiEditSheet({
    required this.ct,
    required this.piOptions,
    this.disabledPiIds = const [],
  });
  @override
  State<_PiEditSheet> createState() => _PiEditSheetState();
}

class _PiEditSheetState extends State<_PiEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _chiSoCtl;
  late TextEditingController _tyTrongCtl;
  late TextEditingController _giaTriCtl;
  late TextEditingController _noiDungCtl;
  late TextEditingController _dienGiaiCtl;

  // bool get _isNoiDung => widget.ct.isNoiDung == true;
  // bool get _hasChild => widget.ct.chiTietCons?.isNotEmpty == true;
  // String get _dv => widget.ct.tenDonViTinh ?? '';

  late ChiTietPIModel _selectedPi; // <-- PI đang chọn (đổi được)
  late bool _isNoiDung; // <-- theo _selectedPi
  late bool _hasChild; // <-- theo _selectedPi
  String _dv = '';

  @override
  void initState() {
    super.initState();
    _selectedPi = widget.piOptions.firstWhere(
      (p) => p.vptq_kpi_DanhMucPIChiTiet_Id == widget.ct.vptq_kpi_DanhMucPIChiTiet_Id,
      orElse: () => widget.ct,
    );
    _isNoiDung = _selectedPi.isNoiDung == true;
    _hasChild = _selectedPi.chiTietCons?.isNotEmpty == true;
    _dv = _selectedPi.tenDonViTinh ?? '';

    _chiSoCtl = TextEditingController(text: _selectedPi.chiSoDanhGia ?? '');
    _tyTrongCtl = TextEditingController(text: (widget.ct.tyTrong ?? 0).toString());
    _giaTriCtl = TextEditingController(text: widget.ct.giaTriChiTieu != null ? '${widget.ct.giaTriChiTieu}' : '');
    _noiDungCtl = TextEditingController(text: widget.ct.noiDungChiTieu ?? '');
    _dienGiaiCtl = TextEditingController(text: widget.ct.dienGiai ?? '');
  }

  @override
  void dispose() {
    _chiSoCtl.dispose();
    _tyTrongCtl.dispose();
    _giaTriCtl.dispose();
    _noiDungCtl.dispose();
    _dienGiaiCtl.dispose();
    super.dispose();
  }

  String? _validateTyTrong(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final n = int.tryParse(v);
    if (n == null || n < 1) return 'Tối thiểu 1';
    if (n % 5 != 0) return 'Tỷ trọng phải là bội của 5';
    return null;
  }

  String? _validateGiaTri(String? v) {
    if (_hasChild || _isNoiDung) return null; // không hiện/không bắt buộc
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final d = double.tryParse(v);
    if (d == null || d < 0) return 'Phải là số ≥ 0';
    return null;
  }

  String? _validateNoiDung(String? v) {
    if (!_isNoiDung) return null;
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    if (v.length > 2000) return 'Tối đa 2000 ký tự';
    return null;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = ChiTietPIModel.fromJson(widget.ct.toJson());
    updated.tyTrong = int.tryParse(_tyTrongCtl.text.trim());
    updated.dienGiai = _dienGiaiCtl.text.trim().isEmpty ? null : _dienGiaiCtl.text.trim();

    // map theo loại PI
    if (_isNoiDung) {
      updated.noiDungChiTieu = _noiDungCtl.text.trim();
      updated.giaTriChiTieu = null;
    } else if (!_hasChild) {
      updated.giaTriChiTieu = double.tryParse(_giaTriCtl.text.trim());
      updated.noiDungChiTieu = null;
    }

    // ==== các trường khóa/thuộc tính theo PI chọn (y như React) ====
    updated.vptq_kpi_DanhMucPIChiTiet_Id = _selectedPi.vptq_kpi_DanhMucPIChiTiet_Id;
    updated.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id = _selectedPi.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id;
    updated.vptq_kpi_DanhMucPIChiTietPhienBan_Id = _selectedPi.vptq_kpi_DanhMucPIChiTietPhienBan_Id;
    updated.maSoPI = _selectedPi.maSoPI;
    updated.isNoiDung = _selectedPi.isNoiDung;
    updated.isKetQuaThucHien = _selectedPi.isKetQuaThucHien;
    updated.tenDonViTinh = _selectedPi.tenDonViTinh;
    updated.vptq_kpi_DanhMucPI_Id = _selectedPi.vptq_kpi_DanhMucPI_Id;
    updated.chiSoDanhGia = _selectedPi.chiSoDanhGia;

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Row(children: [
            const Expanded(child: Center(child: Text('Chỉnh sửa chỉ tiêu KPI', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 10),

          // Nhóm PI & Mã PI (readonly)
          _ReadOnly(label: 'Nhóm PI', value: widget.ct.tenNhomPI ?? ''),
          const SizedBox(height: 8),
          _Field(
            label: 'Mã số PI *',
            child: DropdownButtonFormField<ChiTietPIModel>(
              value: _selectedPi,
              isExpanded: true,
              menuMaxHeight: 40.h, // <-- giới hạn chiều cao menu (px)

              decoration: InputDecoration(
                hintText: 'Chọn PI',
                isDense: true, // field gọn hơn
                filled: true,
                fillColor: Colors.white, // nền xám nhạt như React
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: widget.piOptions.map((pi) {
                final id = pi.vptq_kpi_DanhMucPIChiTiet_Id ?? '';
                final disabled = widget.disabledPiIds.contains(id);
                return DropdownMenuItem<ChiTietPIModel>(
                  value: pi,
                  enabled: !disabled,
                  child: Row(
                    children: [
                      Expanded(child: Text('${pi.maSoPI ?? ''} - ${pi.chiSoDanhGia ?? ''}')),
                      if (disabled) const Icon(Icons.block, size: 14),
                    ],
                  ),
                );
              }).toList(),

              onChanged: (pi) {
                if (pi == null) return;
                setState(() {
                  _selectedPi = pi;
                  _chiSoCtl.text = pi.chiSoDanhGia ?? '';
                  _isNoiDung = pi.isNoiDung == true;
                  _hasChild = pi.chiTietCons?.isNotEmpty == true;
                  _dv = pi.tenDonViTinh ?? '';

                  // reset vùng nhập theo loại
                  _noiDungCtl.text = _isNoiDung ? (pi.noiDungChiTieu ?? '') : '';
                  _giaTriCtl.text = (!_isNoiDung && !_hasChild && pi.giaTriChiTieu != null) ? '${pi.giaTriChiTieu}' : '';
                });
              },
              validator: (v) => v == null ? 'Bắt buộc' : null,
            ),
          ),
          const SizedBox(height: 8),

// Chỉ số đánh giá (readonly vì auto theo Mã PI)
          // _ReadOnly(label: 'Chỉ số đánh giá', value: _chiSoCtl.text),
          _ReadOnly(label: 'Chỉ số đánh giá', value: _selectedPi.chiSoDanhGia ?? ''),

          const SizedBox(height: 8),

          // Tỷ trọng
          _Field(
            label: 'Tỷ trọng *',
            child: TextFormField(
              controller: _tyTrongCtl,
              // onTapOutside: (_) => FocusScope.of(context).unfocus(),
              keyboardType: TextInputType.number,
              validator: _validateTyTrong,
              decoration: InputDecoration(
                hintText: 'Nhập tỷ trọng',
                isDense: true, // field gọn hơn
                filled: true,
                fillColor: Colors.white, // nền xám nhạt như React
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Chỉ tiêu cần đạt
          if (!_hasChild && !_isNoiDung) ...[
            _Field(
              label: 'Chỉ tiêu cần đạt *' + (_dv.isNotEmpty ? ' ($_dv)' : ''),
              child: TextFormField(
                controller: _giaTriCtl,
                // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateGiaTri,
                decoration: InputDecoration(
                  hintText: 'Nhập chỉ tiêu cần đạt (số)',
                  isDense: true, // field gọn hơn
                  filled: true,
                  fillColor: Colors.white, // nền xám nhạt như React
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          if (_isNoiDung) ...[
            _Field(
              label: 'Chỉ tiêu cần đạt *',
              child: TextFormField(
                controller: _noiDungCtl,
                // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                maxLines: 3,
                validator: _validateNoiDung,
                decoration: InputDecoration(
                  hintText: 'Nhập chỉ tiêu cần đạt',
                  isDense: true, // field gọn hơn
                  filled: true,
                  fillColor: Colors.white, // nền xám nhạt như React
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          // Diễn giải (optional)
          _Field(
            label: 'Diễn giải',
            child: TextFormField(
              controller: _dienGiaiCtl,
              // onTapOutside: (_) => FocusScope.of(context).unfocus(),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập diễn giải (tối đa 2000 ký tự)',
                isDense: true, // field gọn hơn
                filled: true,
                fillColor: Colors.white, // nền xám nhạt như React
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('LƯU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 6),
        ]),
      ),
    );
  }
}

class _ReadOnly extends StatelessWidget {
  final String label, value;
  const _ReadOnly({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return _Field(
      label: label,
      child: TextFormField(
        key: ValueKey(value),
        initialValue: value,
        enabled: false,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF4F4F4), // nền xám nhạt như React
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        style: const TextStyle(
          fontWeight: FontWeight.w700, // <-- chữ đậm
          color: Colors.black, // <-- màu đen rõ
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 10),
      ],
    );
  }
}

class _PiItem extends StatefulWidget {
  final int index;
  final ChiTietPIModel ct;
  final NhomPIModel nhom;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<NhomPIModel> listNhomDangKy; // phiếu hiện có
  final List<NhomPIModel> listNhomBanHanh; // danh mục chuẩn

  // form controllers
  final TextEditingController ctrlThucHien;
  final TextEditingController ctrlNhanXet;
  final TextEditingController ctrlNguyenNhan;
  final TextEditingController ctrlGiaiPhap;
  final bool khongHopLe;
  final ValueChanged<bool> setKhongHopLe;

  final TextEditingController Function(Map<String, TextEditingController>, String) getCtrlById;
  final Map<String, TextEditingController> mapThucHien, mapNhanXet, mapNguyenNhan, mapGiaiPhap;
  final bool Function(String id) khongHopLeOfId;
  final void Function(String id, bool v) setKhongHopLeId;
  final VoidCallback onMutate;

  const _PiItem({
    required this.index,
    required this.ct,
    required this.listNhomDangKy,
    required this.listNhomBanHanh,
    required this.nhom,
    required this.onMutate,
    required this.isExpanded,
    required this.onToggle,
    required this.ctrlThucHien,
    required this.ctrlNhanXet,
    required this.ctrlNguyenNhan,
    required this.ctrlGiaiPhap,
    required this.khongHopLe,
    required this.setKhongHopLe,
    required this.getCtrlById,
    required this.mapThucHien,
    required this.mapNhanXet,
    required this.mapNguyenNhan,
    required this.mapGiaiPhap,
    required this.khongHopLeOfId,
    required this.setKhongHopLeId,
  });
  @override
  State<_PiItem> createState() => _PiItemState();
}

class _PiItemState extends State<_PiItem> {
  void _openEditPiForm(BuildContext context, ChiTietPIModel ct, NhomPIModel nhom) async {
    final nhomBH = widget.listNhomBanHanh.firstWhere(
      (x) => x.vptq_kpi_NhomPI_Id == nhom.vptq_kpi_NhomPI_Id,
      orElse: () => NhomPIModel(),
    );
    final piOptions = nhomBH.chiTiets ?? [];

    // Những PI đã đăng ký trong nhóm hiện tại để disable
    final nhomDK = widget.listNhomDangKy.firstWhere(
      (x) => x.vptq_kpi_NhomPI_Id == nhom.vptq_kpi_NhomPI_Id,
      orElse: () => NhomPIModel(),
    );
    final disabledIds = (nhomDK.chiTiets ?? []).where((x) => x.vptq_kpi_DanhMucPIChiTiet_Id != ct.vptq_kpi_DanhMucPIChiTiet_Id).map((x) => x.vptq_kpi_DanhMucPIChiTiet_Id ?? '').toList();
    final updated = await showModalBottomSheet<ChiTietPIModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // builder: (_) => Padding(
      //   padding: EdgeInsets.only(
      //     bottom: MediaQuery.of(context).viewInsets.bottom,
      //   ),
      //   child: _PiEditSheet(
      //     ct: ct,
      //     piOptions: piOptions,
      //     disabledPiIds: disabledIds,
      //   ),
      // ),
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.95,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1,
            maxChildSize: 1,
            minChildSize: .4,
            builder: (_, scroll) => SingleChildScrollView(
              controller: scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _PiEditSheet(
                ct: ct,
                piOptions: piOptions,
                disabledPiIds: disabledIds,
              ),
            ),
          ),
        ),
      ),
    );

    // if (updated != null) {
    //   // === CHỈ LƯU CỤC BỘ: patch lại ct và vẽ lại ===
    //   setState(() {
    //     ct.tyTrong = updated.tyTrong;
    //     ct.dienGiai = updated.dienGiai;

    //     if (ct.isNoiDung == true) {
    //       ct.noiDungChiTieu = updated.noiDungChiTieu;
    //     } else if (!(ct.chiTietCons?.isNotEmpty ?? false)) {
    //       // không phải PI cha có con -> cho nhập số
    //       ct.giaTriChiTieu = updated.giaTriChiTieu;
    //     }
    //   });
    // }
    if (updated != null) {
      setState(() {
        ct.tyTrong = updated.tyTrong;
        ct.dienGiai = updated.dienGiai;
        ct.noiDungChiTieu = updated.noiDungChiTieu;
        ct.giaTriChiTieu = updated.giaTriChiTieu;
        ct.chiSoDanhGia = updated.chiSoDanhGia;
        ct.tenDonViTinh = updated.tenDonViTinh;
        ct.isNoiDung = updated.isNoiDung;
        // đồng bộ các id quan trọng khi đổi mã PI
        ct.vptq_kpi_DanhMucPIChiTiet_Id = updated.vptq_kpi_DanhMucPIChiTiet_Id;
        ct.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id = updated.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id;
        ct.vptq_kpi_DanhMucPIChiTietPhienBan_Id = updated.vptq_kpi_DanhMucPIChiTietPhienBan_Id;
        ct.maSoPI = updated.maSoPI;
      });
    }
  }

  List<ChiTietPIModel> _childOptionsForParent() {
    final nhomBH = widget.listNhomBanHanh.firstWhere(
      (x) => x.vptq_kpi_NhomPI_Id == widget.nhom.vptq_kpi_NhomPI_Id,
      orElse: () => NhomPIModel(),
    );
    final parentInDanhMuc = (nhomBH.chiTiets ?? []).firstWhere(
      (x) => x.vptq_kpi_DanhMucPIChiTiet_Id == widget.ct.vptq_kpi_DanhMucPIChiTiet_Id,
      orElse: () => ChiTietPIModel(),
    );
    return (parentInDanhMuc.chiTietCons ?? []).where((c) => (c.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id ?? '').isNotEmpty).toList();
  }

  bool _canAddChild() {
    return _childOptionsForParent().isNotEmpty; // chỉ cho thêm khi danh mục có PI con
  }

  Future<void> _openAddChildPiForm() async {
    final options = _childOptionsForParent();

    final disabledIds = (widget.ct.chiTietCons ?? []).map((c) => c.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id ?? '').where((s) => s.isNotEmpty).toList();

    final added = await showModalBottomSheet<ChiTietPIModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // builder: (_) => Padding(
      //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      //   child: _PiChildEditSheet(
      //     // truyền 1 record rỗng để sheet xử lý như "new"
      //     child: ChiTietPIModel(),
      //     options: options,
      //     disabledIds: disabledIds,
      //     isNew: true,
      //   ),
      // ),
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.95,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1,
            maxChildSize: 1,
            minChildSize: .4,
            builder: (_, scroll) => SingleChildScrollView(
              controller: scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _PiChildEditSheet(
                // truyền 1 record rỗng để sheet xử lý như "new"
                child: ChiTietPIModel(),
                options: options,
                disabledIds: disabledIds,
                isNew: true,
              ),
            ),
          ),
        ),
      ),
    );

    if (added != null) {
      setState(() {
        widget.ct.chiTietCons ??= [];
        widget.ct.chiTietCons!.add(added);

        // cập nhật tỷ trọng CHA = tổng tỷ trọng con
        widget.ct.tyTrong = widget.ct.chiTietCons!.fold<int>(0, (s, e) => s + (e.tyTrong ?? 0));

        // cập nhật tổng tỷ trọng NHÓM
        widget.nhom.tongTyTrong = (widget.nhom.chiTiets ?? []).fold<int>(0, (s, e) => s + (e.tyTrong ?? 0));
      });
    }
  }

  void _confirmDeleteParent() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: '',
      text: 'Bạn có chắc muốn xoá chỉ tiêu này?',
      confirmBtnText: 'Đồng ý',
      cancelBtnText: 'Không',
      onCancelBtnTap: () => Navigator.of(context).pop(),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();

        // 1) Xoá PI cha khỏi nhóm
        widget.nhom.chiTiets?.removeWhere((ct) => (ct.vptq_kpi_KPICaNhanChiTiet_Id ?? '') == (widget.ct.vptq_kpi_KPICaNhanChiTiet_Id ?? ''));

        // 2) Cập nhật tổng tỷ trọng NHÓM = sum(tyTrong các PI còn lại)
        final sumGroup = (widget.nhom.chiTiets ?? []).fold<int>(0, (s, e) => s + (e.tyTrong ?? 0));
        widget.nhom.tongTyTrong = sumGroup;

        // 3) Báo cha rebuild UI
        widget.onMutate();

        // 4) Thông báo
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Đã xoá',
          text: 'Xoá chỉ tiêu thành công',
          confirmBtnText: 'Đồng ý',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tyTrong = widget.ct.tyTrong ?? 0;
    final bool isNoiDung = widget.ct.isNoiDung == true;
    final bool isChiTietCon = widget.ct.hasCon == true ? false : (widget.ct.isNoiDung == true ? false : (widget.ct.chiTietCons != null && (widget.ct.chiTietCons!.isNotEmpty)));
    ;

// ================== CHỈ TIÊU CẦN ĐẠT ==================
    String noiDungCanDat;
    if (isChiTietCon) {
      noiDungCanDat = widget.ct.dienGiai ?? '';
    } else if (isNoiDung) {
      final base = widget.ct.noiDungChiTieu ?? '';
      final extra = (widget.ct.dienGiai?.isNotEmpty ?? false) ? '\n(${widget.ct.dienGiai})' : '';
      noiDungCanDat = '$base$extra';
    } else {
      final so = (widget.ct.giaTriChiTieu != null || widget.ct.giaTriChiTieu == 0) ? '${formatNumber(widget.ct.giaTriChiTieu, fractionDigits: 1)}${widget.ct.tenDonViTinh?.isNotEmpty == true ? ' ${widget.ct.tenDonViTinh}' : ''}' : '';
      final extra = (widget.ct.dienGiai?.isNotEmpty ?? false) ? '\n(${widget.ct.dienGiai})' : '';
      noiDungCanDat = '$so$extra';
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onToggle, // toggle ở mọi khoảng trống trong card
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F9),
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
                padding: const EdgeInsets.fromLTRB(12, 10, 6, 8),
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
                                onTap: () => _showPiInfo(context, widget.ct, tyTrong),
                                child: Text(
                                  widget.ct.maSoPI ?? '',
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
                                TextSpan(text: widget.ct.chiSoDanhGia ?? ''),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                              children: [
                                const TextSpan(text: 'Chỉ tiêu cần đạt: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: noiDungCanDat ?? ''),
                              ],
                            ),
                          ),
                          _PiActions(
                            item: widget.ct.toJson(),
                            type: "edit", // cùng giá trị như React
                            onEdit: () => _openEditPiForm(context, widget.ct, widget.nhom),
                            onDelete: _confirmDeleteParent,
                          ),
                          if (_canAddChild()) ...[
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 38,
                              child: ElevatedButton.icon(
                                onPressed: _openAddChildPiForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                                label: const Text('THÊM PI CON', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    if ((widget.ct.chiTietCons?.isNotEmpty ?? false)) Icon(widget.isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.red),
                  ],
                ),
              ),

              // --- body (mở rộng) ---

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isExpanded)
                      if ((widget.ct.chiTietCons?.isNotEmpty ?? false)) ...[
                        // _label('Chi tiết con:'),
                        // const SizedBox(height: 5),
                        for (int j = 0; j < widget.ct.chiTietCons!.length; j++)
                          _ChildPiCard(
                            index: '${widget.index}.${j + 1}',
                            childCt: widget.ct.chiTietCons![j],
                            parentCt: widget.ct,
                            // controllers/flags theo ID
                            getCtrlById: widget.getCtrlById,
                            mapThucHien: widget.mapThucHien,
                            mapNhanXet: widget.mapNhanXet,
                            mapNguyenNhan: widget.mapNguyenNhan,
                            mapGiaiPhap: widget.mapGiaiPhap,
                            khongHopLeOfId: widget.khongHopLeOfId,
                            setKhongHopLeId: widget.setKhongHopLeId,
                            // NEW: truyền danh mục & callback để parent rebuild
                            listNhomDangKy: widget.listNhomDangKy,
                            listNhomBanHanh: widget.listNhomBanHanh,
                            onMutate: () => setState(() {}), // bắt buộc để parent vẽ lại khi sửa/xoá con

                            // tick “không hợp lệ” ở CON → cập nhật CHA
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

  Widget _uploadButton() => SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: () {/* TODO: upload */},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('TẢI LÊN FILE ĐÍNH KÈM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      );
}

class _PiChildEditSheet extends StatefulWidget {
  final ChiTietPIModel child;
  final List<ChiTietPIModel> options; // danh mục PI con của PI cha
  final List<String> disabledIds; // đã đăng ký rồi (trừ chính nó)
  final bool isNew;

  const _PiChildEditSheet({
    required this.child,
    required this.options,
    this.disabledIds = const [],
    this.isNew = false,
  });

  @override
  State<_PiChildEditSheet> createState() => _PiChildEditSheetState();
}

class _PiChildEditSheetState extends State<_PiChildEditSheet> {
  final _formKey = GlobalKey<FormState>();

  late ChiTietPIModel _selected; // option đang chọn
  late bool _isNoiDung;
  String _dv = '';

  late TextEditingController _tyTrongCtl;
  late TextEditingController _giaTriCtl;
  late TextEditingController _noiDungCtl;
  late TextEditingController _dienGiaiCtl;

  @override
  void initState() {
    super.initState();
    if (widget.isNew) {
      // không prefill
      _selected = ChiTietPIModel(); // chưa chọn gì
      _isNoiDung = false;
      _dv = '';
      _tyTrongCtl = TextEditingController();
      _giaTriCtl = TextEditingController();
      _noiDungCtl = TextEditingController();
      _dienGiaiCtl = TextEditingController();
    } else {
      _selected = widget.options.firstWhere(
        (o) => (o.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id ?? '') == (widget.child.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id ?? ''),
        orElse: () => (widget.options.isNotEmpty ? widget.options.first : ChiTietPIModel()),
      );

      _isNoiDung = _selected.isNoiDung == true;
      _dv = _selected.tenDonViTinh ?? '';

      _tyTrongCtl = TextEditingController(text: (widget.child.tyTrong ?? 0).toString());
      _giaTriCtl = TextEditingController(text: widget.child.giaTriChiTieu != null ? '${widget.child.giaTriChiTieu}' : '');
      _noiDungCtl = TextEditingController(text: widget.child.noiDungChiTieu ?? '');
      _dienGiaiCtl = TextEditingController(text: widget.child.dienGiai ?? '');
    }
  }

  @override
  void dispose() {
    _tyTrongCtl.dispose();
    _giaTriCtl.dispose();
    _noiDungCtl.dispose();
    _dienGiaiCtl.dispose();
    super.dispose();
  }

  bool get _hasSelected => (_selected.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id ?? '').isNotEmpty;

  String? _validateTyTrong(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final n = int.tryParse(v);
    if (n == null || n < 1) return 'Tối thiểu 1';
    if (n % 5 != 0) return 'Tỷ trọng phải là bội của 5';
    return null;
  }

  // String? _validateGiaTri(String? v) {
  //   if (_isNoiDung) return null;
  //   if (v == null || v.trim().isEmpty) return 'Bắt buộc';
  //   final d = double.tryParse(v);
  //   if (d == null || d < 0) return 'Phải là số ≥ 0';
  //   return null;
  // }

  // String? _validateNoiDung(String? v) {
  //   if (!_isNoiDung) return null;
  //   if (v == null || v.trim().isEmpty) return 'Bắt buộc';
  //   if (v.length > 2000) return 'Tối đa 2000 ký tự';
  //   return null;
  // }
  String? _validateGiaTri(String? v) {
    if (!_hasSelected || _isNoiDung) return null;
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final d = double.tryParse(v);
    if (d == null || d < 0) return 'Phải là số ≥ 0';
    return null;
  }

  String? _validateNoiDung(String? v) {
    if (!_hasSelected || !_isNoiDung) return null;
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    if (v.length > 2000) return 'Tối đa 2000 ký tự';
    return null;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = ChiTietPIModel.fromJson(widget.child.toJson());
    updated.tyTrong = int.tryParse(_tyTrongCtl.text.trim());
    updated.dienGiai = _dienGiaiCtl.text.trim().isEmpty ? null : _dienGiaiCtl.text.trim();

    // map theo loại
    if (_isNoiDung) {
      updated.noiDungChiTieu = _noiDungCtl.text.trim();
      updated.giaTriChiTieu = null;
    } else {
      updated.giaTriChiTieu = double.tryParse(_giaTriCtl.text.trim());
      updated.noiDungChiTieu = null;
    }

    // đồng bộ thông tin theo PI con chọn (giống React)
    updated.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id = _selected.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id;
    updated.maSoPI = _selected.maSoPI;
    updated.chiSoDanhGia = _selected.chiSoDanhGia;
    updated.tenDonViTinh = _selected.tenDonViTinh;
    updated.isNoiDung = _selected.isNoiDung;

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Center(child: Text(widget.isNew ? 'Thêm mới chỉ tiêu KPI con' : 'Chỉnh sửa chỉ tiêu KPI con', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 10),

          // Mã PI con
          _Field(
            label: 'Mã số PI con *',
            child: DropdownButtonFormField<ChiTietPIModel>(
              value: _selected.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id == null ? null : _selected,
              isExpanded: true,
              menuMaxHeight: 320,
              decoration: InputDecoration(
                hintText: widget.isNew ? 'Chọn mã số PI' : '',
                isDense: true, // field gọn hơn
                filled: true,
                fillColor: Colors.white, // nền xám nhạt như React
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: widget.options.map((op) {
                final id = op.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id ?? '';
                final disabled = widget.disabledIds.contains(id);
                return DropdownMenuItem<ChiTietPIModel>(
                  value: op,
                  enabled: !disabled,
                  child: Row(
                    children: [
                      Expanded(child: Text('${op.maSoPI ?? ''} - ${op.chiSoDanhGia ?? ''}')),
                      if (disabled) const Icon(Icons.block, size: 14),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (op) {
                if (op == null) return;
                setState(() {
                  _selected = op;
                  _isNoiDung = op.isNoiDung == true;
                  _dv = op.tenDonViTinh ?? '';
                  // reset field theo loại
                  _noiDungCtl.text = _isNoiDung ? (op.noiDungChiTieu ?? '') : '';
                  _giaTriCtl.text = !_isNoiDung && op.giaTriChiTieu != null ? '${op.giaTriChiTieu}' : '';
                });
              },
              validator: (v) => v == null ? 'Bắt buộc' : null,
            ),
          ),

          // Chỉ số đánh giá (readonly)
          _ReadOnly(label: 'Chỉ số đánh giá', value: _selected.chiSoDanhGia ?? ' Nhập chỉ số đánh giá'),
          const SizedBox(height: 8),

          // Tỷ trọng
          _Field(
            label: 'Tỷ trọng *',
            child: TextFormField(
              controller: _tyTrongCtl,
              // onTapOutside: (_) => FocusScope.of(context).unfocus(),
              keyboardType: TextInputType.number,
              validator: _validateTyTrong,
              decoration: InputDecoration(
                hintText: 'Nhập tỷ trọng',
                isDense: true, // field gọn hơn
                filled: true,
                fillColor: Colors.white, // nền xám nhạt như React
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Chỉ tiêu cần đạt
          if (_hasSelected) ...[
            _isNoiDung
                ? _Field(
                    label: 'Chỉ tiêu cần đạt *',
                    child: TextFormField(
                      controller: _noiDungCtl,
                      // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      maxLines: 3,
                      validator: _validateNoiDung,
                      decoration: InputDecoration(
                        hintText: 'Nhập chỉ tiêu cần đạt',
                        isDense: true, // field gọn hơn
                        filled: true,
                        fillColor: Colors.white, // nền xám nhạt như React
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                : _Field(
                    label: 'Chỉ tiêu cần đạt *' + (_dv.isNotEmpty ? ' ($_dv)' : ''),
                    child: TextFormField(
                      controller: _giaTriCtl,
                      // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validateGiaTri,
                      decoration: InputDecoration(
                        hintText: 'Nhập chỉ tiêu cần đạt (số)',
                        isDense: true, // field gọn hơn
                        filled: true,
                        fillColor: Colors.white, // nền xám nhạt như React
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
          ],
          // Diễn giải
          _Field(
            label: 'Diễn giải',
            child: TextFormField(
              controller: _dienGiaiCtl,
              // onTapOutside: (_) => FocusScope.of(context).unfocus(),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập diễn giải (tối đa 2000 ký tự)',
                isDense: true, // field gọn hơn
                filled: true,
                fillColor: Colors.white, // nền xám nhạt như React
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('LƯU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 6),
        ]),
      ),
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
  final List<NhomPIModel> listNhomDangKy;
  final List<NhomPIModel> listNhomBanHanh;
  final VoidCallback onMutate;

  const _ChildPiCard({
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
    required this.listNhomDangKy,
    required this.listNhomBanHanh,
    required this.onMutate,
  });

  @override
  State<_ChildPiCard> createState() => _ChildPiCardState();
}

class _ChildPiCardState extends State<_ChildPiCard> {
  bool _open = false;
  void _confirmDeleteChild() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: '',
      text: 'Bạn có chắc muốn xoá chỉ tiêu con này?',
      confirmBtnText: 'Đồng ý',
      cancelBtnText: 'Không',
      onCancelBtnTap: () => Navigator.of(context).pop(),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        setState(() {
          widget.parentCt.chiTietCons?.removeWhere((c) => (c.vptq_kpi_KPICaNhanChiTietCon_Id ?? '') == (widget.childCt.vptq_kpi_KPICaNhanChiTietCon_Id ?? ''));

          // 2) Cập nhật tỷ trọng CHA = sum(tyTrong con)
          final newTyTrongCha = (widget.parentCt.chiTietCons ?? []).fold<int>(0, (s, e) => s + (e.tyTrong ?? 0));
          widget.parentCt.tyTrong = newTyTrongCha;

          // 3) Cập nhật tổng tỷ trọng NHÓM = sum(tyTrong các PI cha)
          final group = widget.listNhomDangKy.firstWhere(
            (g) => (g.vptq_kpi_NhomPI_Id ?? '') == (widget.parentCt.vptq_kpi_NhomPI_Id ?? ''),
            orElse: () => NhomPIModel(),
          );
          if ((group.vptq_kpi_NhomPI_Id ?? '').isNotEmpty) {
            group.tongTyTrong = (group.chiTiets ?? []).fold<int>(0, (s, e) => s + (e.tyTrong ?? 0));
          }
        });
        widget.onMutate(); // báo parent vẽ lại list
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Đã xoá',
          text: 'Xoá chỉ tiêu con thành công',
          confirmBtnText: 'Đồng ý',
        );
      },
    );
  }

  void _openEditChildPiForm(BuildContext context) async {
    // 1) Lấy danh mục PI con được ban hành theo đúng NHÓM + PI CHA
    final nhomBH = widget.listNhomBanHanh.firstWhere(
      (x) => x.vptq_kpi_NhomPI_Id == widget.parentCt.vptq_kpi_NhomPI_Id,
      orElse: () => NhomPIModel(),
    );
    final parentInDanhMuc = (nhomBH.chiTiets ?? []).firstWhere(
      (x) => x.vptq_kpi_DanhMucPIChiTiet_Id == widget.parentCt.vptq_kpi_DanhMucPIChiTiet_Id,
      orElse: () => ChiTietPIModel(),
    );

    // 2) Options cho dropdown PI con
    final options = (parentInDanhMuc.chiTietCons ?? []).where((c) => (c.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id ?? '').isNotEmpty).toList();

    // 3) Disable những mã con đã đăng ký (trừ chính nó)
    final disabledIds = (widget.parentCt.chiTietCons ?? []).where((c) => c.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id != widget.childCt.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id).map((c) => c.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id ?? '').toList();

    final updated = await showModalBottomSheet<ChiTietPIModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      // builder: (_) => Padding(
      //   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      //   child: _PiChildEditSheet(
      //     child: widget.childCt,
      //     options: options,
      //     disabledIds: disabledIds,
      //     isNew: false,
      //   ),
      // ),
      builder: (ctx) => AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.95,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1,
            maxChildSize: 1,
            minChildSize: .4,
            builder: (_, scroll) => SingleChildScrollView(
              controller: scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _PiChildEditSheet(
                child: widget.childCt,
                options: options,
                disabledIds: disabledIds,
                isNew: false,
              ),
            ),
          ),
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        // cập nhật lại bản ghi con tại chỗ
        widget.childCt.tyTrong = updated.tyTrong;
        widget.childCt.dienGiai = updated.dienGiai;
        widget.childCt.noiDungChiTieu = updated.noiDungChiTieu;
        widget.childCt.giaTriChiTieu = updated.giaTriChiTieu;
        widget.childCt.maSoPI = updated.maSoPI;
        widget.childCt.chiSoDanhGia = updated.chiSoDanhGia;
        widget.childCt.tenDonViTinh = updated.tenDonViTinh;
        widget.childCt.isNoiDung = updated.isNoiDung;

        // id định danh PI con theo phiên bản danh mục
        widget.childCt.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id = updated.vptq_kpi_DanhMucPIChiTietPhienBanCon_Id;
      });
      widget.onMutate(); // để parent re-build card list
    }
  }

  @override
  Widget build(BuildContext context) {
    final ct = widget.childCt;
    final id = ct.vptq_kpi_KPICaNhanChiTietCon_Id ?? ct.vptq_kpi_KPICaNhanChiTiet_Id ?? '';

    final tyTrong = ct.tyTrong ?? 0;

    final khongHopLe = widget.khongHopLeOfId(id);

    // nội dung “Chỉ tiêu cần đạt”
    final so = (ct.giaTriChiTieu != null || ct.giaTriChiTieu == 0) ? '${formatNumber(ct.giaTriChiTieu, fractionDigits: 1)}${ct.tenDonViTinh?.isNotEmpty == true ? ' ${ct.tenDonViTinh}' : ''}' : '';
    final extra = (ct.dienGiai?.isNotEmpty ?? false) ? '\n(${ct.dienGiai})' : '';
    final noiDungCanDat = '$so$extra';

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
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 8),
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
                            InkWell(
                              onTap: () => _showPiInfo(context, ct, tyTrong, parentCt: widget.parentCt),
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
                        const SizedBox(
                          height: 5,
                        ),
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                            children: [
                              const TextSpan(text: 'Chỉ tiêu cần đạt: ', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: noiDungCanDat ?? ''),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        _PiActions(
                          item: widget.childCt.toJson(),
                          type: "edit",
                          onEdit: () => _openEditChildPiForm(context),
                          onDelete: _confirmDeleteChild,
                        ),
                      ],
                    ),
                  ),
                  // Icon(_open ? Icons.expand_less : Icons.expand_more, color: Colors.green),
                ],
              ),
            ),
          ),

          // if (_open) const Divider(height: 1),

          // // --- BODY con ---
          // if (_open)
          //   Padding(
          //     padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [

          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }
}
