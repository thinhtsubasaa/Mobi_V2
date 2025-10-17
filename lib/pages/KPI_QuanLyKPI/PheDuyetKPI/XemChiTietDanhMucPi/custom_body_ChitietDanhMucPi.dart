import 'dart:convert';

import 'package:Thilogi/services/request_helper_kpi.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../../blocs/user_bloc.dart';
import '../../../../models/checksheet.dart';
import '../../../../models/kpi/danhmucpi.dart';
import '../../../../widgets/loading.dart';

class BodyChiTietDMPIScreen extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  final bool isChiTiet;
  const BodyChiTietDMPIScreen({super.key, required this.id, required this.lstFiles, required this.isChiTiet});

  @override
  _BodyChiTietDMPIScreenState createState() => _BodyChiTietDMPIScreenState();
}

class _BodyChiTietDMPIScreenState extends State<BodyChiTietDMPIScreen> with TickerProviderStateMixin, ChangeNotifier {
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

  DanhMucPiModel? _data;
  late final Set<String> _expandedIds = {};
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnControllerDuyet = RoundedLoadingButtonController();

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
      final http.Response response = await requestHelper.getData('vptq_kpi_DanhMucPI/$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _data = DanhMucPiModel.fromJson(decoded);
        } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
          _data = DanhMucPiModel.fromJson(
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
        'vptq_kpi_DanhMucPI/tra-cap-duoi/$id',
        payload, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Từ chối danh mục PI thành công',
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
        'vptq_kpi_DanhMucPI/gui-duyet-cap-tren/$id',
        null, // không body
      );

      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Duyệt danh mục PI thành công!',
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
        text: 'Xác nhận duyệt danh mục PI?',
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
    final items = data.chiTiets ?? const <DanhMucPiChiTietModel>[];

    // lấy tổng điểm hiển thị: ưu tiên server trả, fallback tính tổng

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
              // Header: Đơn vị + Áp dụng
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),

                // child: Column(
                //   children: [
                //     _kvRow('Đơn vị:', data.tenDonViKPI ?? '—'),
                //     const SizedBox(height: 8),
                //     _kvRow('Áp dụng từ:', '${data.apDungTu ?? '—'} đến ${data.apDungDen ?? '—'}'),
                //   ],
                // ),
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
                                data.tenDonViKPI ?? '',
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Áp dụng từ: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87, // đậm
                              ),
                            ),
                            TextSpan(
                              text: '${data.apDungTu ?? ''} đến ${data.apDungDen ?? ''}',
                              style: const TextStyle(
                                color: Colors.black, // xám nhạt hơn
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // List PI
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final it = items[i];
                  final (bg, fg, lb) = _statusChip(it.isSuDung);
                  final isPICha = it.hasCon == true; // map điều kiện PI Cha
                  final id = it.vptq_kpi_DanhMucPI_DanhMucPIChiTiet_Id?.toString() ?? 'idx_$i';
                  final isOpen = _expandedIds.contains(id);
                  final hasChildren = it.chiTietCons?.isNotEmpty == true;
                  return InkWell(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    onTap: hasChildren
                        ? () => setState(() {
                              if (isOpen) {
                                _expandedIds.remove(id);
                              } else {
                                _expandedIds.add(id);
                              }
                            })
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOpen ? const Color(0xFF2E71FF) : const Color(0xFFE7E8EC),
                          width: isOpen ? 2 : 1,
                        ),
                        // boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // bóng mờ
                            blurRadius: 8, // độ mờ
                            offset: const Offset(0, 5), // đổ bóng xuống
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header của card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              // color: (it.isSuDung == true) ? const Color(0xFFFFEBEB) : const Color(0xFFF5F6F7),
                              color: Color(0xFFFFEBEB),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1), // bóng mờ
                                  blurRadius: 15, // độ mờ
                                  offset: const Offset(0, 3), // đổ bóng xuống
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // index tròn đỏ
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFB91C1C),
                                  ),
                                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    it.maSoPI ?? '—',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB91C1C),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                                  child: Text(lb, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 5),
                                if ((it.chiTietCons?.isNotEmpty ?? false)) Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: Colors.red),
                              ],
                            ),
                          ),

                          // Body
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _section('Nhóm PI:', it.tenNhomPI),
                                const SizedBox(height: 8),
                                _section('KPI THILOGI:', (it.mucTieuTrongYeus?.isNotEmpty ?? false) ? it.mucTieuTrongYeus!.first.tenMucTieu : '—'),
                                const SizedBox(height: 8),
                                _section('Chỉ số đánh giá:', it.chiSoDanhGia),
                                const SizedBox(height: 8),
                                _section('Chu kỳ đánh giá:', _chuKyText(it.chuKy)),
                                const SizedBox(height: 12),

                                // Buttons
                                Row(
                                  children: [
                                    // if (isPICha)
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          // TODO: mở màn hình cấu hình chức danh theo it
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFF22C55E),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('CẤU HÌNH CHỨC DANH', style: TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    // if (isPICha)
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          // TODO: điều hướng xem chi tiết PI
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFF22C55E),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: const Text('XEM CHI TIẾT', style: TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isOpen)
                                      if ((it.chiTietCons?.isNotEmpty ?? false)) ...[
                                        // _label('Chi tiết con:'),
                                        // const SizedBox(height: 5),
                                        for (int j = 0; j < it.chiTietCons!.length; j++)
                                          _ChildPiCard(
                                            index: '${i + 1}.${j + 1}',
                                            childCt: it.chiTietCons![j],
                                            parentCt: it,
                                          ),
                                      ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
                      onTap: data.viTriDuyet == 0 ? () => _showConfirmationDialogInfo(context) : () => openRejectDialog(widget.id),
                      // onTap: () => _saveKPIAndMaybeSend(sendApproval: true),
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

class _ChildPiCard extends StatefulWidget {
  final String index; // ví dụ: "1.1"
  final DanhMucPiChiTietModel childCt;
  final DanhMucPiChiTietModel parentCt;

  const _ChildPiCard({
    super.key,
    required this.index,
    required this.childCt,
    required this.parentCt,
  });

  @override
  State<_ChildPiCard> createState() => _ChildPiCardState();
}

class _ChildPiCardState extends State<_ChildPiCard> {
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

  @override
  Widget build(BuildContext context) {
    final ct = widget.childCt;
    final ctcha = widget.parentCt;
    final (bg, fg, lb) = _statusChip(ct.isSuDung);
    final index = widget.index;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // bóng mờ
            blurRadius: 8, // độ mờ
            offset: const Offset(0, 3), // đổ bóng xuống
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header của card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              // color: (it.isSuDung == true) ? const Color(0xFFFFEBEB) : const Color(0xFFF5F6F7),
              color: Color(0xFFECF4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                // index tròn đỏ
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB91C1C),
                  ),
                  child: Text('$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ct.maSoPI ?? '—',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB91C1C),
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                  child: Text(lb, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Nhóm PI:', ctcha.tenNhomPI),
                const SizedBox(height: 8),

                _section('Chỉ số đánh giá:', ct.chiSoDanhGia),
                const SizedBox(height: 8),
                _section('Chu kỳ đánh giá:', _chuKyText(ctcha.chuKy)),
                const SizedBox(height: 12),

                // Buttons
                Row(
                  children: [
                    // if (isPICha)
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // TODO: điều hướng xem chi tiết PI
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('XEM CHI TIẾT', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _section(String title, String? value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(value == null || value.isEmpty ? '—' : value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}
