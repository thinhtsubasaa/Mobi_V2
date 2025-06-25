import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/kehoachgiaoxe.dart';
import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/services/request_helper_mms.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../../config/config.dart';
import '../../../models/mms/lichsubaoduong_LS.dart';

class CustomBodyDSCaNhanBaoDuong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSCaNhanBaoDuongScreen());
  }
}

class BodyDSCaNhanBaoDuongScreen extends StatefulWidget {
  const BodyDSCaNhanBaoDuongScreen({super.key});

  @override
  _BodyDSCaNhanBaoDuongScreenState createState() => _BodyDSCaNhanBaoDuongScreenState();
}

class _BodyDSCaNhanBaoDuongScreenState extends State<BodyDSCaNhanBaoDuongScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();

  KeHoachGiaoXeModel? _data;

  bool _loading = false;

  String? barcodeScanResult;
  String? viTri;
  late XeRaCongBloc _bl;
  String? _errorCode;
  String? get errorCode => _errorCode;

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  String? id;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  List<String> noiDenList = [];
  List<NoiDenModel>? _noidenList;
  List<NoiDenModel>? get noidenList => _noidenList;
  List<LyDoModel>? _lydoList;
  List<LyDoModel>? get lydoList => _lydoList;
  List<XeRaCongModel>? _xeracongList;
  List<XeRaCongModel>? get xeracongList => _xeracongList;
  late UserBloc? _ub;
  String? bienSo;
  String? selectedDate;

  List<LichSuBaoDuongLSModel>? _kehoachList;
  List<LichSuBaoDuongLSModel>? get kehoachList => _kehoachList;
  List<bool> selectedItems = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);
    getListThayDoiKH(selectedDate, textEditingController.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getListThayDoiKH(String? ngay, String? keyword) async {
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/GetLichSuYeuCauBaoDuongCaNhan?Ngay=$ngay&User_Id=${_ub?.id}&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachList = (decodedData as List).map((item) => LichSuBaoDuongLSModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
            selectedItems = List.filled(_kehoachList?.length ?? 0, false);
          });
        }
      } else {
        _kehoachList = [];
        // Làm sạch danh sách cũ trước khi tải mới
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
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
      await getListThayDoiKH(selectedDate, textEditingController.text);
      // getDSXDaNhan(selectedDate);

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getListThayDoiKH(selectedDate, textEditingController.text);
      },
      child: Container(
        child: Column(
          children: [
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Tổng yêu cầu: ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${_kehoachList?.length.toString() ?? ""}",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
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
                            Container(
                              height: MediaQuery.of(context).size.height < 600 ? 10.h : 6.h,
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
                                    width: 25.w,
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
                                          fontSize: 15,
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
                                        controller: textEditingController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          hintText: 'Nhập biển số để tìm kiếm',
                                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                                      getListThayDoiKH(selectedDate, textEditingController.text);
                                      setState(() {
                                        _loading = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            ListView.builder(
                              shrinkWrap: true, // Đảm bảo danh sách nằm gọn trong SingleChildScrollView
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _kehoachList?.length,
                              itemBuilder: (context, index) {
                                final item = _kehoachList?[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    // color: Color.fromARGB(255, 226, 167, 187),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InfoColumn(
                                        lyDo: item?.lyDo ?? "",
                                        trangThai: item?.trangThai ?? "",
                                        nguoiXacNhan: item?.nguoiXacNhan ?? "",
                                        nguoiYeuCau: item?.nguoiYeuCau ?? "",
                                        bienSo1: item?.bienSo1 ?? "",
                                        soKM: item?.soKM ?? "",
                                        giaTri: item?.giaTri ?? "",
                                        model: item?.model ?? "",
                                        model_Option: item?.model_Option ?? "",
                                        soKM_Adsun: item?.soKM_Adsun ?? "",
                                        ngay: item?.ngay ?? "",
                                      ),
                                    ],
                                  ),
                                );
                              },
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

class InfoColumn extends StatelessWidget {
  final String nguoiXacNhan, trangThai;
  final String nguoiYeuCau;
  final String bienSo1;
  final String model; // Thời gian yêu cầu
  final String lyDo; // Lý do đổi
  final String model_Option, ngay; // Nhà xe
  final String soKM_Adsun, soKM, giaTri;

  const InfoColumn({
    Key? key,
    required this.nguoiXacNhan,
    required this.nguoiYeuCau,
    required this.lyDo,
    required this.ngay,
    required this.bienSo1,
    required this.model,
    required this.model_Option,
    required this.soKM_Adsun,
    required this.soKM,
    required this.giaTri,
    required this.trangThai,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0), // Padding cho toàn bộ cột lớn
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền cho cột lớn
        border: Border.all(color: Colors.grey.shade300), // Viền
        borderRadius: BorderRadius.circular(8), // Bo tròn góc
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Góc trên bên phải: Thời gian yêu cầu
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                ngay,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SelectableText(
            bienSo1, // Nội dung TD
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.red, // Màu xám cho nội dung YC
            ),
          ),
          CustomRichText(
            title: "Người yêu cầu",
            content: nguoiYeuCau,
          ),
          const SizedBox(height: 4),
          CustomRichText(
            title: "Người xác nhận",
            content: nguoiXacNhan,
          ),
          const SizedBox(height: 4),
          // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
          InfoRow(
            title: "Tên loại bảo dưỡng:",
            contentYC: model,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Option_bảo dưỡng:",
            contentYC: model_Option,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Số KM theo Adsun:",
            contentYC: soKM_Adsun,
          ),
          InfoRow(
            title: "Số KM theo xe:",
            contentYC: soKM,
          ),
          InfoRow(
            title: "Số KM đến hạn:",
            contentYC: giaTri,
          ),
          SizedBox(
            height: 4,
          ),
          CustomRichTextTT(
            title: "Trạng thái",
            content: trangThai,
          ),
          SizedBox(
            height: 4,
          ),
          if (trangThai == "Đã từ chối")
            CustomRichText(
              title: "Lý do từ chối",
              content: lyDo,
            ),

          // Hàng nút bấm: TỪ CHỐI và ĐỒNG Ý
        ],
      ),
    );
  }
}

