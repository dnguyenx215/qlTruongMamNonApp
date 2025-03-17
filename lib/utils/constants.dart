// lib/utils/constants.dart
import 'package:flutter/material.dart';

// Hằng số màu sắc theo thiết kế
class AppColors {
  static Color primary = Colors.blue.shade700;
  static Color secondary = Colors.blue.shade100;
  static Color background = Colors.grey.shade100;
  static Color textPrimary = Colors.black;
  static Color textSecondary = Colors.grey.shade600;
  static Color error = Colors.red;
  static Color success = Colors.green;
}

// Các giá trị mặc định
class AppDefaults {
  static const double padding = 16.0;
  static const double margin = 16.0;
  static const double borderRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}

// Responsive breakpoints
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

// Enum cho các tùy chọn lọc
enum GenderFilter { all, male, female }

enum YearFilter { y2023_2024, y2024_2025, y2025_2026 }

// Chuyển đổi giá trị enum gender sang text hiển thị
String getGenderFilterText(GenderFilter filter) {
  switch (filter) {
    case GenderFilter.all:
      return 'Tất cả';
    case GenderFilter.male:
      return 'Nam';
    case GenderFilter.female:
      return 'Nữ';
  }
}

// Chuyển đổi giá trị enum gender sang giá trị backend
String? getGenderFilterValue(GenderFilter filter) {
  switch (filter) {
    case GenderFilter.all:
      return null;
    case GenderFilter.male:
      return 'male';
    case GenderFilter.female:
      return 'female';
  }
}

// Chuyển đổi giá trị enum năm học sang text hiển thị
String getYearFilterText(YearFilter filter) {
  switch (filter) {
    case YearFilter.y2023_2024:
      return '2023-2024';
    case YearFilter.y2024_2025:
      return '2024-2025';
    case YearFilter.y2025_2026:
      return '2025-2026';
  }
}

const vietnameseAccentMap = {
  'á': 'a',
  'à': 'a',
  'ả': 'a',
  'ã': 'a',
  'ạ': 'a',
  'ă': 'a',
  'ắ': 'a',
  'ằ': 'a',
  'ẳ': 'a',
  'ẵ': 'a',
  'ặ': 'a',
  'â': 'a',
  'ấ': 'a',
  'ầ': 'a',
  'ẩ': 'a',
  'ẫ': 'a',
  'ậ': 'a',
  'é': 'e',
  'è': 'e',
  'ẻ': 'e',
  'ẽ': 'e',
  'ẹ': 'e',
  'ê': 'e',
  'ế': 'e',
  'ề': 'e',
  'ể': 'e',
  'ễ': 'e',
  'ệ': 'e',
  'í': 'i',
  'ì': 'i',
  'ỉ': 'i',
  'ĩ': 'i',
  'ị': 'i',
  'ó': 'o',
  'ò': 'o',
  'ỏ': 'o',
  'õ': 'o',
  'ọ': 'o',
  'ô': 'o',
  'ố': 'o',
  'ồ': 'o',
  'ổ': 'o',
  'ỗ': 'o',
  'ộ': 'o',
  'ơ': 'o',
  'ớ': 'o',
  'ờ': 'o',
  'ở': 'o',
  'ỡ': 'o',
  'ợ': 'o',
  'ú': 'u',
  'ù': 'u',
  'ủ': 'u',
  'ũ': 'u',
  'ụ': 'u',
  'ư': 'u',
  'ứ': 'u',
  'ừ': 'u',
  'ử': 'u',
  'ữ': 'u',
  'ự': 'u',
  'ý': 'y',
  'ỳ': 'y',
  'ỷ': 'y',
  'ỹ': 'y',
  'ỵ': 'y',
  'đ': 'd',
  'Á': 'A',
  'À': 'A',
  'Ả': 'A',
  'Ã': 'A',
  'Ạ': 'A',
  'Ă': 'A',
  'Ắ': 'A',
  'Ằ': 'A',
  'Ẳ': 'A',
  'Ẵ': 'A',
  'Ặ': 'A',
  'Â': 'A',
  'Ấ': 'A',
  'Ầ': 'A',
  'Ẩ': 'A',
  'Ẫ': 'A',
  'Ậ': 'A',
  'É': 'E',
  'È': 'E',
  'Ẻ': 'E',
  'Ẽ': 'E',
  'Ẹ': 'E',
  'Ê': 'E',
  'Ế': 'E',
  'Ề': 'E',
  'Ể': 'E',
  'Ễ': 'E',
  'Ệ': 'E',
  'Í': 'I',
  'Ì': 'I',
  'Ỉ': 'I',
  'Ĩ': 'I',
  'Ị': 'I',
  'Ó': 'O',
  'Ò': 'O',
  'Ỏ': 'O',
  'Õ': 'O',
  'Ọ': 'O',
  'Ô': 'O',
  'Ố': 'O',
  'Ồ': 'O',
  'Ổ': 'O',
  'Ỗ': 'O',
  'Ộ': 'O',
  'Ơ': 'O',
  'Ớ': 'O',
  'Ờ': 'O',
  'Ở': 'O',
  'Ỡ': 'O',
  'Ợ': 'O',
  'Ú': 'U',
  'Ù': 'U',
  'Ủ': 'U',
  'Ũ': 'U',
  'Ụ': 'U',
  'Ư': 'U',
  'Ứ': 'U',
  'Ừ': 'U',
  'Ử': 'U',
  'Ữ': 'U',
  'Ự': 'U',
  'Ý': 'Y',
  'Ỳ': 'Y',
  'Ỷ': 'Y',
  'Ỹ': 'Y',
  'Ỵ': 'Y',
  'Đ': 'D',
};
