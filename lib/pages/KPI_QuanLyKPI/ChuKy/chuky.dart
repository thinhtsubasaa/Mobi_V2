import 'dart:convert';
import 'dart:io';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:sizer/sizer.dart';
import '../../../blocs/user_bloc.dart';
import '../../../models/kpi/chuky.dart';
import '../../../services/request_helper_kpi.dart';

class ChuKyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Chữ ký'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomBodyChuKy(),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBodyChuKy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyChuKyScreen(
      lstFiles: [],
    ));
  }
}

class BodyChuKyScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyChuKyScreen({super.key, required this.lstFiles});

  @override
  _BodyChuKyScreenState createState() => _BodyChuKyScreenState();
}

class _BodyChuKyScreenState extends State<BodyChuKyScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperKPI requestHelper = RequestHelperKPI();
  late UserBloc? ub;
  late AppBloc? ab;
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();
  String? imageUrl;
  late bool _loading = false;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _errorCode;
  String? get errorCode => _errorCode;
  ChuKyModel? _data;
  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  ChuKyModel? _chuky;
  ChuKyModel? get chuky => _chuky;
  bool enable = false;

  @override
  void initState() {
    super.initState();
    ub = Provider.of<UserBloc>(context, listen: false);
    ab = Provider.of<AppBloc>(context, listen: false);

    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
    _onScan();
  }

  _onScan() async {
    setState(() {
      _loading = true;
    });
    await getData().then((_) {
      setState(() {
        if (chuky == null) {
          _loading = false;
        } else {
          _loading = false;
          _data = chuky;
          print("datachuky:${_data?.hinhAnhChuKySo}");
        }
      });
    });
  }

  Future<void> getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final http.Response response = await requestHelper.getData('Account/vptq-chu-ky-so');
      ;
      print("data5:${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _chuky = ChuKyModel(
            hinhAnhChuKySo: decodedData['hinhAnhChuKySo'],
            user_Id: decodedData['user_Id'],
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        // openSnackBar(context, errorMessage);
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: 'Hệ thống',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future imageSelector(BuildContext context, String pickerType) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        _pickedFile = await _picker.getImage(source: ImageSource.gallery);
        break;

      case "camera":

        /// CAMERA CAPTURE CODE
        _pickedFile = await _picker.getImage(source: ImageSource.camera);
        break;
    }

    if (_pickedFile != null) {
      setState(() {
        _lstFiles.add(FileItem(
          uploaded: false,
          file: _pickedFile!.path,
          local: true,
          isRemoved: false,
        ));

        _loading = true;
        enable = true;
      });
    }
  }

  String buildQuery(Map<String, dynamic> params) {
    // loại bỏ null / rỗng
    params.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
    // tất cả value -> String
    final qp = params.map((k, v) => MapEntry(k, v.toString()));
    return Uri(queryParameters: qp).query; // "a=1&b=x"
  }

  Future<void> postChuKy(
    String? hinhAnhChuKySo,
    bool? isDelete,
  ) async {
    try {
      setState(() => _isLoading = true);

      final q = buildQuery({
        'HinhAnhChuKySo': hinhAnhChuKySo,
        'IsDelete': isDelete,
      });
      final http.Response response = await requestHelper.putData('Account/vptq-chu-ky-so${q.isEmpty ? '' : '?$q'}', null);
      if (response.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: isDelete == true ? "Xoá chữ ký số thành công!" : "Cập nhật chữ ký số thành công",
          confirmBtnText: 'Đồng ý',
        );
        if (isDelete == true) {
          setState(() {
            // xoá local ngay để UI cập nhật liền
            _data = null;
            _chuky = null;
            _lstFiles.clear();
          });
        }
        _onScan();
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: response.body.replaceAll('"', ''),
          confirmBtnText: 'Đồng ý',
        );
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<File?> compressImage(File file) async {
    setState(() {
      _loading = true;
    });
    print("1");

    final bytes = await file.readAsBytes();
    String extension = file.path.split('.').last.toLowerCase();
    if (extension == 'heic' || extension == 'heif') {
      final jpgPath = await HeicToJpg.convert(file.path);
      if (jpgPath != null) {
        file = File(jpgPath);
        extension = 'jpg';
      } else {
        print("Không thể convert HEIC, gửi file gốc");
      }
    }
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
        print("loại file: ${extension}");
        // throw Exception('Unsupported file format'); // Nếu không hỗ trợ
        return null;
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

  void _showConfirmationDialog(BuildContext context, bool isDelete) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: isDelete ? 'Bạn có muốn xoá chữ ký không?' : 'Bạn có muốn lưu chữ ký không?',
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
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _onSave(isDelete);
        });
  }

  _onSave(bool isDelete) async {
    setState(() {
      _loading = true;
    });
    List<String> imageUrls = [];
    String? imageUrlsString;
    if (isDelete == false) {
      for (var fileItem in _lstFiles) {
        if (fileItem?.uploaded == false && fileItem?.isRemoved == false) {
          File file = File(fileItem!.file!);
          // if (file.existsSync()) {
          //   file = await compressImage(file);
          // }
          if (file.existsSync()) {
            if (file.path.toLowerCase().endsWith(".mov") || file.path.toLowerCase().endsWith(".mp4")) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.info,
                title: 'Lỗi',
                text: 'Không thể gửi ảnh dạng Live Photo. Vui lòng chọn ảnh tĩnh',
              );
              // _btnController.reset(); // Bỏ qua file lỗi
              setState(() {
                _loading = false;
              });
              return;
            } else {
              final convertedOrCompressed = await compressImage(file);
              if (convertedOrCompressed == null) {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.info,
                  title: 'Định dạng không hỗ trợ',
                  text: 'Ảnh HEIC không đọc được. Vui lòng chọn JPG/PNG.',
                );
                // _btnController.reset(); // Bỏ qua file lỗi
                setState(() {
                  _loading = false;
                });
                return;
              }
              file = convertedOrCompressed;
              // file = await compressImage(file);
            }
          }

          var response = await RequestHelperKPI().uploadAvatar(file);
          print("Response: $response");
          if (response != null) {
            widget.lstFiles.add(CheckSheetFileModel(
              isRemoved: response["isRemoved"],
              id: response["id"],
              fileName: response["fileName"],
              path: response["path"],
            ));
            fileItem.uploaded = true;

            if (response["path"] != null) {
              imageUrls.add(response["path"]);
            }
          }
        }
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    imageUrlsString = imageUrls.join(',');
    print("url: ${imageUrlsString}");

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
        postChuKy(imageUrlsString, isDelete).then((_) {
          print("loading: ${_loading}");
          setState(() {
            _lstFiles.clear();
            _loading = false;
            enable = false;
          });
        });
      }
    });
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
      enable = false;
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

  Widget _buildSignatureImage(BuildContext context, String? src, {String? apiBase}) {
    if (src == null || src.isEmpty) return const SizedBox.shrink();

    // 1) data URI: data:image/png;base64,....
    if (src.startsWith('data:image')) {
      final b64 = src.split(',').last;
      return Image.memory(base64Decode(b64), fit: BoxFit.contain);
    }

    // 2) base64 trần (không có prefix)
    final isBase64 = RegExp(r'^[A-Za-z0-9+/]+={0,2}$').hasMatch(src) && src.length % 4 == 0;
    if (isBase64) {
      return Image.memory(base64Decode(src), fit: BoxFit.contain);
    }

    // 3) đường dẫn tương đối -> ghép apiBase
    if (src.startsWith('/')) {
      final url = '${apiBase ?? ''}$src';
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(child: Text('Không tải được ảnh')),
      );
    }

    // 4) URL đầy đủ
    return Image.network(
      src,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Center(child: Text('Không tải được ảnh')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(children: [
          const SizedBox(height: 5),
          Center(
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
                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                // Hiển thị hình ảnh
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildSignatureImage(
                                      context,
                                      _data?.hinhAnhChuKySo,
                                      apiBase: ab?.apiUrl,
                                    ),
                                  ),
                                ),
                                // Đặt Icon edit ở góc trên phải
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                  onPressed: (_data?.hinhAnhChuKySo != null) ? null : () => imageSelector(context, 'gallery'),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text(""),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      // backgroundColor: Theme.of(context).primaryColor,
                                      ),
                                  onPressed: (_data?.hinhAnhChuKySo != null) ? null : () => imageSelector(context, 'camera'),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text(""),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00B528),
                                  ),
                                  // onPressed: (enable == false) ? null : () => _onSave(false),
                                  onPressed: (enable == false) ? null : () => _showConfirmationDialog(context, false),
                                  // onPressed: () => _onSave(),
                                  icon: const Icon(Icons.cloud_upload),
                                  label: const Text("Lưu chữ ký"),
                                ),
                                ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    // onPressed: (_data?.hinhAnhChuKySo == null) ? null : () => _onSave(true),
                                    onPressed: (_data?.hinhAnhChuKySo == null) ? null : () => _showConfirmationDialog(context, true),
                                    // onPressed: () => _onSave(),
                                    icon: const Icon(Icons.delete),
                                    label: const Text(
                                      "Xoá chữ ký",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ],
                            ),
                          ),
                        ),

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
                                            '${ab?.apiUrl}/${image.file}',
                                            errorBuilder: ((context, error, stackTrace) {
                                              return Container(
                                                height: 70,
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
        ]),
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
