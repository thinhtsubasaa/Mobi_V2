import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestHelper {
  var token = "";
  var refreshToken = "";
  // ignore: constant_identifier_names
  // static const API = '${Config.apiUrl}/api/';
  // ignore: non_constant_identifier_names
  var API = "";

  _getInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    token = sp.getString('token') ?? '';
    refreshToken = sp.getString('refreshToken') ?? '';
    API = '${sp.getString('apiUrl')}/api/';
  }

  loginAction(data) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
<<<<<<< HEAD
    Map<String, String> headers = {"Content-type": "application/json"};
=======
    Map<String, String> headers = {
      "Content-type": "application/json",
    };
>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
    return await http.post(
      Uri.parse('${sp.getString('apiUrl')}/token'),
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
        Uri.parse('${sp.getString('apiUrl')}/token/refresh'),
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

  uploadFile(File file) async {
    await _getInfo();
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
<<<<<<< HEAD
      http.MultipartRequest request = http.MultipartRequest(
          "POST", Uri.parse('${sp.getString('apiUrl')}/api/upload'));
=======
      http.MultipartRequest request = http.MultipartRequest("POST",
          Uri.parse('${sp.getString('apiUrl')}/api/Upload/Multi/Image'));
>>>>>>> 145bdff5b4959865954ab870a740ff42146aeebe
      request.headers.addAll(_setHeaders());
      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath('file', file.path);
      request.files.add(multipartFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }
  }

  postData(endpoint, data) async {
    await _getInfo();
    var response = await http.post(Uri.parse(API + endpoint),
        body: jsonEncode(data), headers: _setHeaders());
    return response;
  }

  getData(endpoint) async {
    await _getInfo();
    var response =
        await http.get(Uri.parse(API + endpoint), headers: _setHeaders());
    return response;
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
