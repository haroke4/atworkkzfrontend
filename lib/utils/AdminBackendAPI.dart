import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BackendAPI.dart';

String token = '';

Future<Response> _post(String url, Map<String, dynamic> body) async {
  return await post(Uri.parse('$host/api/admin$url'),
      body: jsonEncode(body), headers: headers);
}

Future<Response> _get(String url) async {
  return await get(Uri.parse('$host/api/admin$url'), headers: headers);
}

class AdminBackendAPI {
  static Future<dynamic> getImage(String imagePath) async {
    return BackendAPI.getImage(imagePath);
  }

  static String getImageUrl(String imagePath) {
    return BackendAPI.getImageUrl(imagePath);
  }

  static Future<dynamic> login(String username, String password) async {
    final json = {"username": username, "code": password};
    final response = await _post('/login', json);
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      headers["Authorization"] = "Token ${jsonResponse['token']}";
    }
    return response;
  }

  static Future<dynamic> createCompany({
    required String name,
    required String department,
    required String pinCode,
    required String mail,
    required String truancyPrice,
    required String prize,
    required String begOffPrice,
    required String beforeMinute,
    required String postponementMinute,
    required String truancyMinute,
    required String lateMinutePrice,
    required String afterMinute,
  }) async {
    final json = {
      "name": name,
      "department": department,
      "pin_code": pinCode,
      "mail": mail,
      "truancy_price": truancyPrice,
      "prize": prize,
      "beg_off_price": begOffPrice,
      "before_minute": beforeMinute,
      "postponement_minute": postponementMinute,
      "truancy_minute": truancyMinute,
      "late_minute_price": lateMinutePrice,
      "after_minute": afterMinute,
    };
    final response = await _post('/create_company', json);
    final jsonResponse = jsonDecode(response.body);
    return response;
  }

  static Future<dynamic> editCompany({
    String? name,
    String? department,
    String? mail,
    String? truancyPrice,
    String? prize,
    String? begOffPrice,
    String? beforeMinute,
    String? postponementMinute,
    String? truancyMinute,
    String? lateMinutePrice,
    String? afterMinute,
  }) async {
    final json = {
      "name": name,
      "department": department,
      "mail": mail,
      "truancy_price": truancyPrice,
      "prize": prize,
      "beg_off_price": begOffPrice,
      "before_minute": beforeMinute,
      "postponement_minute": postponementMinute,
      "truancy_minute": truancyMinute,
      "late_minute_price": lateMinutePrice,
      "after_minute": afterMinute,
    };
    final response = await _post('/edit_company', json);
    return response;
  }

  static Future<dynamic> changePinCode(String newPinCode) async {
    final json = {"pin_code": newPinCode};
    final response = await _post('/change_pin_code', json);
    final jsonResponse = jsonDecode(response.body);
    return response;
  }

  static Future<bool> checkPinCode(String PinCode) async {
    final json = {"pin_code": PinCode};
    final response = await _post('/check_company_password', json);
    return response.statusCode == 200;
  }

  static Future<dynamic> registerWorker({
    required String displayName,
    required String username,
  }) async {
    final json = {"display_name": displayName, "username": username};
    final response = await _post('/register_worker', json);
    final jsonResponse = jsonDecode(response.body);
    return response;
  }

  // final json = {"nigger": "shit"};
  // final response = await _post('/register_worker', json);
  // final jsonResponse = jsonDecode(response.body);
  // print(jsonResponse);
  // return jsonResponse;

  static Future<dynamic> deleteWorker({required String workerUsername}) async {
    final json = {"worker_username": workerUsername};
    final response = await _post('/delete_worker', json);
    final jsonResponse = jsonDecode(response.body);
    return response;
  }

  static Future<dynamic> getWorkers() async {
    final response = await _get('/get_workers');
    return response;
  }

  static Future<dynamic> editDay({
    required String workerUsername,
    required int dayId,
    String? date,
    String? startTime,
    String? endTime,
    String? geoposition,
    String? dayStatus,
    String? penaltyCount,
    String? startPhotoTime,
    String? endPhotoTime,
    String? workerStatusStart,
    String? workerStatusEnd,
    bool? confirmedStart,
    bool? confirmedEnd,
    bool updateWorkerPenalty = false,
    bool today = false,
  }) async {
    final json = {
      "worker_username": workerUsername,
      "day_id": dayId,
      "start_time": startTime == "__/__" ? null : startTime,
      "end_time": endTime == "__/__" ? null : endTime,
      "geoposition": geoposition,
      "day_status": dayStatus,
      "penalty_count": penaltyCount,
      "start_photo_time": startPhotoTime,
      "end_photo_time": endPhotoTime,
      "worker_status_start": workerStatusStart,
      "worker_status_end": workerStatusEnd,
      "confirmed_start": confirmedStart,
      "confirmed_end": confirmedEnd,
      "update_worker_penalty": updateWorkerPenalty,
      "today": today,
    };
    final response = await _post('/edit_day', json);
    final jsonResponse = jsonDecode(response.body);
    return response;
  }

  static Future<dynamic> extendPlan() async {
    return await _post('/extend_plan', {});
  }
}
