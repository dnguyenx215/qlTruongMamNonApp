// lib/models/attendance.dart
class Attendance {
  final int? id;
  final int studentId;
  final String date;
  final String? status; // 'present', 'absent_excused', 'absent_unexcused'
  final String? absenceReason;
  final bool isLocked;

  Attendance({
    this.id,
    required this.studentId,
    required this.date,
    this.status,
    this.absenceReason,
    this.isLocked = false,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentId: json['student_id'],
      date: json['date'],
      status: json['status'] ?? 'present',
      absenceReason: json['absence_reason'],
      // Chuyển đổi từ int (0/1) sang bool
      isLocked: json['is_locked'] == 1 || json['is_locked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date,
      'status': status,
      'absence_reason': absenceReason,
      // Chuyển đổi từ bool sang int (0/1) khi gửi lên server
      'is_locked': isLocked ? 1 : 0,
    };
  }

  // Phương thức copyWith giữ nguyên
  Attendance copyWith({
    int? id,
    int? studentId,
    String? date,
    String? status,
    String? absenceReason,
    bool? isLocked,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      absenceReason: absenceReason ?? this.absenceReason,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
