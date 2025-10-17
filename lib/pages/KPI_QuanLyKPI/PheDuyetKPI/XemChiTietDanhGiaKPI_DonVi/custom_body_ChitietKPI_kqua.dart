import 'dart:convert';

import 'package:Thilogi/services/request_helper_kpi.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../../blocs/user_bloc.dart';
import '../../../../config/config.dart';
import '../../../../models/checksheet.dart';
import '../../../../models/kpi/chitietdanhgiakpi.dart';
import '../../../../widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class BodyChiTietDanhGiaKPI_DonViScreen extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  final bool isChiTiet;
  const BodyChiTietDanhGiaKPI_DonViScreen({super.key, required this.id, required this.lstFiles, required this.isChiTiet});

  @override
  _BodyChiTietDanhGiaKPI_DonViScreenState createState() => _BodyChiTietDanhGiaKPI_DonViScreenState();
}

class _BodyChiTietDanhGiaKPI_DonViScreenState extends State<BodyChiTietDanhGiaKPI_DonViScreen> with TickerProviderStateMixin, ChangeNotifier {
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

  ChiTietDanhGiaKPIModel? _data;
  ChiTietPIModel? _datacon;
  final Set<String> _expanded = {};

  // state form cho từng PI (key = KPICaNhanChiTiet_Id)
  final Map<String, TextEditingController> _txtThucHien = {};
  final Map<String, TextEditingController> _txtNhanXet = {};
  final Map<String, TextEditingController> _txtNguyenNhan = {};
  final Map<String, TextEditingController> _txtGiaiPhap = {};
  final Map<String, bool> _khongHopLe = {};
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnControllerDuyet = RoundedLoadingButtonController();

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

  Future<void> BatDaXem(
    bool isDaXem,
    bool? isDanhGia,
  ) async {
    try {
      setState(() => _isLoading = true);

      final q = buildQuery({
        'isDaXem': !isDaXem,
        'isDanhGia': isDanhGia,
      });
      final http.Response response = await requestHelper.putData('vptq_kpi_KPIDonVi/da-xem/${widget.id}${q.isEmpty ? '' : '?$q'}', null);
      if (response.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: isDaXem ? "Đóng đã xem thành công!" : "Mở đã xem thành công",
          confirmBtnText: 'Đồng ý',
        );
        getListData(widget.id);
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: response.body.replaceAll('"', ''),
          confirmBtnText: 'Đồng ý',
        );
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
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
          sum += (ct.diemTrongSoLanhDao ?? 0);
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

  String _stageLabel(int v) {
    switch (v) {
      case 1:
        return 'Lãnh đạo Đơn vị';
      case 2:
        return 'Lãnh đạo đánh giá';
      case 3:
        return 'Phòng Quản trị KPI';
      default:
        return 'Lãnh đạo phê duyệt';
    }
  }

// y chang renderNhanXet bên React
  String _renderNhanXet(String? ma, String? ten, String? nx, int vitri, int? viTriThucTe) {
    if (vitri == viTriThucTe) {
      return (nx ?? '');
    } else if ((ma ?? '').isNotEmpty) {
      final head = '$ma - $ten - ${_stageLabel(vitri)}';
      final tail = (nx != null && nx.trim().isNotEmpty) ? '\n$nx' : '';
      return head + tail;
    }
    return '';
  }

  Widget _nxPill(String text) {
    final parts = text.split('\n');
    final head = parts.first;
    final body = parts.skip(1).join('\n');
    final isLink = head.toLowerCase().contains('xem xét');
    const _pillBg = Color(0xFFD5DBE5);
    const _textCol = Color(0xFF555E67);
    const _linkCol = Color(0xFF2E71FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: _pillBg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            head,
            style: const TextStyle(
              // color: isLink ? _linkCol : _textCol,

              // decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              color: _textCol,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          if (body.isNotEmpty) const SizedBox(height: 6),
          if (body.isNotEmpty) Text(body, style: const TextStyle(color: _textCol, height: 1.35)),
        ],
      ),
    );
  }

