// lib/widgets/student/student_table.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';

class StudentTable extends StatelessWidget {
  final List<Student> students;
  final Function(Student, bool) onStudentChecked;
  final VoidCallback? onRefresh;

  const StudentTable({
    Key? key,
    required this.students,
    required this.onStudentChecked,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          if (onRefresh != null) onRefresh!();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_off, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không tìm thấy học sinh nào',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kéo xuống để làm mới',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) onRefresh!();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('')), // Cột checkbox
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('TÊN HỌC SINH')),
                    DataColumn(label: Text('MÃ HS')),
                    DataColumn(label: Text('GIỚI TÍNH')),
                    DataColumn(label: Text('NGÀY SINH')),
                    DataColumn(label: Text('LỚP')),
                    DataColumn(label: Text('ĐỊA CHỈ')),
                  ],
                  rows:
                      students.asMap().entries.map((entry) {
                        final index = entry.key;
                        final student = entry.value;

                        // Format ngày sinh nếu có
                        String formattedBirthday = student.birthday ?? '';
                        try {
                          if (student.birthday != null &&
                              student.birthday!.isNotEmpty) {
                            final date = DateTime.parse(student.birthday!);
                            formattedBirthday = DateFormat(
                              'dd/MM/yyyy',
                            ).format(date);
                          }
                        } catch (e) {
                          // Giữ nguyên giá trị nếu lỗi format
                        }

                        return DataRow(
                          cells: [
                            // Checkbox
                            DataCell(
                              Checkbox(
                                value: student.checked,
                                onChanged: (val) {
                                  onStudentChecked(student, val ?? false);
                                },
                              ),
                            ),
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(student.fullName)),
                            DataCell(Text(student.studentCode ?? '')),
                            DataCell(Text(student.genderText)),
                            DataCell(Text(formattedBirthday)),
                            DataCell(Text(student.classId?.toString() ?? '')),
                            DataCell(Text(student.address ?? '')),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
