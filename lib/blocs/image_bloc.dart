import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/request_helper.dart';

class ImageBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _message;
  String? get message => _message;
  var token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6IjI5YjhhNmE0LWJjM2ItNDM3MS05ZGJhLWMwYThiNTM5ZDMxMyIsIm5iZiI6MTcxMDU2MTYxNiwiZXhwIjoxNzExMTY2NDE2LCJpYXQiOjE3MTA1NjE2MTZ9.0vCEy-hHku5gKHzJEc67uKAMkxjJv3oDBQZkDGrYNBc";

  Future<void> pickImage(
      BuildContext context, List<File> _selectedImages) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn ảnh'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Chụp ảnh'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto(_selectedImages);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _selectFromGallery(_selectedImages);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _takePhoto(List<File> _selectedImages) async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        final File image = File(pickedImage.path);
        _selectedImages.add(image);
      }
    } catch (e) {
      print("Failed to pick image: $e");
    }
  }

  Future<void> _selectFromGallery(List<File> _selectedImages) async {
    try {
      List<Asset> resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: false,
        selectedAssets: [],
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: const MaterialOptions(
          actionBarTitle: "Chọn ảnh",
          allViewTitle: "Tất cả ảnh",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );

      // Convert selected assets to files
      for (var asset in resultList) {
        final ByteData byteData = await asset.getByteData();
        final List<int> imageData = byteData.buffer.asUint8List();
        final File imageFile =
            File('${(await getTemporaryDirectory()).path}/${asset.name}');
        await imageFile.writeAsBytes(imageData);
        _selectedImages.add(imageFile);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<void> uploadFiles(List<File> files) async {
  //   await _getInfo();
  //   print("file:${files}");
  //   try {
  //     SharedPreferences sp = await SharedPreferences.getInstance();
  //     http.MultipartRequest request = http.MultipartRequest("POST",
  //         Uri.parse('${sp.getString('apiUrl')}/api/Upload/Multi/Image'));
  //     request.headers.addAll(_setHeaders());

  //     for (var file in files) {
  //       http.MultipartFile multipartFile =
  //           await http.MultipartFile.fromPath('files', file.path);
  //       request.files.add(multipartFile);
  //     }

  //     var streamedResponse = await request.send();
  //     var response = await http.Response.fromStream(streamedResponse);
  //     print("statusCode : ${response.statusCode}");
  //     if (response.statusCode == 200) {
  //       // return jsonDecode(response.body);
  //       var decodedData = jsonDecode(response.body);
  //       print("data:${decodedData}");
  //     } else {
  //       // Xử lý lỗi khi máy chủ trả về mã lỗi không phải là 200
  //       throw Exception('Failed to upload files: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Xử lý lỗi khi có lỗi trong quá trình gửi yêu cầu
  //     print('Upload error: $e');
  //     throw Exception('Failed to upload files: $e');
  //   }
  // }

  // Future<void> uploadImages(List<File> images) async {
  //   print("images: $images");
  //   var url = Uri.parse('https://apiwms.thilogi.click/api/Upload/Multi/Image');
  //   var request = http.MultipartRequest('POST', url);
  //   request.headers.addAll(_setHeaders());

  //   for (var image in images) {
  //     var stream = http.ByteStream(image.openRead());
  //     var length = await image.length();
  //     var fileName = image.path.split('/').last;
  //     var multipartFile =
  //         http.MultipartFile('images', stream, length, filename: fileName);
  //     request.files.add(multipartFile);
  //   }

  //   try {
  //     _hasError = false;
  //     var response = await request.send();

  //     if (response.statusCode == 200) {
  //       print('Images uploaded successfully: ');
  //     }
  //     notifyListeners(); // Gọi notifyListeners() ở đây để thông báo rằng dữ liệu đã được cập nhật thành công
  //   } catch (e) {
  //     _hasError = true;
  //     _errorCode = e.toString();
  //     notifyListeners(); // Gọi notifyListeners() ở đây trong trường hợp xảy ra lỗi
  //   }
  // }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
  Future<List<http.MultipartFile>> _convertImagesToMultipartFiles(
      List<File> images) async {
    List<http.MultipartFile> files = [];

    for (var image in images) {
      var multipartFile = await http.MultipartFile.fromPath(
        'files', // Tên trường dùng trong FormData
        image.path,
      );
      files.add(multipartFile);
      print(files);
    }
    return files;
  }

  Future<void> upload(BuildContext context, List<File> images) async {
    _isLoading = true;
    var multipartFiles = await _convertImagesToMultipartFiles(images);

    try {
      // final http.Response response =
      //     await requestHelper.postData('Upload/Multi/Image', multipartFiles);
      var uri =
          Uri.parse('https://apiwms.thilogi.click/api/Upload/Multi/Image');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_setHeaders());
      request.files.addAll(multipartFiles);
      var response = await request.send();
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("upload successful");

        _isLoading = false;
        // _success = decodedData["success"];
        // _message = decodedData["message"];
        notifyListeners();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: "Upload thành công",
        );
      } else {
        // String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: "error",
        );
      }
    } catch (e) {
      _hasError = true;
      _isLoading = false;
      _message = e.toString();
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
