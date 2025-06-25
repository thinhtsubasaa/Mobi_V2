import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/services/request_helper_mms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../../blocs/user_bloc.dart';
import '../../../models/mms/lichsubaoduong_LS.dart';

class CustomBodyDSDaXacNhanBaoDuongNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSDaXacNhanBaoDuongNewScreen());
  }
}

class BodyDSDaXacNhanBaoDuongNewScreen extends StatefulWidget {
  const BodyDSDaXacNhanBaoDuongNewScreen({super.key});

  @override
  _BodyDSDaXacNhanBaoDuongNewScreenState createState() => _BodyDSDaXacNhanBaoDuongNewScreenState();
}

class _BodyDSDaXacNhanBaoDuongNewScreenState extends State<BodyDSDaXacNhanBaoDuongNewScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();

  bool _loading = false;

  String? barcodeScanResult;
  String? viTri;
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
  LichSuBaoDuongLSModel? _kehoachList;
  LichSuBaoDuongLSModel? get kehoachList => _kehoachList;

  List<bool> selectedItems = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    getListThayDoiKH();
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
      _kehoachList = null;
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/GetLichSuYeuCauBaoDuong_New?User_Id=${_ub?.id}');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          _kehoachList = LichSuBaoDuongLSModel(
            id: decodedData['id'],
            nguoiYeuCau: decodedData['nguoiYeuCau'],
            nguoiXacNhan: decodedData['nguoiXacNhan'],
            ngayXacNhan: decodedData['ngayXacNhan'],
            bienSo1: decodedData['bienSo1'],
            model: decodedData['model'],
            model_Option: decodedData['model_Option'],
            soKM: decodedData['soKM'],
            soKM_Adsun: decodedData['soKM_Adsun'],
            giaTri: decodedData['giaTri'],
            lyDo: decodedData['lyDo'],
            trangThai: decodedData['trangThai'],
          );
          setState(() {
            _loading = false;
          });
        }
      } else {
        _kehoachList = null;
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
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoColumn(
                        lyDo: _kehoachList?.lyDo ?? "",
                        trangThai: _kehoachList?.trangThai ?? "",
                        nguoiXacNhan: _kehoachList?.nguoiXacNhan ?? "",
                        nguoiYeuCau: _kehoachList?.nguoiYeuCau ?? "",
                        bienSo1: _kehoachList?.bienSo1 ?? "",
                        soKM: _kehoachList?.soKM ?? "",
                        giaTri: _kehoachList?.giaTri ?? "",
                        model: _kehoachList?.model ?? "",
                        model_Option: _kehoachList?.model_Option ?? "",
                        soKM_Adsun: _kehoachList?.soKM_Adsun ?? "",
                        ngay: _kehoachList?.ngay ?? "",
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

          // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
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
