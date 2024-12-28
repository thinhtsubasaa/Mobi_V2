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
import '../../models/kehoachgiaoxe_ls.dart';
import '../../widgets/custom_title.dart';

class CustomBodyDSDaXacNhanDiGapNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSDaXacNhanDiGapNewScreen());
  }
}

class BodyDSDaXacNhanDiGapNewScreen extends StatefulWidget {
  const BodyDSDaXacNhanDiGapNewScreen({super.key});

  @override
  _BodyDSDaXacNhanDiGapNewScreenState createState() => _BodyDSDaXacNhanDiGapNewScreenState();
}

class _BodyDSDaXacNhanDiGapNewScreenState extends State<BodyDSDaXacNhanDiGapNewScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String _qrData = '';
  final _qrDataController = TextEditingController();

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

  KeHoachGiaoXeLSModel? _kehoachList;
  KeHoachGiaoXeLSModel? get kehoachList => _kehoachList;

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
      _kehoachList = null;
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('XeDiGap/GetLichSuYeuCauDiGap_New');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          _kehoachList = KeHoachGiaoXeLSModel(
            id: decodedData['id'],
            soKhung: decodedData['soKhung'],
            nguoiYeuCau: decodedData['nguoiYeuCau'],
            nguoiXacNhan: decodedData['nguoiXacNhan'],
            ngayXacNhan: decodedData['ngayXacNhan'],
            ngayYeuCau: decodedData['ngayYeuCau'],
            nhaXeYC: decodedData['nhaXeYC'],
            nhaXeTD: decodedData['nhaXeTD'],
            bienSoYC: decodedData['bienSoYC'],
            bienSoTD: decodedData['bienSoTD'],
            taiXeYC: decodedData['taiXeYC'],
            taiXeTD: decodedData['taiXeTD'],
            lyDo: decodedData['lyDo'],
            lyDoTuChoi: decodedData['lyDoTuChoi'],
            trangThai: decodedData['trangThai'],
            noidi: decodedData['noidi'],
            noiden: decodedData['noiden'],
            benVanChuyen: decodedData['benVanChuyen'],
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
                        lyDoTC: _kehoachList?.lyDoTuChoi ?? "",
                        trangThai: _kehoachList?.trangThai ?? "",
                        nguoiXacNhan: _kehoachList?.nguoiXacNhan ?? "",
                        nguoiYeuCau: _kehoachList?.nguoiYeuCau ?? "",
                        soKhung: _kehoachList?.soKhung ?? "",
                        ngayYeuCau: _kehoachList?.ngayXacNhan ?? "",
                        lyDo: _kehoachList?.lyDo ?? "",
                        mauXe: _kehoachList?.mauXe ?? "",
                        noidi: _kehoachList?.noidi ?? "",
                        noiden: _kehoachList?.noiden ?? "",
                        benvanchuyen: _kehoachList?.benVanChuyen ?? "",
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
  final String soKhung;
  final String ngayYeuCau; // Thời gian yêu cầu
  final String lyDo, lyDoTC; // Lý do đổi
  final String noidi, noiden, benvanchuyen, mauXe; // Nhà xe

  const InfoColumn({
    Key? key,
    required this.nguoiXacNhan,
    required this.nguoiYeuCau,
    required this.soKhung,
    required this.ngayYeuCau,
    required this.lyDo,
    required this.noidi,
    required this.noiden,
    required this.benvanchuyen,
    required this.mauXe,
    required this.trangThai,
    required this.lyDoTC,
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
              color: Colors.red, // Màu xám cho nội dung YC
            ),
          ),

          // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
          InfoRow(
            title: "Màu xe:",
            contentYC: mauXe,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Bên vân chuyển:",
            contentYC: benvanchuyen,
          ),

          const SizedBox(height: 4),
          InfoRow(
            title: "Nơi đi:",
            contentYC: noidi,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Nơi đến:",
            contentYC: noiden,
          ),
          const SizedBox(height: 4),
          CustomRichText(
            title: "Người yêu cầu",
            content: nguoiYeuCau,
          ),
          const SizedBox(height: 4),
          CustomRichText(
            title: "Người xác nhận",
            content: nguoiXacNhan,
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
              color: content != "Đã đồng ý" ? Colors.red : Colors.green, // Màu xám cho nội dung
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