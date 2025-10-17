import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Thilogi/blocs/xeracong_bloc.dart';

import 'package:Thilogi/services/app_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../../blocs/user_bloc.dart';
import '../../../config/config.dart';
import '../../../models/checksheet.dart';
import '../../../models/diadiem.dart';
import '../../../models/kehoach.dart';
import '../../../models/mms/dsphuongtien.dart';
import '../../../models/mms/hangmuc.dart';
import '../../../models/mms/lichsubaoduong.dart';
import '../../../services/request_helper_mms.dart';
import '../../../utils/delete_dialog.dart';
import '../../../widgets/custom_title.dart';

class CustomBodySuaChua extends StatelessWidget {
  final String? id;
  CustomBodySuaChua({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodySuaChuaScreen(
      id: id,
      lstFiles: [],
    ));
  }
}

class BodySuaChuaScreen extends StatefulWidget {
  final String? id;
  final List<CheckSheetFileModel?> lstFiles;
  const BodySuaChuaScreen({super.key, required this.id, required this.lstFiles});

  @override
  _BodySuaChuaScreenState createState() => _BodySuaChuaScreenState();
}

class _BodySuaChuaScreenState extends State<BodySuaChuaScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();

  String _qrData = '';
  final _qrDataController = TextEditingController();
  LichSuBaoDuongModel? _data;
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
  final TextEditingController soKMController = TextEditingController();
  final TextEditingController _ghiChu = TextEditingController();
  final TextEditingController _chiphi = TextEditingController();
  final TextEditingController _vattu = TextEditingController();
  final TextEditingController _tongChiPhi = TextEditingController();
  Map<String, TextEditingController> chiphiControllers = {};
  bool _IsTuChoi = false;
  bool _IsXacNhan = false;
  late UserBloc? _ub;
  String? bienSo;
  KeHoachModel? _thongbao;
  List<PhuongTienModel>? _lenhHoanThanhList;
  List<PhuongTienModel>? get lenhHoanThanhList => _lenhHoanThanhList;
  List<PhuongTienModel>? _kehoachList;
  List<PhuongTienModel>? get kehoachList => _kehoachList;
  List<HangMucModel>? _hangmucList;
  List<HangMucModel>? get hangmucList => _hangmucList;
  List<bool> selectedItems = [];
  bool selectAll = false;
  String? DongXeId;
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();
  ValueNotifier<List<FileItem>> lstFilesNotifier = ValueNotifier<List<FileItem>>([]);
  List<DiaDiemModel>? _dn;
  List<DiaDiemModel>? get dn => _dn;
  String? DiaDiem_Id;
  String? body;
  String? _previousPhuongTienId;
  bool _errorHinhAnh = false;
  bool _errorChiPhiSC = false;
  bool _errorNhapKM = false;

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
    print("Id: ${widget.id} - Type: ${widget.id.runtimeType}");
    if (widget.id?.isNotEmpty ?? false) {
      getListThayDoiKH(widget.id, textEditingController.text);
      getDiaDiem();
    } else {
      print("theo ca nhan");
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    textEditingController.dispose();
    soKMController.dispose();
    _ghiChu.dispose();
    _chiphi.dispose();
    super.dispose();
  }

  Future<void> getLenhHoanThanh() async {
    _loading = true;

    try {
      final http.Response response = await requestHelper.getData('MMS_SuaChua/DanhSachYeuCauHoanThanh');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _lenhHoanThanhList = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).toList();
        // getHangMuc();
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("databiensolenh:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future imageSelector(BuildContext context, String pickerType, int index) async {
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

              // if (Navigator.canPop(context)) {
              //   Navigator.pop(context); // Đóng dialog cũ (nếu cần)
              //   _showDetailsDialog(context, index); // Mở dialog với dữ liệu mới
              // }
            });
          }
        }
      } on Exception catch (e) {
        print(e);
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
          // if (Navigator.canPop(context)) {
          //   Navigator.pop(context); // Đóng dialog cũ (nếu cần)
          //   _showDetailsDialog(context, index); // Mở dialog với dữ liệu mới
          // }
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

  _removeImage(FileItem image, int index) {
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
      // if (Navigator.canPop(context)) {
      //   Navigator.pop(context); // Đóng dialog cũ (nếu cần)
      //   _showDetailsDialog(context, index); // Mở dialog với dữ liệu mới
      // }
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

  Future<File> compressImage(File file) async {
    setState(() {
      _loading = true;
    });

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

  Future<void> getListChiTietHangMuc(String? listIds, StateSetter dialogSetState) async {
    print("data:${listIds}");
    _isLoading = true;
    dialogSetState(() {});
    // Làm sạch danh sách cũ trước khi tải mới
    try {
      final http.Response response = await requestHelper.getData('MMS_SuaChua/LichSuSuaChuaChiTietTheoPT?BaoDuong_Id=$listIds');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("dataPT:${decodedData}");
        if (decodedData != null) {
          _hangmucList = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
          // Gọi setState để cập nhật giao diện

          dialogSetState(() {
            _loading = false;
          });
        }
      } else {
        _hangmucList = [];
        // Làm sạch danh sách cũ trước khi tải mới
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      print("error:${e.toString()}");
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> getListThayDoiKH(String? listIds, String? keyword) async {
    print("data:${listIds}");
    setState(() {
      _isLoading = true;
      _kehoachList = [];
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_SuaChua/LichSuSuaChuaTheoPT?PhuongTien_Id=$listIds&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          _kehoachList = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).toList();
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
      print("error:${e.toString()}");
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> getDiaDiem() async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData('MMS_DM_SuaChua');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => DiaDiemModel.fromJson(item)).toList();
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

  Future<void> postData(LichSuBaoDuongModel? scanData) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;
      final http.Response response = await requestHelper.postData('MMS_SuaChua/DiSuaChua?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}', newScanData?.toJson());
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: "Xác nhận thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.pop(context); // Đóng dialog cũ (nếu cần)
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

  _onSave(int index) async {
    setState(() {
      _loading = true;
    });

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.id;
    _data?.diaDiem_Id = DiaDiem_Id;

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
        postData(_data!).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            barcodeScanResult = null;
            _qrData = '';
            _qrDataController.text = '';
            getListThayDoiKH(widget.id, textEditingController.text);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  Future<void> postDataFireBase(KeHoachModel? scanData, String? body, String? id) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      final http.Response response = await requestHelper.postData('MMS_Notification/PushThongBao_SuaChua?body=$body&listIds=$id', newScanData?.toJson());
      print("statusCode: ${response.body}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");
        setState(() {
          _loading = false;
        });

        notifyListeners();
      } else {}
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postDataHoanThanh(LichSuBaoDuongModel? scanData, int? soKM, String? file, List<Map<String, dynamic>> danhSachChiPhi, int index, int tongChiPhi) async {
    _isLoading = true;
    print("dschiphi: ${danhSachChiPhi}");
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;
      Map<String, dynamic> requestBody = {
        "data": newScanData?.toJson() ?? {}, // Dữ liệu sửa chữa
        "chiPhis": danhSachChiPhi
            .map((chiPhi) => {
                  "hangMuc_Id": chiPhi["hangMuc_Id"],
                  // "giaTri": chiPhi["chiPhi"], // Đảm bảo key trùng với backend
                  "ghiChu": chiPhi["ghiChu"],
                })
            .toList(),
      };
      final http.Response response = await requestHelper.postData('MMS_SuaChua/LenhHoanThanhSuaChua?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&SoKM=$soKM&File=$file&TongChiPhi=$tongChiPhi', requestBody);

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: "Xác nhận thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // Đóng dialog cũ (nếu cần)
              // if (Navigator.canPop(context)) {
              //   Navigator.pop(context); // Đóng dialog cũ (nếu cần)
              //   _showDetailsDialog(context, index); // Mở dialog với dữ liệu mới
              // }
            });
        _btnController.reset();
        await getLenhHoanThanh();
        body = "Bạn đã có ${_lenhHoanThanhList?.length.toString() ?? ""} lệnh hoàn thành sửa chữa phương tiện";
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

  _onSaveHoanThanh(int index) async {
    setState(() {
      _loading = true;
    });
    List<String> imageUrls = [];

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
            _btnController.reset(); // Bỏ qua file lỗi
            setState(() {
              _loading = false;
            });
            return;
          } else {
            file = await compressImage(file);
          }
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

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.id;
    _data?.noiDung = textEditingController.text;
    _data?.ketQua = _ghiChu.text;
    _data?.hinhAnh = imageUrlsString;
    _data?.vatTuThayThe = _vattu.text;
    List<Map<String, dynamic>> danhSachChiPhi = [];
    print("_hangmucList:${_hangmucList}");
    for (var hangmuc in _hangmucList ?? []) {
      String chiPhiText = chiphiControllers[hangmuc.hangMuc_Id!]?.text ?? "0";
      // int chiPhiValue = int.tryParse(chiPhiText) ?? 0;
      // danhSachChiPhi.add({
      //   "hangMuc_Id": hangmuc.hangMuc_Id,
      //   "chiPhi": chiPhiValue,
      // });
      danhSachChiPhi.add({"hangMuc_Id": hangmuc.hangMuc_Id, "ghiChu": chiPhiText});
    }
    int tongChiPhi = int.tryParse(_tongChiPhi.text) ?? 0;
    print("SoKMhientai:${soKMController.text}");
    print("chiphi:${danhSachChiPhi}");

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
        postDataHoanThanh(_data!, int.parse(soKMController.text), imageUrlsString, danhSachChiPhi, index, tongChiPhi).then((_) {
          setState(() {
            _IsTuChoi = false;
            _IsXacNhan = false;
            postDataFireBase(_thongbao, body ?? "", widget.id);
            _textController.text = '';
            textEditingController.text = '';
            soKMController.text = '';
            _ghiChu.text = '';
            _vattu.text = '';
            _tongChiPhi.text = '';
            _errorChiPhiSC = false;
            _errorHinhAnh = false;
            _errorNhapKM = false;
            _lstFiles.clear();
            getListThayDoiKH(widget.id, textEditingController.text);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialog(BuildContext context, int index) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có chắc chắn xác nhận đi sửa chữa không?',
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
          _onSave(index);
        });
  }

  void _showConfirmationDialogHoanThanh(BuildContext context, int index) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn hoàn thành sửa chữa không?',
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
          _onSaveHoanThanh(index);
        });
  }

  void _showDetailsDialog(BuildContext context, int index) {
    final baoduongId = _kehoachList?[index].id;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_hangmucList == null || _hangmucList!.isEmpty) {
              getListChiTietHangMuc(baoduongId ?? "", setState);
            }
            print("_hangmucList khi lưu: $_hangmucList");
            // Khởi tạo controller cho từng hạng mục
            for (var hangmuc in _hangmucList ?? []) {
              if (!chiphiControllers.containsKey(hangmuc.hangMuc_Id!)) {
                chiphiControllers[hangmuc.hangMuc_Id!] = TextEditingController();
              }
            }
            return Dialog(
              insetPadding: EdgeInsets.zero, // Loại bỏ khoảng cách viền
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
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
                              'HOÀN THÀNH SỬA CHỮA',
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
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _errorChiPhiSC = false;
                                _errorHinhAnh = false;
                                _errorNhapKM = false;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
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
                                padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Column(
                                        children: [
                                          // ItemGhiChu(
                                          //   title: 'Nội dung sửa chữa: ',
                                          //   controller: textEditingController,
                                          // ),
                                          // const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemGhiChu(
                                            title: 'Ghi chú: ',
                                            controller: _ghiChu,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          // ItemGhiChu(
                                          //   title: 'Nhập số KM hiện tại: ',
                                          //   controller: soKMController,
                                          // ),
                                          buildInputWithError(
                                            title: 'Nhập số KM hiện tại: ',
                                            controller: soKMController,
                                            showError: _errorNhapKM,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          // ItemGhiChu(
                                          //   title: 'Tổng chi phí: ',
                                          //   controller: _tongChiPhi,
                                          // ),
                                          buildInputWithError(
                                            title: 'Tổng chi phí:',
                                            controller: _tongChiPhi,
                                            showError: _errorChiPhiSC,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemGhiChu(
                                            title: 'Vật tư thay thế: ',
                                            controller: _vattu,
                                          ),
                                          ...?_hangmucList?.map((hangmuc) {
                                            return Column(
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                    "${hangmuc.noiDungBaoDuong} - ${hangmuc.dinhMuc2}",
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  child: TextField(
                                                    controller: chiphiControllers[hangmuc.hangMuc_Id!],
                                                    // keyboardType: TextInputType.number,
                                                    decoration: const InputDecoration(
                                                      labelText: "Ghi chú",
                                                      border: OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                              ],
                                            );
                                          }).toList(),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          Container(
                                            margin: const EdgeInsets.only(right: 5),
                                            decoration: BoxDecoration(
                                                // color: Theme.of(context).colorScheme.onPrimary,
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
                                                          onPressed: () => imageSelector(context, 'gallery', index),
                                                          icon: const Icon(Icons.photo_library),
                                                          label: const Text(""),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        ElevatedButton.icon(
                                                          style: ElevatedButton.styleFrom(
                                                              // backgroundColor: Theme.of(context).primaryColor,
                                                              ),
                                                          onPressed: () => imageSelector(context, 'camera', index),
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
                                                if (_errorHinhAnh)
                                                  const Padding(
                                                    padding: const EdgeInsets.only(left: 12, bottom: 10),
                                                    child: Text(
                                                      'Bạn chưa chọn ảnh',
                                                      style: TextStyle(color: Colors.red, fontSize: 13),
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
                                                                  () => _removeImage(image, index),
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
                                          // CheckSheetUploadAnh(
                                          //   lstFiles: [],
                                          // )
                                        ],
                                      ),
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
                      width: 100.w,
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          RoundedLoadingButton(
                            child: Text('Xác nhận',
                                style: TextStyle(
                                  fontFamily: 'Comfortaa',
                                  color: AppConfig.textButton,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                )),
                            controller: _btnController,
                            onPressed: () {
                              setState(() {
                                _errorChiPhiSC = _tongChiPhi.text.isEmpty;
                                _errorHinhAnh = lstFilesNotifier.value.isEmpty;
                                _errorNhapKM = soKMController.text.isEmpty;
                              });

                              if (_errorChiPhiSC || _errorHinhAnh || _errorNhapKM) {
                                _btnController.reset();
                                return;
                              }
                              _showConfirmationDialogHoanThanh(context, index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailsDialogChiTiet(BuildContext context, int index, List<HangMucModel> items) {
    final baoduongId = _kehoachList?[index].id; // Lấy ID của phương tiện
    bool isExpanded = true; // trạng thái mở rộng danh sách
    bool isExpanded2 = true; // trạng thái mở rộng danh sách
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // if (_hangmucList == null || _hangmucList!.isEmpty) {
            //   getListChiTietHangMuc(baoduongId ?? "", setState);
            // }
            if (_previousPhuongTienId != baoduongId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = baoduongId;
              getListChiTietHangMuc(baoduongId ?? "", setState);
            }
            return Dialog(
              insetPadding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
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
                              'HẠNG MỤC SỬA CHỮA',
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

                    // Danh sách hạng mục với checkbox
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                // itemCount: _hangmucList?.length ?? 0,
                                itemCount: _hangmucList?.length ?? 0,
                                itemBuilder: (context, i) {
                                  var item = _hangmucList?[i];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item?.noiDungBaoDuong ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold, // Tiêu đề đậm
                                            color: Colors.blue, // Màu đen cho tiêu đề
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        buildRichText('Chi phí:', item?.chiPhi ?? ""),
                                        Divider(height: 1, color: Color(0xFFDDDDDD)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Button Xác nhận
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialogYeuCau(BuildContext context, String? bienSo1, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            // Sử dụng StateSetter để cập nhật UI trong dialog
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xác nhận đi sửa chữa ${bienSo1}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
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
                                  "TT Sửa chữa",
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
                                      items: _dn?.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item.id,
                                          child: Container(
                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                item.tenDiaDiem ?? "",
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
                                      value: DiaDiem_Id,
                                      onChanged: (newValue) {
                                        setStateDialog(() {
                                          DiaDiem_Id = newValue;
                                        });
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
                                            return _dn?.any((baiXe) => baiXe.id == itemId && baiXe.tenDiaDiem?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _btnController.reset();
                            },
                            child: const Text(
                              'Không',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: (DiaDiem_Id != null) ? () => _showConfirmationDialog(context, index) : null,
                            child: const Text(
                              'Đồng ý',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getListThayDoiKH(widget.id, textEditingController.text);
      },
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      // color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Lịch sử: ",
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

                            // if (_kehoachList != null)
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
                                        isYeuCau: item?.isYeuCau ?? false,
                                        isHoanThanh: item?.isHoanThanh ?? false,
                                        noiDung: item?.noiDung ?? "",
                                        ketQua: item?.ketQua ?? "",
                                        chiPhi: (item?.isHoanThanh == false ? item?.chiPhi : item?.chiPhi_TD) ?? "",
                                        tenDiaDiem: item?.tenDiaDiem ?? "",
                                        isLenhHoanThanh: item?.isLenhHoanThanh ?? false,
                                        tinhTrang: item?.tinhTrang ?? "",
                                        bienSo1: item?.bienSo1 ?? "",
                                        ngay: item?.ngay ?? "",
                                        ngayDeXuatHoanThanh: item?.ngayDeXuatHoanThanh ?? "",
                                        nguoiDeXuatHoanThanh: item?.nguoiDeXuatHoanThanh ?? "",
                                        ngayXacNhan: item?.ngayXacNhan ?? "",
                                        ngayDiSuaChua: item?.ngayDiSuaChua ?? "",
                                        ngayHoanThanh: item?.ngayHoanThanh ?? "",
                                        nguoiYeuCau: item?.nguoiYeuCau ?? "",
                                        nguoiXacNhan: item?.nguoiXacNhan ?? "",
                                        nguoiDiSuaChua: item?.nguoiDiSuaChua ?? "",
                                        nguoiXacNhanHoanThanh: item?.nguoiXacNhanHoanThanh ?? "",
                                        isDuyet: item?.isDuyet ?? false,
                                        isSuaChua: item?.isSuaChua ?? false,
                                        isChiTiet: () {
                                          _showDetailsDialogChiTiet(context, index, item?.lichSu ?? []); // Hành động TỪ CHỐI
                                        },
                                        onDongY: () {
                                          _IsXacNhan = true;
                                          (item?.isDuyet == true && item?.isBaoDuong == false) ? _showConfirmationDialog(context, index) : _showDetailsDialog(context, index); // Hành động ĐỒNG Ý
                                        },
                                        isSelected: selectedItems[index],
                                        onLongPress: () {
                                          setState(() {
                                            selectedItems[index] = !selectedItems[index];
                                          });
                                          print(selectedItems);
                                        },
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
                  'LỊCH SỬ SỬA CHỮA',
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
      height: 6.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
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
            const SizedBox(width: 10), // Khoảng cách giữa title và text field
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none, // Loại bỏ đường viền mặc định
                  hintText: '',
                  // contentPadding: EdgeInsets.symmetric(vertical: 9),
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

class InfoColumn extends StatelessWidget {
  final String bienSo1;
  final String ngay; // Thời gian yêu cầu
  final String ngayXacNhan, ngayDeXuatHoanThanh, nguoiDeXuatHoanThanh; // Lý do đổi
  final String ngayDiSuaChua, tinhTrang; // Nhà xe
  final String ngayHoanThanh, nguoiYeuCau, nguoiXacNhan, nguoiDiSuaChua, nguoiXacNhanHoanThanh, noiDung, ketQua, chiPhi, tenDiaDiem;
  final VoidCallback onDongY; // Hành động khi bấm ĐỒNG Ý
  final bool isSelected, isSuaChua, isDuyet, isLenhHoanThanh, isHoanThanh, isYeuCau; // Trạng thái tích chọn
  final VoidCallback onLongPress; // Xử lý khi nhấn giữ
  final VoidCallback isChiTiet; // Xử lý khi nhấn giữ

  const InfoColumn({
    Key? key,
    required this.onDongY,
    required this.bienSo1,
    required this.ngay,
    required this.noiDung,
    required this.ketQua,
    required this.chiPhi,
    required this.tenDiaDiem,
    required this.ngayXacNhan,
    required this.ngayDiSuaChua,
    required this.ngayHoanThanh,
    required this.nguoiYeuCau,
    required this.nguoiXacNhan,
    required this.nguoiDiSuaChua,
    required this.nguoiXacNhanHoanThanh,
    required this.tinhTrang,
    required this.isSuaChua,
    required this.isLenhHoanThanh,
    required this.isDuyet,
    required this.isChiTiet,
    required this.nguoiDeXuatHoanThanh,
    required this.ngayDeXuatHoanThanh,
    required this.isSelected,
    required this.isYeuCau,
    required this.isHoanThanh,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(8.0), // Padding cho toàn bộ cột lớn
        decoration: BoxDecoration(
          color: Colors.white, // Màu nền cho cột lớn
          border: Border.all(color: Colors.grey.shade300), // Viền
          borderRadius: BorderRadius.circular(8), // Bo tròn góc
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dòng dưới cùng: Lý do đổi
                SelectableText(
                  bienSo1, // Nội dung TD
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red, // Màu xám cho nội dung YC
                  ),
                ),
              ],
            ),

            const SizedBox(height: 3),
            // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
            if (isYeuCau)
              InfoRow(
                title: "Ngày yêu cầu:",
                contentYC: ngay,
              ),
            if (isYeuCau)
              InfoRow(
                title: "Người yêu cầu:",
                contentYC: nguoiYeuCau,
              ),
            if (isDuyet)
              InfoRow(
                title: "Ngày xác nhận:",
                contentYC: ngayXacNhan,
              ),
            if (isDuyet)
              InfoRow(
                title: "Người xác nhận:",
                contentYC: nguoiXacNhan,
              ),
            if (isDuyet)
              InfoRow(
                title: "Ngày đi sửa chữa:",
                contentYC: ngayDiSuaChua,
              ),
            if (isSuaChua)
              InfoRow(
                title: "Người đi sửa chữa:",
                contentYC: nguoiDiSuaChua,
              ),
            if (isLenhHoanThanh)
              InfoRow(
                title: "Ngày đề xuất hoàn thành:",
                contentYC: ngayDeXuatHoanThanh,
              ),
            if (isLenhHoanThanh)
              InfoRow(
                title: "Người đề xuất hoàn thành:",
                contentYC: nguoiDeXuatHoanThanh,
              ),
            if (isHoanThanh)
              InfoRow(
                title: "Ngày hoàn thành:",
                contentYC: ngayHoanThanh,
              ),
            if (isHoanThanh)
              InfoRow(
                title: "Người xác nhận hoàn thành:",
                contentYC: nguoiXacNhanHoanThanh,
              ),

            InfoRow(
              title: "Ghi chú:",
              contentYC: ketQua,
            ),
            if (isLenhHoanThanh)
              InfoRow(
                title: "Chi phí:",
                contentYC: chiPhi,
              ),

            CustomRichText(
              title: "Trạng thái",
              content: tinhTrang,
            ),
            Row(
              children: [
                // Dòng dưới cùng: Lý do đổi
                const Text(
                  "Nội dung sửa chữa:", // Nội dung YC
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black, // Màu xám cho nội dung YC
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.info,
                    color: Colors.blue,
                  ),
                  onPressed: isChiTiet,
                ),
              ],
            ),
            if (isDuyet && !isSuaChua)
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Căn sát phải
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0), // Khoảng cách trên nút
                    child: Container(
                      width: 55.w,
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
                        onPressed: onDongY, // Hành động ĐỒNG Ý
                        child: const Text("ĐI SỬA CHỮA"),
                      ),
                    ),
                  ),
                ],
              ),
            if (!isLenhHoanThanh && isSuaChua)
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Căn sát phải
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0), // Khoảng cách trên nút
                    child: Container(
                      width: 80.w,
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
                        onPressed: onDongY, // Hành động ĐỒNG Ý
                        child: const Text("ĐỀ XUẤT HOÀN THÀNH SỬA CHỮA"),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
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
        SizedBox(height: 3),
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
                // color: title != "Lý do từ chối" ? Colors.grey : Colors.red, // Màu xám cho nội dung
                color: Colors.green),
          ),
        ],
      ),
    );
  }
}

Widget buildRichText(String title, String? data) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '🔹 $title ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold, // Tiêu đề đậm
            color: Colors.black, // Màu đen cho tiêu đề
          ),
        ),
        TextSpan(
          text: data ?? 'N/A',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold, // Dữ liệu bình thường
            color: Colors.blue, // Màu xanh cho dữ liệu
          ),
        ),
      ],
    ),
  );
}

Widget buildInputWithError({required String title, required TextEditingController controller, bool showError = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ItemGhiChu(
        title: title,
        controller: controller,
      ),
      if (showError)
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 4),
          child: Text(
            'Bạn chưa nhập $title',
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ),
      const Divider(height: 1, color: Color(0xFFCCCCCC)),
    ],
  );
}
