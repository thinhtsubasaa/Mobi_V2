import 'dart:convert';
import 'dart:io';

import 'package:Thilogi/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestHelperKPI {
  var token = "";
  var refreshToken = "";
  // ignore: constant_identifier_names
  // static const API = '${Config.apiUrl}/api/';
  // ignore: non_constant_identifier_names
  var API = "";

  _getInfo() async {
    print("KPI: ${AppConfig.BASE_URL_API_KPI}");
    SharedPreferences sp = await SharedPreferences.getInstance();
    token = sp.getString('token') ?? '';
    refreshToken = sp.getString('refreshToken') ?? '';

    //API = '${sp.getString('apiUrl_Sems')}/api/';
    API = '${AppConfig.BASE_URL_API_KPI}/api/';
  }

  loginAction(data) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      "Content-type": "application/json",
    };
    return await http.post(
      Uri.parse('${AppConfig.BASE_URL_API_KPI}/token'),
      headers: headers,
      body: data,
    );
  }

  refreshTokenAction(tokenInfo) async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      var bodyVal = {
        "token": tokenInfo["token"],
        "refreshToken": tokenInfo["refreshToken"],
      };
      http.Response request = await http.post(
        Uri.parse('${AppConfig.BASE_URL_API_KPI}/token/refresh'),
        body: jsonEncode(bodyVal),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );

      var response = jsonDecode(request.body);
      var data = response["data"];
      if (request.statusCode == 200 && data["errors"] == null) {
        // set new token, refreshToken
        token = data['token'];
        refreshToken = data['refreshToken'];
        await sp.setString('token', token);
        await sp.setString('refreshToken', refreshToken);
        return {
          "token": token,
          "refreshToken": refreshToken,
        };
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // uploadFile(File file) async {
  //   await _getInfo();
  //   try {
  //     SharedPreferences sp = await SharedPreferences.getInstance();
  //     http.MultipartRequest request = http.MultipartRequest(
  //         "POST", Uri.parse('${sp.getString('apiUrl')}/api/upload'));
  //     request.headers.addAll(_setHeaders());
  //     http.MultipartFile multipartFile =
  //         await http.MultipartFile.fromPath('file', file.path);
  //     request.files.add(multipartFile);
  //     var streamedResponse = await request.send();
  //     var response = await http.Response.fromStream(streamedResponse);
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  uploadFile(File file) async {
    await _getInfo();
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      http.MultipartRequest request = http.MultipartRequest("POST", Uri.parse('${AppConfig.BASE_URL_API_KPI}/api/Upload'));
      request.headers.addAll(_setHeaders());
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath('file', file.path);
      request.files.add(multipartFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Upload failed with status code: ${response.body}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  uploadAvatar(File file) async {
    await _getInfo();
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      http.MultipartRequest request = http.MultipartRequest("POST", Uri.parse('${AppConfig.BASE_URL_API_KPI}/api/Upload'));
      request.headers.addAll(_setHeaders());
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath('file', file.path);
      request.files.add(multipartFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Upload failed with status code: ${response.body}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  uploadListFile(List<File> files) async {
    await _getInfo();
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      http.MultipartRequest request = http.MultipartRequest("POST", Uri.parse('${AppConfig.BASE_URL_API_KPI}/api/Upload/Multi-vptq'));
      request.headers.addAll(_setHeaders());
      for (var file in files) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath('lstFiles', file.path);
        request.files.add(multipartFile);
      }
      // http.MultipartFile multipartFile = await http.MultipartFile.fromPath('file', file.path);
      // request.files.add(multipartFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Upload failed with status code: ${response.body}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  postData(endpoint, data) async {
    await _getInfo();
    var response = await http.post(Uri.parse(API + endpoint), body: jsonEncode(data), headers: _setHeaders());
    return response;
  }

  // getData(endpoint) async {
  //   await _getInfo();
  //   var response = await http.get(Uri.parse(API + endpoint), headers: _setHeaders());
  //   print('URL: ${API + endpoint}');
  //   print('STATUS: ${response.statusCode}');
  // print('BODY: ${response.body}');
  //   return response;
  // }

  getData(endpoint) async {
    try {
      await _getInfo();
      print('URL: ${API + endpoint}');
      print('TOKEN: $token');

      var response = await http.get(
        Uri.parse(API + endpoint),
        headers: _setHeaders(),
      );

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      return response;
    } catch (e) {
      print('ERROR: $e');
      return null;
    }
  }

  /// Gửi multipart/form-data với các field thuần (không file)
  Future<http.StreamedResponse> postMultipartData(String endpoint, Map<String, String> fields) async {
    await _getInfo();

    final uri = Uri.parse(API + endpoint);
    final request = http.MultipartRequest('POST', uri)..headers['Authorization'] = 'Bearer $token';

    // gán từng field
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    return request.send();
  }

  Future<http.Response> putData(String endpoint, dynamic data) async {
    await _getInfo();
    final uri = Uri.parse(API + endpoint);

    try {
      // --- Trường hợp KHÔNG có body (backend không cần body) ---
      if (data == null) {
        final req = http.Request('PUT', uri);
        req.headers.addAll(_setHeaders());
        print('URL: ${uri.toString()}');
        print('TOKEN: $token');
        final streamed = await req.send();
        final res = await http.Response.fromStream(streamed);
        print('STATUS: ${res.statusCode}');
        print('BODY: ${res.body}');
        return res;
      }

      // --- Trường hợp CÓ body ---
      final bodyStr = (data is String) ? data : jsonEncode(data);

      print('URL: ${uri.toString()}');
      print('TOKEN: $token');
      print('REQ BODY: $bodyStr');

      final res = await http.put(
        uri,
        headers: _setHeaders(),
        body: bodyStr,
      );

      print('STATUS: ${res.statusCode}');
      print('BODY: ${res.body}');
      return res;
    } catch (e) {
      print('PUT ERROR: $e');
      // Trả về Response 500 để code phía trên không bị null
      return http.Response('{"error":"$e"}', 500, headers: {'Content-Type': 'application/json'});
    }
  }

  Future<http.Response> deleteData(String endpoint, dynamic data) async {
    await _getInfo();
    final uri = Uri.parse(API + endpoint);

    try {
      // --- Trường hợp KHÔNG có body ---
      if (data == null) {
        final req = http.Request('DELETE', uri);
        req.headers.addAll(_setHeaders());
        print('URL: ${uri.toString()}');
        print('TOKEN: $token');
        final streamed = await req.send();
        final res = await http.Response.fromStream(streamed);
        print('STATUS: ${res.statusCode}');
        print('BODY: ${res.body}');
        return res;
      }

      // --- Trường hợp CÓ body (chỉ dùng khi backend chấp nhận DELETE có body) ---
      final bodyStr = (data is String) ? data : jsonEncode(data);
      print('URL: ${uri.toString()}');
      print('TOKEN: $token');
      print('REQ BODY: $bodyStr');

      final res = await http.delete(
        uri,
        headers: _setHeaders(),
        body: bodyStr,
      );

      print('STATUS: ${res.statusCode}');
      print('BODY: ${res.body}');
      return res;
    } catch (e) {
      print('DELETE ERROR: $e');
      return http.Response('{"error":"$e"}', 500, headers: {'Content-Type': 'application/json'});
    }
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
