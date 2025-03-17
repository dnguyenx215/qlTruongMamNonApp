// lib/models/student.dart
class Student {
  final int? id;
  final String? studentCode;
  final String firstName;
  final String lastName;
  final String? birthday;
  final String? gender;
  final String? address;
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final int? classId;
  bool checked; // Để quản lý trạng thái chọn trong UI
  String attendanceStatus = 'present'; // Default: present
  String? absenceReason;
  Student({
    this.id,
    this.studentCode,
    required this.firstName,
    required this.lastName,
    this.birthday,
    this.gender,
    this.address,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.classId,
    this.checked = false,
  });

  // Tạo Student từ JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentCode: json['student_code'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      birthday: json['birthday'],
      gender: json['gender'],
      address: json['address'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentEmail: json['parent_email'],
      classId: json['class_id'],
      checked: json['checked'] ?? false,
    );
  }

  // Chuyển đổi Student thành JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_code': studentCode,
      'first_name': firstName,
      'last_name': lastName,
      'birthday': birthday,
      'gender': gender,
      'address': address,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'class_id': classId,
    };
  }

  // Tạo bản sao của Student với một số thuộc tính được cập nhật
  Student copyWith({
    int? id,
    String? studentCode,
    String? firstName,
    String? lastName,
    String? birthday,
    String? gender,
    String? address,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    int? classId,
    bool? checked,
  }) {
    return Student(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      classId: classId ?? this.classId,
      checked: checked ?? this.checked,
    );
  }

  Student copyWithAttendance({
    int? id,
    String? studentCode,
    String? firstName,
    String? lastName,
    String? birthday,
    String? gender,
    String? address,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    int? classId,
    bool? checked,
    String? attendanceStatus,
    String? absenceReason,
  }) {
    return Student(
        id: id ?? this.id,
        studentCode: studentCode ?? this.studentCode,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        birthday: birthday ?? this.birthday,
        gender: gender ?? this.gender,
        address: address ?? this.address,
        parentName: parentName ?? this.parentName,
        parentPhone: parentPhone ?? this.parentPhone,
        parentEmail: parentEmail ?? this.parentEmail,
        classId: classId ?? this.classId,
        checked: checked ?? this.checked,
      )
      ..attendanceStatus = attendanceStatus ?? this.attendanceStatus
      ..absenceReason = absenceReason ?? this.absenceReason;
  }

  // Thuộc tính tính toán để lấy tên đầy đủ
  String get fullName => '$lastName $firstName'.trim();

  // Hiển thị giới tính dạng text
  String get genderText =>
      gender == 'male' ? 'Nam' : (gender == 'female' ? 'Nữ' : 'Khác');
}
