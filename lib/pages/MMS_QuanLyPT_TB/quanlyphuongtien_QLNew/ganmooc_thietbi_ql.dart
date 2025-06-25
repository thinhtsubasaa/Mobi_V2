import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/services/request_helper_mms.dart';
import 'package:Thilogi/widgets/loading.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../../models/checksheet.dart';
import '../../../models/diadiem.dart';
import '../../../models/mms/dsphuongtien.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;

import '../../../utils/delete_dialog.dart';

class CustomBodyGanMoocTB_QL extends StatelessWidget {
  final String? id;
  CustomBodyGanMoocTB_QL({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyGanMoocTB_QLScreen(
      id: id,
      lstFiles: [],
    ));
  }
}

class BodyGanMoocTB_QLScreen extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyGanMoocTB_QLScreen({super.key, required this.id, required this.lstFiles});

  @override
  _BodyGanMoocTB_QLScreenState createState() => _BodyGanMoocTB_QLScreenState();
}

class _BodyGanMoocTB_QLScreenState extends State<BodyGanMoocTB_QLScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelperMMS = RequestHelperMMS();

  final TextEditingController _soKM = TextEditingController();

  String? bienSo;
  List<PhuongTienModel>? _biensoList;
  List<PhuongTienModel>? get biensoList => _biensoList;

  bool _loading = false;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  late UserBloc? _ub;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();
  PhuongTienModel? _phuongtien;
  PhuongTienModel? get phuongtien => _phuongtien;
  PhuongTienModel? _data;
  List<DiaDiemModel>? _dn;
  List<DiaDiemModel>? get dn => _dn;
  List<PhuongTienModel>? _listMooc;
  List<PhuongTienModel>? get listMooc => _listMooc;
  List<PhuongTienModel>? _lichsu;
  List<PhuongTienModel>? get lichsu => _lichsu;
  String? DiaDiem_Id;
  String? PhuongTien2_Id;
  String? lat;
  String? long;
  String? toaDo;
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();
  ValueNotifier<List<FileItem>> lstFilesNotifier = ValueNotifier<List<FileItem>>([]);
  @override
  void initState() {
    super.initState();
    _ub = Provider.of<UserBloc>(context, listen: false);
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
    print("PhuongTien_Id= ${widget.id}");
    getLichSu(widget.id);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> getLichSu(String? id) async {
    _lichsu = [];

    try {
      final http.Response response = await requestHelperMMS.getData('MMS_DS_Mooc/LichSu?PhuongTien_Id=$id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _lichsu = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).toList();
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0;
    const String defaultDate = "1970-01-01 ";
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.2),
                2: FlexColumnWidth(0.2),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.3),
                5: FlexColumnWidth(0.3),
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
                      child: _buildTableCell('Biển số 1', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Mooc', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người thực hiện', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Hình ảnh', textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.45, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.3),
                    1: FlexColumnWidth(0.2),
                    2: FlexColumnWidth(0.2),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.3),
                    5: FlexColumnWidth(0.3),
                  },
                  children: [
                    // Chiều cao cố định
                    ..._lichsu?.map((item) {
                          // index++; // Tăng số thứ tự sau mỗi lần lặp
                          return TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.white, // Nền đỏ nếu đủ điều kiện
                            ),
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              _buildTableCell(item.tinhTrang ?? ""),
                              _buildTableCell(item.bienSo1 ?? ""),
                              _buildTableCell(item.tenMooc ?? ""),
                              _buildTableCell(item.nguoiThucHien ?? ""),
                              _buildTableCell(item.ngay ?? ""),
                              _buildTableHinhAnh(item.hinhAnh ?? ""),
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
      child: SelectableText(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
                  // minScale: PhotoViewComputedScale.contained, // Đảm bảo ảnh hiển thị đầy đủ
                  // maxScale: PhotoViewComputedScale.covered, // Cho phép phóng to vừa đủ nếu cần
                  // initialScale: PhotoViewComputedScale.covered,
                  // backgroundDecoration: BoxDecoration(color: Colors.black),
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc ab = context.watch<UserBloc>();
    return Container(
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
                  _loading
                      ? LoadingWidget(context)
                      : Container(
                          padding: const EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lịch sử gắn/tháo Mooc',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFA71C20)),
                              if ((_lichsu?.isNotEmpty ?? false)) _buildTableOptions(context)
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}

class MyInputWidget extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextStyle textStyle;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.controller,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.h,
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
            width: 27.w,
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
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppConfig.textInput,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 15.sp, bottom: 13),
              child: TextFormField(
                controller: controller,
                style: textStyle,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
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
