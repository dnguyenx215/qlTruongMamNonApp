// lib/screens/student/student_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/student.dart';
import '../../services/student_service.dart';
import '../../widgets/ManagementLayout.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;

  const StudentDetailScreen({Key? key, required this.studentId})
    : super(key: key);

  @override
  _StudentDetailScreenState createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  String _userName = '';
  String _userRole = '';
  bool _isLoading = true;
  Student? _student;
  String _className = 'Chưa phân lớp';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStudentDetails();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user');
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        setState(() {
          _userName = userData['name'] ?? 'Người dùng';
          _userRole = userData['role'] ?? 'Quản lý';
        });
      } catch (e) {
        setState(() {
          _userName = 'Người dùng';
          _userRole = 'Quản lý';
        });
      }
    } else {
      setState(() {
        _userName = 'VUONG THI MAI';
        _userRole = 'QL';
      });
    }
  }

  Future<void> _loadStudentDetails() async {
    setState(() => _isLoading = true);

    try {
      // Lấy thông tin học sinh
      final student = await StudentService.getStudent(widget.studentId);

      // Lấy danh sách lớp học
      final classes = await StudentService.fetchClasses();

      // Tìm tên lớp học
      if (student.classId != null) {
        final classInfo = classes.firstWhere(
          (c) => c['id'] == student.classId,
          orElse: () => {'name': 'Chưa phân lớp'},
        );

        _className = classInfo['name'];
      }

      setState(() {
        _student = student;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error when loading student details: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải thông tin học sinh: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      selectedRoute: 'students',
      userName: _userName,
      userRole: _userRole,
      title: 'Chi tiết học sinh',
      onRouteSelected: (route) => Navigator.pushNamed(context, route),
      mainContent:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _student == null
              ? const Center(child: Text('Không tìm thấy thông tin học sinh'))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header với thông tin cơ bản
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              _student!.fullName.isNotEmpty
                                  ? _student!.fullName
                                      .substring(0, 1)
                                      .toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Thông tin cơ bản
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _student!.fullName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Mã học sinh: ${_student!.studentCode ?? 'Chưa cấp mã'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lớp: $_className',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),

                          // Nút tác vụ
                          Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Quay lại màn hình danh sách
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Quay lại'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Navigate to edit screen
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Sửa'),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Thông tin cá nhân
                      _buildInfoSection('THÔNG TIN CÁ NHÂN', [
                        _buildInfoItem('Họ và tên:', _student!.fullName),
                        _buildInfoItem(
                          'Ngày sinh:',
                          _formatDate(_student!.birthday),
                        ),
                        _buildInfoItem('Giới tính:', _student!.genderText),
                        _buildInfoItem('Địa chỉ:', _student!.address ?? ''),
                      ]),

                      // Thông tin phụ huynh
                      _buildInfoSection('THÔNG TIN PHỤ HUYNH', [
                        _buildInfoItem(
                          'Tên phụ huynh:',
                          _student!.parentName ?? '',
                        ),
                        _buildInfoItem(
                          'Số điện thoại:',
                          _student!.parentPhone ?? '',
                        ),
                        _buildInfoItem('Email:', _student!.parentEmail ?? ''),
                      ]),

                      // Thông tin học tập
                      _buildInfoSection('THÔNG TIN HỌC TẬP', [
                        _buildInfoItem('Lớp hiện tại:', _className),
                        // TODO: Có thể bổ sung thêm lịch sử lớp, điểm danh, học phí
                      ]),
                    ],
                  ),
                ),
              ),
    );
  }
}
