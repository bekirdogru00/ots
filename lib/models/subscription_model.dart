import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String id;
  final String userId;
  final String plan; // 'monthly' or 'yearly'
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool autoRenew;
  final double amount;
  final String? transactionId;
  
  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.autoRenew = true,
    required this.amount,
    this.transactionId,
  });
  
  // Firebase'den veri okuma
  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      plan: data['plan'] ?? 'monthly',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      autoRenew: data['autoRenew'] ?? true,
      amount: (data['amount'] ?? 0).toDouble(),
      transactionId: data['transactionId'],
    );
  }
  
  // Firebase'e veri yazma
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'plan': plan,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'autoRenew': autoRenew,
      'amount': amount,
      'transactionId': transactionId,
    };
  }
  
  // Abonelik süresi doldu mu?
  bool get isExpired => endDate.isBefore(DateTime.now());
  
  // Kalan gün sayısı
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }
  
  // Aylık mı yıllık mı?
  bool get isMonthly => plan == 'monthly';
  bool get isYearly => plan == 'yearly';
  
  // Kopya oluşturma
  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? plan,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? autoRenew,
    double? amount,
    String? transactionId,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      autoRenew: autoRenew ?? this.autoRenew,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
