import 'dart:convert';

import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/dsxdanhan.dart';
import 'package:Thilogi/models/lsxnhapbai.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSNhapBai extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSNhapBaiScreen());
  }
}

class BodyLSNhapBaiScreen extends StatefulWidget {
  const BodyLSNhapBaiScreen({Key? key}) : super(key: key);

  @override
  _BodyLSNhapBaiScreenState createState() => _BodyLSNhapBaiScreenState();
}

class _BodyLSNhapBaiScreenState extends State<BodyLSNhapBaiScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;
  String? id;
  String? KhoXeId;

  List<LSX_NhapBaiModel>? _dn;
  List<LSX_NhapBaiModel>? get dn => _dn;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDSXNhapBai();
  }

  void getDSXNhapBai() async {
    _dn = [];
    try {
      final http.Response response =
          await requestHelper.getData('KhoThanhPham/GetDanhSachXeNhapBai');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dn = (decodedData as List)
            .map((item) => LSX_NhapBaiModel.fromJson(item))
            .toList();

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

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    // _dn?.sort((a, b) => DateTime.parse(b.gioNhan ?? "")
    //     .compareTo(DateTime.parse(a.gioNhan ?? "")));
    const String defaultDate = "1970-01-01 ";

    // Sắp xếp danh sách _dn theo giờ nhận mới nhất
    _dn?.sort((a, b) {
      try {
        DateTime aTime = DateFormat("yyyy-MM-dd HH:mm")
            .parse(defaultDate + (a.gioNhan ?? "00:00"));
        DateTime bTime = DateFormat("yyyy-MM-dd HH:mm")
            .parse(defaultDate + (b.gioNhan ?? "00:00"));
        return bTime.compareTo(aTime); // Sắp xếp giảm dần
      } catch (e) {
        // Xử lý lỗi khi không thể phân tích cú pháp chuỗi thời gian
        return 0;
      }
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Giờ nhận', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child:
                          _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Số Khung', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Nơi nhập', textColor: Colors.white),
                    ),
                  ],
                ),
                ..._dn?.map((item) {
                      index++; // Tăng số thứ tự sau mỗi lần lặp

                      return TableRow(
                        children: [
                          // _buildTableCell(index.toString()), // Số thứ tự
                          _buildTableCell(item.gioNhan ?? ""),
                          _buildTableCell(item.loaiXe ?? ""),
                          _buildTableCell(item.soKhung ?? ""),
                          _buildTableCell(item.noiNhap ?? ""),
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

  Widget _buildTableCell(String content, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 5),
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
                    _loading
                        ? LoadingWidget(context)
                        : Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Danh sách xe đã nhập ',
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFA71C20)),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Tổng số xe đã thực hiện: ${_dn?.length.toString() ?? ''}',
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      _buildTableOptions(context),
                                    ],
                                  ),
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
    );
  }
}
