import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String id;
  final String postId;
  final String studentId;
  final String studentName;
  final String? studentImageUrl;
  final List<String> imageUrls;
  final DateTime submittedAt;
  final String? aiAnalysis;
  final Map<String, dynamic>? aiRecommendations;
  
  SubmissionModel({
    required this.id,
    required this.postId,
    required this.studentId,
    required this.studentName,
    this.studentImageUrl,
    this.imageUrls = const [],
    required this.submittedAt,
    this.aiAnalysis,
    this.aiRecommendations,
  });
  
  // Firebase'den veri okuma
  factory SubmissionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SubmissionModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentImageUrl: data['studentImageUrl'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      aiAnalysis: data['aiAnalysis'],
      aiRecommendations: data['aiRecommendations'] != null
          ? Map<String, dynamic>.from(data['aiRecommendations'])
          : null,
    );
  }
  
  // Firebase'e veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'studentId': studentId,
      'studentName': studentName,
      'studentImageUrl': studentImageUrl,
      'imageUrls': imageUrls,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'aiAnalysis': aiAnalysis,
      'aiRecommendations': aiRecommendations,
    };
  }
  
  // AI analizi yapıldı mı?
  bool get hasAiAnalysis => aiAnalysis != null && aiAnalysis!.isNotEmpty;
  
  // Kopya oluşturma
  SubmissionModel copyWith({
    String? id,
    String? postId,
    String? studentId,
    String? studentName,
    String? studentImageUrl,
    List<String>? imageUrls,
    DateTime? submittedAt,
    String? aiAnalysis,
    Map<String, dynamic>? aiRecommendations,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentImageUrl: studentImageUrl ?? this.studentImageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      submittedAt: submittedAt ?? this.submittedAt,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
    );
  }
}
