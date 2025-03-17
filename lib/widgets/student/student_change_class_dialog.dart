// lib/widgets/student/change_class_dialog.dart
import 'package:flutter/material.dart';
import '../../models/student.dart';

class ChangeClassDialog extends StatefulWidget {
  final List<Student> selectedStudents;
  final List<Map<String, dynamic>> classes;
  final Function(List<Student>, int) onChangeClass;

  const ChangeClassDialog({
    Key? key,
    required this.selectedStudents,
    required this.classes,
    required this.onChangeClass,
  }) : super(key: key);

  @override
  _ChangeClassDialogState createState() => _ChangeClassDialogState();
}

class _ChangeClassDialogState extends State<ChangeClassDialog> {
  int? _selectedClassId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chuyển lớp học sinh'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn đang chọn ${widget.selectedStudents.length} học sinh để chuyển lớp.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Danh sách học sinh:'),
          const SizedBox(height: 4),
          // Đổi ListView thành Container với SingleChildScrollView và Column
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.selectedStudents.length, (
                  index,
                ) {
                  final student = widget.selectedStudents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('${index + 1}. ${student.fullName}'),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Chọn lớp cần chuyển đến:'),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            isExpanded: true,
            hint: const Text('-- Chọn lớp --'),
            value: _selectedClassId,
            items:
                widget.classes.map((classItem) {
                  return DropdownMenuItem<int?>(
                    value: classItem['id'],
                    child: Text(classItem['name']),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedClassId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Vui lòng chọn lớp';
              }
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed:
              _selectedClassId == null
                  ? null
                  : () {
                    widget.onChangeClass(
                      widget.selectedStudents,
                      _selectedClassId!,
                    );
                    Navigator.of(context).pop();
                  },
          child: const Text('Chuyển lớp'),
        ),
      ],
    );
  }
}
