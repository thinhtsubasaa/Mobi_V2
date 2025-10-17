import 'dart:convert';

import 'package:Thilogi/services/request_helper_kpi.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import '../../../../blocs/user_bloc.dart';
import '../../../../models/checksheet.dart';
import '../../../../models/kpi/chitietdanhgiakpi.dart';
import '../../../../widgets/loading.dart';

class CustomBodyDanhGiaChiTietKPI extends StatelessWidget {
  final String? id;
  CustomBodyDanhGiaChiTietKPI({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyDanhGiaChiTietKPIScreen(
      id: id,
      lstFiles: [],
    ));
  }
}

class BodyDanhGiaChiTietKPIScreen extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyDanhGiaChiTietKPIScreen({super.key, required this.id, required this.lstFiles});

  @override
  _BodyDanhGiaChiTietKPIScreenState createState() => _BodyDanhGiaChiTietKPIScreenState();
}

class _BodyDanhGiaChiTietKPIScreenState extends State<BodyDanhGiaChiTietKPIScreen> with TickerProviderStateMixin, ChangeNotifier {
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

  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController soKMController = TextEditingController();

  ChiTietDanhGiaKPIModel? _data;

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
      print("API: ${requestHelper.API}");
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

  @override
  Widget build(BuildContext context) {
    final d = _data;
    final bullets = _parseNhiemVu(d?.nhiemVu);
    if (d == null) {
      return const Center(
        child: CircularProgressIndicator(), // icon xoay
      );
    }
    return _loading
        ? LoadingWidget(context)
        : RefreshIndicator(
            onRefresh: () async {
              await getListData(widget.id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // THẺ THÔNG TIN NHÂN SỰ
                  _InfoCard(children: [
                    _InfoRow(label: 'Họ và tên', value: d?.tenUser ?? ''),
                    _InfoRow(label: 'Mã nhân viên', value: d?.maUser ?? ''),
                    _InfoRow(label: 'Chức danh', value: d?.tenChucDanh ?? ''),
                    _InfoRow(label: 'Bộ phận', value: d?.tenPhongBan ?? ''),
                    _InfoRow(label: 'Chức vụ', value: d?.tenChucVu ?? ''),
                    _InfoRow(label: 'Đơn vị', value: d?.tenDonViKPI ?? ''),
                    _InfoRow(label: 'Kỳ đánh giá', value: d?.thoiDiem ?? ''),
                  ]),

                  SizedBox(height: 14),

                  // THẺ NHIỆM VỤ
                  _InfoCard(
                    title: 'Nhiệm vụ:',
                    children: [
                      ...bullets.map((t) => _Bullet(text: t)),
                      SizedBox(height: 12),
                      // SizedBox(
                      //   height: 44,
                      //   width: double.infinity,
                      //   child: ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color(0xFFB71C1C), // đỏ đậm
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       elevation: 0,
                      //     ),
                      //     onPressed: () {/* TODO: mở màn hình chỉnh sửa */},
                      //     child: const Text(
                      //       'CHỈNH SỬA',
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontWeight: FontWeight.w800,
                      //         letterSpacing: 0.5,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}

List<String> _parseNhiemVu(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  final lines = raw.replaceAll('\r\n', '\n').split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  return lines.map((e) => e.startsWith('-') ? e.substring(1).trim() : e).toList();
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 16, height: 1.35)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
