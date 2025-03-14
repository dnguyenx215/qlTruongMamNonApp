import 'package:flutter/material.dart';

class FoodTrackingComponent extends StatelessWidget {
  const FoodTrackingComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            'THEO DÕI BÁO ĂN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Responsive GridView dùng LayoutBuilder
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              double width = constraints.maxWidth;
              if (width < 600) {
                crossAxisCount = 1;
              } else if (width < 1000) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 3;
              }
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ClassFoodCard(
                    className: 'NHÀ TRẺ 24 - 36 THÁNG CLC',
                    teacherName: 'Phạm Minh Phương',
                    date: '15/06/2024',
                  ),
                  ClassFoodCard(
                    className: 'MẪU GIÁO BÉ CLC',
                    teacherName: 'Nguyễn Thị Cẩm',
                    date: '15/06/2024',
                  ),
                  ClassFoodCard(
                    className: 'MẪU GIÁO BÉ CLC',
                    teacherName: 'Nguyễn Thị Hương',
                    date: '15/06/2024',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ClassFoodCard extends StatelessWidget {
  final String className;
  final String teacherName;
  final String date;

  const ClassFoodCard({
    Key? key,
    required this.className,
    required this.teacherName,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('GVCN: $teacherName', style: TextStyle(color: Colors.grey[600])),
          Text('Ngày: $date', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cháo dinh dưỡng',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text('Cơm', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
