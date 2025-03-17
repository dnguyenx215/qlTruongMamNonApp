// lib/screens/classroom_screen.dart
import 'dart:convert';
import 'package:example_app/models/grade_block.dart';
import 'package:example_app/services/class_service.dart';
import 'package:example_app/widgets/ManagementLayout.dart';
import 'package:example_app/widgets/classroom/ClassAddEditModal.dart';
import 'package:example_app/widgets/classroom/ClassDeleteModal.dart';
import 'package:example_app/widgets/classroom/ClassDetailModal.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/classroom.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  bool _isLoading = false;
  String _userName = '';
  String _userRole = '';

  // Biến lọc
  String _searchKeyword = '';
  String _selectedYear = '2023-2024';
  final List<String> _yearOptions = ['2023-2024', '2024-2025', '2025-2026'];

  // Danh sách lớp học
  List<Classroom> _classList = [];
  List<Map<String, dynamic>> _teacherList = [];
  List<GradeBlock> _gradeBlockList = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchClasses();
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
          _userRole = userData['roles'][0]['display_name'] ?? 'Chưa xác định';
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

  /// Gọi API lấy danh sách lớp
  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);

    try {
      final classList = await ClassroomService.fetchClasses();
      final teacherList = await ClassroomService.fetchTeachers();
      final gradeBlockList = await ClassroomService.fetchGradeBlocks();

      setState(() {
        _classList = classList;
        _teacherList = teacherList;
        _gradeBlockList = gradeBlockList;
        for (var classroom in _classList) {
          // Xử lý tên giáo viên chủ nhiệm
          if (classroom.homeroomTeacherId != null) {
            try {
              var teacher = _teacherList.firstWhere(
                (t) => t['id'] == classroom.homeroomTeacherId,
                orElse: () => {'name': 'Chưa có GVCN'},
              );
              classroom.homeroomTeacherName = teacher['name'];
            } catch (e) {
              classroom.homeroomTeacherName = 'Chưa có GVCN';
            }
          }

          // Xử lý tên khối
          if (classroom.gradeBlockId != null) {
            try {
              var gradeBlock = _gradeBlockList.firstWhere(
                (g) => g.id == classroom.gradeBlockId,
                orElse:
                    () => GradeBlock(id: -1, code: '', name: 'Chưa phân khối'),
              );
              classroom.gradeBlockName = gradeBlock.name;
            } catch (e) {
              classroom.gradeBlockName = 'Chưa phân khối';
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Lỗi khi tải danh sách lớp: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách lớp: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  // Lọc danh sách lớp theo từ khóa
  List<Classroom> get _filteredClassList {
    if (_searchKeyword.isEmpty) {
      return _classList;
    }

    return _classList.where((classroom) {
      final name = classroom.name.toLowerCase();
      final teacherName = classroom.homeroomTeacherName.toLowerCase();
      return name.contains(_searchKeyword.toLowerCase()) ||
          teacherName.contains(_searchKeyword.toLowerCase());
    }).toList();
  }

  // Hiển thị modal thêm/sửa lớp
  void _showAddEditModal([Classroom? existingClass]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassroomAddEditModal(
          existingClass: existingClass,
          onSuccess: _fetchClasses,
        );
      },
    );
  }

  // Hiển thị modal xóa lớp
  void _showDeleteModal(Classroom classroom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassroomDeleteModal(
          classroom: classroom,
          onSuccess: _fetchClasses,
        );
      },
    );
  }

  // Hiển thị modal chi tiết lớp
  void _showClassDetailModal(Classroom classroom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassroomDetailModal(classroom: classroom);
      },
    );
  }

  // Bảng hiển thị danh sách lớp
  Widget _buildClassTable() {
    if (_filteredClassList.isEmpty) {
      return const Center(child: Text("Không có lớp học nào."));
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
                  DataColumn(label: Text('STT')),
                  DataColumn(label: Text('MÃ LỚP')),
                  DataColumn(label: Text('TÊN LỚP')),
                  DataColumn(label: Text('KHỐI')),
                  DataColumn(label: Text('GVCN')),
                  DataColumn(label: Text('SĨ SỐ')),
                  DataColumn(label: Text('TRẠNG THÁI')),
                ],
                rows:
                    _filteredClassList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final classroom = entry.value;

                      return DataRow(
                        selected: classroom.checked,
                        onSelectChanged: (selected) {
                          if (selected != null) {
                            setState(() {
                              // Đảm bảo chỉ được chọn 1 lớp tại một thời điểm
                              for (var c in _classList) {
                                c.checked = false;
                              }
                              classroom.checked = selected;
                            });
                          }
                        },
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(classroom.code)),
                          DataCell(Text(classroom.name)),
                          DataCell(Text(classroom.gradeBlockName)),
                          DataCell(
                            Tooltip(
                              message: classroom.homeroomTeacherName,
                              child: Text(
                                classroom.homeroomTeacherName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${classroom.studentCount}/${classroom.capacity}',
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    classroom.status == "FULL"
                                        ? Colors.red[100]
                                        : Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                classroom.status,
                                style: TextStyle(
                                  color:
                                      classroom.status == "FULL"
                                          ? Colors.red[900]
                                          : Colors.green[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
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

  // Xử lý các nút chức năng
  void _themMoi() => _showAddEditModal();

  void _sua() {
    final selectedClass = _classList.firstWhere(
      (item) => item.checked,
      orElse: () => throw Exception('No classroom selected'),
    );

    if (selectedClass.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một lớp để sửa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showAddEditModal(selectedClass);
  }

  void _xoa() {
    final selectedClass = _classList.firstWhere(
      (item) => item.checked,
      orElse: () => throw Exception('No classroom selected'),
    );

    if (selectedClass.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một lớp để xóa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showDeleteModal(selectedClass);
  }

  void _xemChiTiet() {
    final selectedClass = _classList.firstWhere(
      (item) => item.checked,
      orElse: () => throw Exception('No classroom selected'),
    );

    if (selectedClass.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một lớp để xem chi tiết'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showClassDetailModal(selectedClass);
  }

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      selectedRoute: '/class',
      userName: _userName,
      userRole: _userRole,
      title: 'Quản lý lớp',
      onRouteSelected: (route) => Navigator.pushNamed(context, route),
      mainContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề + các nút chức năng
          Text(
            'DANH SÁCH LỚP',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Khu vực bộ lọc và các nút
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth < 700;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Ô tìm kiếm
                  SizedBox(
                    width: isSmallScreen ? 200 : 300,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tìm lớp, GVCN...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() => _searchKeyword = value);
                      },
                    ),
                  ),

                  // Dropdown chọn năm học
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
                      if (val != null) {
                        setState(() => _selectedYear = val);
                        // TODO: Gọi API lấy danh sách lớp theo năm học khi API hỗ trợ
                      }
                    },
                  ),

                  // Nút Thêm mới
                  ElevatedButton.icon(
                    onPressed: _themMoi,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm mới'),
                  ),
                  // Nút Sửa
                  ElevatedButton.icon(
                    onPressed: _classList.any((c) => c.checked) ? _sua : null,
                    icon: const Icon(Icons.edit),
                    label: const Text('Sửa'),
                  ),
                  // Nút Xóa
                  ElevatedButton.icon(
                    onPressed: _classList.any((c) => c.checked) ? _xoa : null,
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                  ),
                  // Nút Xem chi tiết
                  ElevatedButton.icon(
                    onPressed:
                        _classList.any((c) => c.checked) ? _xemChiTiet : null,
                    icon: const Icon(Icons.info),
                    label: const Text('Xem chi tiết'),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Bảng danh sách
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildClassTable(),
          ),
        ],
      ),
    );
  }
}
