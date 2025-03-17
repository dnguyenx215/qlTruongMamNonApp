// lib/widgets/holidays/holiday_delete_modal.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/holiday.dart';
import '../../services/holiday_service.dart';

class HolidayDeleteModal extends StatefulWidget {
  final Holiday holiday;
  final Function() onDelete;

  const HolidayDeleteModal({
    super.key,
    required this.holiday,
    required this.onDelete,
  });

  @override
  _HolidayDeleteModalState createState() => _HolidayDeleteModalState();
}

class _HolidayDeleteModalState extends State<HolidayDeleteModal> {
  bool _isLoading = false;

  // Get formatted date for display
  String get _formattedDate {
    try {
      final date = DateTime.parse(widget.holiday.holidayDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return widget.holiday.holidayDate;
    }
  }

  // Get holiday type as human-readable string
  String get _holidayTypeLabel {
    switch (widget.holiday.holidayType) {
      case 'weekend':
        return 'Cuối tuần';
      case 'national':
        return 'Lễ quốc gia';
      case 'school':
        return 'Nghỉ trường';
      default:
        return 'Khác';
    }
  }

  // Delete holiday
  Future<void> _deleteHoliday() async {
    if (widget.holiday.id == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await HolidayService.deleteHoliday(widget.holiday.id!);

      // Call the onDelete callback to refresh parent
      widget.onDelete();

      // Close modal
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa ngày nghỉ thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're on a small screen
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Use bottom sheet for mobile
      return Scaffold(
        appBar: AppBar(
          title: const Text('Xác nhận xóa'),
          centerTitle: true,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bạn có chắc chắn muốn xóa ngày nghỉ sau không?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Holiday details as cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Ngày:',
                        value: _formattedDate,
                      ),
                      _buildDetailRow(
                        icon: Icons.event,
                        label: 'Tên sự kiện:',
                        value: widget.holiday.holidayName,
                      ),
                      _buildDetailRow(
                        icon: Icons.category,
                        label: 'Loại:',
                        value: _holidayTypeLabel,
                      ),

                      if (widget.holiday.description.isNotEmpty)
                        _buildDetailRow(
                          icon: Icons.description,
                          label: 'Mô tả:',
                          value: widget.holiday.description,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Hành động này không thể hoàn tác.',
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Spacer(),

              // Bottom action buttons
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _isLoading ? null : _deleteHoliday,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Xóa'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Regular dialog for tablet and desktop
      return AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa ngày nghỉ sau không?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Holiday details
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Ngày:',
              value: _formattedDate,
            ),
            _buildDetailRow(
              icon: Icons.event,
              label: 'Tên sự kiện:',
              value: widget.holiday.holidayName,
            ),
            _buildDetailRow(
              icon: Icons.category,
              label: 'Loại:',
              value: _holidayTypeLabel,
            ),

            if (widget.holiday.description.isNotEmpty)
              _buildDetailRow(
                icon: Icons.description,
                label: 'Mô tả:',
                value: widget.holiday.description,
              ),

            const SizedBox(height: 8),

            const Text(
              'Hành động này không thể hoàn tác.',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            ),
          ],
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
            onPressed: _isLoading ? null : _deleteHoliday,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Xóa'),
          ),
        ],
      );
    }
  }

  // Helper for building detail rows with icons
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
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
}
