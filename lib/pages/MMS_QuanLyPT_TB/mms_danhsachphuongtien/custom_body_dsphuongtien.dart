import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';
import '../../../blocs/user_bloc.dart';
import '../../../config/config.dart';
import '../../../models/checksheet.dart';
import '../../../models/diadiem.dart';
import '../../../models/kehoach.dart';
import '../../../models/kehoachgiaoxe_ls.dart';
import '../../../models/mms/dsphuongtien.dart';
import '../../../models/mms/hangmuc.dart';
import '../../../models/mms/lichsubaoduong.dart';
import '../../../services/app_service.dart';
import '../../../services/request_helper_mms.dart';
import '../../../utils/delete_dialog.dart';
import '../../../widgets/loading.dart';
import '../quanlyphuongtien_QLNew/quanlyphuongtien_canhan.dart';
import 'package:collection/collection.dart';

class CustomBodyDanhSachPhuongTien extends StatelessWidget {
  CustomBodyDanhSachPhuongTien();
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyDanhSachPhuongTienScreen(
      lstFiles: [],
    ));
  }
}

class BodyDanhSachPhuongTienScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyDanhSachPhuongTienScreen({super.key, required this.lstFiles});

  @override
  _BodyDanhSachPhuongTienScreenState createState() => _BodyDanhSachPhuongTienScreenState();
}

