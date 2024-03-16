import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageService extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

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
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
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

  Future<void> uploadImages(List<File> images) async {
    var url = Uri.parse('https://yourserver.com/upload');
    var request = http.MultipartRequest('POST', url);

    for (var image in images) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var fileName = image.path.split('/').last;
      var multipartFile =
          http.MultipartFile('images', stream, length, filename: fileName);
      request.files.add(multipartFile);
    }

    try {
      _hasError = false;
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Images uploaded successfully: ');
      }
      notifyListeners(); // Gọi notifyListeners() ở đây để thông báo rằng dữ liệu đã được cập nhật thành công
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners(); // Gọi notifyListeners() ở đây trong trường hợp xảy ra lỗi
    }
  }
}
