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
import '../../../../widgets/loading.dart';

class BodyGiaoChiTieuKPI_DonViScreen2 extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  final bool isChiTiet;
  const BodyGiaoChiTieuKPI_DonViScreen2({super.key, required this.id, required this.lstFiles, required this.isChiTiet});

  @override
  _BodyGiaoChiTieuKPI_DonViScreen2State createState() => _BodyGiaoChiTieuKPI_DonViScreen2State();
}

class _BodyGiaoChiTieuKPI_DonViScreen2State extends State<BodyGiaoChiTieuKPI_DonViScreen2> with TickerProviderStateMixin, ChangeNotifier {
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
  ChiTietPIModel? _datacon;
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
      final http.Response response = await requestHelper.getData('vptq_kpi_DanhGiaKPIDonVi/$id');
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

  Future<void> getListDataCon(
    String? id,
  ) async {
    try {
      final http.Response response = await requestHelper.getData('vptq_kpi_DanhMucPI/thong-tin-pi/$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _datacon = ChiTietPIModel.fromJson(decoded);
        } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
          _datacon = ChiTietPIModel.fromJson(
            decoded.first as Map<String, dynamic>,
          );
        } else {
          _datacon = null;
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

  Future<void> saveTuChoi(
    String? id,
    String? ghiChu,
  ) async {
    try {
      setState(() => _isLoading = true);
      final payload = {
        "id": id,
        "ghiChu": ghiChu,
      };
      print("payload:$payload");
      final res = await requestHelper.putData(
        'vptq_kpi_KPIDonVi/tra-cap-duoi/$id',
        payload, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Từ chối duyệt KPI đơn vị thành công',
          confirmBtnText: 'Đồng ý',
          onConfirmBtnTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
        _btnController.reset();
        await getListData(widget.id);
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

  Future<void> saveDuyet(
    String? id,
  ) async {
    try {
      setState(() => _isLoading = true);

      final res = await requestHelper.putData(
        'vptq_kpi_KPIDonVi/gui-duyet-cap-tren/$id',
        null, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Duyệt đăng ký KPI thành công!',
          confirmBtnText: 'Đồng ý',
          onConfirmBtnTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
        _btnControllerDuyet.reset();
        await getListData(widget.id);
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
                        _showConfirmationDialogSaveTuChoi(
                          ctx,
                          id,
                          note,
                        );
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

  void _showConfirmationDialogSaveDuyet(BuildContext context) {
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
          saveDuyet(widget.id);
        });
  }

  void _showConfirmationDialogInfo(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      text: 'Cấp đầu tiên không được từ chối!',
      title: '',
      confirmBtnText: 'Xác nhận',
      onConfirmBtnTap: () {
        Navigator.pop(context);
        _btnController.reset();
      },
    );
  }

  void _showConfirmationDialogSaveTuChoi(
    BuildContext context,
    String? id,
    String? ghiChu,
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
          _btnController.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          saveTuChoi(id, ghiChu);
        });
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
    // final kiemNhiem = (data.kiemNhiems ?? []);
    final nhomPIs = data.nhomPIs ?? [];
    print("nhomPIs: ${nhomPIs.length}");

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async => getListData(widget.id),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thẻ TỔNG ĐIỂM
              _InfoCard(children: [
                _InfoRow(label: 'Đơn vị', value: data?.tenDonViKPI ?? ''),
                _InfoRow(label: 'Chu kỳ đánh giá', value: data?.chuKy == 1 ? "Tháng" : "Năm"),
                _InfoRow(label: 'Kỳ đánh giá', value: data?.thoiDiem ?? ''),
              ]),
              SizedBox(
                height: 5,
              ),
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
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: !widget.isChiTiet
          ? Container(
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
                      text: 'DUYỆT',
                      controller: _btnControllerDuyet,
                      onTap: () => _showConfirmationDialogSaveDuyet(context),
                      // onTap: () => _saveKPIAndMaybeSend(sendApproval: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrimaryButton(
                      text: 'TỪ CHỐI',
                      controller: _btnController,
                      // onTap: data.viTriDuyet == 0 ? null : () => openRejectDialog(widget.id),
                      onTap: data.viTriDuyet == 0 ? () => _showConfirmationDialogInfo(context) : () => openRejectDialog(widget.id),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink(),
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

class _InfoCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _InfoCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9), // nền xám nhạt
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: 14,
                height: 1.35,
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
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
  });

  @override
  Widget build(BuildContext context) {
    final chiTiets = nhom.chiTiets ?? [];

    return Container(
      decoration: BoxDecoration(
        // color: Colors.white,
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
              isExpanded: expanded.contains(chiTiets[i].vptq_kpi_KPIDonViChiTiet_Id),
              onToggle: () => onToggle(chiTiets[i].vptq_kpi_KPIDonViChiTiet_Id ?? ''),
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

void _showPiInfo(BuildContext context, ChiTietPIModel ct, int? tyTrong) {
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
      builder: (_, controller) => _PiInfoSheet(
        ct: ct,
        tyTrong: tyTrong ?? 0,
        scroll: controller,
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
  const _PiInfoSheet({required this.ct, required this.tyTrong, required this.scroll});

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
  KetQuaModel? _byScore(int s) {
    return ct.ketQuas?.firstWhere((e) => (e.diem ?? -1) == s, orElse: () => KetQuaModel());
  }

  // “Chỉ tiêu cần đạt”
  // String get _chiTieuCanDat {
  //   if (ct.isNoiDung == true) return '${ct?.noiDungChiTieu}';
  //   if (ct.giaTriChiTieu != null) {
  //     final so = formatNumber(ct.giaTriChiTieu, fractionDigits: 0);
  //     final dv = (ct.tenDonViTinh?.isNotEmpty ?? false) ? ' ${ct.tenDonViTinh}' : '';
  //     return '$so$dv';
  //   }
  //   return '';
  // }
  String formatChiTieu(num? value) {
    if (value == null) return '';
    // Nếu là số nguyên (ví dụ 5.0, 6.0) thì hiển thị nguyên không có .0
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    // Nếu có phần thập phân thì giữ nguyên
    return value.toString();
  }

  String? get chiTieuCanDat {
    final bool isChiTietCon = ct.hasCon == true ? false : (ct.isNoiDung == true ? false : (ct.chiTietCons != null && (ct.chiTietCons!.isNotEmpty)));

    final String dienGiai = (ct.dienGiai?.isNotEmpty ?? false) ? '(${ct.dienGiai})' : '';

    // isChiTietCon -> chỉ hiển thị diễn giải
    if (isChiTietCon == true) {
      return ct.dienGiai ?? '';
    }

    // isNoiDung -> nội dung chỉ tiêu + (diễn giải)
    if (ct.isNoiDung == true) {
      final String noiDung = ct.noiDungChiTieu ?? '';
      return noiDung + (dienGiai.isNotEmpty ? '\n$dienGiai' : '');
    }

    // Mặc định -> giá trị + đơn vị (kể cả = 0) + (diễn giải)
    String left = '';
    if (ct.giaTriChiTieu != null) {
      // final so = formatNumber(ct.giaTriChiTieu, fractionDigits: 0);
      final so = formatChiTieu(ct.giaTriChiTieu);
      // final so = ct.giaTriChiTieu;
      final dv = (ct.tenDonViTinh?.isNotEmpty ?? false) ? ' ${ct.tenDonViTinh}' : '';
      left = '$so$dv';
    }

    return left + (dienGiai.isNotEmpty ? '\n$dienGiai' : '');
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
                _row('Chỉ tiêu cần đạt:', chiTieuCanDat),
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

class _PiItem extends StatelessWidget {
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

  final TextEditingController Function(Map<String, TextEditingController>, String) getCtrlById;
  final Map<String, TextEditingController> mapThucHien, mapNhanXet, mapNguyenNhan, mapGiaiPhap;
  final bool Function(String id) khongHopLeOfId;
  final void Function(String id, bool v) setKhongHopLeId;

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
    required this.getCtrlById,
    required this.mapThucHien,
    required this.mapNhanXet,
    required this.mapNguyenNhan,
    required this.mapGiaiPhap,
    required this.khongHopLeOfId,
    required this.setKhongHopLeId,
  });

  @override
  Widget build(BuildContext context) {
    final tyTrong = ct.tyTrong ?? 0;
    final bool isNoiDung = ct.isNoiDung == true;
    final bool isChiTietCon = ct.hasCon == true ? false : (ct.isNoiDung == true ? false : (ct.chiTietCons != null && (ct.chiTietCons!.isNotEmpty)));

    print("phantram:${ct.isCongDonPhanTramNam}");

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onToggle, // toggle ở mọi khoảng trống trong card
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            // color: const Color(0xFFF6F7F9),
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
            border: Border.all(
              color: isExpanded ? const Color(0xFF2E71FF) : const Color(0xFFE7E8EC),
              width: isExpanded ? 2 : 1,
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
                              Text('${index}. Mã số PI: ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              // Text(ct.maSoPI ?? '', style: const TextStyle(color: Color(0xFF2E71FF), decoration: TextDecoration.underline, fontWeight: FontWeight.w700)),
                              InkWell(
                                onTap: () => _showPiInfo(context, ct, tyTrong),
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
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                              children: [
                                const TextSpan(text: 'Chỉ tiêu cần đạt: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: noiDungCanDat ?? ''),
                              ],
                            ),
                          ),
                          _readonlyFlag('Cộng dồn chỉ tiêu năm', ct.isCongDonGiaTriNam ?? false),
                          _readonlyFlag('Cộng dồn nhập chỉ tiêu năm', ct.isCongDonPhanTramNam ?? false),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    if ((ct.chiTietCons?.isNotEmpty ?? false)) Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.red),
                  ],
                ),
              ),

              // --- body (mở rộng) ---

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isExpanded)
                      if ((ct.chiTietCons?.isNotEmpty ?? false)) ...[
                        // _label('Chi tiết con:'),
                        // const SizedBox(height: 5),
                        for (int j = 0; j < ct.chiTietCons!.length; j++)
                          _ChildPiCard(
                            index: '$index.${j + 1}',
                            childCt: ct.chiTietCons![j],
                            parentCt: ct,
                            // controllers/flags theo ID
                            getCtrlById: getCtrlById,
                            mapThucHien: mapThucHien,
                            mapNhanXet: mapNhanXet,
                            mapNguyenNhan: mapNguyenNhan,
                            mapGiaiPhap: mapGiaiPhap,
                            khongHopLeOfId: khongHopLeOfId,
                            setKhongHopLeId: setKhongHopLeId,

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

  Widget _readonlyFlag(String label, bool value) {
    const _chipBg = Color(0xFFE6E8ED); // xám nhạt
    const _brandRed = Color(0xFFE53935); // đỏ viền/filled
    const _textCol = Color(0xFF555E67);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(
            label,
            style: const TextStyle(color: _textCol, fontSize: 15, fontWeight: FontWeight.w600),
          )),
          IgnorePointer(
            child: Transform.scale(
              scale: 1.3,
              // không cho tương tác nhưng vẫn giữ style enabled
              child: Checkbox(
                value: value,
                onChanged: (_) {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith((s) {
                  return s.contains(MaterialState.selected) ? _brandRed : Colors.transparent;
                }),
                side: const BorderSide(color: _brandRed, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

class _ChildPiCard extends StatefulWidget {
  final String index; // ví dụ: "1.1"
  final ChiTietPIModel childCt;
  final ChiTietPIModel parentCt;

  final TextEditingController Function(Map<String, TextEditingController>, String) getCtrlById;
  final Map<String, TextEditingController> mapThucHien, mapNhanXet, mapNguyenNhan, mapGiaiPhap;
  final bool Function(String id) khongHopLeOfId;
  final void Function(String id, bool v) setKhongHopLeId;

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
  });

  @override
  State<_ChildPiCard> createState() => _ChildPiCardState();
}

class _ChildPiCardState extends State<_ChildPiCard> {
  bool _open = false;

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
                              onTap: () => _showPiInfo(context, ct, tyTrong),
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
                            // Text(ct.maSoPI ?? '',
                            //     style: const TextStyle(
                            //       color: Color(0xFF2E71FF),
                            //       decoration: TextDecoration.underline,
                            //       fontWeight: FontWeight.w700,
                            //     )),
                            // Text('  (Tỷ trọng: $tyTrong%)', style: const TextStyle(fontStyle: FontStyle.italic)),
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
