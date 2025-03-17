// lib/widgets/attendance/attendance_date_picker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final bool isHoliday;
  final bool isLocked;

  const AttendanceDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
    this.isHoliday = false,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    final newDate = selectedDate.subtract(
                      const Duration(days: 1),
                    );
                    onDateChanged(newDate);
                  },
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Column(
                    children: [
                      Text(
                        DateFormat(
                          'EEEE',
                          'vi_VN',
                        ).format(selectedDate).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isHoliday)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Ngày nghỉ',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      if (isLocked)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Đã khóa',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    final newDate = selectedDate.add(const Duration(days: 1));
                    onDateChanged(newDate);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}
