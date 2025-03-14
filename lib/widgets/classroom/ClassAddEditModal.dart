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
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    try {
      final teachers = await ClassService.fetchTeachers();
      setState(() {
        _teachersList = teachers;
        // Ensure selected teacher is in the list if it exists
        if (_selectedTeacherId != null &&
            !_teachersList.any((t) => t['id'] == _selectedTeacherId)) {
          _teachersList.add({
            'id': _selectedTeacherId,
            'name': 'GVCN (${_selectedTeacherId})',
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

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final classData = {
        'name': _nameController.text,
        'capacity': int.parse(_capacityController.text),
        'homeroom_teacher_id': _selectedTeacherId,
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
