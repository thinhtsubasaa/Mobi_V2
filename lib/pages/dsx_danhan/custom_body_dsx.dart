import 'dart:convert';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/dsxdanhan.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/models/timxe.dart';
import 'package:Thilogi/pages/timxe/timxe.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

import '../../models/dsxchoxuat.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

import '../timxe/custom_body_timxe.dart';

class CustomBodyDSXDaNhan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSXScreen());
  }
}

class BodyDSXScreen extends StatefulWidget {
  const BodyDSXScreen({Key? key}) : super(key: key);

  @override
  _BodyDSXScreenState createState() => _BodyDSXScreenState();
}

class _BodyDSXScreenState extends State<BodyDSXScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;
  String? id;
  String? KhoXeId;

  List<DS_DaNhanModel>? _dn;
  List<DS_DaNhanModel>? get dn => _dn;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // getDSXDaNhan(id ?? "", selectedDate);

    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    getDSXDaNhan(selectedDate);
  }

  // void getDSXDaNhan(String? id, String? ngay) async {
  //   _dn = [];
  //   try {
  //     final http.Response response = await requestHelper.getData(
  //         'KhoThanhPham/GetDanhSachXeDaNhanAll?LoaiXe_Id=$id&Ngay=$ngay');
  //     if (response.statusCode == 200) {
  //       var decodedData = jsonDecode(response.body);
  //       print("data: " + decodedData);
  //       if (decodedData != null) {
  //         _dn = (decodedData as List)
  //             .map((item) => DS_DaNhanModel.fromJson(item))
  //             .toList();

  //         // Gọi setState để cập nhật giao diện
  //         setState(() {
  //           _loading = false;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     _hasError = true;
  //     _errorCode = e.toString();
  //   }
  // }
  void getDSXDaNhan(String? ngay) async {
    _dn = [];
    print("Date: $ngay");
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetDanhSachXeDaNhanAll?Ngay=$ngay');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " +
            decodedData.toString()); // In dữ liệu nhận được từ API để kiểm tra
        if (decodedData != null) {
          _dn = (decodedData as List)
              .map((item) => DS_DaNhanModel.fromJson(item))
              .toList();
          setState(() {
            _loading =
                false; // Đã nhận được dữ liệu, không còn trong quá trình loading nữa
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
      getDSXDaNhan(selectedDate);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
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
                fontSize: 17,
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
                4: FlexColumnWidth(0.2),
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
                      child: _buildTableCell('Màu xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người nhận',
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
                          _buildTableCell(item.loaiXe ?? ""),
                          _buildTableCell(item.soKhung ?? ""),
                          _buildTableCell(item.mauXe ?? ""),
                          _buildTableCell(item.nguoiNhan ?? ""),
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
                                      'Danh sách xe đã nhận',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 16,
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