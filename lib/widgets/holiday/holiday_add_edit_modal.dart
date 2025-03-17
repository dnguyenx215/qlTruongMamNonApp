// lib/widgets/holidays/holiday_add_edit_modal.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/holiday.dart';
import '../../services/holiday_service.dart';

class HolidayAddEditModal extends StatefulWidget {
  final Holiday? existingHoliday;
  final Function() onSave;
  final int selectedYear;

  const HolidayAddEditModal({
    super.key,
    this.existingHoliday,
    required this.onSave,
    required this.selectedYear,
  });

  @override
  _HolidayAddEditModalState createState() => _HolidayAddEditModalState();
}

class _HolidayAddEditModalState extends State<HolidayAddEditModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  String _selectedType = 'school'; // Default type

  // Available holiday types
  final Map<String, String> _holidayTypeLabels = {
    'weekend': 'Cuối tuần',
    'national': 'Lễ quốc gia',
    'school': 'Nghỉ trường',
  };

  @override
  void initState() {
    super.initState();

    if (widget.existingHoliday == null) {
      // Set initial date to January 1st of the selected year
      _dateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime(widget.selectedYear, 1, 1));
    }
    // Initialize controllers from existing holiday if any
    if (widget.existingHoliday != null) {
      final holiday = widget.existingHoliday!;

      _nameController = TextEditingController(text: holiday.holidayName);
      _descriptionController = TextEditingController(text: holiday.description);
      _selectedType = holiday.holidayType;

      // Format date for display
      final holidayDate = DateTime.parse(holiday.holidayDate);
      final formatter = DateFormat('dd/MM/yyyy');
      _dateController = TextEditingController(
        text: formatter.format(holidayDate),
      );
    } else {
      _nameController = TextEditingController();
      _dateController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Show date picker
  Future<void> _selectDate() async {
    DateTime initialDate;
    try {
      // Parse the current date from controller
      final formatter = DateFormat('dd/MM/yyyy');
      initialDate = formatter.parse(_dateController.text);
    } catch (e) {
      // Default to today if parsing fails
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final formatter = DateFormat('dd/MM/yyyy');
      setState(() {
        _dateController.text = formatter.format(picked);
      });
    }
  }

  // Save holiday
  Future<void> _saveHoliday() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Parse date from display format to API format
      final displayFormatter = DateFormat('dd/MM/yyyy');
      final apiFormatter = DateFormat('yyyy-MM-dd');

      final displayDate = displayFormatter.parse(
        _dateController.text.toString(),
      );
      final apiDate = apiFormatter.format(displayDate);

      final holidayData = {
        'holiday_date': apiDate,
        'holiday_name': _nameController.text,
        'holiday_type': _selectedType,
        'description': _descriptionController.text,
      };

      if (widget.existingHoliday?.id != null) {
        // Update existing holiday
        await HolidayService.updateHoliday(
          widget.existingHoliday!.id!,
          holidayData,
        );
      } else {
        // Create new holiday
        await HolidayService.addHoliday(holidayData);
      }

      // Call the onSave callback to refresh the parent view
      widget.onSave();

      // Close the modal
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingHoliday?.id != null
                  ? 'Cập nhật ngày nghỉ thành công'
                  : 'Thêm ngày nghỉ thành công',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we're on a small screen
        final isMobile = MediaQuery.of(context).size.width < 600;

        if (isMobile) {
          // Full screen modal for mobile
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.existingHoliday?.id != null
                    ? 'Sửa ngày nghỉ'
                    : 'Thêm ngày nghỉ mới',
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                _isLoading
                    ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _saveHoliday,
                    ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildFormFields(),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Dialog for tablets and desktop
          return AlertDialog(
            title: Text(
              widget.existingHoliday?.id != null
                  ? 'Sửa ngày nghỉ'
                  : 'Thêm ngày nghỉ mới',
            ),
            content: SizedBox(
              width: 500, // Set maximum width for desktop dialog
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildFormFields(),
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
                onPressed: _isLoading ? null : _saveHoliday,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          widget.existingHoliday?.id != null
                              ? 'Cập nhật'
                              : 'Lưu',
                        ),
              ),
            ],
          );
        }
      },
    );
  }

  // Extract form fields to reuse in both layouts
  List<Widget> _buildFormFields() {
    return [
      // Date field
      TextFormField(
        controller: _dateController,
        decoration: InputDecoration(
          labelText: 'Ngày',
          hintText: 'DD/MM/YYYY',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        readOnly: false, // Prevent direct editing
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng chọn ngày';
          }

          try {
            DateFormat('dd/MM/yyyy').parse(value);
            return null;
          } catch (e) {
            return 'Định dạng ngày không hợp lệ';
          }
        },
      ),

      const SizedBox(height: 16),

      // Name field
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Tên sự kiện',
          hintText: 'Ví dụ: Tết Nguyên đán, Nghỉ lễ 30/4...',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập tên sự kiện';
          }
          return null;
        },
      ),

      const SizedBox(height: 16),

      // Holiday type dropdown
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Loại ngày nghỉ',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        value: _selectedType,
        isExpanded: true,
        items:
            _holidayTypeLabels.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedType = value);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng chọn loại ngày nghỉ';
          }
          return null;
        },
      ),

      const SizedBox(height: 16),

      // Description field
      TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          labelText: 'Mô tả (tùy chọn)',
          hintText: 'Thêm thông tin chi tiết về ngày nghỉ',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          alignLabelWithHint: true,
        ),
        maxLines: 3,
      ),
    ];
  }
}
