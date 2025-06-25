import 'dart:convert';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/lsuracong.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../models/chuyenxe.dart';
import '../../models/lsu_giaoxe.dart';
import '../../services/app_service.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSRaCong extends StatelessWidget {
  final String? maPin;

  CustomBodyLSRaCong({this.maPin});
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSRaCongScreen(maPin: maPin));
  }
}

class BodyLSRaCongScreen extends StatefulWidget {
  final String? maPin;
  const BodyLSRaCongScreen({Key? key, this.maPin}) : super(key: key);

  @override
  _BodyLSRaCongScreenState createState() => _BodyLSRaCongScreenState();
}

class _BodyLSRaCongScreenState extends State<BodyLSRaCongScreen> with TickerProviderStateMixin, ChangeNotifier {
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
  final TextEditingController _textController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  LSX_GiaoXeModel? _data;
  bool _option1 = false;
  bool _option2 = false;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _message;
  String? get message => _message;
  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    print("maPin: ${widget.maPin}");
    getDSXRaCong(selectedDate, widget.maPin ?? "", soKhungController.text);

    // getDSXRaCong(selectedDate, soKhungController.text);
  }

  Future<void> getDSXRaCong(String? ngay, String? maPin, String? keyword) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetDanhSachXeRaCong?Ngay=$ngay&MaPin=$maPin&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dn = (decodedData as List).map((item) => DS_RaCongModel.fromJson(item)).toList();

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
      await getDSXRaCong(selectedDate, widget.maPin ?? "", soKhungController.text);

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> postData(String? xeRaCong_Id, bool? trangThai, String? liDo) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData('Kho/UpdateLSXeRaCong?XeRaCong_Id=$xeRaCong_Id&IsThanhCong=$trangThai&LiDo=$liDo', _data?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Thành công",
            text: "Điều chỉnh xe ra cổng thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              getDSXRaCong(selectedDate, widget.maPin ?? "", soKhungController.text);
            });

        _btnController.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        _btnController.error();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Thất bại',
            text: errorMessage,
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              getDSXRaCong(selectedDate, widget.maPin ?? "", soKhungController.text);
            });
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  _onSave(String? xeRaCong_Id, bool? trangThai, String? liDo) {
    AppService().checkInternet().then((hasInternet) {
      if (!hasInternet!) {
        // openSnackBar(context, 'no internet'.tr());
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
          confirmBtnText: 'Đồng ý',
        );
      } else {
        postData(xeRaCong_Id ?? "", trangThai ?? false, _textController.text).then((_) {
          print("loading: ${_loading}");
          setState(() {
            _loading = false;
          });
        });
      }
    });
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 3.7,
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
              columnWidths: const {
                0: FlexColumnWidth(0.15),
                1: FlexColumnWidth(0.15),
                2: FlexColumnWidth(0.15),
                3: FlexColumnWidth(0.22),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
                6: FlexColumnWidth(0.3),
                7: FlexColumnWidth(0.3),
                8: FlexColumnWidth(0.2),
                9: FlexColumnWidth(0.3),
                10: FlexColumnWidth(0.3),
                11: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Chỉnh sửa', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Chi tiết', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Giờ ra', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Trạng thái', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Biển số', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Số xe đã kiểm tra', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Tên bảo vệ', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Tên tài xế', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Hình ảnh tài xế', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Ghi chú', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Lý do', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child: _buildTableCell('Hình Ảnh', textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.15),
                    1: FlexColumnWidth(0.15),
                    2: FlexColumnWidth(0.15),
                    3: FlexColumnWidth(0.22),
                    4: FlexColumnWidth(0.3),
                    5: FlexColumnWidth(0.3),
                    6: FlexColumnWidth(0.3),
                    7: FlexColumnWidth(0.3),
                    8: FlexColumnWidth(0.2),
                    9: FlexColumnWidth(0.3),
                    10: FlexColumnWidth(0.3),
                    11: FlexColumnWidth(0.3),
                  },
                  children: [
                    ..._dn?.map((item) {
                          index++; // Tăng số thứ tự sau mỗi lần lặp
                          // bool highlightRed = item.tenTaiXe == "-" || item.lyDo != null;
                          return TableRow(
                            decoration: BoxDecoration(
                              color: item.trangThaiChuyenXe == "Đã xác nhận ra cổng"
                                  ? Colors.green.withOpacity(0.3)
                                  : item.trangThaiChuyenXe == "Đã từ chối ra cổng"
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.white, // Màu trắng cho trạng thái Đang kiểm tra hoặc các trạng thái khác
                            ),
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              IconButton(
                                icon: Icon(Icons.edit, color: item.isKiemTra == true ? Colors.red : Colors.grey), // Icon thùng rác
                                onPressed: (item.isKiemTra == true)
                                    ? () => showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                return Scaffold(
                                                  resizeToAvoidBottomInset: false,
                                                  backgroundColor: Colors.transparent,
                                                  body: Center(
                                                    child: Container(
                                                      padding: EdgeInsets.all(20),
                                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Center(
                                                            child: Text(
                                                              "Chỉnh sửa trạng thái chuyến xe",
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(
                                                                fontFamily: 'Comfortaa',
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.w700,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Checkbox(
                                                                value: _option1,
                                                                onChanged: (bool? value) {
                                                                  setState(() {
                                                                    _option1 = value ?? false;
                                                                    if (_option1) {
                                                                      _option2 = false; // Bỏ chọn _option2 khi _option1 được tick
                                                                      print("option, option : $_option1, $_option2");
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              const Text(
                                                                "Xác nhận",
                                                                textAlign: TextAlign.left,
                                                                style: TextStyle(
                                                                  fontFamily: 'Comfortaa',
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.green,
                                                                ),
                                                              ),
                                                              Checkbox(
                                                                value: _option2,
                                                                onChanged: (bool? value) {
                                                                  setState(() {
                                                                    _option2 = value ?? false;
                                                                    if (_option2) {
                                                                      _option1 = false; // Bỏ chọn _option1 khi _option2 được tick
                                                                      print("option, option : $_option1, $_option2");
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              const Text(
                                                                "Từ chối",
                                                                textAlign: TextAlign.left,
                                                                style: TextStyle(
                                                                  fontFamily: 'Comfortaa',
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Text(
                                                            'Vui lòng nhập lí do chỉnh sửa của bạn?',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          TextField(
                                                            controller: _textController,
                                                            onChanged: (text) {
                                                              // Gọi setState để cập nhật giao diện khi giá trị TextField thay đổi
                                                              setState(() {});
                                                            },
                                                            decoration: InputDecoration(
                                                              labelText: 'Nhập lí do',
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 20),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.red,
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();
                                                                  _btnController.reset();
                                                                },
                                                                child: const Text(
                                                                  'Không',
                                                                  style: TextStyle(
                                                                    fontFamily: 'Comfortaa',
                                                                    fontSize: 13,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.green,
                                                                ),
                                                                onPressed: _textController.text.isNotEmpty ? () => _onSave(item.id, _option1, _textController.text) : null,
                                                                child: const Text(
                                                                  'Đồng ý',
                                                                  style: TextStyle(
                                                                    fontFamily: 'Comfortaa',
                                                                    fontSize: 13,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        )
                                    : null,
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.error, // Biểu tượng dấu chấm than
                                    color: Colors.blue,
                                    size: 20, // Kích thước biểu tượng
                                  ),
                                  onPressed: () {
                                    _showDetailsDialog(context, item.chuyenXe ?? []);
                                  },
                                ),
                              ),
                              _buildTableCell(item.gioRa ?? ""),
                              _buildTableCell(
                                item.trangThaiChuyenXe ?? "",
                              ),
                              _buildTableCell(item.bienSo ?? ""),
                              _buildTableCell(item.tongXeDaCheck_TongXe ?? ""),
                              _buildTableCell(item.tenBaoVe ?? ""),
                              _buildTableCell(item.tenTaiXe ?? ""),
                              _buildTableHinhAnh_New(
                                item.hinhAnhTaiXe ?? "",
                              ),
                              _buildTableCell(item.ghiChu ?? ""),
                              _buildTableCell(item.lyDo ?? ""),
                              _buildTableHinhAnh(
                                item.hinhAnh ?? "",
                              ),
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

  void _showDetailsDialog(BuildContext context, List<ChuyenXeModel> items) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero, // Loại bỏ khoảng cách viền
          child: Container(
            width: MediaQuery.of(context).size.width, // Full chiều rộng màn hình
            height: MediaQuery.of(context).size.height, // Full chiều cao màn hình
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Chi tiết chuyến xe',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 4.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Table(
                            border: TableBorder.all(),
                            columnWidths: const {
                              0: FlexColumnWidth(0.3),
                              1: FlexColumnWidth(0.3),
                              2: FlexColumnWidth(0.3),
                              3: FlexColumnWidth(0.3),
                              4: FlexColumnWidth(0.3),
                              5: FlexColumnWidth(0.3),
                              6: FlexColumnWidth(0.3),
                              7: FlexColumnWidth(0.3),
                              8: FlexColumnWidth(0.3),
                              9: FlexColumnWidth(0.3),
                              10: FlexColumnWidth(0.3),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Trạng thái', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Biển số', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Loại xe', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Số khung', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Số máy', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Màu xe', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Nơi đi', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Nơi đến', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Bên vận chuyển', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Tên tài xế', textColor: Colors.white),
                                  ),
                                  Container(
                                    color: Colors.red,
                                    child: _buildTableCell('Bảo vệ kiểm tra', textColor: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Table(
                                border: TableBorder.all(),
                                columnWidths: const {
                                  0: FlexColumnWidth(0.3),
                                  1: FlexColumnWidth(0.3),
                                  2: FlexColumnWidth(0.3),
                                  3: FlexColumnWidth(0.3),
                                  4: FlexColumnWidth(0.3),
                                  5: FlexColumnWidth(0.3),
                                  6: FlexColumnWidth(0.3),
                                  7: FlexColumnWidth(0.3),
                                  8: FlexColumnWidth(0.3),
                                  9: FlexColumnWidth(0.3),
                                  10: FlexColumnWidth(0.3),
                                },
                                children: [
                                  ...items?.map((item) {
                                        return TableRow(
                                          decoration: BoxDecoration(
                                            color: item.trangThaiXe == "Đã hoàn thành kiểm tra" ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                                          ),
                                          children: [
                                            _buildTableCell(item.trangThaiXe ?? ""),
                                            _buildTableCell(item.bienSo ?? ""),
                                            _buildTableCell(item.loaiXe ?? ""),
                                            _buildTableCell(item.soKhung ?? ""),
                                            _buildTableCell(item.soMay ?? ""),
                                            _buildTableCell(item.mauXe ?? ""),
                                            _buildTableCell(item.noiDi ?? ""),
                                            _buildTableCell(item.noiDen ?? ""),
                                            _buildTableCell(item.donViVanChuyen ?? ""),
                                            _buildTableCell(item.tenTaiXe ?? ""),
                                            _buildTableCell(item.baoVeKiemTra ?? ""),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHinhAnh_New(String content, {Color textColor = Colors.black}) {
    List<String> imageUrls = content.split(',');

    // Kiểm tra xem có ảnh nào trong danh sách không
    if (imageUrls.isEmpty) {
      return Container(); // Trả về Container rỗng nếu không có ảnh
    }

    // Lấy ảnh đầu tiên trong danh sách
    String imageUrl = imageUrls[0];

    return GestureDetector(
      onTap: () {
        _showFullImageDialog(imageUrls, 0); // Truyền danh sách ảnh và index 0 (ảnh đầu tiên)
      },
      child: Container(
        width: 70, // Thiết lập chiều rộng của ảnh
        height: 60, // Thiết lập chiều cao của ảnh
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain, // Đảm bảo ảnh không bị méo và có thể điều chỉnh đúng tỷ lệ
        ),
      ),
    );
  }

  Widget _buildTableCell(String content, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SelectableText(
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

  Widget _buildTableHinhAnh(String content, {Color textColor = Colors.black}) {
    List<String> imageUrls = content.split(',');

    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          String imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () {
              _showFullImageDialog(imageUrls, index); // Truyền danh sách ảnh và index hiện tại
            },
            child: Container(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullImageDialog(List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          child: Container(
            // width: screenSize.width * 1,
            height: screenSize.height * 0.7,
            child: PhotoViewGallery.builder(
              itemCount: imageUrls.length,
              pageController: PageController(initialPage: initialIndex),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(imageUrls[index]),
                  // backgroundDecoration: BoxDecoration(color: Colors.black),
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }
  // Widget _buildTableHinhAnh(String content, {Color textColor = Colors.black}) {
  //   // Tách chuỗi URL thành danh sách các link ảnh
  //   List<String> imageUrls = content.split(',');

  //   return Container(
  //     height: 120,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: imageUrls.length,
  //       itemBuilder: (context, index) {
  //         String? imageUrl = imageUrls[index];
  //         return GestureDetector(
  //           onTap: () {
  //             _showFullImageDialog(imageUrl);
  //           },
  //           child: Container(
  //             child: Image.network(
  //               imageUrl,
  //               fit: BoxFit.contain,
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // void _showFullImageDialog(String imageUrl) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: Container(
  //         width: double.infinity,
  //         height: double.infinity,
  //         child: PhotoView(
  //           imageProvider: NetworkImage(imageUrl),
  //           backgroundDecoration: const BoxDecoration(color: Colors.black),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getDSXRaCong(selectedDate, widget.maPin ?? "", soKhungController.text);
      }, // Gọi hàm tải lại dữ liệu
      child: Container(
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blue),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.calendar_today, color: Colors.blue),
                                              const SizedBox(width: 8),
                                              Text(
                                                selectedDate ?? 'Chọn ngày',
                                                style: const TextStyle(color: Colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const Divider(height: 1, color: Color(0xFFA71C20)),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: MediaQuery.of(context).size.height < 600 ? 10.h : 7.h,
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
                                          child: const Center(
                                            child: Text(
                                              "Tìm kiếm",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
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
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                            child: TextField(
                                              controller: soKhungController,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: 'Nhập số khung để tìm kiếm',
                                                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
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
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.search),
                                          onPressed: () {
                                            setState(() {
                                              _loading = true;
                                            });
                                            // Gọi API với từ khóa tìm kiếm
                                            getDSXRaCong(selectedDate, widget.maPin ?? "", soKhungController.text);
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Tổng số chuyến đã thực hiện: ${_dn?.length.toString() ?? ''}',
                                          style: const TextStyle(
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
      ),
    );
  }
}
