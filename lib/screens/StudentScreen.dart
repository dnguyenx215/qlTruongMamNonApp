// lib/screens/StudentScreen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import file service (điều chỉnh đường dẫn tùy project của bạn)
import '../services/student_service.dart';

import '../widgets/ManagementLayout.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  // Thông tin người dùng (hiển thị trên header)
  String _userName = '';
  String _userRole = '';

  // Dữ liệu danh sách học sinh
  List<Map<String, dynamic>> _studentList = [];
  bool _isLoading = false;

  // Bộ lọc
  String _searchKeyword = '';
  String _selectedClass = 'Tất cả';
  String _selectedGender = 'Tất cả';
  String _selectedYear = '2023-2024';

  // Các tùy chọn demo
  final List<String> _classOptions = ['Tất cả', '1', '2', '3'];
  final List<String> _genderOptions = ['Tất cả', 'Nam', 'Nữ'];
  final List<String> _yearOptions = ['2023-2024', '2024-2025', '2025-2026'];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchStudents();
  }

  /// Lấy thông tin user (để hiển thị trên header)
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

  /// Gọi service lấy danh sách học sinh
  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      // Gọi hàm từ StudentService
      final students = await StudentService.fetchStudents();
      setState(() {
        _studentList = students;
      });
    } catch (e) {
      debugPrint('Lỗi khi gọi API: $e');
    }
    setState(() => _isLoading = false);
  }

  /// Lọc danh sách theo từ khóa, giới tính, lớp
  List<Map<String, dynamic>> get _filteredStudentList {
    return _studentList.where((student) {
      // Lọc theo search (tìm trong họ tên, mã HS)
      final fullName =
          '${student['first_name']} ${student['last_name']}'.toLowerCase();
      final code = (student['student_code'] ?? '').toString().toLowerCase();
      final searchMatch =
          fullName.contains(_searchKeyword.toLowerCase()) ||
          code.contains(_searchKeyword.toLowerCase());

      // Lọc theo giới tính
      final gender =
          (student['gender'] ?? '').toLowerCase(); // "male" / "female"
      bool genderMatch = true;
      if (_selectedGender == 'Nam') {
        genderMatch = (gender == 'male');
      } else if (_selectedGender == 'Nữ') {
        genderMatch = (gender == 'female');
      }

      // Lọc theo lớp (nếu _selectedClass != 'Tất cả')
      bool classMatch = true;
      if (_selectedClass != 'Tất cả') {
        final classIdString = (student['class_id'] ?? '').toString();
        classMatch = (classIdString == _selectedClass);
      }

      return searchMatch && genderMatch && classMatch;
    }).toList();
  }

  // Ví dụ hàm xử lý khi bấm các nút (tự tuỳ biến logic)
  void _themMoi() {
    debugPrint('Thêm mới học sinh');
  }

  void _chuyenLop() {
    debugPrint('Chuyển lớp cho các học sinh đã chọn');
  }

  void _inDanhSach() {
    debugPrint('In danh sách học sinh');
  }

  void _xuatExcel() {
    debugPrint('Xuất Excel danh sách học sinh');
  }

  void _xuatPDF() {
    debugPrint('Xuất PDF danh sách học sinh');
  }

  // Tạo bảng DataTable
  Widget _buildStudentTable() {
    final dataList = _filteredStudentList;
    if (dataList.isEmpty) {
      return const Center(child: Text("Không có học sinh nào."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('')), // Cột checkbox
                  DataColumn(label: Text('STT')),
                  DataColumn(label: Text('TÊN HỌC SINH')),
                  DataColumn(label: Text('MÃ HS')),
                  DataColumn(label: Text('GIỚI TÍNH')),
                  DataColumn(label: Text('NGÀY SINH')),
                  DataColumn(label: Text('LỚP')),
                  DataColumn(label: Text('ĐỊA CHỈ')),
                ],
                rows:
                    dataList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final student = entry.value;

                      final fullName =
                          '${student['first_name']} ${student['last_name']}'
                              .trim();
                      final genderString =
                          (student['gender'] == 'male') ? 'Nam' : 'Nữ';

                      return DataRow(
                        cells: [
                          // Checkbox
                          DataCell(
                            Checkbox(
                              value: student['checked'] ?? false,
                              onChanged: (val) {
                                setState(() {
                                  student['checked'] = val ?? false;
                                });
                              },
                            ),
                          ),
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(fullName)),
                          DataCell(Text(student['student_code'] ?? '')),
                          DataCell(Text(genderString)),
                          DataCell(Text(student['birthday'] ?? '')),
                          // Hiển thị class_id; nếu muốn hiển thị tên lớp cần thêm logic
                          DataCell(Text(student['class_id']?.toString() ?? '')),
                          DataCell(Text(student['address'] ?? '')),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      selectedRoute: 'students',
      userName: _userName,
      userRole: _userRole,
      title: 'Quản lý học sinh',
      onRouteSelected: (route) => Navigator.pushNamed(context, route),
      mainContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            'DANH SÁCH HỌC SINH',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Thanh công cụ: chọn lớp, giới tính, năm học, tìm kiếm, nút chức năng
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth < 800;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Dropdown Chọn lớp
                  DropdownButton<String>(
                    value: _selectedClass,
                    items:
                        _classOptions.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text('Lớp $item'),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedClass = val ?? 'Tất cả');
                    },
                  ),

                  // Dropdown Giới tính
                  DropdownButton<String>(
                    value: _selectedGender,
                    items:
                        _genderOptions.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedGender = val ?? 'Tất cả');
                    },
                  ),

                  // Dropdown Năm học
                  DropdownButton<String>(
                    value: _selectedYear,
                    items:
                        _yearOptions.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedYear = val ?? _selectedYear);
                    },
                  ),

                  // Ô tìm kiếm
                  SizedBox(
                    width: isSmallScreen ? 200 : 250,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tìm theo tên, mã HS...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() => _searchKeyword = value);
                      },
                    ),
                  ),

                  // Các nút chức năng
                  ElevatedButton.icon(
                    onPressed: _themMoi,
                    icon: const Icon(Icons.add),
                    label: const Text('Mới'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _chuyenLop,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Chuyển lớp'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _inDanhSach,
                    icon: const Icon(Icons.print),
                    label: const Text('In DS'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _xuatExcel,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Excel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _xuatPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Bảng danh sách học sinh
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildStudentTable(),
          ),

          // Thanh hiển thị tổng số và trang (demo)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng số: ${_filteredStudentList.length} học sinh'),
              const Text('Trang 1/1'), // Nếu cần phân trang thật, bạn tự xử lý
            ],
          ),
        ],
      ),
    );
  }
}
