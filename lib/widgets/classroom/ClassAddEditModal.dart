// lib/widgets/classroom/classroom_add_edit_modal.dart
import 'package:example_app/services/class_service.dart';
import 'package:flutter/material.dart';
import '../../models/classroom.dart';
import '../../models/grade_block.dart';

class ClassroomAddEditModal extends StatefulWidget {
  final Classroom? existingClass;
  final VoidCallback onSuccess;

  const ClassroomAddEditModal({
    super.key,
    this.existingClass,
    required this.onSuccess,
  });

  @override
  _ClassroomAddEditModalState createState() => _ClassroomAddEditModalState();
}

class _ClassroomAddEditModalState extends State<ClassroomAddEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  int? _selectedTeacherId;
  int? _selectedGradeBlockId;

  List<Map<String, dynamic>> _teachersList = [];
  List<GradeBlock> _gradeBlocksList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo các controller và giá trị từ lớp cần sửa (nếu có)
    _nameController = TextEditingController(
      text: widget.existingClass?.name ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.existingClass?.capacity.toString() ?? '',
    );
    _selectedTeacherId = widget.existingClass?.homeroomTeacherId;
    _selectedGradeBlockId = widget.existingClass?.gradeBlockId;

    // Tải danh sách giáo viên và khối học
    _loadTeachersAndGradeBlocks();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachersAndGradeBlocks() async {
    setState(() => _isLoading = true);
    try {
      // Tải song song cả hai danh sách
      final Future<List<Map<String, dynamic>>> teachersFuture =
          ClassroomService.fetchTeachers();
      final Future<List<GradeBlock>> gradeBlocksFuture =
          ClassroomService.fetchGradeBlocks();

      final teachers = await teachersFuture;
      final gradeBlocks = await gradeBlocksFuture;

      setState(() {
        _teachersList = teachers;
        _gradeBlocksList = gradeBlocks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải dữ liệu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      // Tạo đối tượng Classroom từ dữ liệu form
      final classroom = Classroom(
        id: widget.existingClass?.id ?? 0,
        code: widget.existingClass?.code ?? '',
        name: _nameController.text,
        capacity: int.parse(_capacityController.text),
        studentCount: widget.existingClass?.studentCount ?? 0,
        status: widget.existingClass?.status ?? 'INCOMPLETE',
        homeroomTeacherId: _selectedTeacherId,
        gradeBlockId: _selectedGradeBlockId,
      );

      if (widget.existingClass == null) {
        // Thêm mới lớp học
        await ClassroomService.addClass(classroom);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm lớp học thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Cập nhật lớp học
        await ClassroomService.updateClass(classroom);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật lớp học thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Đóng modal và cập nhật lại danh sách
      Navigator.of(context).pop();
      widget.onSuccess();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingClass == null
            ? 'Thêm lớp mới'
            : 'Sửa lớp ${widget.existingClass!.name}',
      ),
      content:
          _isLoading
              ? const Center(
                heightFactor: 2,
                child: CircularProgressIndicator(),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tên lớp
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

                      // Sĩ số tối đa
                      TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Sĩ số tối đa',
                          hintText: 'Ví dụ: 25',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập sĩ số tối đa';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Sĩ số phải là số';
                          }
                          if (int.parse(value) <= 0) {
                            return 'Sĩ số phải lớn hơn 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown chọn khối
                      DropdownButtonFormField<int?>(
                        decoration: const InputDecoration(labelText: 'Khối'),
                        hint: const Text('Chọn khối'),
                        value: _selectedGradeBlockId,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('-- Chọn khối --'),
                          ),
                          ..._gradeBlocksList.map((block) {
                            return DropdownMenuItem<int?>(
                              value: block.id,
                              child: Text('${block.name} (${block.code})'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGradeBlockId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown chọn giáo viên chủ nhiệm
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
                              child: Text(teacher['name']),
                            );
                          }).toList(),
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
          child: Text(widget.existingClass == null ? 'Thêm mới' : 'Cập nhật'),
        ),
      ],
    );
  }
}
