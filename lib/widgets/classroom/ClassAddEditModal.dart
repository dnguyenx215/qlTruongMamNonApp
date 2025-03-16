import 'package:flutter/material.dart';
import '../../services/class_service.dart';

class ClassAddEditModal extends StatefulWidget {
  final Map<String, dynamic>? existingClass;
  final Function() onRefresh;

  const ClassAddEditModal({
    super.key,
    this.existingClass,
    required this.onRefresh,
  });

  @override
  _ClassAddEditModalState createState() => _ClassAddEditModalState();
}

class _ClassAddEditModalState extends State<ClassAddEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  int? _selectedTeacherId;
  List<Map<String, dynamic>> _teachersList = [];
  bool _isLoading = false;
  String? _selectedGradeBlockId;
  List<Map<String, dynamic>> _gradeBlocksList = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingClass?['tenLop'] ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.existingClass?['capacity']?.toString() ?? '',
    );
    _selectedTeacherId = widget.existingClass?['gvcnId'];
    _selectedGradeBlockId = widget.existingClass?['grade_block_id']?.toString();

    // Load teachers and grade blocks
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Parallel loading of teachers and grade blocks
      final teachersLoader = ClassService.fetchTeachers();
      final gradeBlocksLoader = ClassService.fetchGradeBlocks();

      final teachers = await teachersLoader;
      final gradeBlocks = await gradeBlocksLoader;

      setState(() {
        // Ensure unique teachers with no duplicates
        _teachersList = _removeDuplicateTeachers(teachers);
        _gradeBlocksList = _removeDuplicateBlocks(gradeBlocks);

        // Ensure selected teacher exists in list
        if (_selectedTeacherId != null &&
            !_teachersList.any(
              (teacher) => teacher['id'] == _selectedTeacherId,
            )) {
          _teachersList.add({
            'id': _selectedTeacherId,
            'name': 'GVCN (${_selectedTeacherId})',
            'email': '',
          });
        }

        // Ensure selected grade block exists in list
        if (_selectedGradeBlockId != null &&
            !_gradeBlocksList.any(
              (b) => b['id'].toString() == _selectedGradeBlockId,
            )) {
          _gradeBlocksList.add({
            'id': int.parse(_selectedGradeBlockId!),
            'name': 'Khối (${_selectedGradeBlockId})',
            'code': 'CUSTOM',
            'description': '',
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Remove duplicate teachers based on ID
  List<Map<String, dynamic>> _removeDuplicateTeachers(
    List<Map<String, dynamic>> teachers,
  ) {
    final uniqueTeachers = <int, Map<String, dynamic>>{};
    for (var teacher in teachers) {
      if (!uniqueTeachers.containsKey(teacher['id'])) {
        uniqueTeachers[teacher['id']] = teacher;
      }
    }
    return uniqueTeachers.values.toList();
  }

  // Remove duplicate grade blocks based on ID
  List<Map<String, dynamic>> _removeDuplicateBlocks(
    List<Map<String, dynamic>> blocks,
  ) {
    final uniqueBlocks = <int, Map<String, dynamic>>{};
    for (var block in blocks) {
      if (!uniqueBlocks.containsKey(block['id'])) {
        uniqueBlocks[block['id']] = block;
      }
    }
    return uniqueBlocks.values.toList();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final classData = {
        'name': _nameController.text,
        'capacity': int.parse(_capacityController.text),
        'homeroom_teacher_id': _selectedTeacherId,
        'grade_block_id':
            _selectedGradeBlockId != null
                ? int.parse(_selectedGradeBlockId!)
                : null,
      };

      if (widget.existingClass == null) {
        await ClassService.addClass(classData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm lớp thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await ClassService.updateClass(widget.existingClass!['id'], classData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật lớp thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onRefresh();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingClass == null
            ? 'Thêm lớp mới'
            : 'Sửa lớp ${widget.existingClass!['tenLop']}',
      ),
      content:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
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
                        controller: _capacityController,
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
                      DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(
                          labelText: 'Giáo viên chủ nhiệm',
                        ),
                        hint: const Text('Chọn giáo viên chủ nhiệm'),
                        value: _selectedTeacherId,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Không có GVCN'),
                          ),
                          ..._teachersList.map((teacher) {
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
                            _selectedTeacherId = value;
                          });
                        },
                        validator: (value) {
                          // Optional: Add validation if needed
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(
                          labelText: 'Khối học',
                        ),
                        hint: const Text('Chọn khối học'),
                        value: _selectedGradeBlockId?.toString(),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Chưa chọn khối'),
                          ),
                          ..._gradeBlocksList.map((block) {
                            return DropdownMenuItem<String?>(
                              value: block['id'].toString(),
                              child: Text(
                                '${block['name']} (${block['code']})',
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGradeBlockId = value;
                          });
                        },
                        validator: (value) {
                          // Optional: Add validation if needed
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: Text(widget.existingClass == null ? 'Lưu' : 'Cập nhật'),
        ),
      ],
    );
  }
}
