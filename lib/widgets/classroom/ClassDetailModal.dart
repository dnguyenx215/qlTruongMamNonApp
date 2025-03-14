import 'package:flutter/material.dart';

class ClassDetailModal extends StatelessWidget {
  final Map<String, dynamic> classData;

  const ClassDetailModal({super.key, required this.classData});

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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