  List<Widget> _buildNhanXetPills(Map<String, dynamic>? info) {
    if (info == null) return const [];
    final int? viTri = info['viTriDuyetDanhGia'] as int?;
    final out = <Widget>[];

    for (int i = 1; i <= 5; i++) {
      final id = info['nguoiDuyetDanhGia${i}_Id'] as String?;
      if (id == null || id.isEmpty) continue;

      final ma = info['maNguoiDuyet$i'] as String?;
      final ten = info['tenNguoiDuyet$i'] as String?;
      final nx = info['nhanXetDanhGia$i'] as String?;
      final text = _renderNhanXet(ma, ten, nx, i, viTri).trim();

      if (text.isNotEmpty) {
        out
          ..add(_nxPill(text))
          ..add(const SizedBox(height: 10));
      }
    }
    if (out.isNotEmpty) out.removeLast();
    return out;
  }

// helper
  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
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
        'vptq_kpi_DanhGiaKPIDonVi/tra-cap-duoi/$id',
        payload, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Từ chối duyệt đánh giá KPI đơn vị thành công',
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
        'vptq_kpi_DanhGiaKPIDonVi/gui-duyet-cap-tren/$id',
        null, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Duyệt đánh giá KPI đơn vị thành công!',
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
        text: 'Xác nhận duyệt KPI?',
        title: '',
        confirmBtnText: 'Xác nhận',
        cancelBtnText: 'Hủy',
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
        cancelBtnText: 'Hủy',
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
          _btnController.reset();
        });
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

    // lấy tổng điểm hiển thị: ưu tiên server trả, fallback tính tổng
    final tongDiem = data.diemKetQua ?? _tinhTongDiemTrongSo(data);

    final nhomPIs = data.nhomPIs ?? [];
    final bool canMark = _data?.isDuocPhepDanhDauDaXem ?? false;
    final bool isSeen = _data?.isDaXem ?? false;

    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: const Color(0xFFF6F7F9),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng Đơn vị với icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF7E6), // nền vàng nhạt
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.apartment, // có thể đổi sang Icons.business hoặc Icons.domain tuỳ bạn
                              color: Colors.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Đơn vị',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  data.tenDonViKPI ?? '—',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Ô Áp dụng từ
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip('Chu kỳ', data?.chuKy == 1 ? 'Tháng' : 'Năm'),
                          _infoChip('Kỳ đánh giá', data?.thoiDiem ?? ''),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Thẻ TỔNG ĐIỂM
                _TongDiemGrid(
                  diemCuoi: data.diemKetQua ?? tongDiem ?? 0,
                  diemKetQuaCuoiCung: data.diemKetQuaCuoiCung ?? 0,
                  diemCong: data.diemCong ?? 0,
                  diemTru: data.diemTru ?? 0,
                  // diemKetQuaCuoiCung: data.diemKetQuaCuoiCung ?? 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => getListData(widget.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // _InfoCard(children: [
                    //   _InfoRow(label: 'Đơn vị', value: data?.tenDonViKPI ?? ''),
                    //   _InfoRow(label: 'Chu kỳ đánh giá', value: data?.chuKy == 1 ? "Tháng" : "Năm"),
                    //   _InfoRow(label: 'Kỳ đánh giá', value: data?.thoiDiem ?? ''),
                    // ]),

                    if (canMark)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 0.3),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            const Expanded(
                              child: Text(
                                'Đã xem',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              tooltip: isSeen ? 'Đóng đã xem' : 'Mở đã xem',
                              onPressed: () => BatDaXem(_data?.isDaXem ?? false, true),
                              icon: Icon(
                                isSeen ? Icons.visibility : Icons.visibility_off,
                                color: const Color(0xFF0369b9),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

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
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        // color: const Color(0xFFF6F7F9),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nhận xét:', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 8),
                          ..._buildNhanXetPills(data.toJson()),
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
                      // onTap: data.viTriDuyet == 0 ? () => _showConfirmationDialogInfo(context) : () => openRejectDialog(widget.id),
                      onTap: () => openRejectDialog(widget.id),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink(),
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
        // color: const Color(0xFFF6F7F9), // nền xám nhạt
        color: Colors.white,
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

/// 4 thẻ tóm tắt ở đầu màn hình
class _TongDiemGrid extends StatelessWidget {
  final double diemCuoi; // ví dụ: data.diemKetQuaCuoiCung ?? 0
  final double diemKetQuaCuoiCung; // ví dụ: data.xepLoai ?? '—'
  final double diemCong; // ví dụ: data.diemCong ?? 0
  final double diemTru; // ví dụ: data.diemTru ?? 0

  const _TongDiemGrid({
    required this.diemCuoi,
    required this.diemKetQuaCuoiCung,
    required this.diemCong,
    required this.diemTru,
  });

  // String _fmt(num v) => v.toStringAsFixed(1);
  String _fmt(num v) => v.toString();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        const gap = 12.0;
        final cardW = (c.maxWidth - gap) / 2; // 2 cột

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            // SizedBox(
            //   width: cardW,
            //   child: _MiniKpiCard(
            //     bg: const Color(0xFFEAF2FF), // xanh nhạt
            //     iconBg: const Color(0xFF3B82F6), // xanh dương
            //     icon: Icons.inventory_2_rounded,
            //     value: _fmt(diemKetQuaCuoiCung),
            //     title: 'Điểm kết quả đánh giá cuối cùng',
            //   ),
            // ),
            SizedBox(
              width: cardW,
              child: _MiniKpiCard(
                bg: const Color(0xFFEAF2FF), // xanh nhạt
                iconBg: const Color(0xFF3B82F6), // xanh dương
                icon: Icons.inventory_2_rounded,
                value: _fmt(diemCuoi),
                title: 'KQ đánh giá cuối cùng',
              ),
            ),
            SizedBox(
              width: cardW,
              child: _MiniKpiCard(
                bg: const Color(0xFFE9F7EF), // xanh lá nhạt
                iconBg: const Color(0xFF10B981), // xanh lá
                icon: Icons.badge_rounded,
                value: _fmt(diemKetQuaCuoiCung), // là text
                title: 'Điểm kết quả đánh giá cuối cùng',
                // isTextValue: true,
              ),
            ),
            SizedBox(
              width: cardW,
              child: _MiniKpiCard(
                bg: const Color(0xFFEFF8FB), // teal nhạt
                iconBg: const Color(0xFF059669), // teal
                icon: Icons.add_circle_outline,
                value: _fmt(diemCong),
                title: 'Điểm cộng',
              ),
            ),
            SizedBox(
              width: cardW,
              child: _MiniKpiCard(
                bg: const Color(0xFFFFECEC), // hồng nhạt
                iconBg: const Color(0xFFEF4444), // đỏ
                icon: Icons.remove_circle_outline,
                value: _fmt(diemTru),
                title: 'Điểm trừ',
              ),
            ),
          ],
        );
      },
    );
  }
}

