import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:Thilogi/services/request_helper_mms.dart';
import 'package:Thilogi/widgets/loading.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

class CustomBodyGanMoocTB extends StatelessWidget {
  final String? id;
  CustomBodyGanMoocTB({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyGanMoocTBScreen(
      id: id,
      lstFiles: [],
    ));
  }
}

class BodyGanMoocTBScreen extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  const BodyGanMoocTBScreen({super.key, required this.id, required this.lstFiles});

  @override
  _BodyGanMoocTBScreenState createState() => _BodyGanMoocTBScreenState();
}

class _BodyGanMoocTBScreenState extends State<BodyGanMoocTBScreen> with TickerProviderStateMixin, ChangeNotifier {
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
  PhuongTienModel? _phuongtienmooc;
  PhuongTienModel? get phuongtienmooc => _phuongtienmooc;
  PhuongTienModel? _data;
  PhuongTienModel? _data2;
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
    requestLocationPermission();
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
    print("PhuongTien_Id= ${widget.id}");

    _onScan();
    getLichSu(widget.id);
  }

  Future<void> getDiaDiem(String? toaDo, StateSetter dialogSetState) async {
    _dn = [];
    dialogSetState(() {});
    try {
      final http.Response response = await requestHelperMMS.getData('MMS_DM_SuaChua/GetDiaDiemTheoToaDo?ToaDo=$toaDo');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => DiaDiemModel.fromJson(item)).toList();
          setState(() {
            _loading = false;
          });
          dialogSetState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getMooc(StateSetter dialogSetState) async {
    _listMooc = [];
    dialogSetState(() {});
    try {
      final http.Response response = await requestHelperMMS.getData('MMS_DS_Mooc');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _listMooc = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).toList();
          setState(() {
            _loading = false;
          });
          dialogSetState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  _onScan() async {
    setState(() {
      _loading = true;
    });
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) async {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });
      print(lat);
      toaDo = "$lat,$long";
      print("toaDo: $toaDo");
      await getThongTin(widget.id).then((_) {
        setState(() {
          if (phuongtien == null) {
            QuickAlert.show(
              // ignore: use_build_context_synchronously
              context: context,
              type: QuickAlertType.info,
              title: '',
              text: 'Không có dữ liệu',
              confirmBtnText: 'Đồng ý',
            );
            _loading = false;
          } else {
            _loading = false;
            _data = phuongtien;
            print("ID Ghepnoi: ${phuongtien?.ghepNoiPhuongTien_ThietBi_Id}");
          }
        });
      });
    }).catchError((error) {
      _btnController.error();
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Thất bại',
        text: 'Bạn chưa có tọa độ vị trí. Vui lòng BẬT VỊ TRÍ',
        confirmBtnText: 'Đồng ý',
      );
      _btnController.reset();
      setState(() {
        _loading = false;
      });
      print("Error getting location: $error");
    });
  }

  _onScan2(String? id) async {
    setState(() {
      _loading = true;
    });

    await getThongTinMooc(id).then((_) {
      setState(() {
        if (phuongtienmooc == null) {
          QuickAlert.show(
            // ignore: use_build_context_synchronously
            context: context,
            type: QuickAlertType.info,
            title: '',
            text: 'Không có dữ liệu',
            confirmBtnText: 'Đồng ý',
          );
          _loading = false;
        } else {
          _loading = false;
          _data2 = phuongtienmooc;
          print("ID Ghepnoi: ${phuongtienmooc?.ghepNoiPhuongTien_ThietBi_Id}");
        }
      });
    });
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

  void requestLocationPermission() async {
    // Kiểm tra quyền truy cập vị trí
    LocationPermission permission = await Geolocator.checkPermission();
    // Nếu chưa có quyền, yêu cầu quyền truy cập vị trí
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Yêu cầu quyền truy cập vị trí
      await Geolocator.requestPermission();
    }
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
              lstFilesNotifier.value = List.from(_lstFiles);
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
          lstFilesNotifier.value = List.from(_lstFiles);
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
      lstFilesNotifier.value = List.from(_lstFiles);
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

  Future<void> getThongTin(String? id) async {
    _loading = true;
    try {
      final http.Response response = await requestHelperMMS.getData('MMS_DS_Mooc/GetById?id=$id');
      print("abc5 : ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          print("dataAdsun:${decodedData}");
          _phuongtien = PhuongTienModel(
              bienSo1: decodedData['bienSo1'],
              tenMooc: decodedData['tenMooc'],
              ghepNoiPhuongTien_ThietBi_Id: decodedData['ghepNoiPhuongTien_ThietBi_Id'],
              phuongTien2_Id: decodedData['phuongTien2_Id'],
              loaiPT: decodedData['loaiPT'],
              model: decodedData['model'],
              tenDiaDiem: decodedData['tenDiaDiem']);

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
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      print("datahangmuc:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> getThongTinMooc(String? id) async {
    _loading = true;
    try {
      final http.Response response = await requestHelperMMS.getData('MMS_DS_Mooc/GetById?id=$id');
      print("abc5 : ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          print("dataAdsun:${decodedData}");
          _phuongtienmooc = PhuongTienModel(
              bienSo1: decodedData['bienSo1'],
              tenMooc: decodedData['tenMooc'],
              ghepNoiPhuongTien_ThietBi_Id: decodedData['ghepNoiPhuongTien_ThietBi_Id'],
              phuongTien2_Id: decodedData['phuongTien2_Id'],
              loaiPT: decodedData['loaiPT'],
              model: decodedData['model'],
              tenDiaDiem: decodedData['tenDiaDiem']);

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
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      print("datahangmuc:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> postData(PhuongTienModel scanData, String? toaDo, String? bienSo, String? file) async {
    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      final String endpoint = scanData.ghepNoiPhuongTien_ThietBi_Id == null ? 'MMS_DS_Mooc' : 'MMS_DS_Mooc/ThaoMooc';

      final String url = '$endpoint?ToaDo=$toaDo&BienSo=$bienSo&HinhAnh=$file';
      final http.Response response = await requestHelperMMS.postData(url, newScanData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        notifyListeners();
        _btnController.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: scanData?.nguoiGhep != null ? "Gắn mooc thành công" : "Tháo mooc thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
      _data = PhuongTienModel(); // Đảm bảo _data không bị null
    }
    _data?.id = widget.id;
    _data?.phuongTien_Id = widget.id;
    _data?.phuongTien2_Id = PhuongTien2_Id ?? phuongtien?.phuongTien2_Id;
    _data?.bienSo1 = phuongtien?.bienSo1;

    if (phuongtien?.ghepNoiPhuongTien_ThietBi_Id == null) {
      _data?.nguoiGhep = "${_ub?.name} - ${_ub?.maNhanVien}";
    } else {
      _data?.nguoiThao = "${_ub?.name} - ${_ub?.maNhanVien}";
    }

    _data?.diaDiem_Id = DiaDiem_Id;
    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });
      toaDo = "$lat,$long";
      print("Vi tri: $toaDo");

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
          postData(_data!, toaDo, _data?.bienSo1, imageUrlsString).then((_) {
            setState(() {
              textEditingController.text = '';
              _lstFiles.clear();
              _onScan();
              _listMooc = null;
              bienSo = null;
              _data2 = null;
              PhuongTien2_Id = null;
              getLichSu(widget.id);
              _loading = false;
            });
          });
        }
      });
    }).catchError((error) {
      _btnController.error();
      QuickAlert.show(
        // ignore: use_build_context_synchronously
        context: context,
        type: QuickAlertType.error,
        title: 'Thất bại',
        text: 'Bạn chưa có tọa độ vị trí. Vui lòng BẬT VỊ TRÍ',
        confirmBtnText: 'Đồng ý',
      );
      _btnController.reset();
      setState(() {
        _loading = false;
      });
      print("Error getting location: $error");
    });
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_listMooc == null || _listMooc!.isEmpty) {
              getMooc(setState);
            }
            if (_dn == null || _dn!.isEmpty) {
              getDiaDiem(toaDo, setState);
            }
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'THÔNG TIN YÊU CẦU',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red, size: 30),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Biển số: ${_data?.bienSo1 ?? ""}',
                        style: const TextStyle(
                          fontFamily: 'Comfortaa',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_data?.tenMooc != null) ...[
                        Text(
                          'MOOC: ${_data?.tenMooc ?? ""}',
                          style: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      SizedBox(
                        height: 10,
                      ),
                      // Container(
                      //   height: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(5),
                      //     border: Border.all(
                      //       color: const Color(0xFFBC2925),
                      //       width: 1.5,
                      //     ),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         width: 30.w,
                      //         decoration: const BoxDecoration(
                      //           color: Color(0xFFF6C6C7),
                      //           border: Border(
                      //             right: BorderSide(
                      //               color: Color(0xFF818180),
                      //               width: 1,
                      //             ),
                      //           ),
                      //         ),
                      //         child: const Center(
                      //           child: Text(
                      //             "Địa điểm",
                      //             textAlign: TextAlign.left,
                      //             style: TextStyle(
                      //               fontFamily: 'Comfortaa',
                      //               fontSize: 15,
                      //               fontWeight: FontWeight.w400,
                      //               color: AppConfig.textInput,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       Expanded(
                      //         flex: 1,
                      //         child: Container(
                      //             padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                      //             child: DropdownButtonHideUnderline(
                      //               child: DropdownButton2<String>(
                      //                 isExpanded: true,
                      //                 items: _dn?.map((item) {
                      //                   return DropdownMenuItem<String>(
                      //                     value: item.id,
                      //                     child: Container(
                      //                       constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                      //                       child: SingleChildScrollView(
                      //                         scrollDirection: Axis.horizontal,
                      //                         child: Text(
                      //                           item.tenDiaDiem ?? "",
                      //                           textAlign: TextAlign.center,
                      //                           style: const TextStyle(
                      //                             fontFamily: 'Comfortaa',
                      //                             fontSize: 13,
                      //                             fontWeight: FontWeight.w600,
                      //                             color: AppConfig.textInput,
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   );
                      //                 }).toList(),
                      //                 value: DiaDiem_Id,
                      //                 onChanged: (newValue) {
                      //                   setState(() {
                      //                     DiaDiem_Id = newValue;
                      //                   });
                      //                 },
                      //                 buttonStyleData: const ButtonStyleData(
                      //                   padding: EdgeInsets.symmetric(horizontal: 16),
                      //                   height: 40,
                      //                   width: 200,
                      //                 ),
                      //                 dropdownStyleData: const DropdownStyleData(
                      //                   maxHeight: 200,
                      //                 ),
                      //                 menuItemStyleData: const MenuItemStyleData(
                      //                   height: 40,
                      //                 ),
                      //                 dropdownSearchData: DropdownSearchData(
                      //                   searchController: textEditingController,
                      //                   searchInnerWidgetHeight: 50,
                      //                   searchInnerWidget: Container(
                      //                     height: 50,
                      //                     padding: const EdgeInsets.only(
                      //                       top: 8,
                      //                       bottom: 4,
                      //                       right: 8,
                      //                       left: 8,
                      //                     ),
                      //                     child: TextFormField(
                      //                       expands: true,
                      //                       maxLines: null,
                      //                       controller: textEditingController,
                      //                       decoration: InputDecoration(
                      //                         isDense: true,
                      //                         contentPadding: const EdgeInsets.symmetric(
                      //                           horizontal: 10,
                      //                           vertical: 8,
                      //                         ),
                      //                         hintText: 'Tìm địa điểm',
                      //                         hintStyle: const TextStyle(fontSize: 12),
                      //                         border: OutlineInputBorder(
                      //                           borderRadius: BorderRadius.circular(8),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   searchMatchFn: (item, searchValue) {
                      //                     if (item is DropdownMenuItem<String>) {
                      //                       // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                      //                       String itemId = item.value ?? "";
                      //                       // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                      //                       return _dn?.any((baiXe) => baiXe.id == itemId && baiXe.tenDiaDiem?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                      //                     } else {
                      //                       return false;
                      //                     }
                      //                   },
                      //                 ),
                      //                 onMenuStateChange: (isOpen) {
                      //                   if (!isOpen) {
                      //                     textEditingController.clear();
                      //                   }
                      //                 },
                      //               ),
                      //             )),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      if (_data?.ghepNoiPhuongTien_ThietBi_Id == null)
                        Container(
                          height: MediaQuery.of(context).size.height < 600 ? 10.h : 5.h,
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
                                    "Mooc",
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
                                child: Container(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        items: _listMooc?.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item.id,
                                            child: Container(
                                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Text(
                                                  item.bienSo1 ?? "",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontFamily: 'Comfortaa',
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppConfig.textInput,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        value: PhuongTien2_Id,
                                        onChanged: (newValue) {
                                          setState(() {
                                            PhuongTien2_Id = newValue;
                                          });
                                          if (newValue != null) {
                                            _onScan2(newValue);
                                          }
                                        },
                                        buttonStyleData: const ButtonStyleData(
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          height: 40,
                                          width: 200,
                                        ),
                                        dropdownStyleData: const DropdownStyleData(
                                          maxHeight: 200,
                                        ),
                                        menuItemStyleData: const MenuItemStyleData(
                                          height: 40,
                                        ),
                                        dropdownSearchData: DropdownSearchData(
                                          searchController: textEditingController,
                                          searchInnerWidgetHeight: 50,
                                          searchInnerWidget: Container(
                                            height: 50,
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 4,
                                              right: 8,
                                              left: 8,
                                            ),
                                            child: TextFormField(
                                              expands: true,
                                              maxLines: null,
                                              controller: textEditingController,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8,
                                                ),
                                                hintText: 'Tìm địa điểm',
                                                hintStyle: const TextStyle(fontSize: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          searchMatchFn: (item, searchValue) {
                                            if (item is DropdownMenuItem<String>) {
                                              // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                              String itemId = item.value ?? "";
                                              // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                              return _listMooc?.any((baiXe) => baiXe.id == itemId && baiXe.bienSo1?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                            } else {
                                              return false;
                                            }
                                          },
                                        ),
                                        onMenuStateChange: (isOpen) {
                                          if (!isOpen) {
                                            textEditingController.clear();
                                          }
                                        },
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      if (_data2 != null) ...[
                        Text(
                          'Biển số Mooc: ${_data2?.bienSo1 ?? ""}',
                          style: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Loại PT: ${_data2?.loaiPT ?? ""}',
                          style: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Model: ${_data2?.model ?? ""}',
                          style: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Vị trí: ${_data2?.tenDiaDiem ?? ""}',
                          style: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
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
                            ValueListenableBuilder<List<FileItem>>(
                              valueListenable: lstFilesNotifier,
                              builder: (context, lstFiles, _) {
                                return ResponsiveGridRow(
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
                                                    '${_ub?.apiUrl2}/${image.file}',
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
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(5),
                        child: RoundedLoadingButton(
                          child: Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              color: AppConfig.textButton,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          controller: _btnController,
                          // onPressed: (PhuongTien2_Id != null) ? () => _onSave() : null,
                          onPressed: () => _onSave(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
                6: FlexColumnWidth(0.3),
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
                      child: _buildTableCell('Địa điểm', textColor: Colors.white),
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
              height: MediaQuery.of(context).size.height * 0.8, // Chiều cao cố định
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
                    6: FlexColumnWidth(0.3),
                  },
                  children: [
                    // Chiều cao cố định
                    ..._lichsu?.map((item) {
                          // index++; // Tăng số thứ tự sau mỗi lần lặp
                          return TableRow(
                            decoration: BoxDecoration(
                              color: Colors.white, // Nền đỏ nếu đủ điều kiện
                            ),
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              _buildTableCell(item.tinhTrang ?? ""),
                              _buildTableCell(item.bienSo1 ?? ""),
                              _buildTableCell(item.tenMooc ?? ""),
                              _buildTableCell(item.nguoiThucHien ?? ""),
                              _buildTableCell(item.ngay ?? ""),
                              _buildTableCell(item.tenDiaDiem ?? ""),
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
                                'Thông tin gắn/tháo mooc',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFA71C20)),
                              const SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Bên trái: Biển số + MOOC
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(
                                        'Biển số: ${_data?.bienSo1 ?? ""}',
                                        style: const TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'MOOC: ${_data?.tenMooc ?? ""}',
                                        style: const TextStyle(
                                          fontFamily: 'Comfortaa',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
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
                                                              'Lịch sử gắn/tháo Mooc',
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
                                                    _buildTableOptions(context)
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.list_alt), // Bạn có thể đổi icon khác
                                      color: Colors.black,
                                      tooltip: "Xem lịch sử", // Tooltip khi hover chuột
                                      iconSize: 28,
                                    ),
                                  ),

                                  // Bên phải: Nút
                                  if (true)
                                    Container(
                                      width: 30.w,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppConfig.popup, // Màu nền
                                          foregroundColor: AppConfig.textButton, // Màu chữ
                                          textStyle: const TextStyle(
                                            fontFamily: 'Comfortaa',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(13), // Bo góc
                                          ),
                                        ),
                                        onPressed: () {
                                          _showDetailsDialog(context);
                                        },
                                        child: Text(
                                          _data?.ghepNoiPhuongTien_ThietBi_Id == null ? "Gắn mooc" : "Tháo mooc",
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              // SizedBox(height: 10),
                              // const Text(
                              //   'Lịch sử gắn/tháo Mooc',
                              //   style: TextStyle(
                              //     fontFamily: 'Comfortaa',
                              //     fontSize: 20,
                              //     fontWeight: FontWeight.w700,
                              //   ),
                              // ),
                              // const Divider(height: 1, color: Color(0xFFA71C20)),
                              // if ((_lichsu?.isNotEmpty ?? false)) _buildTableOptions(context)
                              SizedBox(height: 10),
                              // const Text(
                              //   'Thông tin ghép nối thiết bị',
                              //   style: TextStyle(
                              //     fontFamily: 'Comfortaa',
                              //     fontSize: 20,
                              //     fontWeight: FontWeight.w700,
                              //   ),
                              // ),
                              // const Divider(height: 1, color: Color(0xFFA71C20)),
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
