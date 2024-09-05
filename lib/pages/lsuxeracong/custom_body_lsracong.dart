import 'dart:convert';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/lsuracong.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSRaCong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSRaCongScreen());
  }
}

class BodyLSRaCongScreen extends StatefulWidget {
  const BodyLSRaCongScreen({Key? key}) : super(key: key);

  @override
  _BodyLSRaCongScreenState createState() => _BodyLSRaCongScreenState();
}

class _BodyLSRaCongScreenState extends State<BodyLSRaCongScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;
  String? id;
  String? KhoXeId;

  List<DS_RaCongModel>? _dn;
  List<DS_RaCongModel>? get dn => _dn;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController soKhungController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    getDSXRaCong(selectedDate, soKhungController.text);
  }

  void getDSXRaCong(String? ngay, String? keyword) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData(
          'KhoThanhPham/GetDanhSachXeRaCong?Ngay=$ngay&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dn = (decodedData as List)
            .map((item) => DS_RaCongModel.fromJson(item))
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
      getDSXRaCong(selectedDate, soKhungController.text);

      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 3,
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
                0: FlexColumnWidth(0.15),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
                7: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Giờ ra', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Số Khung', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child:
                          _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Tên tài xế',
                          textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Tên bảo vệ',
                          textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child:
                          _buildTableCell('Nơi đến', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child:
                          _buildTableCell('Ghi chú', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Lý do', textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height:
                  MediaQuery.of(context).size.height * 0.7, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FlexColumnWidth(0.15),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.3),
                    5: FlexColumnWidth(0.3),
                    6: FlexColumnWidth(0.3),
                    7: FlexColumnWidth(0.3),
                  },
                  children: [
                    ..._dn?.map((item) {
                          index++; // Tăng số thứ tự sau mỗi lần lặp

                          return TableRow(
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              _buildTableCell(item.gioRa ?? ""),
                              _buildTableCell(item.soKhung ?? ""),
                              _buildTableCell(item.loaiXe ?? ""),
                              _buildTableCell(item.tenTaiXe ?? ""),
                              _buildTableCell(item.tenBaoVe ?? ""),
                              _buildTableCell(item.noiDen ?? ""),
                              _buildTableCell(item.ghiChu ?? ""),
                              _buildTableCell(item.lyDo ?? ""),
                            ],
                          );
                        }).toList() ??
                        [],
                  ],
                ),
              ),
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
          fontSize: 11,
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
                                      'Danh sách xe ra cổng',
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
                                const SizedBox(height: 4),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height < 600
                                          ? 10.h
                                          : 7.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: const Color(0xFFBC2925),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30.w,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF6C6C7),
                                          border: Border(
                                            right: BorderSide(
                                              color: Color(0xFF818180),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Tìm kiếm",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: AppConfig.textInput,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      600
                                                  ? 0
                                                  : 5),
                                          child: TextField(
                                            controller: soKhungController,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              hintText:
                                                  'Nhập số khung để tìm kiếm',
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 15),
                                            ),
                                            style: const TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.search),
                                        onPressed: () {
                                          setState(() {
                                            _loading = true;
                                          });
                                          // Gọi API với từ khóa tìm kiếm

                                          getDSXRaCong(selectedDate,
                                              soKhungController.text);

                                          setState(() {
                                            _loading = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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
