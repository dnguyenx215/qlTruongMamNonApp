// lib/widgets/classroom/classroom_detail_modal.dart
import 'package:flutter/material.dart';
import '../../models/classroom.dart';

class ClassroomDetailModal extends StatelessWidget {
  final Classroom classroom;

  const ClassroomDetailModal({super.key, required this.classroom});

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chi tiết lớp ${classroom.name}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Mã lớp:', classroom.code),
            _buildDetailRow('Tên lớp:', classroom.name),
            _buildDetailRow('Khối:', classroom.gradeBlockName),
            _buildDetailRow(
              'Giáo viên chủ nhiệm:',
              classroom.homeroomTeacherName,
            ),
            _buildDetailRow(
              'Sĩ số:',
              '${classroom.studentCount}/${classroom.capacity}',
            ),
            _buildDetailRow('Tình trạng:', classroom.status),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
