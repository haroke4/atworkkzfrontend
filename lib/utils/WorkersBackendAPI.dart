import 'dart:collection';
import 'dart:convert';
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
    return jsonDecode(response.body);
  }

  static Future<dynamic> assignPhoto(dayId, photo, {start=true}) async {
    final str = start ? 'start_photo' : 'end_photo';
    final Map<String, String> json = {'day_id': dayId, str:"yes"};
    final url = Uri.parse("$host/api/workers/assign_photo");
    final request = MultipartRequest("POST", url);

    var imageFile = File('lib/utils/Untitled.png');
    final stream = ByteStream(imageFile.readAsBytes().asStream());
    final length = await imageFile.length();
    final multipartFile = MultipartFile('file', stream, length, filename: photo);

    request.files.add(multipartFile);
    request.headers.addAll(headers);
    request.fields.addAll(json);
    final response = await request.send();
    // final response = await post(url, headers: headers, )
    // final response = await _post('/assign_photo', json);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
    return;
  }
}

void main() async {
  await BackendAPI.sendSms("firstWroker");
  var token =
      await WorkersBackendAPI.login("TypicalAdmin", "firstWroker", "1234");

  WorkersBackendAPI.getDays();
  WorkersBackendAPI.assignPhoto("4", "Untitled.png", start: false);
}
