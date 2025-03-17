// lib/services/holiday_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HolidayService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  /// Lấy danh sách ngày nghỉ theo năm
  static Future<List<Map<String, dynamic>>> fetchHolidays(int year) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    // URL API lấy danh sách ngày nghỉ
    final String apiUrl = "$baseUrl/holidays?user_id=$userId&year=$year";

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> holidays = responseData["data"];

      return holidays.map<Map<String, dynamic>>((item) {
        return {
          "id": item["id"],
          "holiday_date": item["holiday_date"],
          "holiday_name": item["holiday_name"] ?? "",
          "holiday_type": item["holiday_type"] ?? "other",
          "description": item["description"] ?? "",
        };
      }).toList();
    } else {
      throw Exception(
        'Failed to load holidays, status: ${response.statusCode}, message: ${response.body}',
      );
    }
  }

  /// Thêm mới một ngày nghỉ
  static Future<Map<String, dynamic>> addHoliday(
    Map<String, dynamic> holidayData,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');
    print(jsonEncode(holidayData));
    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    final response = await http.post(
      Uri.parse("$baseUrl/holidays?user_id=$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(holidayData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)["data"];
    } else {
      throw Exception('Failed to add holiday: ${response.body}');
    }
  }

  /// Cập nhật một ngày nghỉ
  static Future<Map<String, dynamic>> updateHoliday(
    int holidayId,
    Map<String, dynamic> holidayData,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    // Add user_id to request
    holidayData['user_id'] = userId.toString();

    final response = await http.put(
      Uri.parse("$baseUrl/holidays/$holidayId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(holidayData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"];
    } else {
      throw Exception('Failed to update holiday: ${response.body}');
    }
  }

  /// Xóa một ngày nghỉ
  static Future<void> deleteHoliday(int holidayId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    final response = await http.delete(
      Uri.parse("$baseUrl/holidays/$holidayId?user_id=$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete holiday: ${response.body}');
    }
  }

  /// Tạo tự động ngày nghỉ cuối tuần cho một năm
  static Future<List<Map<String, dynamic>>> createWeekendHolidays(
    int year,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    final response = await http.post(
      Uri.parse("$baseUrl/holidays/create-weekend"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'user_id': userId, 'year': year}),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> holidays = responseData["data"];

      return holidays.map<Map<String, dynamic>>((item) {
        return {
          "id": item["id"],
          "holiday_date": item["holiday_date"],
          "holiday_name": item["holiday_name"] ?? "Cuối tuần",
          "holiday_type": item["holiday_type"] ?? "weekend",
          "description": item["description"] ?? "",
        };
      }).toList();
    } else {
      throw Exception('Failed to create weekend holidays: ${response.body}');
    }
  }

  /// Kiểm tra một ngày có phải là ngày nghỉ không
  static Future<bool> checkIsHoliday(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    final response = await http.post(
      Uri.parse("$baseUrl/holidays/check"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'user_id': userId, 'date': date}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["is_holiday"] ?? false;
    } else {
      throw Exception('Failed to check holiday: ${response.body}');
    }
  }
}
