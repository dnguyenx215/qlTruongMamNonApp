// lib/services/student_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  /// Gọi API lấy danh sách học sinh
  /// Trả về danh sách [Map<String, dynamic>]
  static Future<List<Map<String, dynamic>>> fetchStudents() async {
    final response = await http.get(Uri.parse('$_baseUrl/students'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // data['data'] là một List<dynamic>
      final rawList = data['data'] as List<dynamic>;

      // Chuyển mỗi phần tử sang Map<String, dynamic> và thêm 'checked': false
      final students =
          rawList.map((item) {
            final mapItem = Map<String, dynamic>.from(item as Map);
            mapItem['checked'] = false;
            return mapItem;
          }).toList();

      return students;
    } else {
      throw Exception('Lỗi khi gọi API (code: ${response.statusCode})');
    }
  }

  static Future<void> updateStudent(Map<String, dynamic> student) async {
    final id = student['id'];
    final response = await http.put(
      Uri.parse('$_baseUrl/students/$id'),
      body: jsonEncode(student),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi gọi API (code: ${response.statusCode})');
    }
  }

static Future<void> deleteStudent(String id) async {
  final response = await http.delete(
    Uri.parse('$_baseUrl/students/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Lỗi khi gọi API xóa học sinh (code: ${response.statusCode})');
  }
}
}
