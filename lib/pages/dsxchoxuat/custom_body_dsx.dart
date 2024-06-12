import 'dart:convert';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/models/timxe.dart';
import 'package:Thilogi/pages/timxe/timxe.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

import '../../models/dsxchoxuat.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

import '../timxe/custom_body_timxe.dart';

class CustomBodyDSX extends StatelessWidget {
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
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<DS_ChoXuatModel>? _cx;
  List<DS_ChoXuatModel>? get cx => _cx;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
    getBaiXeList(KhoXeId ?? "");
  }

  void getData() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _khoxeList = (decodedData as List)
            .map((item) => KhoXeModel.fromJson(item))
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

  void getBaiXeList(String KhoXeId) async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_BaiXe?khoXe_Id=$KhoXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _baixeList = (decodedData as List)
            .map((item) => BaiXeModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDSXChoXuat(String? id) async {
    _cx = [];
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetDanhSachXeChoXuat?id=$id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          // Lọc dữ liệu chỉ bao gồm các mục có 'isKeHoach' là true
          var filteredData =
              decodedData.where((item) => item['isKeHoach'] == true).toList();
          print("dayaaaa:$filteredData");

          if (filteredData.isNotEmpty) {
            _cx = (filteredData as List)
                .map((item) => DS_ChoXuatModel.fromJson(item))
                .toList();
            print("Updated _cx: $_cx");

            setState(() {
              _loading = false;
            });
          }
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    return Container(
      width: 100.w,
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
              0: FlexColumnWidth(0.35),
              1: FlexColumnWidth(0.35),
              2: FlexColumnWidth(0.18),
              3: FlexColumnWidth(0.12),
            },
            children: [
              TableRow(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    child: _buildTableCell('Loại Xe', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Số Khung', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Vị trí', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell(''),
                  ),
                ],
              ),
              ..._cx?.map((item) {
                    index++; // Tăng số thứ tự sau mỗi lần lặp

                    return TableRow(
                      children: [
                        // _buildTableCell(index.toString()), // Số thứ tự
                        _buildTableCell(item.loaiXe ?? ""),
                        _buildTableCell(item.soKhung ?? ""),
                        _buildTableCell(item.tenViTri ?? ""),
                        Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.remove_red_eye),
                            iconSize: 20.0,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TimXePage(
                                    soKhung: item.soKhung ?? "",
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList() ??
                  [],
              TableRow(
                children: [
                  _buildTableCell('Tổng số', textColor: Colors.red),
                  _buildTableCell(_cx?.length.toString() ?? ''),
                  Container(),
                  Container(),
                ],
              ),
            ],
          ),
        ],
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
                                const Text(
                                  'Danh sách xe chờ xuất',
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFA71C20)),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height <
                                                    600
                                                ? 10.h
                                                : 7.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: const Color(0xFF818180),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 20.w,
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
                                                  "Bãi Xe",
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
                                              child: Container(
                                                  padding: EdgeInsets.only(
                                                      top:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .height <
                                                                  600
                                                              ? 0
                                                              : 5),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton2<String>(
                                                      isExpanded: true,
                                                      items: _baixeList
                                                          ?.map((item) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: item.id,
                                                          child: Container(
                                                            constraints: BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.9),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Text(
                                                                item.tenBaiXe ??
                                                                    "",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'Comfortaa',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppConfig
                                                                      .textInput,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      value: id,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          id = newValue;
                                                        });
                                                        if (newValue != null) {
                                                          getDSXChoXuat(
                                                              newValue);
                                                          print(
                                                              "object : ${id}");
                                                        }
                                                      },
                                                      buttonStyleData:
                                                          const ButtonStyleData(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 16),
                                                        height: 40,
                                                        width: 200,
                                                      ),
                                                      dropdownStyleData:
                                                          const DropdownStyleData(
                                                        maxHeight: 200,
                                                      ),
                                                      menuItemStyleData:
                                                          const MenuItemStyleData(
                                                        height: 40,
                                                      ),
                                                      dropdownSearchData:
                                                          DropdownSearchData(
                                                        searchController:
                                                            textEditingController,
                                                        searchInnerWidgetHeight:
                                                            50,
                                                        searchInnerWidget:
                                                            Container(
                                                          height: 50,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 8,
                                                            bottom: 4,
                                                            right: 8,
                                                            left: 8,
                                                          ),
                                                          child: TextFormField(
                                                            expands: true,
                                                            maxLines: null,
                                                            controller:
                                                                textEditingController,
                                                            decoration:
                                                                InputDecoration(
                                                              isDense: true,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8,
                                                              ),
                                                              hintText:
                                                                  'Tìm bãi xe',
                                                              hintStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        searchMatchFn: (item,
                                                            searchValue) {
                                                          if (item
                                                              is DropdownMenuItem<
                                                                  String>) {
                                                            // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                            String itemId =
                                                                item.value ??
                                                                    "";
                                                            // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                            return _baixeList?.any((baiXe) =>
                                                                    baiXe.id ==
                                                                        itemId &&
                                                                    baiXe.tenBaiXe
                                                                            ?.toLowerCase()
                                                                            .contains(searchValue.toLowerCase()) ==
                                                                        true) ??
                                                                false;
                                                          } else {
                                                            return false;
                                                          }
                                                        },
                                                      ),
                                                      onMenuStateChange:
                                                          (isOpen) {
                                                        if (!isOpen) {
                                                          textEditingController
                                                              .clear();
                                                        }
                                                      },
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      SizedBox(height: 4),
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
