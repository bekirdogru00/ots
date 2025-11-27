import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'student' or 'teacher'
  final String? teacherId; // Öğrenciler için hangi hocaya bağlı
  final String? profileImageUrl;
  final bool subscriptionStatus;
  final DateTime? subscriptionEndDate;
  final DateTime createdAt;
  final DateTime? lastSeen;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.teacherId,
    this.profileImageUrl,
    this.subscriptionStatus = false,
    this.subscriptionEndDate,
    required this.createdAt,
    this.lastSeen,
  });
  
  // Firebase'den veri okuma
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      teacherId: data['teacherId'],
      profileImageUrl: data['profileImageUrl'],
      subscriptionStatus: data['subscriptionStatus'] ?? false,
      subscriptionEndDate: data['subscriptionEndDate'] != null
          ? (data['subscriptionEndDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }
  
  // Firebase'e veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'teacherId': teacherId,
      'profileImageUrl': profileImageUrl,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionEndDate': subscriptionEndDate != null
          ? Timestamp.fromDate(subscriptionEndDate!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }
  
  // Kullanıcı öğrenci mi?
  bool get isStudent => role == 'student';
  
  // Kullanıcı hoca mı?
  bool get isTeacher => role == 'teacher';
  
  // Abonelik aktif mi?
  bool get hasActiveSubscription {
    if (!subscriptionStatus) return false;
    if (subscriptionEndDate == null) return false;
    return subscriptionEndDate!.isAfter(DateTime.now());
  }
  
  // Kopya oluşturma (güncelleme için)
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? teacherId,
    String? profileImageUrl,
    bool? subscriptionStatus,
    DateTime? subscriptionEndDate,
    DateTime? createdAt,
    DateTime? lastSeen,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      teacherId: teacherId ?? this.teacherId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
