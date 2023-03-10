import 'dart:collection';
import 'dart:convert';
import 'package:path/path.dart';
import 'dart:io';
import 'package:http/http.dart';

import 'BackendAPI.dart';

Future<Response> _post(String url, Map<String, dynamic> body) async {
  return await post(Uri.parse('$host/api/workers$url'),
      body: jsonEncode(body), headers: headers);
}

Future<Response> _get(String url) async {
  return await get(Uri.parse('$host/api/workers$url'), headers: headers);
}

class WorkersBackendAPI {
  static Future<dynamic> getImage(String imagePath) async {
    return BackendAPI.getImage(imagePath);
  }

  static String getImageUrl(String imagePath) {
    return BackendAPI.getImageUrl(imagePath);
  }

  static Future<dynamic> login(adminUsername, username, password) async {
    final json = {
      "admin_username": adminUsername,
      "username": username,
      "code": password
    };
    final response = await _post('/login', json);
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      headers["Authorization"] = "Token ${jsonResponse['token']}";
    }
    return response;
  }

  static Future<dynamic> getDays() async {
    final response = await _get('/get_days');
    return response;
  }

  static Future<dynamic> assignPhoto(dayId, File photo, {start=true}) async {
    final str = start ? 'start_photo' : 'end_photo';
    final Map<String, String> json = {'day_id': dayId.toString(), str:"yes"};
    final url = Uri.parse("$host/api/workers/assign_photo");
    final request = MultipartRequest("POST", url);

    var imageFile = photo;
    final stream = ByteStream(imageFile.readAsBytes().asStream());
    final length = await imageFile.length();
    final multipartFile = MultipartFile('file', stream, length, filename: basename(photo.path));

    request.files.add(multipartFile);
    request.headers.addAll(headers);
    request.fields.addAll(json);
    final response = await request.send();
    return response;
  }
}

void main() async {
  await BackendAPI.sendSms("firstWroker");
  var token =
      await WorkersBackendAPI.login("TypicalAdmin", "firstWroker", "1234");

  WorkersBackendAPI.getDays();
  // WorkersBackendAPI.assignPhoto("4", "Untitled.png", start: false);
}
