import 'dart:convert';

class Subject {
  final String id;
  final String name;
  final int difficulty; // 1-5
  final DateTime examDate;
  final double requiredHours;
  final double completedHours;

  Subject({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.examDate,
    required this.requiredHours,
    required this.completedHours,
  });

  Subject copyWith({
    String? id,
    String? name,
    int? difficulty,
    DateTime? examDate,
    double? requiredHours,
    double? completedHours,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      examDate: examDate ?? this.examDate,
      requiredHours: requiredHours ?? this.requiredHours,
      completedHours: completedHours ?? this.completedHours,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'examDate': examDate.toIso8601String(),
      'requiredHours': requiredHours,
      'completedHours': completedHours,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      name: map['name'] as String,
      difficulty: map['difficulty'] as int,
      examDate: DateTime.parse(map['examDate'] as String),
      requiredHours: (map['requiredHours'] as num).toDouble(),
      completedHours: (map['completedHours'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Subject.fromJson(String source) =>
      Subject.fromMap(json.decode(source) as Map<String, dynamic>);
}
