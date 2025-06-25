import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/xeracong.dart';

import 'package:flutter/material.dart';

import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../blocs/user_bloc.dart';

import '../../models/giaoxeho.dart';
import '../../models/xuatxeho.dart';

class CustomBodyDSDaXacNhanXuatHoNew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSDaXacNhanXuatHoNewScreen());
  }
}

class BodyDSDaXacNhanXuatHoNewScreen extends StatefulWidget {
  const BodyDSDaXacNhanXuatHoNewScreen({super.key});

  @override
  _BodyDSDaXacNhanXuatHoNewScreenState createState() => _BodyDSDaXacNhanXuatHoNewScreenState();
}

class _BodyDSDaXacNhanXuatHoNewScreenState extends State<BodyDSDaXacNhanXuatHoNewScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

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

  XuatXeHoModel? _kehoachList;
  XuatXeHoModel? get kehoachList => _kehoachList;

  List<bool> selectedItems = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    getListThayDoiKH();

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
      final http.Response response = await requestHelper.getData('LichSuYeuCauXuatXeHo/GetLichSuYeuCauXuatHo_New');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          _kehoachList = XuatXeHoModel(
            id: decodedData['id'],
            soKhung: decodedData['soKhung'],
            nguoiYeuCau: decodedData['nguoiYeuCau'],
            nguoiXacNhan: decodedData['nguoiXacNhan'],
            ngayXuatXe: decodedData['ngayXuatXe'],
            ngayYeuCau: decodedData['ngayYeuCau'],
            noiXuat: decodedData['noiXuat'],
            ngayXacNhan: decodedData['ngayXacNhan'],
            lyDo: decodedData['lyDo'],
            lyDoTuChoi: decodedData['lyDoTuChoi'],
            trangThai: decodedData['trangThai'],
            mauXe: decodedData['mauXe'],
            benVanChuyen: decodedData['benVanChuyen'],
            taiXe: decodedData['taiXe'],
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
                        taiXe: _kehoachList?.taiXe ?? "",
                        benVanChuyen: _kehoachList?.benVanChuyen ?? "",
                        lyDoTC: _kehoachList?.lyDoTuChoi ?? "",
                        trangThai: _kehoachList?.trangThai ?? "",
                        nguoiXacNhan: _kehoachList?.nguoiXacNhan ?? "",
                        nguoiYeuCau: _kehoachList?.nguoiYeuCau ?? "",
                        soKhung: _kehoachList?.soKhung ?? "",
                        ngayYeuCau: _kehoachList?.ngayYeuCau ?? "",
                        lyDo: _kehoachList?.lyDo ?? "",
                        mauXe: _kehoachList?.mauXe ?? "",
                        noiGiao: _kehoachList?.noiXuat ?? "",
                        ngayGiao: _kehoachList?.ngayXuatXe ?? "",
                        ngayXacNhan: _kehoachList?.ngayXacNhan ?? "",
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
  final String ngayYeuCau, ngayXacNhan; // Thời gian yêu cầu
  final String lyDo, lyDoTC; // Lý do đổi
  final String noiGiao, mauXe; // Nhà xe
  final String ngayGiao, benVanChuyen, taiXe;

  const InfoColumn({
    Key? key,
    required this.nguoiXacNhan,
    required this.nguoiYeuCau,
    required this.soKhung,
    required this.ngayYeuCau,
    required this.lyDo,
    required this.noiGiao,
    required this.ngayGiao,
    required this.mauXe,
    required this.trangThai,
    required this.lyDoTC,
    required this.ngayXacNhan,
    required this.benVanChuyen,
    required this.taiXe,
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
                ngayXacNhan,
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
            title: "Màu xe:",
            contentYC: mauXe,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Nơi xuất:",
            contentYC: noiGiao,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Nhà xe:",
            contentYC: benVanChuyen,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Tài xế:",
            contentYC: taiXe,
          ),
          const SizedBox(height: 4),
          InfoRow(
            title: "Ngày xuất:",
            contentYC: ngayGiao,
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
          InfoRow(
            title: "Lý do yêu cầu:",
            contentYC: lyDo,
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
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: title != "Lý do yêu cầu:" ? Colors.grey : Colors.red, // Màu xám cho nội dung YC
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
