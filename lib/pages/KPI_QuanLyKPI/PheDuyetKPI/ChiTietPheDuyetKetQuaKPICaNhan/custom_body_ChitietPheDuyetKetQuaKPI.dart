import 'dart:convert';

import 'package:Thilogi/services/request_helper_kpi.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';

import '../../../../blocs/user_bloc.dart';
import '../../../../models/checksheet.dart';

import '../../../../models/kpi/pheduyetketquakpi.dart';
import '../../../../widgets/loading.dart';

class BodyChiTietPheDuyetKetQuaKPIScreen extends StatefulWidget {
  final String? id;
  final bool isCaNhan;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyChiTietPheDuyetKetQuaKPIScreen({
    super.key,
    required this.id,
    required this.lstFiles,
    required this.isCaNhan,
  });

  @override
  _BodyChiTietPheDuyetKetQuaKPIScreenState createState() => _BodyChiTietPheDuyetKetQuaKPIScreenState();
}

class _BodyChiTietPheDuyetKetQuaKPIScreenState extends State<BodyChiTietPheDuyetKetQuaKPIScreen> with TickerProviderStateMixin, ChangeNotifier {
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

  PheDuyetKetQuaKPIModel? _data;
  List<bool> selectedItems = [];

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
      final http.Response response = await requestHelper.getData(widget.isCaNhan ? 'vptq_kpi_DeXuatPheDuyetKetQuaKPICaNhan/$id' : 'vptq_kpi_DeXuatPheDuyetKetQuaKPIDonVi/$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _data = PheDuyetKetQuaKPIModel.fromJson(decoded);
        } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
          _data = PheDuyetKetQuaKPIModel.fromJson(
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

  String _chuKyText(int? chuKy) {
    // backend của bạn dùng: 2 = Năm, 1 = Tháng (tuỳ chỉnh nếu khác)
    if (chuKy == 2) return 'Năm';
    if (chuKy == 1) return 'Tháng';
    return '—';
  }

  (Color bg, Color fg, String label) _statusChip(bool? isSuDung) {
    if (isSuDung == true) {
      return (const Color(0xFFE9FFF3), const Color(0xFF16A34A), 'Đang sử dụng');
    }
    return (const Color(0xFFF1F5F9), const Color(0xFF64748B), 'Không sử dụng');
  }

  Widget _iconCircle(IconData icon) => Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(color: Color(0xFFFFF7E6), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.orange, size: 20),
      );

