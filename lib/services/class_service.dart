// lib/services/classroom_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/classroom.dart';
import '../models/grade_block.dart';

class ClassroomService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Lấy token và user id từ SharedPreferences
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

  /// Lấy danh sách lớp học
  static Future<List<Classroom>> fetchClasses() async {
    final authData = await _getAuthData();
    final userId = authData['userId'];
    final token = authData['token'];

    // URL API lấy danh sách lớp
    final apiUrl = '$baseUrl/admin/classes?user_id=$userId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> classesData = responseData['data'];

      return classesData
          .map<Classroom>((item) => Classroom.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Không thể tải danh sách lớp. Mã lỗi: ${response.statusCode}, nội dung: ${response.body}',
      );
    }
  }

  /// Thêm mới lớp học
  static Future<void> addClass(Classroom classroom) async {
    final authData = await _getAuthData();
    final userId = authData['userId'];

    // Chuẩn bị dữ liệu gửi lên
    Map<String, dynamic> requestData = {
      'user_id': userId,
      'name': classroom.name,
      'capacity': classroom.capacity,
      'homeroom_teacher_id': classroom.homeroomTeacherId,
      'grade_block_id': classroom.gradeBlockId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/admin/classes'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 201) {
      throw Exception('Thêm lớp thất bại: ${response.body}');
    }
  }

  /// Cập nhật thông tin lớp học
  static Future<void> updateClass(Classroom classroom) async {
    final authData = await _getAuthData();
    final userId = authData['userId'];
    final token = authData['token'];

    // Chuẩn bị dữ liệu gửi lên
    Map<String, dynamic> requestData = {
      'user_id': userId,
      'name': classroom.name,
      'capacity': classroom.capacity,
      'homeroom_teacher_id': classroom.homeroomTeacherId,
      'grade_block_id': classroom.gradeBlockId,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/admin/classes/${classroom.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật lớp thất bại: ${response.body}');
    }
  }

  /// Xóa lớp học
  static Future<void> deleteClass(int classId) async {
    final authData = await _getAuthData();
    final userId = authData['userId'];
    final token = authData['token'];

    final response = await http.delete(
      Uri.parse('$baseUrl/admin/classes/$classId?user_id=$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Xóa lớp thất bại: ${response.body}');
    }
  }

  /// Lấy danh sách khối học
  static Future<List<GradeBlock>> fetchGradeBlocks() async {
    final authData = await _getAuthData();
    final userId = authData['userId'];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grade-blocks?user_id=$userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Kiểm tra nếu data['data'] không phải là List hoặc null
        if (data == null || data['data'] == null || !(data['data'] is List)) {
          // Trả về danh sách mặc định
          return [
            GradeBlock(
              id: 1,
              code: 'NT',
              name: 'Nhà trẻ',
              description: 'Dành cho học sinh từ 2-3 tuổi',
            ),
            GradeBlock(
              id: 2,
              code: 'MG',
              name: 'Mẫu giáo',
              description: 'Dành cho học sinh từ 3-6 tuổi',
            ),
          ];
        }

        final List<dynamic> blocksData = data['data'];
        return blocksData
            .map<GradeBlock>((item) => GradeBlock.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Không thể tải danh sách khối học. Mã lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách khối học: $e');
      // Trả về danh sách mặc định nếu có lỗi
      return [
        GradeBlock(
          id: 1,
          code: 'NT',
          name: 'Nhà trẻ',
          description: 'Dành cho học sinh từ 2-3 tuổi',
        ),
        GradeBlock(
          id: 2,
          code: 'MG',
          name: 'Mẫu giáo',
          description: 'Dành cho học sinh từ 3-6 tuổi',
        ),
      ];
    }
  }

  /// Lấy danh sách giáo viên
  static Future<List<Map<String, dynamic>>> fetchTeachers() async {
    try {
      // Lấy danh sách người dùng có vai trò là giáo viên
      final response = await http.get(
        Uri.parse('$baseUrl/users?role=teacher'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final dataMap = responseJson['data'];

        if (dataMap is Map<String, dynamic>) {
          // Chuyển từ Map sang List
          final List<Map<String, dynamic>> teachersList = [];

          dataMap.forEach((key, teacher) {
            teachersList.add({
              'id': teacher['id'],
              'name': teacher['name'] ?? 'Không có tên',
              'email': teacher['email'] ?? '',
            });
          });

          return teachersList;
        } else if (dataMap is List) {
          // Nếu API đã trả về dạng List
          return dataMap.map<Map<String, dynamic>>((teacher) {
            return {
              'id': teacher['id'],
              'name': teacher['name'] ?? 'Không có tên',
              'email': teacher['email'] ?? '',
            };
          }).toList();
        } else {
          debugPrint('Cấu trúc dữ liệu không đúng định dạng: $dataMap');
          return _getDefaultTeachers();
        }
      } else {
        throw Exception(
          'Không thể tải danh sách giáo viên. Mã lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách giáo viên: $e');
      return _getDefaultTeachers();
    }
  }

  // Hàm trả về danh sách giáo viên mặc định
  static List<Map<String, dynamic>> _getDefaultTeachers() {
    return [
      {'id': 1, 'name': 'Nguyễn Văn A', 'email': 'nguyenvana@example.com'},
      {'id': 2, 'name': 'Trần Thị B', 'email': 'tranthib@example.com'},
      {'id': 3, 'name': 'Lê Văn C', 'email': 'levanc@example.com'},
    ];
  }
}
