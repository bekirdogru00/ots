import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String? teacherImageUrl;
  final String title;
  final String description;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? deadline;
  final int submissionCount;
  
  PostModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    this.teacherImageUrl,
    required this.title,
    required this.description,
    this.imageUrls = const [],
    required this.createdAt,
    this.deadline,
    this.submissionCount = 0,
  });
  
  // Firebase'den veri okuma
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      teacherImageUrl: data['teacherImageUrl'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      submissionCount: data['submissionCount'] ?? 0,
    );
  }
  
  // Firebase'e veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherImageUrl': teacherImageUrl,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'submissionCount': submissionCount,
    };
  }
  
  // Deadline geçti mi?
  bool get isDeadlinePassed {
    if (deadline == null) return false;
    return deadline!.isBefore(DateTime.now());
  }
  
  // Deadline'a kalan süre
  Duration? get timeUntilDeadline {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now());
  }
  
  // Kopya oluşturma
  PostModel copyWith({
    String? id,
    String? teacherId,
    String? teacherName,
    String? teacherImageUrl,
    String? title,
    String? description,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? deadline,
    int? submissionCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      teacherImageUrl: teacherImageUrl ?? this.teacherImageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      submissionCount: submissionCount ?? this.submissionCount,
    );
  }
}
