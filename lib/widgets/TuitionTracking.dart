import 'package:flutter/material.dart';

class TuitionTrackingComponent extends StatelessWidget {
  const TuitionTrackingComponent({Key? key}) : super(key: key);

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
            'THEO DÕI THU HP',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Responsive GridView
          LayoutBuilder(
            builder: (context, constraints) {
              double availableWidth = constraints.maxWidth;
              int crossAxisCount;
              if (availableWidth < 600) {
                crossAxisCount = 1;
              } else if (availableWidth < 900) {
                crossAxisCount = 2;
              } else if (availableWidth < 1200) {
                crossAxisCount = 3;
              } else {
                crossAxisCount = 4;
              }
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  TuitionCard(
                    className: 'NHÀ TRẺ 12 - 24 THÁNG',
                    stats: '13/16 HS',
                  ),
                  TuitionCard(
                    className: 'NHÀ TRẺ 12 - 24 THÁNG',
                    stats: '11/13 HS',
                  ),
                  TuitionCard(
                    className: 'NHÀ TRẺ 24 - 36 THÁNG',
                    stats: '12/14 HS',
                  ),
                  TuitionCard(
                    className: 'NHÀ TRẺ 24 - 36 THÁNG',
                    stats: '13/16 HS',
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

class TuitionCard extends StatelessWidget {
  final String className;
  final String stats;

  const TuitionCard({Key? key, required this.className, required this.stats})
    : super(key: key);

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(stats, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
