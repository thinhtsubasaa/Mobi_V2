import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/kehoachgiaoxe.dart';
import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../blocs/user_bloc.dart';
import '../../config/config.dart';
import '../../widgets/custom_title.dart';

class CustomBodyDSDaXacNhan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSDaXacNhanScreen());
  }
}

class BodyDSDaXacNhanScreen extends StatefulWidget {
  const BodyDSDaXacNhanScreen({super.key});

  @override
  _BodyDSDaXacNhanScreenState createState() => _BodyDSDaXacNhanScreenState();
}

class _BodyDSDaXacNhanScreenState extends State<BodyDSDaXacNhanScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String _qrData = '';
  final _qrDataController = TextEditingController();
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

  bool _IsTuChoi = false;
  bool _IsXacNhan = false;
  List<String> noiDenList = [];
  List<NoiDenModel>? _noidenList;
  List<NoiDenModel>? get noidenList => _noidenList;
  List<LyDoModel>? _lydoList;
  List<LyDoModel>? get lydoList => _lydoList;
  List<XeRaCongModel>? _xeracongList;
  List<XeRaCongModel>? get xeracongList => _xeracongList;
  late UserBloc? _ub;
  String? bienSo;

  List<KeHoachGiaoXeModel>? _kehoachList;
  List<KeHoachGiaoXeModel>? get kehoachList => _kehoachList;
  List<bool> selectedItems = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    getListThayDoiKH();
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getListThayDoiKH() async {
    setState(() {
      _isLoading = true;
      _kehoachList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('Kho/LichSuThongTinYeuCauThayDoiKH');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachList = (decodedData as List).map((item) => KeHoachGiaoXeModel.fromJson(item)).toList();

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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getListThayDoiKH();
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
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text.rich(
                                //   TextSpan(
                                //     children: [
                                //       const TextSpan(
                                //         text: "Tổng yêu cầu: ",
                                //         style: TextStyle(
                                //           color: Colors.black,
                                //           fontSize: 15,
                                //           fontWeight: FontWeight.w600,
                                //         ),
                                //       ),
                                //       TextSpan(
                                //         text: "${_kehoachList?.length.toString() ?? ""}",
                                //         style: TextStyle(
                                //           color: Colors.red,
                                //           fontSize: 15,
                                //           fontWeight: FontWeight.w600,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
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
                                      InfoColumn1(
                                        lyDoTC: item?.lyDoTuChoi ?? "",
                                        trangThai: item?.trangThai ?? "",
                                        nguoiXacNhan: item?.nguoiXacNhan ?? "",
                                        nguoiYeuCau: item?.nguoiYeuCau ?? "",
                                        soKhung: item?.soKhung ?? "",
                                        ngayYeuCau: item?.ngayYeuCau ?? "",
                                        lyDo: item?.lyDo ?? "",
                                        nhaXeYC: item?.nhaXeYC ?? '',
                                        nhaXeTD: item?.nhaXeTD ?? '',
                                        bienSoYC: item?.bienSoYC ?? '',
                                        bienSoTD: item?.bienSoTD ?? '',
                                        taiXeYC: item?.taiXeYC ?? '',
                                        taiXeTD: item?.taiXeTD ?? '',
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
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 11,
              padding: EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppConfig.bottom,
              ),
              child: Center(
                child: customTitle(
                  'DANH SÁCH ĐÃ XÁC NHẬN',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoColumn1 extends StatelessWidget {
  final String nguoiXacNhan, trangThai;
  final String nguoiYeuCau;
  final String soKhung;
  final String ngayYeuCau; // Thời gian yêu cầu
  final String lyDo, lyDoTC; // Lý do đổi
  final String nhaXeYC, nhaXeTD; // Nhà xe
  final String bienSoYC, bienSoTD; // Biển số
  final String taiXeYC, taiXeTD; // Tài xế

  const InfoColumn1({
    Key? key,
    required this.nguoiXacNhan,
    required this.nguoiYeuCau,
    required this.soKhung,
    required this.ngayYeuCau,
    required this.lyDo,
    required this.nhaXeYC,
    required this.nhaXeTD,
    required this.bienSoYC,
    required this.bienSoTD,
    required this.taiXeYC,
    required this.taiXeTD,
    required this.trangThai,
    required this.lyDoTC,
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
                ngayYeuCau,
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
            soKhung, // Nội dung TD
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey, // Màu xám cho nội dung YC
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
            title: "Nhà xe:",
            contentYC: nhaXeYC,
            contentTD: nhaXeTD,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Biển số:",
            contentYC: bienSoYC,
            contentTD: bienSoTD,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Tài xế:",
            contentYC: taiXeYC,
            contentTD: taiXeTD,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dòng dưới cùng: Lý do đổi
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RichText(
                  text: TextSpan(
                    text: "Lý do đổi: ", // Tiêu đề
                    style: const TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black, // Màu đen cho tiêu đề
                    ),
                    children: [
                      TextSpan(
                        text: lyDo, // Nội dung
                        style: const TextStyle(
                          fontFamily: 'Comfortaa',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red, // Màu đỏ cho lý do
                        ),
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
          CustomRichText(
            title: "Trạng thái",
            content: trangThai,
          ),
          SizedBox(
            height: 4,
          ),
          if (trangThai == "Đã từ chối")
            CustomRichText(
              title: "Lý do từ chối",
              content: lyDoTC,
            ),

          // Hàng nút bấm: TỪ CHỐI và ĐỒNG Ý
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title; // Tiêu đề: "Nhà xe:", "Biển số:", "Tài xế:"
  final String contentYC; // Nội dung yêu cầu (YC): item?.nhaXeYC, item?.bienSoYC, item?.taiXeYC
  final String contentTD; // Nội dung thực tế (TD): item?.nhaXeTD, item?.bienSoTD, item?.taiXeTD

  const InfoRow({
    Key? key,
    required this.title,
    required this.contentYC,
    required this.contentTD,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần Tiêu đề và nội dung YC
        CustomRichText(
          title: "$title ",
          content: contentYC,
        ),

        Row(
          children: [
            Container(
              width: 20, // Độ rộng khung vuông
              height: 20, // Độ cao khung vuông
              decoration: BoxDecoration(
                color: Colors.transparent, // Hoặc màu nền bạn muốn
                border: Border.all(color: Colors.green, width: 1), // Viền
                borderRadius: BorderRadius.circular(4), // Góc bo tròn
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward, // Icon mũi tên
                  color: Colors.green,
                  size: 16, // Kích thước icon
                ),
              ),
            ),
            const SizedBox(width: 3), // Khoảng cách giữa icon và text
            Text(
              contentTD, // Nội dung TD
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
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
