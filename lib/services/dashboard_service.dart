import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
  static const String baseApiUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseApiUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return null;
    }
  }

  // Thêm các phương thức khác để lấy dữ liệu cụ thể như:
  // getStudentMonitoring(), getFoodTracking(), getTuitionTracking(), getNotifications()
}
