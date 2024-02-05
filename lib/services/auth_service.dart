// api_service.dart
import 'dart:convert';
import 'package:http/http.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(
      String username, String password, String domain) async {
    try {
      Response response = await post(
        Uri.parse('http://14.241.134.199:8021/token'),
        body: jsonEncode({
          'username': username,
          'password': password,
          'domain': domain,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data['token']);
        print('Login successfully');
        return {'success': true, 'token': data['token']};
      } else {
        print('Login failed');
        return {'success': false, 'error': 'Login failed'};
      }
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'error': 'An error occurred'};
    }
  }
}
