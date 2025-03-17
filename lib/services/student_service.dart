// lib/services/student_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/student.dart';

class StudentService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api';

  /// Lấy danh sách học sinh từ API
  static Future<List<Student>> fetchStudents() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userDataString = prefs.getString('user');

      if (userDataString == null) {
        throw Exception("User data not found");
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      final response = await http.get(
        Uri.parse('$baseUrl/students?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> studentsJson = data['data'];

        // Chuyển đổi JSON thành danh sách Student
        return studentsJson.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi gọi API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
      throw Exception('Lỗi khi tải danh sách học sinh: $e');
    }
  }

  /// Lấy chi tiết một học sinh
  static Future<Student> getStudent(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userDataString = prefs.getString('user');

      if (userDataString == null) {
        throw Exception("User data not found");
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      final response = await http.get(
        Uri.parse('$baseUrl/students/$id?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Student.fromJson(data['data']);
      } else {
        throw Exception(
          'Lỗi khi lấy thông tin học sinh: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting student: $e');
      throw Exception('Lỗi khi tải thông tin học sinh: $e');
    }
  }

  /// Thêm học sinh mới
  static Future<Student> addStudent(Student student) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userDataString = prefs.getString('user');

      if (userDataString == null) {
        throw Exception("User data not found");
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      // Chuẩn bị dữ liệu gửi lên
      final studentData = student.toJson();
      studentData['user_id'] = userId;

      final response = await http.post(
        Uri.parse('$baseUrl/students'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(studentData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Student.fromJson(data['data']);
      } else {
        throw Exception('Lỗi khi thêm học sinh: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error adding student: $e');
      throw Exception('Lỗi khi thêm học sinh: $e');
    }
  }

  /// Cập nhật thông tin học sinh
  static Future<Student> updateStudent(Student student) async {
    try {
      if (student.id == null) {
        throw Exception("Student ID is required for update");
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userDataString = prefs.getString('user');

      if (userDataString == null) {
        throw Exception("User data not found");
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      // Chuẩn bị dữ liệu gửi lên
      final studentData = student.toJson();
      studentData['user_id'] = userId;

      final response = await http.put(
        Uri.parse('$baseUrl/students/${student.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(studentData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Student.fromJson(data['data']);
      } else {
        throw Exception('Lỗi khi cập nhật học sinh: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating student: $e');
      throw Exception('Lỗi khi cập nhật học sinh: $e');
    }
  }

  /// Xóa học sinh
  static Future<void> deleteStudent(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userDataString = prefs.getString('user');

      if (userDataString == null) {
        throw Exception("User data not found");
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      final response = await http.delete(
        Uri.parse('$baseUrl/students/$id?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi khi xóa học sinh: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting student: $e');
      throw Exception('Lỗi khi xóa học sinh: $e');
    }
  }

  /// Chuyển lớp cho học sinh
  static Future<void> assignClass(int studentId, int classId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userDataString = prefs.getString('user');

      if (userDataString == null) {
        throw Exception("User data not found");
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      final response = await http.post(
        Uri.parse('$baseUrl/students/$studentId/assign-class'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'class_id': classId, 'user_id': userId}),
      );

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        throw Exception(
          'Lỗi khi chuyển lớp: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error assigning class: $e');
      throw Exception('Lỗi khi chuyển lớp: $e');
    }
  }

  /// Lấy danh sách lớp học (để phục vụ cho việc chọn lớp)
  static Future<List<Map<String, dynamic>>> fetchClasses() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userDataString = prefs.getString('user');

      if (userDataString == null) {
        throw Exception("User data not found");
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      final response = await http.get(
        Uri.parse('$baseUrl/admin/classes?user_id=$userId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> classes = data['data'];

        return classes
            .map<Map<String, dynamic>>(
              (item) => {
                'id': item['id'],
                'name': item['name'] ?? 'Không có tên',
                'capacity': item['capacity'],
                'grade_block_id': item['grade_block_id'],
              },
            )
            .toList();
      } else {
        throw Exception('Lỗi khi lấy danh sách lớp: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
      throw Exception('Lỗi khi tải danh sách lớp: $e');
    }
  }
}
