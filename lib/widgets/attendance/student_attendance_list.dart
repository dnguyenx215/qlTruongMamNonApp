// lib/widgets/attendance/student_attendance_list.dart
import 'package:flutter/material.dart';
import '../../models/student.dart';

class StudentAttendanceList extends StatelessWidget {
  final List<Student> students;
  final Function(Student, String) onStatusChanged;
  final Function(Student, String) onAbsenceReasonChanged;
  final bool isLocked;

  const StudentAttendanceList({
    Key? key,
    required this.students,
    required this.onStatusChanged,
    required this.onAbsenceReasonChanged,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách học sinh',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Số lượng: ${students.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            students.isEmpty
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Không có học sinh trong lớp này'),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return StudentAttendanceItem(
                      student: student,
                      onStatusChanged: onStatusChanged,
                      onAbsenceReasonChanged: onAbsenceReasonChanged,
                      isLocked: isLocked,
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class StudentAttendanceItem extends StatelessWidget {
  final Student student;
  final Function(Student, String) onStatusChanged;
  final Function(Student, String) onAbsenceReasonChanged;
  final bool isLocked;

  const StudentAttendanceItem({
    Key? key,
    required this.student,
    required this.onStatusChanged,
    required this.onAbsenceReasonChanged,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _reasonController = TextEditingController(
      text: student.absenceReason,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  student.fullName.isNotEmpty
                      ? student.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      student.studentCode ?? 'Chưa có mã học sinh',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusOption('Có mặt', 'present', Icons.check_circle),
              const SizedBox(width: 8),
              _buildStatusOption(
                'Vắng có phép',
                'absent_excused',
                Icons.assignment_turned_in,
              ),
              const SizedBox(width: 8),
              _buildStatusOption(
                'Vắng không phép',
                'absent_unexcused',
                Icons.assignment_late,
              ),
            ],
          ),
          if (student.attendanceStatus != 'present')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý do vắng mặt',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                enabled: !isLocked,
                onChanged: (value) => onAbsenceReasonChanged(student, value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String label, String value, IconData icon) {
    final isSelected = student.attendanceStatus == value;

    return Expanded(
      child: InkWell(
        onTap: isLocked ? null : () => onStatusChanged(student, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
