// lib/widgets/classroom/classroom_delete_modal.dart
import 'package:QL_TruongMamNon/services/class_service.dart';
import 'package:flutter/material.dart';
import '../../models/classroom.dart';

class ClassroomDeleteModal extends StatefulWidget {
  final Classroom classroom;
  final VoidCallback onSuccess;

  const ClassroomDeleteModal({
    super.key,
    required this.classroom,
    required this.onSuccess,
  });

  @override
  State<ClassroomDeleteModal> createState() => _ClassroomDeleteModalState();
}

class _ClassroomDeleteModalState extends State<ClassroomDeleteModal> {
  bool _isDeleting = false;

  Future<void> _deleteClass() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // Gọi service để xóa lớp
      await ClassroomService.deleteClass(widget.classroom.id);

      // Nếu không có lỗi, đóng modal và gọi callback thành công
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa lớp thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Nếu có lỗi, hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset trạng thái loading nếu modal chưa đóng
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận xóa lớp'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn có chắc chắn muốn xóa lớp "${widget.classroom.name}" không?',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lưu ý: Hành động này không thể hoàn tác và sẽ xóa tất cả dữ liệu liên quan đến lớp này.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        // Nút hủy
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Hủy',
            style: TextStyle(color: _isDeleting ? Colors.grey : Colors.blue),
          ),
        ),
        // Nút xóa
        ElevatedButton(
          onPressed: _isDeleting ? null : _deleteClass,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.shade200,
          ),
          child:
              _isDeleting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text('Xóa lớp'),
        ),
      ],
    );
  }
}
