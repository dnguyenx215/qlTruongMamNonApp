// lib/services/attendance_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance.dart';
import '../models/student.dart';

class AttendanceService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Lấy thông tin điểm danh theo ngày và lớp
  static Future<List<Attendance>> fetchAttendanceByDate(
    String date,
    int classId,
  ) async {
    final authData = await _getAuthData();
    final userId = authData['userId'];
    final token = authData['token'];

    final response = await http.get(
      Uri.parse(
        '$baseUrl/attendances?date=$date&class_id=$classId&user_id=$userId',
      ),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> attendances = data['data'];
      return attendances.map((item) => Attendance.fromJson(item)).toList();
    } else {
      throw Exception(
        'Không thể tải dữ liệu điểm danh: ${response.statusCode}',
      );
    }
  }

  /// Cập nhật điểm danh cho một học sinh
  static Future<Attendance> updateAttendance(Attendance attendance) async {
    final body = {
      'student_id': attendance.studentId,
      'date': attendance.date,
      'status': attendance.status,
      'absence_reason': attendance.absenceReason,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/attendances'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Attendance.fromJson(data['data']);
    } else {
      throw Exception('Không thể cập nhật điểm danh: ${response.statusCode}');
    }
  }

  /// Khóa điểm danh của một ngày
  static Future<void> lockAttendance(String date, int classId) async {
    final authData = await _getAuthData();
    final userId = authData['userId'];
    final token = authData['token'];

    final body = {
      'user_id': userId,
      'date': date,
      'class_id': classId,
      'is_locked': true,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/attendances/lock'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể khóa điểm danh: ${response.statusCode}');
    }
  }

  /// Kiểm tra xem ngày có phải là ngày nghỉ không
  static Future<bool> checkIsHoliday(String date) async {
    final authData = await _getAuthData();
    final userId = authData['userId'];
    final token = authData['token'];

    final response = await http.post(
      Uri.parse('$baseUrl/holidays/check'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'user_id': userId, 'date': date}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_holiday'] ?? false;
    } else {
      throw Exception('Không thể kiểm tra ngày nghỉ: ${response.statusCode}');
    }
  }

  /// Lấy thông tin auth
  static Future<Map<String, dynamic>> _getAuthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    return {'userId': userId, 'token': token};
  }
}
