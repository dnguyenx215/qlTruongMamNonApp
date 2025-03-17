// lib/widgets/attendance/class_selector.dart
import 'package:flutter/material.dart';

class ClassSelector extends StatelessWidget {
  final List<Map<String, dynamic>> classes;
  final int? selectedClassId;
  final Function(int?) onClassChanged;

  const ClassSelector({
    Key? key,
    required this.classes,
    required this.selectedClassId,
    required this.onClassChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn lớp',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
              value: selectedClassId,
              items:
                  classes.map((classItem) {
                    return DropdownMenuItem<int?>(
                      value: classItem['id'],
                      child: Text(classItem['name']),
                    );
                  }).toList(),
              onChanged: onClassChanged,
              hint: const Text('-- Chọn lớp --'),
            ),
          ],
        ),
      ),
    );
  }
}