  Widget _infoRow(String label, String? value, {required IconData icon}) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          _iconCircle(icon),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value, style: const TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFFFF7E6), borderRadius: BorderRadius.circular(6)),
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

  Widget _buildPaginatedTable(BuildContext context) {
    final items = _data?.chiTiets ?? const <ChiTietModel>[];
    print("_data?.tenDonViKPI:${_data?.tenDonViKPI}");
    final donViLabel = _data?.tenDonViKPI == null ? 'Đơn vị' : 'Bộ phận';
    final dataSource = KeHoachDataSource(
      items,
      widget.isCaNhan,
      _data,
    );

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
            columns: [
              if (widget.isCaNhan) ...[
                const DataColumn(label: Text('STT')),
                const DataColumn(label: Text('Mã nhân viên')),
                const DataColumn(label: Text('Họ và tên')),
                const DataColumn(label: Text('Chức vụ')),
                DataColumn(label: Text(donViLabel)), // <-- giống React
                // const DataColumn(label: Text('Bộ phận')),
                const DataColumn(label: Text('KQ đánh giá KPI')),
                const DataColumn(label: Text('Điểm cộng')),
                const DataColumn(label: Text('Điểm trừ')),
                const DataColumn(label: Text('KQ đánh giá KPI cuối cùng')),
                const DataColumn(label: Text('Xếp loại')),
                const DataColumn(label: Text('Ghi chú')),
              ],
              if (!widget.isCaNhan) ...[
                const DataColumn(label: Text('STT')),
                const DataColumn(label: Text('Đơn vị')),
                const DataColumn(label: Text('Lãnh đạo Đơn vị')),
                const DataColumn(label: Text('Kết quả đánh giá KPI cuối cùng')),
                // DataColumn(label: Text(donViLabel)), // <-- giống React
                const DataColumn(label: Text('Số lượng các chỉ số có Điểm đánh giá <= 2 điểm"')),
                const DataColumn(label: Text('Số lượng các chỉ số có Điểm đánh giá <= 1 điểm')),
                const DataColumn(label: Text('Lợi nhuận <= 0')),
                const DataColumn(label: Text('Số sự cố tai nạn nặng, tai nạn nghiêm trọng; sự cố cháy nổ hoặc sự cố môi trường')),
                const DataColumn(label: Text('Xếp loại')),

                const DataColumn(label: Text('Ghi chú')),
              ],
            ],
            source: dataSource,
            rowsPerPage: 10,
            showCheckboxColumn: false,
            columnSpacing: 20,
          ),
        ],
      ),
    );
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
    final stats = _extractStats(data);

    // lấy tổng điểm hiển thị: ưu tiên server trả, fallback tính tổng

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: RefreshIndicator(
        onRefresh: () async => getListData(widget.id),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Đơn vị + Áp dụng
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (widget.isCaNhan) ...[
                    // Hàng Đơn vị với icon
                    _infoRow('Đơn vị', data.tenDonViKPI, icon: Icons.apartment_rounded),
                    _infoRow('Kiểm tra 1', data.tenKiemTra1, icon: Icons.fact_check_rounded),
                    _infoRow('Kiểm tra 2', data.tenKiemTra2, icon: Icons.fact_check_rounded),
                    _infoRow('Phê duyệt', data.tenPheDuyet, icon: Icons.edit_note_rounded),

                    const SizedBox(height: 12),

                    // chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoChip('Thang điểm', data.tenThangDiemXepLoai),
                        _infoChip('Kỳ', data.thoiDiem),
                      ],
                    ),
                  ],
                  if (!widget.isCaNhan) ...[
                    // Hàng Đơn vị với icon
                    _infoRow('Kiểm tra', data.tenKiemTra, icon: Icons.fact_check_rounded),

                    _infoRow('Phê duyệt', data.tenPheDuyet, icon: Icons.edit_note_rounded),

                    const SizedBox(height: 12),

                    // chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoChip('Kỳ', data.thoiDiem),
                      ],
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  // thẻ lớn tổng cộng
                  _bigTotalCard(stats.total, widget.isCaNhan),
                  const SizedBox(height: 12),

                  // 6 thẻ nhỏ
                  LayoutBuilder(builder: (_, c) {
                    const gap = 10.0;
                    final w = (c.maxWidth - gap) / 2;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final s in stats.cats) SizedBox(width: w, child: _smallCard(s, context)),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
              _buildPaginatedTable(context)
              // List PI
            ],
          ),
        ),
      ),
    );
  }
}

// ===== helpers =====
class _CardStat {
  final String label;
  final int count;
  final double pct;
  final Color bg;
  final bool hasData; // mới
  final String? tip;
  const _CardStat(this.label, this.count, this.pct, this.bg, {this.hasData = true, this.tip});
}

String _fmtPct(double v) => '${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}%';

_MapStats _extractStats(PheDuyetKetQuaKPIModel d) {
  final list = d.tyLeXepLoais ?? const <XepLoaiChiTietModel>[];
  final total = list.fold<int>(0, (a, e) => a + (e.soLuong ?? 0));

  XepLoaiChiTietModel? find(String label) => list.cast<XepLoaiChiTietModel?>().firstWhere(
        (e) => (e?.xepLoai ?? '') == label,
        orElse: () => null,
      );

  int cnt(String label) => find(label)?.soLuong ?? 0;
  double pct(String label) {
    final v = find(label)?.tyLe;
    if (v != null) return v;
    if (total == 0) return 0;
    return cnt(label) * 100 / total;
  }

  final cats = <_CardStat>[];

  void addIfPresent(String label, Color bg) {
    final f = find(label);

    final tip = (label != 'Không đánh giá' && (f?.mucDiem?.trim().isNotEmpty ?? false)) ? f?.mucDiem : null;
    if (f != null) cats.add(_CardStat(label, f.soLuong ?? 0, pct(label), bg, tip: tip));
  }

  // các nhóm có thì mới thêm
  addIfPresent('Xuất sắc', const Color(0xFFEAF7ED));
  addIfPresent('Vượt yêu cầu', const Color(0xFFEAF2FF));
  addIfPresent('Đạt yêu cầu', const Color(0xFFFFF5DB));
  addIfPresent('Đạt yêu cầu tối thiếu', const Color(0xFFFFF5DB));
  addIfPresent('Không đạt yêu cầu', const Color(0xFFFFEDEF));

  // "Không đánh giá" luôn có thẻ, thiếu dữ liệu thì để trống
  final fKDG = find('Không đánh giá');
  if (fKDG != null) {
    cats.add(_CardStat(
      'Không đánh giá',
      fKDG.soLuong ?? 0,
      pct('Không đánh giá'),
      const Color(0xFFF3F4F6),
      tip: null,
    ));
  } else {
    cats.add(_CardStat(
      'Không đánh giá',
      0,
      0,
      const Color(0xFFF3F4F6),
      hasData: false,
      tip: null,
    ));
  }

  return _MapStats(total, cats);
}

