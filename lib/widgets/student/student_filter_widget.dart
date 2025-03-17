// lib/widgets/student/student_filter_widget.dart
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StudentFilterWidget extends StatelessWidget {
  final String searchKeyword;
  final Function(String) onSearchChanged;
  final GenderFilter selectedGender;
  final Function(GenderFilter) onGenderFilterChanged;
  final YearFilter selectedYear;
  final Function(YearFilter) onYearFilterChanged;
  final int? selectedClassId;
  final List<Map<String, dynamic>> classes;
  final Function(int?) onClassFilterChanged;

  const StudentFilterWidget({
    Key? key,
    required this.searchKeyword,
    required this.onSearchChanged,
    required this.selectedGender,
    required this.onGenderFilterChanged,
    required this.selectedYear,
    required this.onYearFilterChanged,
    required this.selectedClassId,
    required this.classes,
    required this.onClassFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 800;

        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Dropdown chọn lớp
            DropdownButton<int?>(
              hint: const Text('Chọn lớp'),
              value: selectedClassId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Tất cả'),
                ),
                ...classes.map((classItem) {
                  return DropdownMenuItem<int?>(
                    value: classItem['id'],
                    child: Text(classItem['name']),
                  );
                }),
              ],
              onChanged: onClassFilterChanged,
            ),

            // Dropdown giới tính
            DropdownButton<GenderFilter>(
              value: selectedGender,
              items:
                  GenderFilter.values.map((filter) {
                    return DropdownMenuItem<GenderFilter>(
                      value: filter,
                      child: Text(getGenderFilterText(filter)),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) onGenderFilterChanged(value);
              },
            ),

            // Dropdown năm học
            DropdownButton<YearFilter>(
              value: selectedYear,
              items:
                  YearFilter.values.map((filter) {
                    return DropdownMenuItem<YearFilter>(
                      value: filter,
                      child: Text(getYearFilterText(filter)),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) onYearFilterChanged(value);
              },
            ),

            // Ô tìm kiếm
            SizedBox(
              width: isSmallScreen ? 200 : 250,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm theo tên, mã HS...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  isDense: true,
                ),
                onChanged: onSearchChanged,
                controller: TextEditingController(text: searchKeyword)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: searchKeyword.length),
                  ),
              ),
            ),
          ],
        );
      },
    );
  }
}
