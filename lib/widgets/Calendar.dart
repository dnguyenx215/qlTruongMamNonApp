import 'package:flutter/material.dart';

class CalendarComponent extends StatelessWidget {
  const CalendarComponent({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng LayoutBuilder để lấy thông tin kích thước
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double headerFontSize = availableWidth < 300 ? 16 : 18;
        double labelFontSize = availableWidth < 300 ? 12 : 14;
        double verticalSpacing = availableWidth < 300 ? 8 : 16;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tháng 6, 2024',
                style: TextStyle(
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: verticalSpacing),
              // Week days and dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Days of week
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDayLabel('CN', labelFontSize),
                      _buildDayLabel('T2', labelFontSize),
                      _buildDayLabel('T3', labelFontSize),
                      _buildDayLabel('T4', labelFontSize),
                      _buildDayLabel('T5', labelFontSize),
                      _buildDayLabel('T6', labelFontSize),
                      _buildDayLabel('T7', labelFontSize),
                    ],
                  ),
                  // Dates
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildDateLabel('28', labelFontSize),
                      _buildDateLabel('29', labelFontSize),
                      _buildDateLabel('30', labelFontSize),
                      _buildDateLabel('31', labelFontSize),
                      _buildDateLabel('1', labelFontSize),
                      _buildDateLabel('2', labelFontSize),
                      _buildDateLabel('3', labelFontSize),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayLabel(String day, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        day,
        style: TextStyle(color: Colors.grey[600], fontSize: fontSize),
      ),
    );
  }

  Widget _buildDateLabel(String date, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        date,
        style: TextStyle(color: Colors.grey[600], fontSize: fontSize),
      ),
    );
  }
}
