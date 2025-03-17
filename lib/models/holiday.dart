// lib/models/holiday.dart
class Holiday {
  final int? id;
  final String holidayDate;
  final String holidayName;
  final String holidayType;
  final String description;
  bool checked; // Dùng để chọn trong danh sách

  Holiday({
    this.id,
    required this.holidayDate,
    required this.holidayName,
    required this.holidayType,
    this.description = '',
    this.checked = false,
  });

  // Tạo từ JSON
  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      holidayDate: json['holiday_date'],
      holidayName: json['holiday_name'] ?? '',
      holidayType: json['holiday_type'] ?? 'other',
      description: json['description'] ?? '',
      checked: json['checked'] ?? false,
    );
  }

  // Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'holiday_date': holidayDate,
      'holiday_name': holidayName,
      'holiday_type': holidayType,
      'description': description,
    };
  }

  // Tạo bản sao với giá trị đã thay đổi
  Holiday copyWith({
    int? id,
    String? holidayDate,
    String? holidayName,
    String? holidayType,
    String? description,
    bool? checked,
  }) {
    return Holiday(
      id: id ?? this.id,
      holidayDate: holidayDate ?? this.holidayDate,
      holidayName: holidayName ?? this.holidayName,
      holidayType: holidayType ?? this.holidayType,
      description: description ?? this.description,
      checked: checked ?? this.checked,
    );
  }
}
