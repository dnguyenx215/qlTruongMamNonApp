import 'package:flutter/material.dart';

class StudentMonitoringComponent extends StatelessWidget {
  const StudentMonitoringComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Điều chỉnh kích thước chữ và khoảng cách dựa theo chiều rộng
        double headerFontSize = constraints.maxWidth < 400 ? 16 : 18;
        double contentFontSize = constraints.maxWidth < 400 ? 14 : 16;
        double spacing = constraints.maxWidth < 400 ? 8 : 16;
        bool isSmallWidth = constraints.maxWidth < 500;

        // Nếu màn hình nhỏ, hiển thị stats và button theo dạng cột
        Widget genderAndFilter =
            isSmallWidth
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NAM (61%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: contentFontSize,
                          ),
                        ),
                        Text(
                          'NỮ (39%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: contentFontSize,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text('Toàn trường'),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NAM (61%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: contentFontSize,
                          ),
                        ),
                        Text(
                          'NỮ (39%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: contentFontSize,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text('Toàn trường'),
                    ),
                  ],
                );

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
                'THEO DÕI HỌC SINH NGÀY 15/6/2024',
                style: TextStyle(
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: spacing),
              genderAndFilter,
              SizedBox(height: spacing),
              // Bảng điểm danh học sinh
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing / 2),
                        child: Text(
                          'Có mặt',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: contentFontSize,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing / 2),
                        child: Text(
                          'Vắng mặt có phép',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: contentFontSize,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing / 2),
                        child: Text(
                          'Vắng mặt không phép',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: contentFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing / 2),
                        child: Text(
                          '158 HS',
                          style: TextStyle(fontSize: contentFontSize),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing / 2),
                        child: Text(
                          '8 HS',
                          style: TextStyle(fontSize: contentFontSize),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing / 2),
                        child: Text(
                          '5 HS',
                          style: TextStyle(fontSize: contentFontSize),
                        ),
                      ),
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
}
