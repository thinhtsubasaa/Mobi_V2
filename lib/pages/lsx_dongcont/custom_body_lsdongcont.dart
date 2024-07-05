import 'dart:convert';

import 'package:Thilogi/models/lsxdongcont.dart';
import 'package:Thilogi/models/lsxdieuchuyen.dart';

import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSDongCont extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSDongContScreen());
  }
}

class BodyLSDongContScreen extends StatefulWidget {
  const BodyLSDongContScreen({Key? key}) : super(key: key);

  @override
  _BodyLSDongContScreenState createState() => _BodyLSDongContScreenState();
}

class _BodyLSDongContScreenState extends State<BodyLSDongContScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  bool _loading = false;

  String? id;
  String? KhoXeId;

  List<LSDongContModel>? _dn;
  List<LSDongContModel>? get dn => _dn;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    getDSXDongCont(selectedDate);
  }

  void getDSXDongCont(String? Ngay) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetDanhSachXeDongContAll?Ngay=$Ngay');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString());
        if (decodedData != null) {
          _dn = (decodedData as List)
              .map((item) => LSDongContModel.fromJson(item))
              .toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(picked);
        // Gọi API với ngày đã chọn
        _loading = false;
      });
      print("Selected Date: $selectedDate");
      getDSXDongCont(selectedDate);
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
        width: MediaQuery.of(context).size.width * 2.5,
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
                0: FlexColumnWidth(0.2),
                1: FlexColumnWidth(0.2),
                2: FlexColumnWidth(0.2),
                3: FlexColumnWidth(0.2),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.2),
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
                      color: Colors.red,
                      child: _buildTableCell('Tàu', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Số khung', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Số Cont', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Số Seal', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Họ tên lái xe',
                          textColor: Colors.white),
                    ),
                  ],
                ),
                ..._dn?.map((item) {
                      index++; // Tăng số thứ tự sau mỗi lần lặp

                      return TableRow(
                        children: [
                          // _buildTableCell(index.toString()), // Số thứ tự
                          _buildTableCell(item.gioNhan ?? ""),
                          _buildTableCell(item.bienSo ?? ""),
                          _buildTableCell(item.loaiXe ?? ""),
                          _buildTableCell(item.soKhung ?? ""),
                          _buildTableCell(item.soCont ?? ""),
                          _buildTableCell(item.soSeal ?? ""),
                          _buildTableCell(item.taiXe ?? ""),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Danh sách xe đóng cont',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text(
                                              selectedDate ?? 'Chọn ngày',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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