import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/models/listcongviec.dart';
import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/models/xeraconglist.dart';
import 'package:Thilogi/pages/giaoxe/giaoxe.dart';
import 'package:Thilogi/pages/khoxe/khoxe.dart';
import 'package:Thilogi/pages/lsuxeracong/ls_racong.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:Thilogi/widgets/loading_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:image/image.dart' as img;
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/user_bloc.dart';
import '../../config/config.dart';
import '../../services/app_service.dart';
import '../../utils/next_screen.dart';
import '../../widgets/loading.dart';

class CustomBodyCVVanChuyen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyCVVanChuyenScreen(
      lstFiles: [],
    ));
  }
}

class BodyCVVanChuyenScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyCVVanChuyenScreen({super.key, required this.lstFiles});

  @override
  _BodyCVVanChuyenScreenState createState() => _BodyCVVanChuyenScreenState();
}

class _BodyCVVanChuyenScreenState extends State<BodyCVVanChuyenScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  XeRaCongModel? _data;
  List<XeRaCongModel>? _listData;
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
  final TextEditingController _ghiChu = TextEditingController();
  final TextEditingController _noiden = TextEditingController();
  final TextEditingController _lido = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  bool _Isred = false;
  bool _Iskehoach = false;
  List<String> noiDenList = [];
  List<NoiDenModel>? _noidenList;
  List<NoiDenModel>? get noidenList => _noidenList;
  List<LyDoModel>? _lydoList;
  List<LyDoModel>? get lydoList => _lydoList;
  List<XeRaCongModel>? _xeracongList;
  List<XeRaCongModel>? get xeracongList => _xeracongList;
  late UserBloc? _ub;
  XeRaCongListModel? _datalist;
  String? bienSo;

  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();

  List<CongViecModel>? _vanchuyenList;
  List<CongViecModel>? get vanchuyenList => _vanchuyenList;

  @override
  void initState() {
    super.initState();
    getListXeRaCong();
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);
  }

  @override
  void dispose() {
    _lido.dispose();
    _textController.dispose();
    textEditingController.dispose();
    _noiden.dispose();

    super.dispose();
  }

  Future<void> getListXeRaCong() async {
    setState(() {
      _isLoading = true;
      _vanchuyenList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('Kho/GetListCongViec');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _vanchuyenList = (decodedData['dulieu'] as List).map((item) => CongViecModel.fromJson(item)).toList();

          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
          });
        }
      } else {
        _vanchuyenList = [];
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
    final AppBloc ab = context.watch<AppBloc>();
    return RefreshIndicator(
      onRefresh: () async {
        await getListXeRaCong();
      }, // Gọi hàm tải lại dữ liệu
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
                                text: "Tổng xe: ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: "${_vanchuyenList?.length.toString() ?? ""}",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Danh sách các số khung với khả năng mở rộng
                    ListView.builder(
                      shrinkWrap: true, // Đảm bảo danh sách nằm gọn trong SingleChildScrollView
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _vanchuyenList?.length,
                      itemBuilder: (context, index) {
                        final item = _vanchuyenList?[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 226, 167, 187),
                            // border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ), // Màu nền cam cho số khung
                          child: ExpansionTile(
                            shape: Border(),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                  size: 35,
                                ),
                                // Khoảng cách giữa icon và số thứ tự
                                Text(
                                  "${index + 1}.", // Số thứ tự
                                  style: const TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              item?.soKhung ?? "", // Hiển thị số khung
                              style: const TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                nextScreen(
                                    context,
                                    GiaoXePage(
                                      soKhung: item?.soKhung ?? "",
                                    ));
                              },
                            ),
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  // border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Item(
                                      title: 'Loại xe: ',
                                      value: item?.loaiXe ?? "",
                                    ),
                                    Item(
                                      title: 'Màu xe: ',
                                      value: item?.mauXe ?? "",
                                    ),
                                    Item(
                                      title: 'Nơi đi: ',
                                      value: item?.noiDi ?? "",
                                    ),
                                    Item(
                                      title: 'Nơi đến: ',
                                      value: item?.noiDen ?? "",
                                    ),
                                    Item(
                                      title: 'Ngày vận chuyển: ',
                                      value: item?.ngayVanChuyen ?? "",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Để không hiển thị Divider sau mục cuối cùng
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemLX extends StatelessWidget {
  final String title;
  final String? value;

  const ItemLX({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            SelectableText(
              value ?? "",
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item extends StatelessWidget {
  final String title;
  final String? value;

  const Item({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SelectableText(
              value ?? "",
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemLXKH extends StatelessWidget {
  final String title;
  final String? value;

  const ItemLXKH({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.h,
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            SelectableText(
              value ?? "",
              style: const TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
    // Container(
    //   height: 5.h,
    //   child: Center(
    //     child: Row(
    //       children: [
    //         Text(
    //           value ?? "",
    //           style: const TextStyle(
    //             fontFamily: 'Comfortaa',
    //             fontSize: 12,
    //             fontWeight: FontWeight.w700,
    //             color: AppConfig.primaryColor,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

class ItemTaiXe extends StatelessWidget {
  final String title;
  final String? value;

  const ItemTaiXe({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.h,
      child: Row(
        children: [
          SelectableText(
            title,
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF818180),
            ),
          ),
          Text(
            value ?? "",
            style: const TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemTaiXeNoiDen extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const ItemTaiXeNoiDen({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      child: Row(
        children: [
          SelectableText(
            title,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF818180),
            ),
          ),
          Container(
            width: 37.w,
            // Hoặc dùng Flexible

            child: TextFormField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 13.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemNoiden extends StatelessWidget {
  final String title;
  final String? value;
  final ValueChanged<String>? onChanged;

  const ItemNoiden({
    Key? key,
    required this.title,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            SelectableText(
              title,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: value,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                onChanged: onChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemGhiChu extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const ItemGhiChu({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            SelectableText(
              title,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            SizedBox(width: 10), // Khoảng cách giữa title và text field
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none, // Loại bỏ đường viền mặc định
                  hintText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileItem {
  bool? uploaded = false;
  String? file;
  bool? local = true;
  bool? isRemoved = false;

  FileItem({
    required this.uploaded,
    required this.file,
    required this.local,
    required this.isRemoved,
  });
}