class _BodyDanhSachPhuongTienScreenState extends State<BodyDanhSachPhuongTienScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelperMMS requestHelper = RequestHelperMMS();

  bool _loading = false;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  late UserBloc? _ub;
  bool _IsXacNhan = false;
  bool _errorChiPhiBD = false;
  bool _errorHinhAnh = false;
  bool _errorChiPhiSC = false;
  bool _IsKhac = false;

  List<PhuongTienModel>? _kehoachList;
  List<PhuongTienModel>? get kehoachList => _kehoachList;
  List<PhuongTienModel>? _lenhHoanThanhList;
  List<PhuongTienModel>? get lenhHoanThanhList => _lenhHoanThanhList;
  List<PhuongTienModel>? _phuongtien;
  List<PhuongTienModel>? get phuongtien => _phuongtien;
  List<PhuongTienModel>? _phuongtienList;
  List<PhuongTienModel>? get phuongtienList => _phuongtienList;
  LichSuBaoDuongModel? _data;
  List<bool> selectedItems = [];
  bool selectAll = false;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController soKMController = TextEditingController();
  final TextEditingController _ghiChu = TextEditingController();
  final TextEditingController _vattu = TextEditingController();
  final TextEditingController _tongChiPhiBD = TextEditingController();
  final TextEditingController _tongChiPhiSC = TextEditingController();
  final TextEditingController _tongChiPhi = TextEditingController();
  TextEditingController newHangMucController = TextEditingController();
  Map<String, TextEditingController> chiphiControllers = {};
  String? body;
  List<KeHoachGiaoXeLSModel>? _kehoachlsList;
  List<KeHoachGiaoXeLSModel>? get kehoachlsList => _kehoachlsList;
  KeHoachModel? _thongbao;
  List<HangMucModel>? _hangmucList;
  List<HangMucModel>? get hangmucList => _hangmucList;
  List<HangMucModel>? _hangmucscList;
  List<HangMucModel>? get hangmucscList => _hangmucscList;
  List<dynamic> _selectedItems = [];
  List<dynamic> _selectedSCItems = [];
  List<DiaDiemModel>? _dn;
  List<DiaDiemModel>? get dn => _dn;
  String? DiaDiem_Id;
  String? PhuongTien_Id;
  String? selectedDate;
  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();
  List<String> _addedHangMuc = [];
  String? _previousPhuongTienId;
  ValueNotifier<List<FileItem>> lstFilesNotifier = ValueNotifier<List<FileItem>>([]);
  List<HangMucModel>? _hangmucListnew;
  List<HangMucModel>? get hangmucListnew => _hangmucListnew;
  List<dynamic> _selectedItemsnew = [];

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
    getBienSo();
    getBienSoKhongQuanLy();
    // getDiaDiem();
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

  _removeImage2(FileItem image, int index) {
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

  Future<void> getDiaDiem(StateSetter dialogSetState) async {
    _dn = [];
    dialogSetState(() {});
    try {
      final http.Response response = await requestHelper.getData('MMS_DM_SuaChua');
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

  Future<void> getHangMucSC(StateSetter dialogSetState) async {
    print("datahangmuchang");
    _loading = true;
    dialogSetState(() {});
    try {
      final http.Response response = await requestHelper.getData('MMS_DM_HangMuc/HangMucSuaChua');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _hangmucscList = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
        setState(() {
          // _selectedSCItems = List.from(_hangmucscList!);
          _loading = false;
        });
        dialogSetState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("datahangmuc999:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> getHangMuc(String? phuongTien_Id, StateSetter dialogSetState) async {
    print("datahangmuchang");
    _loading = true;
    dialogSetState(() {});
    try {
      final http.Response response = await requestHelper.getData('MMS_ThongTinTheoHangMuc/DSHangMuc?Id_PhuongTien=$phuongTien_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _hangmucList = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
        setState(() {
          _selectedItems = List.from(_hangmucList!.where((item) => item.isDenHan == true));
          _loading = false;
        });
        dialogSetState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("datahangmuc999:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> getListThayDoiKHDiGap() async {
    setState(() {
      _isLoading = true;
      _kehoachlsList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/DanhSachYeuCau');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachlsList = (decodedData as List).map((item) => KeHoachGiaoXeLSModel.fromJson(item)).toList();
          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
            selectedItems = List.filled(_kehoachlsList?.length ?? 0, false);
          });
        }
      } else {
        _kehoachlsList = [];
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

  Future<void> getBienSo() async {
    _loading = true;

    try {
      final http.Response response = await requestHelper.getData('MMS_DS_PhuongTien/GetListPhuongTienTheoCaNhan?User_Id=${_ub?.id}');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _kehoachList = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).toList();
        // getHangMuc();
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("databienso2:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> getListYeuCauSC() async {
    setState(() {
      _isLoading = true;
      _kehoachlsList = [];
      // Làm sạch danh sách cũ trước khi tải mới
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_SuaChua/DanhSachYeuCau');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _kehoachlsList = (decodedData as List).map((item) => KeHoachGiaoXeLSModel.fromJson(item)).toList();
          // Gọi setState để cập nhật giao diện
          setState(() {
            _loading = false;
            // selectedItems = List.filled(_kehoachlsList?.length ?? 0, false);
          });
        }
      } else {
        _kehoachlsList = [];
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

  Future<void> getLenhHoanThanh() async {
    _loading = true;
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/DanhSachYeuCauHoanThanh');
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

  Future<void> getLenhHoanThanhSC() async {
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

  Future<void> getBienSoKhongQuanLy() async {
    _loading = true;
    try {
      final http.Response response = await requestHelper.getData('MMS_DS_PhuongTien/GetPhuongTienKhongQuanLy');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _phuongtien = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).toList();
        // getHangMuc();
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("databienso2:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> GetListPhuongTienKhongQuanLy(String? phuongTien_Id) async {
    _loading = true;
    try {
      final http.Response response = await requestHelper.getData('MMS_DS_PhuongTien/GetListPhuongTienKhongQuanLy?PhuongTien_Id=$phuongTien_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _phuongtienList = (decodedData as List).map((item) => PhuongTienModel.fromJson(item)).toList();
        // getHangMuc();
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      print("databienso2:${e..toString()}");
      _errorCode = e.toString();
    }
  }

  Future<void> postDataFireBase(KeHoachModel? scanData, String? body, String? id) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData?.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      final http.Response response = await requestHelper.postData('MMS_Notification/PushThongBao?body=$body&listIds=$id', newScanData?.toJson());
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

  Future<void> postDataFireBaseSC(KeHoachModel? scanData, String? body, String? id) async {
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

  Future<void> postData(LichSuBaoDuongModel? scanData, String? ngayDiBaoDuong, List<String> selectedIds, String? file, List<String> addHangMuc, bool? isKhac) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData.bienSo1 == 'null' ? null : newScanData.bienSo1;
      var dataList = [newScanData];
      final http.Response response = await requestHelper.postData(
          'MMS_BaoCao/YeuCauBaoDuong?ids=${selectedIds.join("&ids=")}&addHangMuc=${addHangMuc.join("&addHangMuc=")}&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&NgayDiBaoDuong=$ngayDiBaoDuong&HinhAnh=$file&IsKhac=$isKhac', dataList.map((e) => e?.toJson()).toList());
      print("code: ${response.statusCode}");
      print("Response body: ${response.body}");
      print("Dữ liệu gửi lên:");
      print(jsonEncode(dataList.map((e) => e?.toJson()).toList()));
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
              Navigator.pop(context); // Đóng dialog cũ (nếu cần)
              Navigator.pop(context);
            });
        _selectedItems.clear();
        _btnController.reset();
        await getListThayDoiKHDiGap();
        body = "Bạn đã có ${_kehoachlsList?.length.toString() ?? ""} yêu cầu bảo dưỡng phương tiện";
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

  _onSave(int index, List<dynamic> selectedItems, List<String> addedHangMuc, bool? isKhac) async {
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
    List<String> selectedIds = selectedItems.map((e) => e.hangMuc_Id.toString()).toList();
    print("Danh sách ID đã chọn: $selectedIds");
    print("Hạng mục nhập tay thêm: $addedHangMuc");
    PhuongTienModel? item;
    if (isKhac == false) {
      item = _kehoachList?[index];
    } else {
      item = _phuongtienList?[index];
    }

    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    var uuid = Uuid();
    _data?.id = uuid.v4();
    // _data?.id = item?.id;
    _data?.phuongTien_Id = item?.id;
    _data?.baoDuong_Id = item?.model_Id;
    _data?.soKM = item?.soKM_Adsun;
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
        postData(_data!, selectedDate, selectedIds, imageUrlsString, addedHangMuc, isKhac).then((_) {
          setState(() {
            _IsXacNhan = false;
            _IsKhac = false;
            PhuongTien_Id = null;
            getBienSo();
            postDataFireBase(_thongbao, body ?? "", _data?.phuongTien_Id);
            _data = null;
            _phuongtienList = null;
            DiaDiem_Id = null;
            _loading = false;
            _addedHangMuc = [];
            selectedIds = [];
          });
        });
      }
    });
  }

  void _showDetailsDialog(BuildContext context, int index, bool? isKhac, String? id) {
    // final phuongTienId = _kehoachList?[index].id; // Lấy ID của phương tiện
    final phuongTienId = id;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_hangmucscList == null || _hangmucscList!.isEmpty) {
              getHangMucSC(setState);
            }
            if (_hangmucList == null || _hangmucList!.isEmpty) {
              getHangMuc(phuongTienId ?? "", setState);
              getDiaDiem(setState);
            }
            if (_previousPhuongTienId != phuongTienId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = phuongTienId;
              getHangMuc(phuongTienId ?? "", setState);
            }
            TextEditingController _selectedController = TextEditingController(
              // text: _selectedItems.map((e) => e.noiDungBaoDuong).join(', '),
              text: [..._selectedItems.map((e) => e.noiDungBaoDuong), ..._addedHangMuc].join(', '),
            );

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
                                'YÊU CẦU BẢO DƯỠNG',
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
                      TextField(
                        controller: _selectedController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Danh sách hạng mục",
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () {
                          // _showHangMucPopup(context, setState, _selectedController);
                          if (_hangmucList != null && _hangmucList!.isNotEmpty) {
                            _showHangMucPopup(context, setState, _selectedController);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang tải danh sách hạng mục...")));
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                                  "TT Bảo dưỡng",
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
                                        setState(() {
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngày đi bảo dưỡng',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
                                lastDate: DateTime(2100),
                              );

                              if (picked != null) {
                                setState(() {
                                  // Cập nhật UI ngay lập tức
                                  selectedDate = DateFormat('dd/MM/yyyy').format(picked);
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFBC2925)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, color: Color(0xFFBC2925)),
                                  SizedBox(width: 8),
                                  Text(
                                    selectedDate ?? 'Chọn ngày',
                                    style: TextStyle(color: Color(0xFFBC2925)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                      SizedBox(height: 10),
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
                          onPressed: (selectedDate != null && DiaDiem_Id != null) ? () => _onSave(index, _selectedItems, _addedHangMuc, isKhac) : null,
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

  Future<void> getListChiTietHangMuc2(String? phuongTien_Id, StateSetter dialogSetState) async {
    print("datamms:${phuongTien_Id}");
    _isLoading = true;
    dialogSetState(() {});
    // Làm sạch danh sách cũ trước khi tải mới
    try {
      final http.Response response = await requestHelper.getData('MMS_ThongTinTheoHangMuc/DSHangMucYeuCau?Id_PhuongTien=$phuongTien_Id');
      print("datamms5:${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        if (decodedData != null) {
          _hangmucListnew = (decodedData as List).map((item) => HangMucModel.fromJson(item)).toList();
          // Gọi setState để cập nhật giao diện

          dialogSetState(() {
            _selectedItemsnew = List.from(_hangmucListnew!.where((item) => item.isDenHan == true));
            _loading = false;
          });
        }
      } else {
        _hangmucListnew = [];
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

  Future<void> postDataDuyet(LichSuBaoDuongModel scanData, String? ngayDiBaoDuong, List<String> selectedIds, List<String> addHangMuc) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.bienSo1 = newScanData.bienSo1 == 'null' ? null : newScanData.bienSo1;

      var dataList = [newScanData];
      print("idssss: ${selectedIds}");
      final http.Response response =
          await requestHelper.postData('MMS_BaoCao/ChinhSuaYeuCau?ids=${selectedIds.join("&ids=")}&NgayDiBaoDuong=$ngayDiBaoDuong&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&addHangMuc=${addHangMuc.join("&addHangMuc=")}', dataList.map((e) => e.toJson()).toList());
      print("statusCode: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        print("text: ${_textController.text}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: "Xác nhận thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              if (_textController.text == "") {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
              if (_textController.text != "") {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                setState(() {
                  _textController.text = "";
                });
              }
            });
        _btnController.reset();
        // await getListThayDoiKH(widget.id, soKhungController.text);
        body = "Bạn vừa được xác nhận 1 yêu cầu bảo dưỡng phương tiện";
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
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  _onSaveXacNhan(int index, List<dynamic> selectedItems, List<String> addedHangMuc) async {
    setState(() {
      _loading = true;
    });
    List<String> selectedIds = selectedItems.map((e) => e.hangMuc_Id.toString()).toList();
    print("Danh sách ID đã chọn: $selectedIds");
    print("Hạng mục nhập tay thêm: $addedHangMuc");
    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    print("ngay = ${selectedDate}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.lichSuBaoDuong_Id;
    _data?.phuongTien_Id = item?.id;
    _data?.soKM = item?.soKM;
    _data?.diaDiem_Id = DiaDiem_Id;
    // _data?.keHoachGiaoXe_Id = item?.keHoachGiaoXe_Id;
    // _data?.nguoiYeuCau = item?.nguoiYeuCau;

    // if (_IsXacNhan == true) {
    //   _data?.trangThai = "1";
    // }
    // if (_IsTuChoi == true) {
    //   _data?.trangThai = "2";
    // }

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
        postDataDuyet(_data!, selectedDate, selectedIds, addedHangMuc).then((_) {
          setState(() {
            _IsXacNhan = false;
            selectedIds = [];
            getBienSo();

            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogYeuCau2(BuildContext context, int index) {
    final baoduongId = _kehoachList?[index].id;
    final bienSo1 = _kehoachList?[index].bienSo1;
    final image = _kehoachList?[index]?.hinhAnh;

    DiaDiem_Id = _kehoachList?[index].diaDiem_Id;
    selectedDate = _kehoachList?[index].ngayDiBaoDuong;
    print("abc:${baoduongId}, ${_hangmucListnew}");
    print("diadiem ${DiaDiem_Id}");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            if (_hangmucListnew == null || _hangmucListnew!.isEmpty) {
              getListChiTietHangMuc2(baoduongId ?? "", setStateDialog);
              getDiaDiem(setStateDialog);
            }

            if (_previousPhuongTienId != baoduongId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = baoduongId;
              getListChiTietHangMuc2(baoduongId ?? "", setStateDialog);
            }
            if (_hangmucscList == null || _hangmucscList!.isEmpty) {
              getHangMucSC(setStateDialog);
            }

            // text
            TextEditingController _selectedController = TextEditingController(
              // text: _selectedItemsnew.map((e) => e.noiDungBaoDuong).join(', '),
              text: [..._selectedItemsnew.map((e) => e.noiDungBaoDuong), ..._addedHangMuc].join(', '),
            );
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            // Giúp text co giãn mà không làm tràn
                            child: Text(
                              'Chỉnh sửa yêu cầu phương tiện ${bienSo1}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              overflow: TextOverflow.ellipsis, // Cắt nếu quá dài
                              maxLines: 1, // Chỉ hiển thị 1 dòng
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () => {Navigator.pop(context)},
                          ),
                        ],
                      ),
                      TextField(
                        controller: _selectedController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Danh sách hạng mục",
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () {
                          _showHangMucPopup2(context, setStateDialog, _selectedController);
                        },
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
                                  "TT Bảo dưỡng",
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngày đi bảo dưỡng',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
                                lastDate: DateTime(2100),
                              );

                              if (picked != null) {
                                setStateDialog(() {
                                  // Cập nhật UI ngay lập tức
                                  selectedDate = DateFormat('dd/MM/yyyy').format(picked);
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFBC2925)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, color: Color(0xFFBC2925)),
                                  SizedBox(width: 8),
                                  Text(
                                    selectedDate ?? 'Chọn ngày',
                                    style: TextStyle(color: Color(0xFFBC2925)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 10),
                      if (image != null)
                        Row(
                          children: [
                            const Text(
                              "Hình ảnh:",
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(child: _buildTableHinhAnh(image ?? "")),
                          ],
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
                              onPressed: (selectedDate != null && DiaDiem_Id != null) ? () => _onSaveXacNhan(index, _selectedItemsnew, _addedHangMuc) : null,
                            ),
                          ],
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

  void _showHangMucPopup2(BuildContext context, StateSetter parentSetState, TextEditingController controller) {
    String searchTerm = '';
    bool isExpanded = true; // trạng thái mở rộng danh sách
    bool isExpanded2 = true; // trạng thái mở rộng danh sách
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn bấm ra ngoài để đóng
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            final filteredList = _hangmucscList!.where((item) => searchTerm.isEmpty || (item.noiDungBaoDuong?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false)).toList();
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              insetPadding: EdgeInsets.all(10), // Giảm khoảng cách với viền màn hình
              child: Container(
                width: MediaQuery.of(context).size.width, // Full chiều rộng
                height: MediaQuery.of(context).size.height, // Full chiều cao
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với dấu X đóng
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              setStateDialog(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  "Chọn hạng mục bảo dưỡng",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    // Nội dung danh sách checkbox
                    if (isExpanded)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _hangmucListnew!.where((item) => item.isBaoDuong == true).map((item) {
                                bool isChecked = _selectedItemsnew.any((e) => e.hangMuc_Id == item.hangMuc_Id);
                                return CheckboxListTile(
                                  title: Text(item.noiDungBaoDuong ?? "",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold, // Tiêu đề đậm
                                          color: Colors.blue)), // Màu đen cho tiêu đề),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildRichText('Định mức:', item?.dinhMuc),
                                      buildRichText('Loại bảo dưỡng:', item?.loaiBaoDuong),
                                      buildRichText('Gía trị hiện tại:', item?.soKM),
                                      buildRichText('Gía trị ngày bảo dưỡng gần nhất:', item?.giaTriBaoDuong),
                                      buildRichText('Gía trị đã đi được/ngày bảo dương:', item?.soKM_DaDiDuoc),
                                      buildRichText('Gía trị còn lại :', item?.soKM_CanDenHan),
                                      buildRichText('Tiêu chí:', item?.tieuChi),
                                    ],
                                  ),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setStateDialog(() {
                                      if (value == true) {
                                        _selectedItemsnew.add(item);
                                      } else {
                                        _selectedItemsnew.removeWhere((e) => e.hangMuc_Id == item.hangMuc_Id);
                                      }
                                    });

                                    // Cập nhật UI của dialog chính
                                    parentSetState(() {
                                      controller.text = _selectedItemsnew.map((e) => e.noiDungBaoDuong).join(', ');
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setStateDialog(() {
                                isExpanded2 = !isExpanded2;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  "Hạng mục sửa chữa",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  isExpanded2 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          if (_hangmucListnew!.where((item) => item.isBaoDuong == false).isNotEmpty && isExpanded2)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _hangmucListnew!.where((item) => item.isBaoDuong == false && item.isDenHan == true).map((item) {
                                bool isChecked = _selectedItemsnew.any((e) => e.hangMuc_Id == item.hangMuc_Id);
                                return CheckboxListTile(
                                  title: Text(
                                    item.noiDungBaoDuong ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold, // Tiêu đề đậm
                                      color: Colors.blue, // Màu đen cho tiêu đề
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildRichText('Ghi chú:', item?.ghiChu ?? ""),
                                    ],
                                  ),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setStateDialog(() {
                                      if (value == true) {
                                        _selectedItemsnew.add(item);
                                      } else {
                                        _selectedItemsnew.removeWhere((e) => e.hangMuc_Id == item.hangMuc_Id);
                                      }
                                    });

                                    // Cập nhật UI của dialog chính
                                    parentSetState(() {
                                      controller.text = _selectedItemsnew.map((e) => e.noiDungBaoDuong).join(', ');
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: newHangMucController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Nhập hạng mục mới",
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          searchTerm = value;
                        });
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          List<String> items = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                          setStateDialog(() {
                            // _addedHangMuc = items;
                            _addedHangMuc.addAll(items.where((e) => !_addedHangMuc.contains(e)));
                            newHangMucController.clear();
                            print("Danh sách hạng mục thêm tay:");
                            print(_addedHangMuc);
                          });

                          parentSetState(() {
                            controller.text = [..._addedHangMuc].join(', ');
                          });
                          print(controller.text);
                        }
                      },
                    ),
                    if (isExpanded2)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                children: _addedHangMuc.map((e) {
                                  return Chip(
                                    label: Text(e),
                                    onDeleted: () {
                                      setStateDialog(() {
                                        _addedHangMuc.remove(e);
                                        final currentText = newHangMucController.text;
                                        final updatedText = currentText.split(',').map((s) => s.trim()).where((word) => word != e && word.isNotEmpty).join(', ');
                                        newHangMucController.text = updatedText;
                                        _selectedSCItems.removeWhere((s) => s.noiDungBaoDuong == e);
                                      });
                                      parentSetState(() {
                                        // controller.text = [..._addedHangMuc].join(', ');
                                        controller.text = [..._selectedSCItems.map((e) => e.noiDungBaoDuong), ..._addedHangMuc].where((e) => e.isNotEmpty).join(', ');
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              Container(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: filteredList.map((item) {
                                        bool isChecked = _selectedSCItems.any((e) => e.id == item.id);
                                        return CheckboxListTile(
                                            title: Text(item.noiDungBaoDuong ?? ""),
                                            value: isChecked,
                                            onChanged: (bool? value) {
                                              setStateDialog(() {
                                                if (value == true) {
                                                  _selectedSCItems.add(item);
                                                  if (!_addedHangMuc.contains(item.noiDungBaoDuong)) {
                                                    _addedHangMuc.add(item.noiDungBaoDuong ?? "");
                                                  }
                                                } else {
                                                  _selectedSCItems.removeWhere((e) => e.id == item.id);
                                                  _addedHangMuc.remove(item.noiDungBaoDuong ?? "");
                                                }

                                                // Cập nhật lại controller text cho field chính
                                                parentSetState(() {
                                                  controller.text = [
                                                    ..._selectedSCItems.map((e) => e.noiDungBaoDuong),
                                                    ..._addedHangMuc.where((e) => !_selectedSCItems.any((s) => s.noiDungBaoDuong == e)),
                                                  ].where((e) => e.isNotEmpty).join(', ');
                                                });

                                                // 👇 Cập nhật luôn newHangMucController để hiển thị text trên ô nhập
                                                // newHangMucController.text = [
                                                //   ..._selectedSCItems.map((e) => e.noiDungBaoDuong),
                                                //   ..._addedHangMuc.where((e) => !_selectedSCItems.any((s) => s.noiDungBaoDuong == e)),
                                                // ].where((e) => e.isNotEmpty).join(', ');
                                              });
                                            });
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Nút Xong
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Xong", style: TextStyle(fontSize: 16)),
                        ),
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

  void _showHangMucPopup(BuildContext context, StateSetter parentSetState, TextEditingController controller) {
    String searchTerm = '';
    String searchTerm2 = '';
    bool isExpanded = true; // trạng thái mở rộng danh sách
    bool isExpanded2 = true; // trạng thái mở rộng danh sách
    // TextEditingController newHangMucController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn bấm ra ngoài để đóng
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            final filteredList = _hangmucscList!.where((item) => searchTerm.isEmpty || (item.noiDungBaoDuong?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false)).toList();
            final filteredList2 = _hangmucList!.where((item) => searchTerm2.isEmpty || (item.noiDungBaoDuong?.toLowerCase().contains(searchTerm2.toLowerCase()) ?? false)).toList();
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              insetPadding: EdgeInsets.all(10), // Giảm khoảng cách với viền màn hình
              child: Container(
                width: MediaQuery.of(context).size.width, // Full chiều rộng
                height: MediaQuery.of(context).size.height, // Full chiều cao
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với dấu X đóng
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // const Text(
                          //   "Chọn hạng mục bảo dưỡng",
                          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          // ),
                          InkWell(
                            onTap: () {
                              setStateDialog(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  "Chọn hạng mục bảo dưỡng",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm hạng mục...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          searchTerm2 = value;
                        });
                      },
                    ),
                    Divider(),
                    // Nội dung danh sách checkbox
                    if (isExpanded)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: filteredList2!.sorted((a, b) {
                                bool aChecked = _selectedItems.any((e) => e.hangMuc_Id == a.hangMuc_Id);
                                bool bChecked = _selectedItems.any((e) => e.hangMuc_Id == b.hangMuc_Id);
                                // Nếu a được tick mà b không => a đứng trước => return -1
                                if (aChecked && !bChecked) return -1;
                                if (!aChecked && bChecked) return 1;
                                return 0; // giữ nguyên thứ tự nếu cả hai đều tick hoặc đều chưa tick
                              }).map((item) {
                                bool isChecked = _selectedItems.any((e) => e.hangMuc_Id == item.hangMuc_Id);
                                return CheckboxListTile(
                                  title: Text(item.noiDungBaoDuong ?? ""),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setStateDialog(() {
                                      if (value == true) {
                                        _selectedItems.add(item);
                                      } else {
                                        _selectedItems.removeWhere((e) => e.hangMuc_Id == item.hangMuc_Id);
                                      }
                                    });
                                    // Cập nhật UI của dialog chính
                                    parentSetState(() {
                                      controller.text = _selectedItems.map((e) => e.noiDungBaoDuong).join(', ');
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    // Thêm hạng mục sửa chữa
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text("Thêm hạng mục sửa chữa:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    //       SizedBox(height: 5),
                    //       // TextField(
                    //       //   controller: newHangMucController,
                    //       //   decoration: const InputDecoration(
                    //       //     border: OutlineInputBorder(),
                    //       //     hintText: "Nhập hạng mục mới",
                    //       //   ),
                    //       //   onSubmitted: (value) {
                    //       //     // Tùy chọn: bạn có thể thêm vào danh sách _hangmucList ở đây
                    //       //     // hoặc xử lý logic khác theo nhu cầu.
                    //       //     print("Đã nhập hạng mục mới: $value");
                    //       //   },
                    //       // ),
                    //       TextField(
                    //         controller: newHangMucController,
                    //         decoration: const InputDecoration(
                    //           border: OutlineInputBorder(),
                    //           hintText: "Nhập hạng mục mới",
                    //         ),
                    //         onSubmitted: (value) {
                    //           if (value.trim().isNotEmpty) {
                    //             List<String> items = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

                    //             setStateDialog(() {
                    //               _addedHangMuc = items;
                    //               // newHangMucController.clear();
                    //               print("Danh sách hạng mục thêm tay:");
                    //               print(_addedHangMuc);
                    //               print(_selectedItems.map((e) => e.noiDungBaoDuong));
                    //             });

                    //             parentSetState(() {
                    //               controller.text = [..._selectedItems.map((e) => e.noiDungBaoDuong), ..._addedHangMuc].join(', ');
                    //             });
                    //             print(controller.text);
                    //           }
                    //         },
                    //       ),

                    //       if (_addedHangMuc.isNotEmpty)
                    //         // Padding(
                    //         //   padding: const EdgeInsets.only(top: 10),
                    //         //   child: Wrap(
                    //         //     spacing: 6,
                    //         //     children: _addedHangMuc.map((e) =>
                    //         //      Chip(label: Text(e))).toList(),
                    //         //   ),
                    //         // ),
                    //         Padding(
                    //           padding: const EdgeInsets.only(top: 10),
                    //           child: Wrap(
                    //             spacing: 6,
                    //             children: _addedHangMuc.map((e) {
                    //               return Chip(
                    //                 label: Text(e),
                    //                 onDeleted: () {
                    //                   setStateDialog(() {
                    //                     _addedHangMuc.remove(e);
                    //                     final currentText = newHangMucController.text;
                    //                     final updatedText = currentText.split(',').map((s) => s.trim()).where((word) => word != e && word.isNotEmpty).join(', ');
                    //                     newHangMucController.text = updatedText;
                    //                   });
                    //                   parentSetState(() {
                    //                     controller.text = [..._selectedItems.map((e) => e.noiDungBaoDuong), ..._addedHangMuc].join(', ');
                    //                   });
                    //                 },
                    //               );
                    //             }).toList(),
                    //           ),
                    //         ),
                    //     ],
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // const Text(
                          //   "Chọn hạng mục bảo dưỡng",
                          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          // ),
                          InkWell(
                            onTap: () {
                              setStateDialog(() {
                                isExpanded2 = !isExpanded2;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  "Chọn hạng mục sửa chữa",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: newHangMucController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Nhập hạng mục mới",
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          searchTerm = value;
                        });
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          List<String> items = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                          setStateDialog(() {
                            // _addedHangMuc = items;
                            _addedHangMuc.addAll(items.where((e) => !_addedHangMuc.contains(e)));
                            newHangMucController.clear();
                            print("Danh sách hạng mục thêm tay:");
                            print(_addedHangMuc);
                          });

                          parentSetState(() {
                            controller.text = [..._addedHangMuc].join(', ');
                          });
                          print(controller.text);
                        }
                      },
                    ),
                    if (isExpanded2)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                children: _addedHangMuc.map((e) {
                                  return Chip(
                                    label: Text(e),
                                    onDeleted: () {
                                      setStateDialog(() {
                                        _addedHangMuc.remove(e);
                                        final currentText = newHangMucController.text;
                                        final updatedText = currentText.split(',').map((s) => s.trim()).where((word) => word != e && word.isNotEmpty).join(', ');
                                        newHangMucController.text = updatedText;
                                        _selectedSCItems.removeWhere((s) => s.noiDungBaoDuong == e);
                                      });
                                      parentSetState(() {
                                        // controller.text = [..._addedHangMuc].join(', ');
                                        controller.text = [..._selectedSCItems.map((e) => e.noiDungBaoDuong), ..._addedHangMuc].where((e) => e.isNotEmpty).join(', ');
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              Container(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: filteredList.map((item) {
                                        bool isChecked = _selectedSCItems.any((e) => e.id == item.id);
                                        return CheckboxListTile(
                                            title: Text(item.noiDungBaoDuong ?? ""),
                                            value: isChecked,
                                            // onChanged: (bool? value) {
                                            //   setStateDialog(() {
                                            //     if (value == true) {
                                            //       _selectedSCItems.add(item);
                                            //       if (!_addedHangMuc.contains(item.noiDungBaoDuong)) {
                                            //         _addedHangMuc.add(item.noiDungBaoDuong ?? "");
                                            //       }
                                            //     } else {
                                            //       _selectedSCItems.removeWhere((e) => e.id == item.id);
                                            //       _addedHangMuc.remove(item.noiDungBaoDuong ?? "");
                                            //     }
                                            //   });

                                            //   // Cập nhật UI của dialog chính
                                            //   // parentSetState(() {
                                            //   //   controller.text = _selectedSCItems.map((e) => e.noiDungBaoDuong).join(', ');
                                            //   // });
                                            //   parentSetState(() {
                                            //     controller.text = [
                                            //       ..._selectedSCItems.map((e) => e.noiDungBaoDuong),
                                            //       ..._addedHangMuc.where((e) => !_selectedSCItems.any((s) => s.noiDungBaoDuong == e)),
                                            //     ].where((e) => e.isNotEmpty).join(', ');
                                            //   });
                                            // },
                                            onChanged: (bool? value) {
                                              setStateDialog(() {
                                                if (value == true) {
                                                  _selectedSCItems.add(item);
                                                  if (!_addedHangMuc.contains(item.noiDungBaoDuong)) {
                                                    _addedHangMuc.add(item.noiDungBaoDuong ?? "");
                                                  }
                                                } else {
                                                  _selectedSCItems.removeWhere((e) => e.id == item.id);
                                                  _addedHangMuc.remove(item.noiDungBaoDuong ?? "");
                                                }

                                                // Cập nhật lại controller text cho field chính
                                                parentSetState(() {
                                                  controller.text = [
                                                    ..._selectedSCItems.map((e) => e.noiDungBaoDuong),
                                                    ..._addedHangMuc.where((e) => !_selectedSCItems.any((s) => s.noiDungBaoDuong == e)),
                                                  ].where((e) => e.isNotEmpty).join(', ');
                                                });

                                                // 👇 Cập nhật luôn newHangMucController để hiển thị text trên ô nhập
                                                // newHangMucController.text = [
                                                //   ..._selectedSCItems.map((e) => e.noiDungBaoDuong),
                                                //   ..._addedHangMuc.where((e) => !_selectedSCItems.any((s) => s.noiDungBaoDuong == e)),
                                                // ].where((e) => e.isNotEmpty).join(', ');
                                              });
                                            });
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Nút Xong
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Xong",
                              style: TextStyle(
                                fontSize: 16,
                              )),
                        ),
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

  Future<void> postDataSC(LichSuBaoDuongModel? scanData, String? ngayDiBaoDuong, String? file, List<String> addHangMuc, bool? isKhac) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData.bienSo1 == 'null' ? null : newScanData.bienSo1;
      var dataList = [newScanData];
      final http.Response response =
          await requestHelper.postData('MMS_SuaChua/YeuCauSuaChua?addHangMuc=${addHangMuc.join("&addHangMuc=")}&TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&NgayDiSuaChua=$ngayDiBaoDuong&HinhAnh=$file&IsKhac=$isKhac', dataList.map((e) => e?.toJson()).toList());
      print("code: ${response.statusCode}");

      print("Response body: ${response.body}");
      print("Dữ liệu gửi lên:");
      print(jsonEncode(dataList.map((e) => e?.toJson()).toList()));
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
              Navigator.pop(context); // Đóng dialog cũ (nếu cần)
              Navigator.pop(context);
            });
        _selectedItems.clear();
        _btnController.reset();
        await getListYeuCauSC();
        body = "Bạn đã có ${_kehoachlsList?.length.toString() ?? ""} yêu cầu sửa chữa phương tiện";
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

  _onSaveSC(int index, List<String> addedHangMuc, bool? isKhac) async {
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
        }
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
    print("image:$imageUrlsString");
    print("Hạng mục nhập tay thêm: $addedHangMuc");

    // final item = _kehoachList?[index];
    PhuongTienModel? item;
    if (isKhac == false) {
      item = _kehoachList?[index];
    } else {
      item = _phuongtienList?[index];
    }
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    var uuid = Uuid();
    _data?.id = uuid.v4();
    // _data?.id = item?.id;
    _data?.phuongTien_Id = item?.id;
    _data?.baoDuong_Id = item?.model_Id;
    _data?.soKM = item?.soKM_Adsun;
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
        postDataSC(_data!, selectedDate, imageUrlsString, addedHangMuc, isKhac).then((_) {
          setState(() {
            _IsXacNhan = false;
            _IsKhac = false;
            PhuongTien_Id = null;
            _phuongtienList = null;
            getBienSo();
            postDataFireBaseSC(_thongbao, body ?? "", _data?.phuongTien_Id);
            _data = null;
            DiaDiem_Id = null;
            _loading = false;
            _addedHangMuc = [];
          });
        });
      }
    });
  }

  void _showDetailsDialogSC(BuildContext context, int index, bool? isKhac, String? id) {
    // final phuongTienId = _kehoachList?[index].id; // Lấy ID của phương tiện
    final phuongTienId = id;
    bool _isFetching = false;
    bool _dialogIsStillOpen = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_dn == null || _dn!.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                getDiaDiem(setState);
              });
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_isFetching && _dialogIsStillOpen && (_hangmucscList == null || _hangmucscList!.isEmpty)) {
                _isFetching = true;
                getHangMucSC(setState);
              }
            });
            // if (_hangmucscList == null || _hangmucscList!.isEmpty) {
            //   getHangMucSC(setState);
            // }
            TextEditingController _selectedController = TextEditingController(
              // text: _selectedItems.map((e) => e.noiDungBaoDuong).join(', '),
              text: [..._addedHangMuc].join(', '),
            );

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
                                'YÊU CẦU SỬA CHỮA',
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
                      TextField(
                        controller: _selectedController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Danh sách hạng mục",
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () {
                          // _showHangMucPopupSC(context, setState, _selectedController);
                          if (_hangmucscList != null && _hangmucscList!.isNotEmpty) {
                            _showHangMucPopupSC(context, setState, _selectedController);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đang tải danh sách hạng mục...")));
                          }
                        },
                      ),

                      SizedBox(
                        height: 10,
                      ),
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
                                        setState(() {
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Ngày đi sửa chữa',
                            style: TextStyle(
                              fontFamily: 'Comfortaa',
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(), // Không cho chọn ngày trong quá khứ
                                lastDate: DateTime(2100),
                              );

                              if (picked != null) {
                                setState(() {
                                  // Cập nhật UI ngay lập tức
                                  selectedDate = DateFormat('dd/MM/yyyy').format(picked);
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFBC2925)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, color: Color(0xFFBC2925)),
                                  SizedBox(width: 8),
                                  Text(
                                    selectedDate ?? 'Chọn ngày',
                                    style: TextStyle(color: Color(0xFFBC2925)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                      SizedBox(height: 10),
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
                          onPressed: (selectedDate != null && DiaDiem_Id != null) ? () => _onSaveSC(index, _addedHangMuc, isKhac) : null,
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

  void _showHangMucPopupSC(BuildContext context, StateSetter parentSetState, TextEditingController controller) {
    // TextEditingController newHangMucController = TextEditingController();
    String searchTerm = '';
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn bấm ra ngoài để đóng

      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            final filteredList = _hangmucscList!.where((item) => searchTerm.isEmpty || (item.noiDungBaoDuong?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false)).toList();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              insetPadding: EdgeInsets.all(10), // Giảm khoảng cách với viền màn hình
              // child: Container(
              //   width: MediaQuery.of(context).size.width, // Full chiều rộng
              //   height: MediaQuery.of(context).size.height, // Full chiều cao
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(15),
              //     color: Colors.white,
              //   ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    reverse: true, // giúp cuộn ngược lên khi bàn phím mở
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thêm hạng mục sửa chữa
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Chọn hạng mục sửa chữa",
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.black),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      controller: newHangMucController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "Nhập hạng mục mới",
                                      ),
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          searchTerm = value;
                                        });
                                      },
                                      onSubmitted: (value) {
                                        if (value.trim().isNotEmpty) {
                                          List<String> items = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                                          setStateDialog(() {
                                            // _addedHangMuc = items;
                                            _addedHangMuc.addAll(items.where((e) => !_addedHangMuc.contains(e)));
                                            newHangMucController.clear();
                                            print("Danh sách hạng mục thêm tay:");
                                            print(_addedHangMuc);
                                          });

                                          parentSetState(() {
                                            controller.text = [..._addedHangMuc].join(', ');
                                          });
                                          print(controller.text);
                                        }
                                      },
                                    ),
                                    if (_addedHangMuc.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Wrap(
                                          spacing: 6,
                                          children: _addedHangMuc.map((e) {
                                            return Chip(
                                              label: Text(e),
                                              onDeleted: () {
                                                setStateDialog(() {
                                                  _addedHangMuc.remove(e);
                                                  final currentText = newHangMucController.text;
                                                  final updatedText = currentText.split(',').map((s) => s.trim()).where((word) => word != e && word.isNotEmpty).join(', ');
                                                  newHangMucController.text = updatedText;
                                                  _selectedSCItems.removeWhere((s) => s.noiDungBaoDuong == e);
                                                });
                                                parentSetState(() {
                                                  // controller.text = [..._addedHangMuc].join(', ');
                                                  controller.text = [..._selectedSCItems.map((e) => e.noiDungBaoDuong), ..._addedHangMuc].where((e) => e.isNotEmpty).join(', ');
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    Container(
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: filteredList.map((item) {
                                              bool isChecked = _selectedSCItems.any((e) => e.id == item.id);
                                              return CheckboxListTile(
                                                  title: Text(item.noiDungBaoDuong ?? ""),
                                                  value: isChecked,
                                                  // onChanged: (bool? value) {
                                                  //   setStateDialog(() {
                                                  //     if (value == true) {
                                                  //       _selectedSCItems.add(item);
                                                  //       if (!_addedHangMuc.contains(item.noiDungBaoDuong)) {
                                                  //         _addedHangMuc.add(item.noiDungBaoDuong ?? "");
                                                  //       }
                                                  //     } else {
                                                  //       _selectedSCItems.removeWhere((e) => e.id == item.id);
                                                  //       _addedHangMuc.remove(item.noiDungBaoDuong ?? "");
                                                  //     }
                                                  //   });

                                                  //   // Cập nhật UI của dialog chính
                                                  //   // parentSetState(() {
                                                  //   //   controller.text = _selectedSCItems.map((e) => e.noiDungBaoDuong).join(', ');
                                                  //   // });
                                                  //   parentSetState(() {
                                                  //     controller.text = [
                                                  //       ..._selectedSCItems.map((e) => e.noiDungBaoDuong),
                                                  //       ..._addedHangMuc.where((e) => !_selectedSCItems.any((s) => s.noiDungBaoDuong == e)),
                                                  //     ].where((e) => e.isNotEmpty).join(', ');
                                                  //   });
                                                  // },
                                                  onChanged: (bool? value) {
                                                    setStateDialog(() {
                                                      if (value == true) {
                                                        _selectedSCItems.add(item);
                                                        if (!_addedHangMuc.contains(item.noiDungBaoDuong)) {
                                                          _addedHangMuc.add(item.noiDungBaoDuong ?? "");
                                                        }
                                                      } else {
                                                        _selectedSCItems.removeWhere((e) => e.id == item.id);
                                                        _addedHangMuc.remove(item.noiDungBaoDuong ?? "");
                                                      }

                                                      // Cập nhật lại controller text cho field chính
                                                      parentSetState(() {
                                                        controller.text = [
                                                          ..._selectedSCItems.map((e) => e.noiDungBaoDuong),
                                                          ..._addedHangMuc.where((e) => !_selectedSCItems.any((s) => s.noiDungBaoDuong == e)),
                                                        ].where((e) => e.isNotEmpty).join(', ');
                                                      });

                                                      // 👇 Cập nhật luôn newHangMucController để hiển thị text trên ô nhập
                                                      // newHangMucController.text = [
                                                      //   ..._selectedSCItems.map((e) => e.noiDungBaoDuong),
                                                      //   ..._addedHangMuc.where((e) => !_selectedSCItems.any((s) => s.noiDungBaoDuong == e)),
                                                      // ].where((e) => e.isNotEmpty).join(', ');
                                                    });
                                                  });
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Nút Xong
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Xong",
                                        style: TextStyle(
                                          fontSize: 16,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> postDataDiBD(LichSuBaoDuongModel? scanData, bool? isKhac) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;
      final http.Response response = await requestHelper.postData('MMS_BaoCao/DiBaoDuong?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&IsKhac=$isKhac', newScanData?.toJson());
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

  _onSaveDiBD(int index, bool? isKhac) async {
    setState(() {
      _loading = true;
    });

    // final item = _kehoachList?[index];
    PhuongTienModel? item;
    if (isKhac == false) {
      item = _kehoachList?[index];
    } else {
      item = _phuongtienList?[index];
    }
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.lichSuBaoDuong_Id;
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
        postDataDiBD(_data!, isKhac).then((_) {
          setState(() {
            getBienSo();
            _IsXacNhan = false;
            _IsKhac = false;
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogDiBD(BuildContext context, int index, bool? isKhac) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có chắc chắn xác nhận đi bảo dưỡng không?',
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
          _onSaveDiBD(index, isKhac);
        });
  }

  Future<void> getListThayDoiKH(String? listIds, String? keyword) async {
    print("data:${listIds}");
    setState(() {
      _isLoading = true;
      _kehoachList = [];
    });
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuongTheoPT?PhuongTien_Id=$listIds&keyword=$keyword');
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

  Future<void> getListChiTietHangMuc(String? listIds, StateSetter dialogSetState) async {
    print("data:${listIds}");
    _isLoading = true;
    dialogSetState(() {});
    // Làm sạch danh sách cũ trước khi tải mới
    try {
      final http.Response response = await requestHelper.getData('MMS_BaoCao/LichSuBaoDuongChiTietTheoPT?BaoDuong_Id=$listIds');
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

  Future<void> postDataHoanThanh(LichSuBaoDuongModel? scanData, int? soKM, String? file, List<Map<String, dynamic>> danhSachChiPhi, int index, int tongChiPhiBD, int tongChiPhiSC) async {
    _isLoading = true;
    final item = _kehoachList?[index];
    print("dschiphi: ${danhSachChiPhi}");
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;
      Map<String, dynamic> requestBody = {
        "data": newScanData?.toJson() ?? {}, // Dữ liệu bảo dưỡng
        "chiPhis": danhSachChiPhi
            .map((chiPhi) => {
                  "hangMuc_Id": chiPhi["hangMuc_Id"],
                  // "giaTri": chiPhi["chiPhi"], // Đảm bảo key trùng với backend
                  "ghiChu": chiPhi["ghiChu"], // Đảm bảo key trùng với backend
                })
            .toList(),
      };
      final http.Response response = await requestHelper.postData('MMS_BaoCao/LenhHoanThanhBaoDuong?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&SoKM=$soKM&File=$file&TongChiPhiBD=$tongChiPhiBD&TongChiPhiSC=$tongChiPhiSC', requestBody);

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
        body = "Bạn đã có ${_lenhHoanThanhList?.length.toString() ?? ""} lệnh hoàn thành bảo dưỡng phương tiện";
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

  _onSaveHoanThanhHT(int index) async {
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

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.lichSuBaoDuong_Id;
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
    int tongChiPhiBD = int.tryParse(_tongChiPhiBD.text) ?? 0;
    int tongChiPhiSC = int.tryParse(_tongChiPhiSC.text) ?? 0;

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
        postDataHoanThanh(_data!, int.parse(soKMController.text), imageUrlsString, danhSachChiPhi, index, tongChiPhiBD, tongChiPhiSC).then((_) {
          setState(() {
            _IsXacNhan = false;
            getBienSo();
            postDataFireBase(_thongbao, body ?? "", item?.id);
            textEditingController.text = '';
            soKMController.text = '';
            _ghiChu.text = '';
            _tongChiPhiBD.text = '';
            _tongChiPhiSC.text = '';
            _vattu.text = '';
            _errorChiPhiBD = false;
            _errorChiPhiSC = false;
            _errorHinhAnh = false;
            _lstFiles.clear();
            // getListThayDoiKH(item?.id, textEditingCRontroller.text);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogHoanThanh(BuildContext context, int index) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn hoàn thành bảo dưỡng không?',
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
          _onSaveHoanThanhHT(index);
        });
  }

  void _showDetailsDialogHT(BuildContext context, int index) {
    final baoduongId = _kehoachList?[index].lichSuBaoDuong_Id;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_hangmucList == null || _hangmucList!.isEmpty) {
              getListChiTietHangMuc(baoduongId ?? "", setState);
            }
            print("_hangmucList khi lưu: $_hangmucList");
            if (_previousPhuongTienId != baoduongId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = baoduongId;
              getListChiTietHangMuc(baoduongId ?? "", setState);
            }

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
                              'HOÀN THÀNH BẢO DƯỠNG',
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
                                _errorChiPhiBD = false;
                                _errorChiPhiSC = false;
                                _errorHinhAnh = false;
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
                                          //   title: 'Nội dung bảo dưỡng: ',
                                          //   controller: textEditingController,
                                          // ),
                                          // const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemGhiChu(
                                            title: 'Ghi chú: ',
                                            controller: _ghiChu,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemGhiChu(
                                            title: 'Nhập số KM hiện tại: ',
                                            controller: soKMController,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          buildInputWithError(
                                            title: 'Chi phí bảo dưỡng:',
                                            controller: _tongChiPhiBD,
                                            showError: _errorChiPhiBD,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          buildInputWithError(
                                            title: 'Chi phí sửa chữa:',
                                            controller: _tongChiPhiSC,
                                            showError: _errorChiPhiSC,
                                          ),
                                          // ItemGhiChu(
                                          //   title: 'Chi phí bảo dưỡng: ',
                                          //   controller: _tongChiPhiBD,
                                          // ),
                                          // const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          // ItemGhiChu(
                                          //   title: 'Chi phí sửa chữa: ',
                                          //   controller: _tongChiPhiSC,
                                          // ),
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
                                                      // labelText: "Chi phí bảo dưỡng",
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
                                            decoration: const BoxDecoration(
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
                                                                  () => _removeImage2(image, index),
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
                                _errorChiPhiBD = _tongChiPhiBD.text.isEmpty;
                                _errorChiPhiSC = _tongChiPhiSC.text.isEmpty;
                                _errorHinhAnh = lstFilesNotifier.value.isEmpty;
                              });

                              if (_errorChiPhiBD || _errorChiPhiSC || _errorHinhAnh) {
                                _btnController.reset();
                                return;
                              }
                              ;
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

  Future<void> postDataDiSC(LichSuBaoDuongModel? scanData, bool? isKhac) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;
      final http.Response response = await requestHelper.postData('MMS_SuaChua/DiSuaChua?TenNhanVien=${_ub?.name}&MaNhanVien=${_ub?.maNhanVien}&User_Id=${_ub?.id}&IsKhac=$isKhac', newScanData?.toJson());
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

  _onSaveDiSC(int index, bool? isKhac) async {
    setState(() {
      _loading = true;
    });

    // final item = _kehoachList?[index];
    PhuongTienModel? item;
    if (isKhac == false) {
      item = _kehoachList?[index];
    } else {
      item = _phuongtienList?[index];
    }
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.lichSuSuaChua_Id;
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
        postDataDiSC(_data!, isKhac).then((_) {
          setState(() {
            getBienSo();
            _IsKhac = false;
            _IsXacNhan = false;
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogDiSC(BuildContext context, int index, bool? isKhac) {
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
          _onSaveDiSC(index, isKhac);
        });
  }

  Future<void> postDataHoanThanhSC(LichSuBaoDuongModel? scanData, int? soKM, String? file, List<Map<String, dynamic>> danhSachChiPhi, int index, int tongChiPhi) async {
    _isLoading = true;
    final item = _kehoachList?[index];
    print("dschiphi: ${danhSachChiPhi}");
    try {
      var newScanData = scanData;
      newScanData?.bienSo1 = newScanData?.bienSo1 == 'null' ? null : newScanData?.bienSo1;
      Map<String, dynamic> requestBody = {
        "data": newScanData?.toJson() ?? {}, // Dữ liệu bảo dưỡng
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
        await getLenhHoanThanhSC();
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

  Future<void> getListChiTietHangMucSC(String? listIds, StateSetter dialogSetState) async {
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

  _onSaveHoanThanhHTSC(int index) async {
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

    final item = _kehoachList?[index];
    print("data kehoach = ${item?.id}");
    _data ??= LichSuBaoDuongModel();
    _data?.id = item?.lichSuSuaChua_Id;
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
        postDataHoanThanhSC(_data!, int.parse(soKMController.text), imageUrlsString, danhSachChiPhi, index, tongChiPhi).then((_) {
          setState(() {
            _IsXacNhan = false;
            getBienSo();
            postDataFireBaseSC(_thongbao, body ?? "", item?.id);
            textEditingController.text = '';
            soKMController.text = '';
            _ghiChu.text = '';
            _tongChiPhiBD.text = '';
            _tongChiPhiSC.text = '';
            _vattu.text = '';
            _tongChiPhi.text = '';
            _errorChiPhiSC = false;
            _errorHinhAnh = false;
            _lstFiles.clear();
            // getListThayDoiKH(item?.id, textEditingController.text);
            _data = null;
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogHoanThanhSC(BuildContext context, int index) {
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
          _onSaveHoanThanhHTSC(index);
        });
  }

  void _showDetailsDialogHTSC(BuildContext context, int index) {
    final baoduongId = _kehoachList?[index].lichSuSuaChua_Id;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            if (_hangmucList == null || _hangmucList!.isEmpty) {
              getListChiTietHangMucSC(baoduongId ?? "", setState);
            }
            print("_hangmucList khi lưu: $_hangmucList");
            if (_previousPhuongTienId != baoduongId) {
              // Lấy danh sách hạng mục mặc định của phương tiện mới
              _previousPhuongTienId = baoduongId;
              getListChiTietHangMucSC(baoduongId ?? "", setState);
            }
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
                                          //   title: 'Nội dung bảo dưỡng: ',
                                          //   controller: textEditingController,
                                          // ),
                                          // const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemGhiChu(
                                            title: 'Ghi chú: ',
                                            controller: _ghiChu,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          ItemGhiChu(
                                            title: 'Nhập số KM hiện tại: ',
                                            controller: soKMController,
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
                                                                  () => _removeImage2(image, index),
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
                              });

                              if (_errorChiPhiSC) {
                                _btnController.reset();
                                return;
                              }
                              _showConfirmationDialogHoanThanhSC(context, index);
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

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingWidget(context)
        : RefreshIndicator(
            onRefresh: () async {
              await getBienSo();
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Danh sách phương tiện: ",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "${_kehoachList?.length.toString() ?? ""}",
                                              style: const TextStyle(
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
                                                isHoatDong: item?.isHoatDong ?? false,
                                                trangThaiPT: item?.trangThaiPT ?? "",
                                                isYeuCauSC: item?.isYeuCauSC ?? false,
                                                isHoanThanhSC: item?.isHoanThanhSC ?? false,
                                                isDuyetSC: item?.isDuyetSC ?? false,
                                                isSuaChua: item?.isSuaChua ?? false,
                                                isLenhHoanThanhSC: item?.isLenhHoanThanhSC ?? false,
                                                id: item?.id ?? "",
                                                tinhTrang: item?.tinhTrang ?? "",
                                                isDenHan: item?.isDenHan ?? false,
                                                isYeuCau: item?.isYeuCau ?? false,
                                                isBaoDuong: item?.isBaoDuong ?? false,
                                                isLenhHoanThanh: item?.isLenhHoanThanh ?? false,
                                                isDuyet: item?.isDuyet ?? false,
                                                soKhung: item?.soKhung ?? "",
                                                bienSo1: item?.bienSo1 ?? "",
                                                soKM: item?.soKM ?? "",
                                                giaTri: item?.giaTri ?? "",
                                                lyDo: "Đến hạn bảo dưỡng",
                                                model: item?.model ?? "",
                                                model_Option: item?.model_Option ?? "",
                                                soKM_Adsun: item?.soKM_Adsun ?? "",
                                                onDongY: () {
                                                  _IsXacNhan = true;
                                                  // _showDetailsDialog(context, index);
                                                  if (item?.isDenHan == true && item?.isYeuCau == false) {
                                                    _IsKhac = false;
                                                    _showDetailsDialog(context, index, _IsKhac, item?.id);
                                                  } else if (item?.isDuyet == true && item?.isBaoDuong == false) {
                                                    _IsKhac = false;
                                                    _showConfirmationDialogDiBD(context, index, _IsKhac);
                                                  } else if (item?.isYeuCau == true && item?.isDuyet == false) {
                                                    _showConfirmationDialogYeuCau2(context, index);
                                                  } else {
                                                    _showDetailsDialogHT(context, index);
                                                  }
                                                },
                                                onSuaChua: () {
                                                  if (item?.isYeuCauSC == false) {
                                                    _IsKhac = false;
                                                    _showDetailsDialogSC(context, index, _IsKhac, item?.id);
                                                  } else if (item?.isDuyetSC == true && item?.isSuaChua == false) {
                                                    print("Sc0: ${item?.isYeuCau} ${item?.isDuyetSC} ${item?.isSuaChua} ");
                                                    _IsKhac = false;
                                                    _showConfirmationDialogDiSC(context, index, _IsKhac);
                                                  } else {
                                                    print("Sc1: ${item?.isYeuCauSC} ${item?.isDuyetSC} ${item?.isSuaChua} ");
                                                    _showDetailsDialogHTSC(context, index);
                                                  }
                                                }),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
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
                                          width: 35.w,
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
                                              "Danh sách PT khác",
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
                                                  items: _phuongtien?.map((item) {
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
                                                  value: PhuongTien_Id,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      PhuongTien_Id = newValue;
                                                    });
                                                    if (newValue != null) {
                                                      GetListPhuongTienKhongQuanLy(newValue);
                                                      print("object : ${newValue}");
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
                                                          hintText: 'Tìm phương tiện',
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
                                                        return _phuongtien?.any((baiXe) => baiXe.id == itemId && baiXe.bienSo1?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
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
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (_phuongtienList != null && _phuongtienList!.isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true, // Đảm bảo danh sách nằm gọn trong SingleChildScrollView
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _phuongtienList?.length,
                                      itemBuilder: (context, index) {
                                        final item = _phuongtienList?[index];
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
                                                  isHoatDong: item?.isHoatDong ?? false,
                                                  trangThaiPT: item?.trangThaiPT ?? "",
                                                  isYeuCauSC: item?.isYeuCauSC ?? false,
                                                  isHoanThanhSC: item?.isHoanThanhSC ?? false,
                                                  isDuyetSC: item?.isDuyetSC ?? false,
                                                  isSuaChua: item?.isSuaChua ?? false,
                                                  isLenhHoanThanhSC: item?.isLenhHoanThanhSC ?? false,
                                                  id: item?.id ?? "",
                                                  tinhTrang: item?.tinhTrang ?? "",
                                                  isDenHan: item?.isDenHan ?? false,
                                                  isYeuCau: item?.isYeuCau ?? false,
                                                  isBaoDuong: item?.isBaoDuong ?? false,
                                                  isLenhHoanThanh: item?.isLenhHoanThanh ?? false,
                                                  isDuyet: item?.isDuyet ?? false,
                                                  soKhung: item?.soKhung ?? "",
                                                  bienSo1: item?.bienSo1 ?? "",
                                                  soKM: item?.soKM ?? "",
                                                  giaTri: item?.giaTri ?? "",
                                                  lyDo: "Đến hạn bảo dưỡng",
                                                  model: item?.model ?? "",
                                                  model_Option: item?.model_Option ?? "",
                                                  soKM_Adsun: item?.soKM_Adsun ?? "",
                                                  onDongY: () {
                                                    _IsXacNhan = true;
                                                    // _showDetailsDialog(context, index);
                                                    if (item?.isDenHan == true && item?.isYeuCau == false) {
                                                      _IsKhac = true;
                                                      _showDetailsDialog(context, index, _IsKhac, item?.id);
                                                    } else if (item?.isDuyet == true && item?.isBaoDuong == false) {
                                                      _IsKhac = true;
                                                      _showConfirmationDialogDiBD(context, index, _IsKhac);
                                                    } else if (item?.isYeuCau == true && item?.isDuyet == false) {
                                                      _showConfirmationDialogYeuCau2(context, index);
                                                    } else {
                                                      _showDetailsDialogHT(context, index);
                                                    }
                                                  },
                                                  onSuaChua: () {
                                                    if (item?.isYeuCauSC == false) {
                                                      _IsKhac = true;
                                                      _showDetailsDialogSC(context, index, _IsKhac, item?.id);
                                                    } else if (item?.isDuyetSC == true && item?.isSuaChua == false) {
                                                      print("Sc0: ${item?.isYeuCau} ${item?.isDuyetSC} ${item?.isSuaChua} ");
                                                      _IsKhac = true;
                                                      _showConfirmationDialogDiSC(context, index, _IsKhac);
                                                    } else {
                                                      print("Sc1: ${item?.isYeuCauSC} ${item?.isDuyetSC} ${item?.isSuaChua} ");
                                                      _showDetailsDialogHTSC(context, index);
                                                    }
                                                  }),
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
                ],
              ),
            ),
          );
  }
}

class InfoColumn extends StatelessWidget {
  final String bienSo1, soKhung;
  final String model; // Thời gian yêu cầu
  final String lyDo; // Lý do đổi
  final String model_Option, tinhTrang; // Nhà xe
  final String soKM_Adsun, soKM, giaTri, id, trangThaiPT;
  final bool isDenHan, isYeuCau, isDuyet, isBaoDuong, isLenhHoanThanh, isDuyetSC, isSuaChua, isLenhHoanThanhSC, isHoanThanhSC, isYeuCauSC, isHoatDong;
  final VoidCallback onDongY, onSuaChua;

  const InfoColumn({
    Key? key,
    required this.isDenHan,
    required this.soKhung,
    required this.lyDo,
    required this.bienSo1,
    required this.model,
    required this.tinhTrang,
    required this.model_Option,
    required this.soKM_Adsun,
    required this.soKM,
    required this.id,
    required this.isYeuCau,
    required this.isDuyet,
    required this.isBaoDuong,
    required this.isLenhHoanThanh,
    required this.isDuyetSC,
    required this.isSuaChua,
    required this.isLenhHoanThanhSC,
    required this.isHoanThanhSC,
    required this.isYeuCauSC,
    required this.giaTri,
    required this.onDongY,
    required this.onSuaChua,
    required this.trangThaiPT,
    required this.isHoatDong,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: id, tabIndex: 3));
      },
      child: Container(
        padding: const EdgeInsets.all(8.0), // Padding cho toàn bộ cột lớn
        decoration: BoxDecoration(
          color: Colors.white, // Màu nền cho cột lớn
          border: Border.all(
            color: isDenHan && !isYeuCau && !isYeuCauSC ? Colors.red : Colors.grey.shade300,
            width: isDenHan && !isYeuCau ? 2.0 : 1.0,
          ), // Viền
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
                SelectableText(
                  trangThaiPT, // Hiển thị nội dung
                  style: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: trangThaiPT != "Đang hoạt động" && !trangThaiPT.contains("hoàn thành") ? Colors.red : Colors.green, // Màu xám cho nội dung
                  ),
                ),
                // IconButton(
                //   icon: const Icon(
                //     Icons.info,
                //     color: Colors.blue,
                //   ),
                //   onPressed: () {
                //     // nextScreen(context, QuanLyPhuongTienPage(id: id));
                //     nextScreen(context, QuanLyPhuongTienCaNhanNewPage(id: id));
                //   },
                // ),
              ],
            ),

            // Các dòng thông tin chính: Nhà xe, Biển số, Tài xế
            InfoRow(
              title: "Số khung:",
              contentYC: soKhung,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Model:",
              contentYC: model,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Model_Option:",
              contentYC: model_Option,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Số KM theo Adsun:",
              contentYC: soKM_Adsun,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Số KM theo xe:",
              contentYC: soKM,
            ),
            const SizedBox(height: 4),
            InfoRow(
              title: "Số KM ngày bảo dưỡng gần nhất:",
              contentYC: giaTri,
            ),
            // const SizedBox(height: 4),
            // CustomRichTextTT(
            //   title: "Tình trạng",
            //   content: tinhTrang,
            // ),
            // CustomRichTextTT(
            //   title: "Trạng thái phương tiện",
            //   content: trangThaiPT,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isDenHan && !isYeuCau && !isYeuCauSC)
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
                        child: const Text("YÊU CẦU BẢO DƯỠNG"),
                      ),
                    ),
                  ),
                if (isYeuCau && !isDuyet && !isYeuCauSC)
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
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13), // Bo góc
                          ),
                        ),
                        onPressed: onDongY, // Hành động ĐỒNG Ý
                        child: const Text("CHỈNH SỬA YÊU CẦU BẢO DƯỠNG"),
                      ),
                    ),
                  ),
                if (isDuyet && !isLenhHoanThanh)
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
                        // child: const Text("ĐI BẢO DƯỠNG"),
                        child: Text(
                          isBaoDuong ? "ĐỀ XUẤT HOÀN THÀNH BẢO DƯỠNG" : "ĐI BẢO DƯỠNG",
                        ),
                      ),
                    ),
                  ),
                if ((!isYeuCau && !isYeuCauSC) || isHoatDong)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0), // Khoảng cách trên nút
                    child: Container(
                      width: 30.w,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Màu nền
                          foregroundColor: AppConfig.textButton, // Màu chữ
                          textStyle: const TextStyle(
                            fontFamily: 'Comfortaa',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13), // Bo góc
                          ),
                        ),
                        onPressed: onSuaChua, // Hành động ĐỒNG Ý
                        child: const Text("SỬA CHỮA"),
                      ),
                    ),
                  ),
                if (isDuyetSC && !isLenhHoanThanhSC)
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
                        onPressed: onSuaChua, // Hành động ĐỒNG Ý
                        // child: const Text("ĐI BẢO DƯỠNG"),
                        child: Text(
                          isSuaChua ? "ĐỀ XUẤT HOÀN THÀNH SỬA CHỮA" : "ĐI SỬA CHỮA",
                        ),
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
              color: content != "Đang hoạt động" && !content.contains("hoàn thành") ? Colors.red : Colors.green, // Màu xám cho nội dung
            ),
          ),
        ],
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
