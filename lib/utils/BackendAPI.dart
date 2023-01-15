import 'dart:convert';
import 'package:http/http.dart';
import '';

const host = "http://45.130.43.56:8000"; // "http://10.0.2.2:8000";
String token = '';
var headers = {"Content-type": "application/json"};

Future<dynamic> _post(String url, String body) async {
  return await post(Uri.parse('$host/api$url'), body: body, headers: headers);
}

Future<Response> _get(String url) async {
  return await get(Uri.parse('$host/api$url'), headers: headers);
}

class BackendAPI {
  static Future<dynamic> registerAsAdmin(String username) async {
    final json = {'username': username};
    final response = await _post('/signup', jsonEncode(json));
    return jsonDecode(response.body);
  }

  static Future<dynamic> sendSms(String username) async {
    final json = {'username': username};
    final response = await _post('/send_sms_code', jsonEncode(json));
    return response;
  }

  static Future<dynamic> getImage(String imagePath) async {
    final response = await _get('/get_image$imagePath');
    return response.body;
  }

  static String getImageUrl(String imagePath) {
    return '$host/api/get_image$imagePath'; //TEST THIS SHIT
  }

  static Future<DateTime> getServerDateTime() async {
    final response = await _get('/get_time');
    if (response.statusCode != 200){
      return DateTime(2022);
    }
    return DateTime.parse(jsonDecode(response.body)['message']['datetime']);
  }

  static Future<bool> isTokenValid(String t) async {
    final response = await _post('/is_token_valid', jsonEncode({'token': t}));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'];
    }
    return false;
  }
}