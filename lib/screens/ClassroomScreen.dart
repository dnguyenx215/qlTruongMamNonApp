import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/class_service.dart';
import '../widgets/ManagementLayout.dart';

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

  // Danh sách lớp lấy từ API, mỗi item bổ sung 'checked' để checkbox
  List<Map<String, dynamic>> _classList = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchClasses();
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
      // Nếu chưa có trong SharedPreferences thì gán tạm
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
      // ClassService.fetchClasses() trả về List<Map<String, dynamic>>
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

  // ============= MODAL THÊM LỚP =============
  Future<void> _showAddClassModal(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final capacityController = TextEditingController();

    // Mặc định là TextFormField cho GVCN
    bool useDropdown = false;
    final teacherIdController = TextEditingController();
    int? selectedTeacherId;

    List<Map<String, dynamic>> teachersList = [];
    bool loadingTeachers = true;

    try {
      teachersList = await ClassService.fetchTeachers();
      useDropdown = teachersList.isNotEmpty; // Chỉ dùng dropdown nếu có dữ liệu
      loadingTeachers = false;
    } catch (e) {
      loadingTeachers = false;
      useDropdown = false; // Dùng TextField khi có lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách giáo viên: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm lớp mới'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên lớp',
                          hintText: 'Ví dụ: Nhà trẻ 24-36 tháng CLC',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên lớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Sĩ số tối đa',
                          hintText: 'Ví dụ: 25',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập sĩ số';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Sĩ số phải là số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      loadingTeachers
                          ? const Center(child: CircularProgressIndicator())
                          : useDropdown
                          ? DropdownButtonFormField<int?>(
                            decoration: const InputDecoration(
                              labelText: 'Giáo viên chủ nhiệm',
                            ),
                            hint: const Text('Chọn giáo viên chủ nhiệm'),
                            value: selectedTeacherId,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Không có GVCN'),
                              ),
                              ...teachersList.map((teacher) {
                                return DropdownMenuItem<int?>(
                                  value: teacher['id'],
                                  child: Text(
                                    '${teacher['name']} (ID: ${teacher['id']})',
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedTeacherId = value;
                              });
                            },
                          )
                          : TextFormField(
                            controller: teacherIdController,
                            decoration: const InputDecoration(
                              labelText: 'ID Giáo viên chủ nhiệm',
                              hintText: 'Để trống nếu không có GVCN',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Xử lý ID giáo viên tùy theo loại input
                      int? teacherId;
                      if (useDropdown) {
                        teacherId = selectedTeacherId;
                      } else {
                        teacherId =
                            teacherIdController.text.isNotEmpty
                                ? int.tryParse(teacherIdController.text)
                                : null;
                      }

                      // Process data and add class
                      final newClass = {
                        "name": nameController.text,
                        "capacity": int.parse(capacityController.text),
                        "homeroom_teacher_id": teacherId,
                      };

                      // Call API through service
                      ClassService.addClass(newClass)
                          .then((_) {
                            Navigator.of(context).pop();
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thêm lớp thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Refresh class list
                            _fetchClasses();
                          })
                          .catchError((error) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: ${error.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============= MODAL SỬA LỚP =============
  Future<void> _showEditClassModal(
    BuildContext context,
    Map<String, dynamic> classData,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: classData['tenLop']);
    final capacityController = TextEditingController(
      text: classData['capacity'].toString(),
    );

    // Mặc định là TextFormField cho GVCN
    bool useDropdown = false;
    final teacherIdController = TextEditingController(
      text: classData['gvcnId']?.toString() ?? '',
    );
    int? selectedTeacherId = classData['gvcnId'];

    List<Map<String, dynamic>> teachersList = [];
    bool loadingTeachers = true;

    try {
      teachersList = await ClassService.fetchTeachers();

      // Kiểm tra nếu _selectedTeacherId có tồn tại trong danh sách không
      bool teacherExists =
          selectedTeacherId == null
              ? true
              : teachersList.any(
                (teacher) => teacher['id'] == selectedTeacherId,
              );

      // Chỉ dùng dropdown nếu có dữ liệu và ID giáo viên hợp lệ
      useDropdown = teachersList.isNotEmpty && teacherExists;

      if (!teacherExists && selectedTeacherId != null) {
        // Thêm giáo viên hiện tại vào danh sách nếu không tìm thấy trong API
        teachersList.add({
          "id": selectedTeacherId,
          "name": classData['gvcn'].toString().replaceAll(
            " (ID: $selectedTeacherId)",
            "",
          ),
        });
      }

      loadingTeachers = false;
    } catch (e) {
      loadingTeachers = false;
      useDropdown = false; // Dùng TextField khi có lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách giáo viên: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Sửa lớp ${classData['tenLop']}'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Tên lớp'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên lớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Sĩ số tối đa',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập sĩ số';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Sĩ số phải là số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      loadingTeachers
                          ? const Center(child: CircularProgressIndicator())
                          : useDropdown
                          ? DropdownButtonFormField<int?>(
                            decoration: const InputDecoration(
                              labelText: 'Giáo viên chủ nhiệm',
                            ),
                            hint: const Text('Chọn giáo viên chủ nhiệm'),
                            value: selectedTeacherId,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Không có GVCN'),
                              ),
                              ...teachersList.map((teacher) {
                                return DropdownMenuItem<int?>(
                                  value: teacher['id'],
                                  child: Text(
                                    '${teacher['name']} (ID: ${teacher['id']})',
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedTeacherId = value;
                              });
                            },
                          )
                          : TextFormField(
                            controller: teacherIdController,
                            decoration: const InputDecoration(
                              labelText: 'ID Giáo viên chủ nhiệm',
                              hintText: 'Để trống nếu không có GVCN',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Xử lý ID giáo viên tùy theo loại input
                      int? teacherId;
                      if (useDropdown) {
                        teacherId = selectedTeacherId;
                      } else {
                        teacherId =
                            teacherIdController.text.isNotEmpty
                                ? int.tryParse(teacherIdController.text)
                                : null;
                      }

                      // Process data and update class
                      final updatedClass = {
                        "name": nameController.text,
                        "capacity": int.parse(capacityController.text),
                        "homeroom_teacher_id": teacherId,
                      };

                      // Call API through service
                      ClassService.updateClass(classData['id'], updatedClass)
                          .then((_) {
                            Navigator.of(context).pop();
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật lớp thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Refresh class list
                            _fetchClasses();
                          })
                          .catchError((error) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: ${error.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============= MODAL XÓA LỚP =============
  Future<void> _showDeleteConfirmationModal(
    BuildContext context,
    Map<String, dynamic> classData,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa lớp "${classData['tenLop']}" không? '
            'Hành động này không thể hoàn tác và sẽ xóa tất cả dữ liệu liên quan đến lớp này.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Call API through service
                ClassService.deleteClass(classData['id'])
                    .then((_) {
                      Navigator.of(context).pop();
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Xóa lớp thành công'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Refresh class list
                      _fetchClasses();
                    })
                    .catchError((error) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${error.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  // ============= MODAL XEM CHI TIẾT LỚP =============
  Future<void> _showClassDetailModal(
    BuildContext context,
    Map<String, dynamic> classData,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết lớp ${classData['tenLop']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Mã lớp:', classData['maLop']),
                _buildDetailRow('Tên lớp:', classData['tenLop']),
                _buildDetailRow('Khối:', classData['heLop']),
                _buildDetailRow('Giáo viên chủ nhiệm:', classData['gvcn']),
                _buildDetailRow('Sĩ số:', classData['siSo']),
                _buildDetailRow('Tình trạng:', classData['tinhTrang']),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  // Widget hiển thị một dòng trong chi tiết lớp
  Widget _buildDetailRow(String label, String value) {
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

  // Ví dụ hàm xử lý khi bấm các nút (đã cập nhật để gọi các modal)
  void _themMoi() {
    _showAddClassModal(context);
  }

  void _sua() {
    // Check if any class is selected
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

    _showEditClassModal(context, selectedClass);
  }

  void _xoa() {
    // Check if any class is selected
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

    _showDeleteConfirmationModal(context, selectedClass);
  }

  void _xemChiTiet() {
    // Check if any class is selected
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

    _showClassDetailModal(context, selectedClass);
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
                      // Gọi API hoặc lọc lại dữ liệu nếu cần
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