/// thẻ con
class _MiniKpiCard extends StatelessWidget {
  final Color bg;
  final Color iconBg;
  final IconData icon;
  final String value;
  final String title;
  final bool isTextValue;

  const _MiniKpiCard({
    required this.bg,
    required this.iconBg,
    required this.icon,
    required this.value,
    required this.title,
    this.isTextValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 18, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // giá trị lớn bên trái
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: isTextValue ? 16 : 26,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ],
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
        // color: const Color(0xFFF6F7F9),
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
      final so = ct.giaTriChiTieu.toString();
      // final so = formatNumber(ct.giaTriChiTieu, fractionDigits: 0);
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
                const SizedBox(height: 4),
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
    final bool disabled = ct.isKhongThucHien == true;
    final enableReasonParent = ct.isKhongThucHien == true || hasChildKhongThucHien(ct);
    ;
    print("ct.isKhongThucHien: ${ct.isKhongThucHien}");
    print("ct.isThuocKPINam: ${ct.isThuocKPINam}");
    print("ct.congDonNamPhanTram: ${ct.congDonNamPhanTram}");

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        // color: Colors.white,
        color: const Color(0xFFF6F7F9),
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
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
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
                        //       TextSpan(text: '${ct.diemTrongSoTuDanhGia ?? 0}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                        //     ],
                        //   ),
                        // ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cá nhân tự đánh giá
                            const Row(
                              children: const [
                                Icon(Icons.person_outline, color: Color(0xFF2E71FF)),
                                SizedBox(width: 8),
                                Text('Tự đánh giá:', style: TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _pill(
                                    RichText(
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(text: 'Điểm đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                          TextSpan(text: '${ct.diemKetQuaTuDanhGia ?? 0}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _pill(
                                    RichText(
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(text: 'Điểm trọng số: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                          TextSpan(text: '${ct.diemTrongSoTuDanhGia ?? 0}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            const Divider(),

                            // Cấp trên đánh giá
                            const Row(
                              children: const [
                                Icon(Icons.groups, color: Color(0xFF00BC7E)),
                                SizedBox(width: 8),
                                Text('Cấp trên đánh giá:', style: TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _pill(
                                    RichText(
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(text: 'Điểm đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                          TextSpan(text: '${ct.diemKetQuaLanhDao ?? 0}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _pill(
                                    RichText(
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(text: 'Điểm trọng số: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                          TextSpan(text: '${ct.diemTrongSoLanhDao ?? 0}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.red),
                ],
              ),
            ),
          ),

          // --- body (mở rộng) ---
          if (isExpanded) const Divider(height: 1),
          if (isExpanded)
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
                  _pill(
                    Container(
                      width: double.infinity,
                      child: Text(
                        buildNdText(
                          isNoiDung: isNoiDung,
                          noiDungChiTieuDanhGia: ct.noiDungChiTieuDanhGia,
                          dienGiaiDanhGia: ct.dienGiaiDanhGia,
                          giaTriChiTieuDanhGia: ct.giaTriChiTieuDanhGia,
                          tenDonViTinh: ct.tenDonViTinh,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _fileDinhKemPill(ct),
                  const SizedBox(height: 5),

                  _label('Nguyên nhân:'),
                  const SizedBox(height: 6),
                  // _input(ctrlNguyenNhan, hint: 'Nhập nguyên nhân', enabled: enableReasonParent, maxLines: 3),
                  _pill(
                    Container(
                      width: double.infinity,
                      child: Text(ct.nguyenNhan ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _label('Giải pháp:'),

                  const SizedBox(height: 6),
                  // _input(ctrlGiaiPhap, hint: 'Nhập giải pháp', enabled: enableReasonParent, maxLines: 2),
                  _pill(
                    Container(
                      width: double.infinity,
                      child: Text(ct.giaiPhap ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _readonlyFlag('Không thực hiện', ct.isKhongThucHien ?? false),
                  _readonlyFlag('Cộng dồn chỉ tiêu năm', ct.isThuocKPINam ?? false),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                      children: [
                        const TextSpan(text: 'Hoàn thành chỉ tiêu năm: ', style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: '${ct.congDonNamPhanTram ?? ''}'),
                      ],
                    ),
                  ),

                  if ((ct.chiTietCons?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
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
                  // nhận xét
                ],
              ),
            ),
        ],
      ),
    );
  }

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

  Widget _fileDinhKemPill(ChiTietPIModel ct) {
    final v = ct.fileDinhKem;
    if (v == null) return _label('File đính kèm:');

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

// helper dùng cùng style với các pill
  Widget _labelAndPill({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        _pill(child),
      ],
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

  Widget _input(TextEditingController c, {String? hint, bool enabled = true, int maxLines = 1, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboard,
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
    final ct2 = widget.parentCt;

    final id = ct.vptq_kpi_KPIDonViChiTietCon_Id ?? ct.vptq_kpi_KPIDonViChiTiet_Id ?? '';
    final bool isNoiDung = ct.isNoiDung == true;
    final bool isChiTietCon = ct.hasCon == true ? false : (ct.isNoiDung == true ? false : (ct.chiTietCons != null && (ct.chiTietCons!.isNotEmpty)));

    final tyTrong = ct.tyTrong ?? 0;

    final khongHopLe = widget.khongHopLeOfId(id);
    print("ct.isKhongThucHien2: ${ct.isKhongThucHien}");
    print("ct.isThuocKPINam2:${ct.isThuocKPINam} ");
    print("ct.congDonNamPhanTram2:${ct.congDonNamPhanTram}");

    // nội dung “Chỉ tiêu cần đạt”
    // final so = (ct.giaTriChiTieu != null || ct.giaTriChiTieu == 0) ? '${formatNumber(ct.giaTriChiTieu, fractionDigits: 1)}${ct.tenDonViTinh?.isNotEmpty == true ? ' ${ct.tenDonViTinh}' : ''}' : '';
    // final extra = (ct.dienGiai?.isNotEmpty ?? false) ? '\n(${ct.dienGiai})' : '';
    // final noiDungCanDat = '$so$extra';
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
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                            children: [
                              const TextSpan(text: 'Chỉ tiêu cần đạt: ', style: TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(text: noiDungCanDat ?? ''),
                            ],
                          ),
                        ),
                        // RichText(
                        //   text: TextSpan(
                        //     style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                        //     children: [
                        //       const TextSpan(text: 'Điểm đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                        //       TextSpan(
                        //         text: '${ct.isKhongThucHien == true ? 0 : (ct.diemKetQuaTuDanhGia ?? 0)}',
                        //         style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                        //       ),
                        //       const TextSpan(text: '  -  Điểm trọng số: ', style: TextStyle(fontWeight: FontWeight.w700)),
                        //       TextSpan(
                        //         text: (ct.isKhongThucHien == true ? 0 : (ct.diemTrongSoTuDanhGia ?? 0)).toStringAsFixed(2),
                        //         style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                        //       ),
                        //     ],
                        //   ),
                        // ),
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
                  // _label('Chỉ tiêu cần đạt:'),
                  // const SizedBox(height: 6),
                  // _pill(Container(width: double.infinity, child: Text(noiDungCanDat, style: const TextStyle(fontWeight: FontWeight.w700)))),

                  _label('Kết quả thực hiện:'),
                  const SizedBox(height: 6),
                  _pill(
                    Container(
                      width: double.infinity,
                      child: Text(
                        buildNdText(
                          isNoiDung: isNoiDung,
                          noiDungChiTieuDanhGia: ct.noiDungChiTieuDanhGia,
                          dienGiaiDanhGia: ct.dienGiaiDanhGia,
                          giaTriChiTieuDanhGia: ct.giaTriChiTieuDanhGia,
                          tenDonViTinh: ct.tenDonViTinh,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  _fileDinhKemPill(ct),
                  const SizedBox(height: 5),
                  _label('Nguyên nhân:'),
                  const SizedBox(height: 6),
                  // _input(ctrlNguyenNhan, hint: 'Nhập nguyên nhân', enabled: enableReasonParent, maxLines: 3),
                  _pill(
                    Container(
                      width: double.infinity,
                      child: Text(ct.nguyenNhan ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _label('Giải pháp:'),
                  const SizedBox(height: 6),
                  // _input(ctrlGiaiPhap, hint: 'Nhập giải pháp', enabled: enableReasonParent, maxLines: 2),
                  _pill(
                    Container(
                      width: double.infinity,
                      child: Text(ct.giaiPhap ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 5),

                  _readonlyFlag('Không thực hiện', ct.isKhongThucHien ?? false),
                  _readonlyFlag('Cộng dồn chỉ tiêu năm', ct.isThuocKPINam ?? false),
                  const SizedBox(height: 6),

                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
                      children: [
                        const TextSpan(text: 'Hoàn thành chỉ tiêu năm: ', style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: '${ct.congDonNamPhanTram ?? ''}'),
                      ],
                    ),
                  ),
                  // _uploadButton(),
                  // const SizedBox(height: 12),

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

  // === helpers nhỏ (copy từ _PiItem) ===
  Widget _label(String s) => Text(s, style: const TextStyle(fontWeight: FontWeight.w800));
  Widget _pill(Widget child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFE9EDF2), borderRadius: BorderRadius.circular(12)),
        child: child,
      );
  Widget _input(TextEditingController c, {String? hint, bool enabled = true, int maxLines = 1, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboard,
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

class _ChiTietPICard extends StatelessWidget {
  final int index;
  final ChiTietPIModel ct;
  const _ChiTietPICard({required this.index, required this.ct});

  @override
  Widget build(BuildContext context) {
    final tyTrong = (ct is ChiTietPIModel) ? (ct as ChiTietPIModel)?.tyTrong : null; // nếu bạn có thêm field tyTrong trong model
    // nếu model ChiTietPIModel chưa có tyTrong -> thêm field int? tyTrong; và parse từ json["tyTrong"]

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE7E8EC)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Mã số PI + Tỷ trọng
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 4,
            children: [
              Text(
                '${index}. Mã số PI: ',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              Text(
                ct.maSoPI ?? '',
                style: const TextStyle(
                  color: Color(0xFF2E71FF),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '  (Tỷ trọng: ${tyTrong ?? 0}%)',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Dòng 2: Chỉ số đánh giá
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
              children: [
                const TextSpan(text: 'Chỉ số đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: ct.chiSoDanhGia ?? ''),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Dòng 3: Điểm
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.35),
              children: [
                const TextSpan(text: 'Điểm đánh giá: ', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(
                  text: '${ct?.diemKetQuaTuDanhGia ?? _suyRaDiem(ct)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                ),
                const TextSpan(text: '  -  Điểm trọng số: ', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(
                  text: (ct.diemTrongSoTuDanhGia ?? 0).toStringAsFixed(2),
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // nếu server không trả "diemKetQuaTuDanhGia" ở ct, có thể suy ra từ ketQuas với kết quả đang chọn
  int _suyRaDiem(ChiTietPIModel ct) {
    // ở payload bạn có "diemKetQuaTuDanhGia": 3
    // nếu không có, mình fallback 3 cho an toàn
    return (ct.ketQuas?.isNotEmpty ?? false) ? (ct.ketQuas!.last.diem ?? 0) : 0;
  }
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
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C1C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
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