class _MapStats {
  final int total;
  final List<_CardStat> cats;

  _MapStats(this.total, this.cats);
}

Widget _bigTotalCard(int total, bool isCaNhan) => Container(
      width: 100.w,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6E6),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 18, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFB91C1C))),
          const SizedBox(height: 4),
          Text('$total ${isCaNhan ? 'CBNV' : 'Đơn vị'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C))),
          const SizedBox(height: 4),
          const Text('100%', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFB91C1C))),
        ],
      ),
    );

Widget _smallCard(_CardStat s, BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 14),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 18, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(s.label, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF374151))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text(s.label, softWrap: true, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF374151), fontSize: 12.2))),
              if (s.tip != null) ...[
                const SizedBox(width: 6),
                // GestureDetector(
                //   onTap: () => showDialog(
                //     context: context,
                //     builder: (_) => AlertDialog(content: Text(s.tip!), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))]),
                //   ),
                //   child: const Icon(Icons.info_rounded, size: 16, color: Color(0xFF6B7280)),
                // ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        elevation: 12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                        contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                        content: Text(
                          s.tip!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),

                        actionsAlignment: MainAxisAlignment.end, // nút góc phải
                        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Đóng',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(Icons.info_rounded, size: 16, color: Color(0xFF6B7280)),
                )
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(s.hasData ? '${s.count}' : '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(s.hasData ? _fmtPct(s.pct) : '', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        ],
      ),
    );

// ===== in build() BEFORE _buildPaginatedTable(context) =====

class KeHoachDataSource extends DataTableSource {
  final List<ChiTietModel> rows;
  final bool isCaNhan;
  final PheDuyetKetQuaKPIModel? _data;
  KeHoachDataSource(this.rows, this.isCaNhan, this._data);

  @override
  DataRow getRow(int index) {
    final r = rows[index];
    final donViOrBoPhan = _data?.tenDonViKPI == null ? r.tenDonViKPI : r.tenPhongBan;

    String _n(num? v) => v == null ? '' : v.toString();
    String? _ghiChu(ChiTietModel r) {
      String addMoTa(String? s) => (s != null && s.trim().isNotEmpty) ? "\n- $s" : "";
      if (r.isKhongDanhGia == true) {
        return "- Không đánh giá (${r.lyDoKhongDanhGia ?? ''})" + addMoTa(r.moTa);
      } else if (r.isHoanThanh != true && r.isKhongThucHien == true) {
        return "- Không thực hiện đăng ký" + addMoTa(r.moTa);
      } else if (r.isHoanThanh != true && r.isKhongThucHien != true) {
        return "- Không thực hiện đánh giá" + addMoTa(r.moTa);
      } else if ((r.moTa?.trim().isNotEmpty ?? false)) {
        return "- ${r.moTa}";
      }
      return null;
    }

    DataCell cellC(String? v) => DataCell(Center(child: Text(v ?? '', textAlign: TextAlign.center)));
    return DataRow.byIndex(
      index: index,
      cells: [
        if (isCaNhan) ...[
          DataCell(Text('${index + 1}')),
          DataCell(Text(r.maUser ?? '')),
          DataCell(Text(r.tenUser ?? '')),
          DataCell(Text(r.tenChucVu ?? '')),
          // DataCell(Text(r.tenPhongBan ?? '')), // <-- giá trị theo điều kiện
          DataCell(Text(donViOrBoPhan ?? '')),
          cellC(_n(r.diemKetQua)),
          cellC(_n(r.diemCong)),
          cellC(_n(r.diemTru)),
          cellC(_n(r.diemKetQuaCuoiCung)),
          DataCell(Text(r.xepLoai ?? '')),
          DataCell(Text(_ghiChu(r) ?? '')),
        ],
        if (!isCaNhan) ...[
          DataCell(Text('${index + 1}')),
          DataCell(Text(r.tenDonViKPI ?? '')),
          DataCell(Text(r.tenLanhDaoDonVi ?? '')),
          cellC(_n(r.diemKetQuaCuoiCung)),
          cellC(_n(r.soLuongBeHonBang2)), // <-- giá trị theo điều kiện
          cellC(_n(r.soLuongBeHonBang1)),
          cellC(_n(r.lonNhuanKhongDuong)),
          cellC(_n(r.soSuCo)),
          DataCell(Text(r.xepLoai ?? '')),
          DataCell(Text(r.moTa ?? '')),
        ]
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
