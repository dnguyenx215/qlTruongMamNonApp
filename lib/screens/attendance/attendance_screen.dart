// lib/screens/attendance/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../models/student.dart';
import '../../models/attendance.dart';
import '../../services/student_service.dart';
import '../../services/attendance_service.dart';
import '../../widgets/attendance/attendance_date_picker.dart';
import '../../widgets/attendance/class_selector.dart';
import '../../widgets/attendance/student_attendance_list.dart';
import '../../widgets/ManagementLayout.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isLoading = false;
  String _userName = '';
  String _userRole = '';

  DateTime _selectedDate = DateTime.now();
  int? _selectedClassId;
  List<Map<String, dynamic>> _classList = [];
  List<Student> _students = [];
  bool _isHoliday = false;
  bool _isAttendanceLocked = false;
  Map<int, Attendance> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadInitialData();
  }

  /// Lấy thông tin user
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

  /// Tải dữ liệu ban đầu
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Tải danh sách lớp
      final classes = await StudentService.fetchClasses();

      setState(() {
        _classList = classes;
        // Nếu có lớp, chọn lớp đầu tiên
        if (classes.isNotEmpty) {
          _selectedClassId = classes[0]['id'];
        }
      });

      // Tải dữ liệu điểm danh nếu đã chọn lớp
      if (_selectedClassId != null) {
        await _loadAttendanceData();
      }
    } catch (e) {
      _showErrorSnackBar('Không thể tải dữ liệu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tải dữ liệu điểm danh theo ngày và lớp
  Future<void> _loadAttendanceData() async {
    if (_selectedClassId == null) return;

    setState(() => _isLoading = true);

    try {
      // Định dạng ngày theo yyyy-MM-dd
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Kiểm tra xem ngày đã chọn có phải là ngày nghỉ không
      final isHoliday = await AttendanceService.checkIsHoliday(dateStr);

      // Tải danh sách học sinh của lớp
      final students = await StudentService.fetchStudents();
      final classStudents =
          students.where((s) => s.classId == _selectedClassId).toList();

      // Tải dữ liệu điểm danh
      final attendances = await AttendanceService.fetchAttendanceByDate(
        dateStr,
        _selectedClassId!,
      );

      // Tạo map từ studentId đến attendance để dễ tra cứu
      final attendanceMap = <int, Attendance>{};
      for (var attendance in attendances) {
        attendanceMap[attendance.studentId] = attendance;
      }

      // Lấy trạng thái khóa điểm danh
      bool isLocked = false;
      if (attendances.isNotEmpty) {
        isLocked = attendances.first.isLocked;
      }

      // Cập nhật trạng thái điểm danh cho từng học sinh
      for (var student in classStudents) {
        if (attendanceMap.containsKey(student.id)) {
          final attendance = attendanceMap[student.id!]!;
          student.attendanceStatus = attendance.status ?? 'present';
          student.absenceReason = attendance.absenceReason;
        } else {
          // Mặc định: có mặt
          student.attendanceStatus = 'present';
          student.absenceReason = null;
        }
      }

      setState(() {
        _students = classStudents;
        _isHoliday = isHoliday;
        _attendanceMap = attendanceMap;
        _isAttendanceLocked = isLocked;
      });
    } catch (e) {
      _showErrorSnackBar('Không thể tải dữ liệu điểm danh: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Thay đổi trạng thái điểm danh của học sinh
  void _handleStatusChanged(Student student, String newStatus) {
    setState(() {
      // Tìm học sinh trong danh sách và cập nhật trạng thái
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index].attendanceStatus = newStatus;

        // Nếu học sinh có mặt, xóa lý do vắng
        if (newStatus == 'present') {
          _students[index].absenceReason = null;
        }
      }
    });

    // Lưu thay đổi lên server
    _saveAttendance(student, newStatus, student.absenceReason);
  }

  /// Thay đổi lý do vắng của học sinh
  void _handleAbsenceReasonChanged(Student student, String reason) {
    // Lưu lý do vắng lên server
    _saveAttendance(student, student.attendanceStatus, reason);
  }

  /// Lưu dữ liệu điểm danh lên server
  Future<void> _saveAttendance(
    Student student,
    String status,
    String? reason,
  ) async {
    if (student.id == null) return;

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // Tạo object attendance để gửi lên server
      final attendance = Attendance(
        id: _attendanceMap[student.id]?.id,
        studentId: student.id!,
        date: dateStr,
        status: status,
        absenceReason: reason,
      );

      // Gửi request cập nhật
      final updatedAttendance = await AttendanceService.updateAttendance(
        attendance,
      );

      // Cập nhật lại map attendance
      setState(() {
        _attendanceMap[student.id!] = updatedAttendance;
      });
    } catch (e) {
      _showErrorSnackBar('Không thể cập nhật điểm danh: $e');
    }
  }

  /// Khóa điểm danh
  Future<void> _lockAttendance() async {
    if (_selectedClassId == null) return;

    setState(() => _isLoading = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      await AttendanceService.lockAttendance(dateStr, _selectedClassId!);

      setState(() {
        _isAttendanceLocked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã khóa điểm danh thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Không thể khóa điểm danh: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Hiển thị dialog xác nhận khóa điểm danh
  void _showLockAttendanceConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận khóa điểm danh'),
            content: const Text(
              'Sau khi khóa, bạn sẽ không thể thay đổi điểm danh của ngày này. Bạn có chắc chắn muốn khóa điểm danh không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _lockAttendance();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9240),
                ),
                child: const Text(
                  'Khóa điểm danh',
                  style: TextStyle(color: Color(0xFFFFFFA9)),
                ),
              ),
            ],
          ),
    );
  }

  /// Hiển thị SnackBar lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      selectedRoute: '/attendance',
      userName: _userName,
      userRole: _userRole,
      title: 'Điểm danh học sinh',
      onRouteSelected: (route) => Navigator.pushNamed(context, route),
      mainContent:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề
                      const Text(
                        'ĐIỂM DANH HỌC SINH',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date picker
                      AttendanceDatePicker(
                        selectedDate: _selectedDate,
                        onDateChanged: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                          _loadAttendanceData();
                        },
                        isHoliday: _isHoliday,
                        isLocked: _isAttendanceLocked,
                      ),
                      const SizedBox(height: 16),

                      // Class selector
                      ClassSelector(
                        classes: _classList,
                        selectedClassId: _selectedClassId,
                        onClassChanged: (classId) {
                          setState(() {
                            _selectedClassId = classId;
                          });
                          _loadAttendanceData();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Warning for holiday
                      if (_isHoliday)
                        Card(
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)} là ngày nghỉ. Không cần điểm danh.',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (!_isHoliday) ...[
                        const SizedBox(height: 16),

                        // Button to lock attendance
                        if (!_isAttendanceLocked && _selectedClassId != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showLockAttendanceConfirmation,
                              icon: const Icon(
                                Icons.lock,
                                color: Color(0xFFFFFFA9),
                              ),
                              label: const Text(
                                'Khóa điểm danh',
                                style: TextStyle(color: Color(0xFFFFFFA9)),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9240),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),

                        if (_isAttendanceLocked)
                          Card(
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Điểm danh đã bị khóa và không thể chỉnh sửa.',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Student attendance list
                        if (_selectedClassId != null)
                          StudentAttendanceList(
                            students: _students,
                            onStatusChanged: _handleStatusChanged,
                            onAbsenceReasonChanged: _handleAbsenceReasonChanged,
                            isLocked: _isAttendanceLocked,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
