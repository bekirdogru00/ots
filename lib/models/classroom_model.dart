import 'package:cloud_firestore/cloud_firestore.dart';

class ClassroomModel {
  final String id;
  final String name;
  final String teacherId;
  final String teacherName;
  final String classCode;
  final String? description;
  final List<String> studentIds;
  final DateTime createdAt;
  final int studentCount;

  ClassroomModel({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.classCode,
    this.description,
    required this.studentIds,
    required this.createdAt,
    required this.studentCount,
  });

  // Firebase'den veri okuma
  factory ClassroomModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClassroomModel(
      id: doc.id,
      name: data['name'] ?? '',
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      classCode: data['classCode'] ?? '',
      description: data['description'],
      studentIds: List<String>.from(data['studentIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      studentCount: data['studentCount'] ?? 0,
    );
  }

  // Firebase'e veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'classCode': classCode,
      'description': description,
      'studentIds': studentIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'studentCount': studentCount,
    };
  }

  // Kopya oluşturma (güncelleme için)
  ClassroomModel copyWith({
    String? id,
    String? name,
    String? teacherId,
    String? teacherName,
    String? classCode,
    String? description,
    List<String>? studentIds,
    DateTime? createdAt,
    int? studentCount,
  }) {
    return ClassroomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      classCode: classCode ?? this.classCode,
      description: description ?? this.description,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
      studentCount: studentCount ?? this.studentCount,
    );
  }

  // Öğrenci sınıfa dahil mi?
  bool hasStudent(String studentId) {
    return studentIds.contains(studentId);
  }
}
