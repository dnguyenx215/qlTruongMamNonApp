import 'package:flutter/material.dart';

class NotificationsComponent extends StatelessWidget {
  final String activeFilter;
  final Function(String) onFilterChanged;

  const NotificationsComponent({
    Key? key,
    required this.activeFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Xác định các giá trị dựa trên chiều rộng hiện có
        double headerFontSize = constraints.maxWidth < 400 ? 16 : 18;
        double spacing = constraints.maxWidth < 400 ? 8 : 16;

        return Container(
          padding: EdgeInsets.all(spacing),
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
                'THÔNG BÁO',
                style: TextStyle(
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: spacing),

              // Sử dụng Wrap cho các nút filter để chúng tự động xuống hàng khi không đủ chỗ
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _buildFilterButton('all', 'Tất cả'),
                  _buildFilterButton('today', 'Hôm nay'),
                  _buildFilterButton('week', 'Tuần'),
                  // Có thể mở rộng thêm nếu cần
                  // _buildFilterButton('month', 'Tháng'),
                ],
              ),
              SizedBox(height: spacing),

              // Các item thông báo
              _buildNotificationItem(
                'Thứ 6',
                'GV Nguyễn Thị Hương đã cập nhật Sổ báo ăn lớp Mẫu giáo bé CLC',
              ),
              const Divider(),
              _buildNotificationItem(
                'Thứ 6',
                'GV Dương Thị Đèo đã cập nhật Danh sách học sinh nghỉ lớp Mẫu giáo lớn',
              ),
              const Divider(),
              _buildNotificationItem(
                'Thứ 6',
                'GV Nguyễn Hương Ly đã cập nhật Sổ báo ăn lớp Nhà trẻ 24 - 36 tháng CLC',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final bool isActive = activeFilter == filter;

    return ElevatedButton(
      onPressed: () => onFilterChanged(filter),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue[500] : Colors.grey[200],
        foregroundColor: isActive ? Colors.white : Colors.grey[600],
        elevation: 0,
      ),
      child: Text(label),
    );
  }

  Widget _buildNotificationItem(String day, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