class CustomRichTextTT extends StatelessWidget {
  final String title; // Tiêu đề (ví dụ: Người yêu cầu, Người xác nhận)
  final String content; // Nội dung (ví dụ: tên người yêu cầu, xác nhận)

  const CustomRichTextTT({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "$title: ", // Hiển thị tiêu đề
        style: const TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black, // Màu đen cho tiêu đề
        ),
        children: [
          TextSpan(
            text: content, // Hiển thị nội dung
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: content != "Đã duyệt" ? Colors.red : Colors.green, // Màu xám cho nội dung
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title; // Tiêu đề: "Nhà xe:", "Biển số:", "Tài xế:"
  final String contentYC; // Nội dung yêu cầu (YC): item?.nhaXeYC, item?.bienSoYC, item?.taiXeYC

  const InfoRow({
    Key? key,
    required this.title,
    required this.contentYC,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần Tiêu đề và nội dung YC
        RichText(
          text: TextSpan(
            text: "$title ", // Tiêu đề
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black, // Màu đen cho tiêu đề
            ),
            children: [
              TextSpan(
                text: contentYC, // Nội dung YC
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey, // Màu xám cho nội dung YC
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomRichText extends StatelessWidget {
  final String title; // Tiêu đề (ví dụ: Người yêu cầu, Người xác nhận)
  final String content; // Nội dung (ví dụ: tên người yêu cầu, xác nhận)

  const CustomRichText({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "$title: ", // Hiển thị tiêu đề
        style: const TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black, // Màu đen cho tiêu đề
        ),
        children: [
          TextSpan(
            text: content, // Hiển thị nội dung
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey, // Màu xám cho nội dung
            ),
          ),
        ],
      ),
    );
  }
}
