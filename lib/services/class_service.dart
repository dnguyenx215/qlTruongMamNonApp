// lib/services/class_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClassService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  /// Lấy thông tin chi tiết của giáo viên chủ nhiệm
  static Future<Map<String, dynamic>> _fetchTeacherDetails(
    int? teacherId,
  ) async {
    if (teacherId == null) {
      return {"id": null, "name": "Chưa có GVCN", "email": ""};
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/$teacherId"),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'] ?? {};

        return {
          "id": userData['id'],
          "name": userData['name'] ?? "Giáo viên không xác định",
          "email": userData['email'] ?? "",
        };
      } else {
        // Trả về thông tin mặc định nếu không tìm thấy giáo viên
        return {
          "id": teacherId,
          "name": "Giáo viên (ID: $teacherId)",
          "email": "",
        };
      }
    } catch (e) {
      // Xử lý lỗi mạng hoặc các lỗi khác
      debugPrint("Lỗi khi lấy thông tin giáo viên: $e");
      return {
        "id": teacherId,
        "name": "Giáo viên (ID: $teacherId)",
        "email": "",
      };
    }
  }

  /// Gọi API lấy danh sách lớp
  static Future<List<Map<String, dynamic>>> fetchClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    // URL API lấy danh sách lớp
    final String apiUrl = "$baseUrl/admin/classes?user_id=$userId";

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> classes = responseData["data"];

      List<Map<String, dynamic>> processedClasses = [];

      for (var item in classes) {
        final int studentsCount = item["students_count"] ?? 0;
        final int capacity = item["capacity"] ?? 0;
        String nameLop = (item["name"] ?? "").toString();

        // Xác định khối
        String heLop =
            (item["grade_block_id"] ?? _determineGradeBlock(nameLop))
                .toString();

        // Xác định tình trạng lớp
        String tinhTrang = (studentsCount >= capacity) ? "FULL" : "INCOMPLETE";

        // Xử lý thông tin giáo viên chủ nhiệm
        final int? homeroomTeacherId = item["homeroom_teacher_id"];
        Map<String, dynamic> gvcnInfo = await _fetchTeacherDetails(
          homeroomTeacherId,
        );

        processedClasses.add({
          "checked": false,
          "id": item["id"],
          "maLop": "L${item["id"]}",
          "tenLop": item["name"] ?? "Chưa rõ",
          "heLop": heLop,
          "gvcn": gvcnInfo["name"] ?? "Chưa có GVCN",
          "gvcnId": gvcnInfo["id"],
          "gvcnEmail": gvcnInfo["email"],
          "doTuoi": "", // Nếu API không có, có thể để trống
          "siSo": "$studentsCount/$capacity",
          "capacity": capacity,
          "students_count": studentsCount,
          "tinhTrang": tinhTrang,
          "grade_block_id": item["grade_block_id"],
        });
      }

      return processedClasses;
    } else {
      throw Exception(
        'Failed to load classes, status: ${response.statusCode}, message: ${response.body}',
      );
    }
  }

  static String _determineGradeBlock(String nameLop) {
    nameLop = nameLop.toLowerCase();
    if (nameLop.contains("nhà trẻ") || nameLop.contains("NT")) {
      return "Nhà trẻ";
    } else if (nameLop.contains("mẫu giáo") || nameLop.contains("MG")) {
      return "Mẫu giáo";
    }
    return "Khác";
  }

  /// Thêm mới một lớp học
  /// URL API trong backend Laravel: POST /admin/classes
  static Future<void> addClass(Map<String, dynamic> classData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    // Add user_id to request
    classData['user_id'] = userId;

    final response = await http.post(
      Uri.parse("$baseUrl/admin/classes"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(classData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add class: ${response.body}');
    }
  }

  /// Cập nhật thông tin lớp học
  /// URL API trong backend Laravel: PUT /admin/classes/{id}
  static Future<void> updateClass(
    int classId,
    Map<String, dynamic> classData,
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
    classData['user_id'] = userId;

    final response = await http.put(
      Uri.parse("$baseUrl/admin/classes/$classId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(classData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update class: ${response.body}');
    }
  }

  /// Xóa một lớp học
  /// URL API trong backend Laravel: DELETE /admin/classes/{id}
  static Future<void> deleteClass(int classId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    final response = await http.delete(
      Uri.parse("$baseUrl/admin/classes/$classId?user_id=$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete class: ${response.body}');
    }
  }

  /// Lấy danh sách giáo viên
  /// URL API có thể là /users?role=teacher
  static Future<List<Map<String, dynamic>>> fetchTeachers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token not found");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/users?role=teacher"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> teachers = data['data'] ?? [];

      return teachers.map<Map<String, dynamic>>((item) {
        return {
          "id": item['id'],
          "name": item['name'] ?? "Chưa có tên",
          "email": item['email'] ?? "",
        };
      }).toList();
    } else {
      throw Exception('Failed to load teachers: ${response.statusCode}');
    }
  }

  /// Lấy danh sách khối học
  /// URL API: /grade-blocks
  static Future<List<Map<String, dynamic>>> fetchGradeBlocks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userDataString = prefs.getString('user');

    if (token == null) {
      throw Exception("Token not found");
    }

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    final response = await http.get(
      Uri.parse("$baseUrl/grade-blocks?user_id=$userId"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> blocks = data['data'] ?? [];

      return blocks.map<Map<String, dynamic>>((item) {
        return {
          "id": item['id'],
          "code": item['code'] ?? "",
          "name": item['name'] ?? "Chưa có tên",
          "description": item['description'] ?? "",
        };
      }).toList();
    } else {
      throw Exception('Failed to load grade blocks: ${response.statusCode}');
    }
  }
}
