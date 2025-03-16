// lib/models/classroom.dart
class Classroom {
  final int id;
  bool checked;
  final String code;
  final String name;
  final int? gradeBlockId;
  String gradeBlockName;
  final int? homeroomTeacherId;
  String homeroomTeacherName;
  final int capacity;
  final int studentCount;
  final String status;

  Classroom({
    required this.id,
    this.checked = false,
    required this.code,
    required this.name,
    this.gradeBlockId,
    this.gradeBlockName = '',
    this.homeroomTeacherId,
    this.homeroomTeacherName = '',
    required this.capacity,
    required this.studentCount,
    required this.status,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    // Xử lý thông tin giáo viên chủ nhiệm
    String teacherName = json['homeroom_teacher']?['name'] ?? 'Chưa có GVCN';

    // Xử lý thông tin khối
    String blockName = json['grade_block']?['name'] ?? 'Chưa phân khối';

    // Xử lý tình trạng lớp
    int studentCount = json['students_count'] ?? 0;
    int capacity = json['capacity'] ?? 0;
    String status = (studentCount >= capacity) ? "FULL" : "INCOMPLETE";

    return Classroom(
      id: json['id'],
      checked: false,
      code: 'L${json['id']}',
      name: json['name'] ?? 'Chưa rõ',
      gradeBlockId: json['grade_block_id'],
      gradeBlockName: blockName,
      homeroomTeacherId: json['homeroom_teacher_id'],
      homeroomTeacherName: teacherName,
      capacity: capacity,
      studentCount: studentCount,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checked': checked,
      'name': name,
      'capacity': capacity,
      'homeroom_teacher_id': homeroomTeacherId,
      'grade_block_id': gradeBlockId,
    };
  }
}
