import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/kehoach.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper_mms.dart';
import 'package:Thilogi/widgets/loading.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import '../../../models/checksheet.dart';
import '../../../models/mms/dsphuongtien.dart';
import '../../../models/mms/hangmuc.dart';
import '../../../models/mms/lichsuhangngay.dart';
import '../../../utils/delete_dialog.dart';

class CustomBodyNhapKM extends StatelessWidget {
  final String? id;
  CustomBodyNhapKM({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyNhapKMScreen(
      id: id,
      lstFiles: [],
    ));
  }
}

class BodyNhapKMScreen extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyNhapKMScreen({super.key, required this.id, required this.lstFiles});

  @override
  _BodyNhapKMScreenState createState() => _BodyNhapKMScreenState();
}

class _BodyNhapKMScreenState extends State<BodyNhapKMScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelperMMS = RequestHelperMMS();

  final TextEditingController _soKM = TextEditingController();

  String? bienSo;
  List<PhuongTienModel>? _biensoList;
  List<PhuongTienModel>? get biensoList => _biensoList;

  LichSuKiemTraModel? _data;
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
  List<HangMucModel>? _hangmucList;
  List<HangMucModel>? get hangmucList => _hangmucList;
  List<dynamic> _selectedItems = [];
  List<dynamic> _unselectedItems = [];
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();

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
    getHangMuc();
    textEditingController.addListener(() {
      setState(() {}); // Cập nhật lại giao diện
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future imageSelector(BuildContext context, String pickerType) async {
    if (pickerType == "gallery") {
      // Chọn nhiều ảnh từ thư viện
      List<Asset> resultList = <Asset>[];

      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 100, // Số lượng ảnh tối đa bạn có thể chọn
          enableCamera: false, // Bật tính năng chụp ảnh nếu cần
          selectedAssets: [], // Các ảnh đã chọn (nếu có)
          materialOptions: const MaterialOptions(
            actionBarTitle: "Chọn ảnh",
            allViewTitle: "Tất cả ảnh",
            useDetailsView: false,
            selectCircleStrokeColor: "#000000",
          ),
        );

        if (resultList.isNotEmpty) {
          // Thêm các ảnh đã chọn vào danh sách _lstFiles

          for (var asset in resultList) {
            ByteData byteData = await asset.getByteData();
            List<int> imageData = byteData.buffer.asUint8List();

            // Lưu ảnh vào thư mục tạm
            final tempDir = await getTemporaryDirectory();
            final file = await File('${tempDir.path}/${asset.name}').create();
            file.writeAsBytesSync(imageData);

            print('file: ${file.path}');
            setState(() {
              _lstFiles.add(FileItem(
                uploaded: false,
                file: file.path, // Đường dẫn file tạm
                local: true,
                isRemoved: false,
              ));
            });
          }
        }
      } on Exception catch (e) {
        print("error:$e");
      }
    } else if (pickerType == "camera") {
      // Sử dụng image_picker để chụp ảnh từ camera
      _pickedFile = await _picker.getImage(source: ImageSource.camera);

      if (_pickedFile != null) {
        setState(() {
          _lstFiles.add(FileItem(
            uploaded: false,
            file: _pickedFile!.path,
            local: true,
            isRemoved: false,
          ));
        });
      }
    }
  }

  // Upload image to server and return path(url)
  Future<void> _uploadAnh() async {
    for (var fileItem in _lstFiles) {
      if (fileItem!.uploaded == false && fileItem.isRemoved == false) {
        setState(() {
          _loading = true;
        });
        File file = File(fileItem.file!);
        var response = await RequestHelperMMS().uploadFile(file);
        widget.lstFiles.add(CheckSheetFileModel(
          isRemoved: response["isRemoved"],
          id: response["id"],
          fileName: response["fileName"],
          path: response["path"],
        ));
        fileItem.uploaded = true;
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _allowUploadFile() {
    var item = _lstFiles.firstWhere(
      (file) => file!.uploaded == false,
      orElse: () => null,
    );
    if (item == null) {
      return false;
    }
    return true;
  }

  _removeImage(FileItem image) {
    // find and remove
    // if don't have
    setState(() {
      _lstFiles.removeWhere((img) => img!.file == image.file);
      // check item exists in widget.lstFiles
      if (image.local == true) {
        widget.lstFiles.removeWhere((img) => img!.path == image.file);
      } else {
        widget.lstFiles.map((file) {
          if (file!.path == image.file) {
            file.isRemoved = true;
            return file;
          }
        }).toList();
      }

      Navigator.pop(context);
    });
  }

  bool _isEmptyLstFile() {
    var isRemoved = false;
    if (_lstFiles.isEmpty) {
      isRemoved = true;
    } else {
      // find in list don't have isRemoved = false and have isRemoved = true
      var tmp = _lstFiles.firstWhere((file) => file!.isRemoved == false, orElse: () => null);
      if (tmp == null) {
        isRemoved = true;
      }
    }
    return isRemoved;
  }

  Future<void> getHangMuc() async {
    _loading = true;
    try {
      final http.Response response = await requestHelperMMS.getData('MMS_DM_HangMuc/KiemTraThuongXuyen');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _hangmucList = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
        print("datahangmuc:${_hangmucList.toString()}");
        setState(() {
          _selectedItems = List.from(_hangmucList ?? []);
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("datahangmuc:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> postData(String? phuongTien_Id, int? soKM, String? tinhTrang, String? ghiChu, String? file) async {
    try {
      final http.Response response = await requestHelperMMS.postData('MMS_DS_PhuongTien/UpdateDS?PhuongTien_Id=$phuongTien_Id&SoKM=$soKM&TinhTrang=$tinhTrang&GhiChu=$ghiChu&NguoiKiemTra=${_ub?.name} - ${_ub?.maNhanVien}&HinhAnh=$file', _data?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: "Thêm thành công",
          confirmBtnText: 'Đồng ý',
        );
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
        );
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<File> compressImage(File file) async {
    setState(() {
      _loading = true;
    });
    print("1");
    final bytes = await file.readAsBytes();
    final String extension = file.path.split('.').last.toLowerCase();
    CompressFormat format;

    // Xác định định dạng dựa trên phần mở rộng của tệp
    switch (extension) {
      case 'png':
        format = CompressFormat.png; // Định dạng PNG
        break;

      case 'jpeg':
        format = CompressFormat.jpeg; // Định dạng JPEG
        break;

      case 'jpg':
        format = CompressFormat.jpeg; // Định dạng JPG cũng coi như JPEG
        break;

      default:
        throw Exception('Unsupported file format'); // Nếu không hỗ trợ
    }

    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 800,
        quality: 90,
        format: format, // Sử dụng định dạng đã xác định
      );

      final newFile = File(file.path)..writeAsBytesSync(compressedBytes);
      return newFile;
    } catch (e) {
      print("Error compressing image: $e"); // Ghi log lỗi
      return file; // Trả về tệp gốc nếu gặp lỗi
    }
  }

  _onSave() async {
    setState(() {
      _loading = true;
    });
    List<String> imageUrls = [];

    for (var fileItem in _lstFiles) {
      if (fileItem?.uploaded == false && fileItem?.isRemoved == false) {
        File file = File(fileItem!.file!);

        if (file.existsSync()) {
          file = await compressImage(file);
        }

        var response = await RequestHelperMMS().uploadFile(file);
        print("Response: $response");
        if (response != null) {
          widget.lstFiles.add(CheckSheetFileModel(
            isRemoved: response["isRemoved"],
            id: response["id"],
            fileName: response["fileName"],
            path: response["path"],
          ));
          fileItem.uploaded = true;
          setState(() {
            _loading = false;
          });
          fileItem.uploaded = true;

          if (response["path"] != null) {
            imageUrls.add(response["path"]);
          }
          // } else if (fileItem?.uploaded == true && fileItem?.file != null) {
          //   imageUrls.add(fileItem.path!); // Nếu đã upload trước đó, chỉ thêm URL
        }
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
    print("image:$imageUrlsString");
    if (_data == null) {
      _data = LichSuKiemTraModel(); // Đảm bảo _data không bị null
    }
    if (textEditingController.text.isEmpty) {
      print("Lỗi: _soKM đang null hoặc rỗng");
      return;
    }
    _data?.phuongTien_Id = widget.id;
    print("SoKM:${textEditingController.text}");
    print("select:${_unselectedItems}");
    if (_unselectedItems.isNotEmpty) {
      _data?.tinhTrang = "Cần kiểm tra";
      _data?.ghiChu = _unselectedItems.map((item) => item.noiDungBaoDuong).join(", ");
    } else {
      _data?.tinhTrang = "OK";
    }
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
        postData(widget.id ?? "", int.parse(textEditingController.text), _data?.tinhTrang ?? "", _data?.ghiChu ?? "", imageUrlsString).then((_) {
          setState(() {
            textEditingController.text = '';
            _lstFiles.clear();
            _data = null;
            _loading = false;
            bienSo = null;
            _unselectedItems.clear();
          });
        });
      }
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn nhập số KM không?',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: const TextStyle(
          color: Colors.red,
          fontSize: 19.0,
          fontWeight: FontWeight.bold,
        ),
        onCancelBtnTap: () {
          Navigator.of(context).pop();
          _btnController.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _onSave();
        });
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
                                'Thông Tin Nhập',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFA71C20)),
                              const SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyInputWidget(
                                    title: 'Số KM',
                                    controller: textEditingController,
                                    textStyle: const TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                  Container(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          const Text(
                                            'Hạng mục kiểm tra hằng ngày',
                                            style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: _hangmucList?.length ?? 0,
                                            itemBuilder: (context, i) {
                                              var item = _hangmucList?[i];
                                              bool isChecked = _selectedItems.contains(item);
                                              return CheckboxListTile(
                                                title: Text(
                                                  item?.noiDungBaoDuong ?? "",
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                                // subtitle: Text('Định mức: ${item?.dinhMuc2}'),
                                                value: isChecked,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      _selectedItems.add(item);
                                                      _unselectedItems.remove(item);
                                                    } else {
                                                      _selectedItems.remove(item);
                                                      _unselectedItems.add(item);
                                                    }
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(right: 5),
                                            padding: const EdgeInsets.only(left: 10, right: 10),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.87),
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        ElevatedButton.icon(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.orangeAccent,
                                                          ),
                                                          onPressed: () => imageSelector(context, 'gallery'),
                                                          icon: const Icon(Icons.photo_library),
                                                          label: const Text(""),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        ElevatedButton.icon(
                                                          style: ElevatedButton.styleFrom(
                                                              // backgroundColor: Theme.of(context).primaryColor,
                                                              ),
                                                          onPressed: () => imageSelector(context, 'camera'),
                                                          icon: const Icon(Icons.camera_alt),
                                                          label: const Text(""),
                                                        ),
                                                        const SizedBox(width: 10),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "Ảnh đã chọn",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                if (_isEmptyLstFile())
                                                  const SizedBox(
                                                    height: 100,
                                                    // child: Center(child: Text("Chưa có ảnh nào")),
                                                  ),
                                                // Display list image
                                                ResponsiveGridRow(
                                                  children: _lstFiles.map((image) {
                                                    if (image!.isRemoved == false) {
                                                      return ResponsiveGridCol(
                                                        xs: 6,
                                                        md: 3,
                                                        child: InkWell(
                                                          onLongPress: () {
                                                            deleteDialog(
                                                              context,
                                                              "Bạn có muốn xoá ảnh này? Việc xoá sẽ không thể quay lại.",
                                                              "Xoá ảnh",
                                                              () => _removeImage(image),
                                                            );
                                                          },
                                                          child: Container(
                                                            margin: const EdgeInsets.only(left: 5),
                                                            child: image.local == true
                                                                ? Image.file(File(image.file!))
                                                                : Image.network(
                                                                    '${ab.apiUrl2}/${image.file}',
                                                                    errorBuilder: ((context, error, stackTrace) {
                                                                      return Container(
                                                                        height: 100,
                                                                        decoration: BoxDecoration(
                                                                          border: Border.all(color: Colors.redAccent),
                                                                        ),
                                                                        child: const Center(
                                                                            child: Text(
                                                                          "Error Image (404)",
                                                                          style: TextStyle(color: Colors.redAccent),
                                                                        )),
                                                                      );
                                                                    }),
                                                                  ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return ResponsiveGridCol(
                                                      child: const SizedBox.shrink(),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundedLoadingButton(
                controller: _btnController,
                onPressed: textEditingController.text.isNotEmpty ? () => _showConfirmationDialog(context) : null,
                child: const Text('Lưu',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      color: AppConfig.textButton,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
              ),
            ],
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
