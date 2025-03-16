// lib/models/grade_block.dart
class GradeBlock {
  final int id;
  final String code;
  final String name;
  final String description;

  GradeBlock({
    required this.id,
    required this.code,
    required this.name,
    this.description = '',
  });

  factory GradeBlock.fromJson(Map<String, dynamic> json) {
    return GradeBlock(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? 'Chưa có tên',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name, 'description': description};
  }
}
