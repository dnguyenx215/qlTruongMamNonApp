// lib/services/class_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClassService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  /// Lấy thông tin của user từ ID
  static Future<Map<String, dynamic>> fetchUserById(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token not found");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId"),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      // Trả về empty map nếu không tìm thấy user, không throw exception
      // để tránh ảnh hưởng đến luồng lấy danh sách lớp
      return {};
    }
  }

  /// Gọi API lấy danh sách lớp theo user_id được lưu trong SharedPreferences.
  /// URL API trong backend Laravel: /admin/classes với query param user_id
  static Future<List<Map<String, dynamic>>> fetchClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    String? token = prefs.getString('token');

    if (userDataString == null) {
      throw Exception("User data not found");
    }

    final userData = jsonDecode(userDataString);
    final userId = userData['id'];

    // Lấy danh sách giáo viên trước để có thể ánh xạ ID -> tên
    Map<int, String> teacherNames = {};
    try {
      List<Map<String, dynamic>> teachers = await fetchTeachers();
      for (var teacher in teachers) {
        teacherNames[teacher['id']] = teacher['name'];
      }
    } catch (e) {
      debugPrint("Không thể lấy danh sách giáo viên: $e");
      // Tiếp tục xử lý, không dừng luồng
    }

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

        String heLop;
        if (nameLop.toLowerCase().contains("nhà trẻ")) {
          heLop = "Nhà trẻ";
        } else if (nameLop.toLowerCase().contains("mẫu giáo")) {
          heLop = "Mẫu giáo";
        } else {
          heLop = "Khác";
        }

        String tinhTrang = (studentsCount >= capacity) ? "FULL" : "INCOMPLETE";

        // Lấy tên giáo viên từ ID
        String gvcnInfo = "Chưa có GVCN";
        int? gvcnId = item["homeroom_teacher_id"];

        if (gvcnId != null) {
          // Ưu tiên lấy từ danh sách teacherNames đã tải
          if (teacherNames.containsKey(gvcnId)) {
            gvcnInfo = teacherNames[gvcnId]!;
          } else {
            // Nếu không có trong danh sách, hiển thị thông tin ID
            gvcnInfo = "GVCN ID: $gvcnId";
          }
        }

        processedClasses.add({
          "checked": false,
          "id": item["id"],
          "maLop": "L${item["id"]}",
          "tenLop": item["name"] ?? "Chưa rõ",
          "heLop": heLop,
          "gvcn": gvcnInfo,
          "gvcnId": gvcnId,
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
