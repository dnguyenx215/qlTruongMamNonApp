import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/class_service.dart';
import '../widgets/ManagementLayout.dart';
import '../widgets/classroom/ClassAddEditModal.dart';
import '../widgets/classroom/ClassDeleteModal.dart';
import '../widgets/classroom/ClassDetailModal.dart';

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

  // Danh sách lớp lấy từ API
  List<Map<String, dynamic>> _classList = [];

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

  /// Gọi API lấy danh sách lớp
  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> classList = await ClassService.fetchClasses();

      setState(() {
        _classList = classList;
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
  List<Map<String, dynamic>> get _filteredClassList {
    if (_searchKeyword.isEmpty) {
      return _classList;
    }
    return _classList.where((c) {
      final tenLop = (c['tenLop'] ?? '').toString().toLowerCase();
      final gvcn = (c['gvcn'] ?? '').toString().toLowerCase();
      return tenLop.contains(_searchKeyword.toLowerCase()) ||
          gvcn.contains(_searchKeyword.toLowerCase());
    }).toList();
  }

  // Hiển thị modal thêm/sửa lớp
  void _showAddEditModal([Map<String, dynamic>? existingClass]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassAddEditModal(
          existingClass: existingClass,
          onRefresh: _fetchClasses,
        );
      },
    );
  }

  // Hiển thị modal xóa lớp
  void _showDeleteModal(Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassDeleteModal(classData: classData, onRefresh: _fetchClasses);
      },
    );
  }

  // Hiển thị modal chi tiết lớp
  void _showClassDetailModal(Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassDetailModal(classData: classData);
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
              constraints: BoxConstraints(
                // Đảm bảo bảng không bị tràn ngang
                minWidth: constraints.maxWidth,
              ),
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
                      final item = entry.value;
                      return DataRow(
                        onSelectChanged: (selected) {
                          if (selected != null) {
                            setState(() {
                              // Đảm bảo chỉ được chọn 1 lớp tại một thời điểm
                              for (var c in _classList) {
                                c["checked"] = false;
                              }
                              item["checked"] = selected;
                            });
                          }
                        },
                        selected: item["checked"] ?? false,
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(item["maLop"] ?? "")),
                          DataCell(Text(item["tenLop"] ?? "")),
                          DataCell(Text(item["heLop"] ?? "")),
                          DataCell(
                            Tooltip(
                              message: item["gvcn"] ?? "Chưa có GVCN",
                              child: Text(
                                item["gvcn"] ?? "Chưa có GVCN",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(item["siSo"]?.toString() ?? "")),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    item["tinhTrang"] == "FULL"
                                        ? Colors.red[100]
                                        : Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item["tinhTrang"] ?? "",
                                style: TextStyle(
                                  color:
                                      item["tinhTrang"] == "FULL"
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
    final selectedClass = _filteredClassList.firstWhere(
      (item) => item["checked"] == true,
      orElse: () => {},
    );

    if (selectedClass.isEmpty) {
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
    final selectedClass = _filteredClassList.firstWhere(
      (item) => item["checked"] == true,
      orElse: () => {},
    );

    if (selectedClass.isEmpty) {
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
    final selectedClass = _filteredClassList.firstWhere(
      (item) => item["checked"] == true,
      orElse: () => {},
    );

    if (selectedClass.isEmpty) {
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
      selectedRoute: 'class',
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
                      setState(() => _selectedYear = val ?? _selectedYear);
                      // TODO: Gọi API hoặc lọc lại dữ liệu nếu cần
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
                    onPressed: _sua,
                    icon: const Icon(Icons.edit),
                    label: const Text('Sửa'),
                  ),
                  // Nút Xóa
                  ElevatedButton.icon(
                    onPressed: _xoa,
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                  ),
                  // Nút Xem chi tiết
                  ElevatedButton.icon(
                    onPressed: _xemChiTiet,
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
