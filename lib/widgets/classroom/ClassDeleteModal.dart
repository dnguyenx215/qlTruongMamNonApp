import 'package:flutter/material.dart';
import '../../services/class_service.dart';

class ClassDeleteModal extends StatelessWidget {
  final Map<String, dynamic> classData;
  final Function() onRefresh;

  const ClassDeleteModal({
    super.key,
    required this.classData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: Text(
        'Bạn có chắc chắn muốn xóa lớp "${classData['tenLop']}" không? '
        'Hành động này không thể hoàn tác và sẽ xóa tất cả dữ liệu liên quan đến lớp này.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            try {
              await ClassService.deleteClass(classData['id']);

              // Đóng modal và refresh danh sách
              Navigator.of(context).pop();
              onRefresh();

              // Hiển thị thông báo thành công
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xóa lớp thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              // Hiển thị thông báo lỗi
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}
