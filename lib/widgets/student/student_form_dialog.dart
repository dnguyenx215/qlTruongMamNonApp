// lib/widgets/student/student_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../../utils/constants.dart';

class StudentFormDialog extends StatefulWidget {
  final Student? student;
  final List<Map<String, dynamic>> classes;
  final Function(Student) onSave;

  const StudentFormDialog({
    Key? key,
    this.student,
    required this.classes,
    required this.onSave,
  }) : super(key: key);

  @override
  _StudentFormDialogState createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _parentEmailController;
  String? _selectedGender;
  int? _selectedClassId;
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với giá trị từ student nếu đang sửa
    _firstNameController = TextEditingController(
      text: widget.student?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.student?.lastName ?? '',
    );

    // Xử lý ngày sinh
    _birthday =
        widget.student?.birthday != null && widget.student!.birthday!.isNotEmpty
            ? DateTime.parse(widget.student!.birthday!)
            : null;
    _birthdayController = TextEditingController(
      text:
          _birthday != null ? DateFormat('dd/MM/yyyy').format(_birthday!) : '',
    );

    _addressController = TextEditingController(
      text: widget.student?.address ?? '',
    );
    _parentNameController = TextEditingController(
      text: widget.student?.parentName ?? '',
    );
    _parentPhoneController = TextEditingController(
      text: widget.student?.parentPhone ?? '',
    );
    _parentEmailController = TextEditingController(
      text: widget.student?.parentEmail ?? '',
    );

    _selectedGender = widget.student?.gender;
    _selectedClassId = widget.student?.classId;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstAllowedDate = DateTime(now.year - 10, 1, 1);
    final DateTime lastAllowedDate = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 5, now.month, now.day),
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
    );

    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
        _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Tạo student mới từ form data
      final student = Student(
        id: widget.student?.id,
        studentCode: widget.student?.studentCode,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthday: _birthday?.toIso8601String(),
        gender: _selectedGender,
        address: _addressController.text.trim(),
        parentName: _parentNameController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        classId: _selectedClassId,
      );

      widget.onSave(student);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.student != null;
    final String title =
        isEditing ? 'Sửa thông tin học sinh' : 'Thêm học sinh mới';

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 500, // Giới hạn chiều rộng dialog
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Họ và tên
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ',
                          hintText: 'Nguyễn Văn',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên',
                          hintText: 'Minh',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ngày sinh và giới tính
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _birthdayController,
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh',
                          hintText: 'DD/MM/YYYY',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Giới tính',
                        ),
                        value: _selectedGender,
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Nam')),
                          DropdownMenuItem(value: 'female', child: Text('Nữ')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Địa chỉ
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    hintText: 'Nhập địa chỉ',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Thông tin phụ huynh
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên phụ huynh',
                    hintText: 'Nhập tên phụ huynh',
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _parentPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại phụ huynh',
                    hintText: 'Nhập số điện thoại',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _parentEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email phụ huynh',
                    hintText: 'Nhập email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Lớp học
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(labelText: 'Chọn lớp'),
                  hint: const Text('-- Chọn lớp --'),
                  value: _selectedClassId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Chưa phân lớp'),
                    ),
                    ...widget.classes.map((classItem) {
                      return DropdownMenuItem<int?>(
                        value: classItem['id'],
                        child: Text(classItem['name']),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(isEditing ? 'Cập nhật' : 'Thêm mới'),
        ),
      ],
    );
  }
}
