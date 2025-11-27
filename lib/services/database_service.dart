import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/submission_model.dart';
import '../models/message_model.dart';
import '../models/subscription_model.dart';
import '../config/constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ==================== POSTS ====================
  
  // Post oluştur
  Future<String> createPost(PostModel post) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.postsCollection)
          .add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      throw 'Post oluşturulamadı: $e';
    }
  }
  
  // Hocaya ait postları getir
  Stream<List<PostModel>> getTeacherPosts(String teacherId) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList());
  }
  
  // Tüm postları getir (öğrenci için - kendi hocasının postları)
  Stream<List<PostModel>> getPosts(String teacherId) {
    return _firestore
        .collection(AppConstants.postsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.postsPerPage)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList());
  }
  
  // Tek bir post getir
  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .get();
      
      if (!doc.exists) return null;
      return PostModel.fromFirestore(doc);
    } catch (e) {
      throw 'Post getirilemedi: $e';
    }
  }
  
  // Post güncelle
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update(updates);
    } catch (e) {
      throw 'Post güncellenemedi: $e';
    }
  }
  
  // Post sil
  Future<void> deletePost(String postId) async {
    try {
      // Önce post'a ait tüm submission'ları sil
      final submissions = await _firestore
          .collection(AppConstants.submissionsCollection)
          .where('postId', isEqualTo: postId)
          .get();
      
      for (var doc in submissions.docs) {
        await doc.reference.delete();
      }
      
      // Sonra post'u sil
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .delete();
    } catch (e) {
      throw 'Post silinemedi: $e';
    }
  }
  
  // ==================== SUBMISSIONS ====================
  
  // Çözüm gönder
  Future<String> createSubmission(SubmissionModel submission) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.submissionsCollection)
          .add(submission.toFirestore());
      
      // Post'un submission sayısını artır
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(submission.postId)
          .update({
        'submissionCount': FieldValue.increment(1),
      });
      
      return docRef.id;
    } catch (e) {
      throw 'Çözüm gönderilemedi: $e';
    }
  }
  
  // Post'a ait tüm çözümleri getir
  Stream<List<SubmissionModel>> getSubmissions(String postId) {
    return _firestore
        .collection(AppConstants.submissionsCollection)
        .where('postId', isEqualTo: postId)
        .orderBy('submittedAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromFirestore(doc))
            .toList());
  }
  
  // Öğrencinin belirli bir post için çözümü var mı?
  Future<bool> hasUserSubmitted(String postId, String studentId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.submissionsCollection)
          .where('postId', isEqualTo: postId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Öğrencinin çözümünü getir
  Future<SubmissionModel?> getUserSubmission(String postId, String studentId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.submissionsCollection)
          .where('postId', isEqualTo: postId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return null;
      return SubmissionModel.fromFirestore(query.docs.first);
    } catch (e) {
      return null;
    }
  }
  
  // Öğrencinin tüm çözümlerini getir
  Stream<List<SubmissionModel>> getStudentSubmissions(String studentId) {
    return _firestore
        .collection(AppConstants.submissionsCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubmissionModel.fromFirestore(doc))
            .toList());
  }
  
  // Çözüme AI analizi ekle
  Future<void> updateSubmissionAnalysis(
    String submissionId,
    String analysis,
    Map<String, dynamic> recommendations,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.submissionsCollection)
          .doc(submissionId)
          .update({
        'aiAnalysis': analysis,
        'aiRecommendations': recommendations,
      });
    } catch (e) {
      throw 'Analiz kaydedilemedi: $e';
    }
  }
  
  // ==================== MESSAGES ====================
  
  // Chat ID oluştur (studentId_teacherId formatında)
  String getChatId(String studentId, String teacherId) {
    return '${studentId}_$teacherId';
  }
  
  // Chat oluştur veya getir
  Future<ChatModel> getOrCreateChat({
    required String studentId,
    required String teacherId,
    required String studentName,
    required String teacherName,
    String? studentImageUrl,
    String? teacherImageUrl,
  }) async {
    try {
      final chatId = getChatId(studentId, teacherId);
      final doc = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .get();
      
      if (doc.exists) {
        return ChatModel.fromFirestore(doc);
      }
      
      // Chat yoksa oluştur
      final chat = ChatModel(
        id: chatId,
        studentId: studentId,
        teacherId: teacherId,
        studentName: studentName,
        teacherName: teacherName,
        studentImageUrl: studentImageUrl,
        teacherImageUrl: teacherImageUrl,
      );
      
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .set(chat.toFirestore());
      
      return chat;
    } catch (e) {
      throw 'Chat oluşturulamadı: $e';
    }
  }
  
  // Mesaj gönder
  Future<String> sendMessage(MessageModel message) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.messagesCollection)
          .add(message.toFirestore());
      
      // Chat'i güncelle
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(message.chatId)
          .update({
        'lastMessage': message.message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
      });
      
      return docRef.id;
    } catch (e) {
      throw 'Mesaj gönderilemedi: $e';
    }
  }
  
  // Mesajları getir
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection(AppConstants.messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(AppConstants.messagesPerPage)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }
  
  // Kullanıcının chat listesini getir
  Stream<List<ChatModel>> getUserChats(String userId, bool isTeacher) {
    final field = isTeacher ? 'teacherId' : 'studentId';
    return _firestore
        .collection(AppConstants.chatsCollection)
        .where(field, isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromFirestore(doc))
            .toList());
  }
  
  // Mesajları okundu olarak işaretle
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messages = await _firestore
          .collection(AppConstants.messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (var doc in messages.docs) {
        await doc.reference.update({'isRead': true});
      }
      
      // Chat'in unread count'unu sıfırla
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .update({'unreadCount': 0});
    } catch (e) {
      print('Mesajlar okundu olarak işaretlenemedi: $e');
    }
  }
  
  // ==================== USERS ====================
  
  // Kullanıcı bilgilerini getir
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
  
  // Hocaya bağlı öğrencileri getir
  Stream<List<UserModel>> getTeacherStudents(String teacherId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('teacherId', isEqualTo: teacherId)
        .where('role', isEqualTo: AppConstants.roleStudent)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }
  
  // Tüm hocaları getir (kayıt ekranı için)
  Future<List<UserModel>> getAllTeachers() async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: AppConstants.roleTeacher)
          .get();
      
      return query.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // ==================== SUBSCRIPTIONS ====================
  
  // Abonelik oluştur
  Future<String> createSubscription(SubscriptionModel subscription) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.subscriptionsCollection)
          .add(subscription.toFirestore());
      
      // Kullanıcının abonelik durumunu güncelle
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(subscription.userId)
          .update({
        'subscriptionStatus': true,
        'subscriptionEndDate': Timestamp.fromDate(subscription.endDate),
      });
      
      return docRef.id;
    } catch (e) {
      throw 'Abonelik oluşturulamadı: $e';
    }
  }
  
  // Kullanıcının aktif aboneliğini getir
  Future<SubscriptionModel?> getActiveSubscription(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.subscriptionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('endDate', descending: true)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return null;
      return SubscriptionModel.fromFirestore(query.docs.first);
    } catch (e) {
      return null;
    }
  }
  
  // Aboneliği iptal et
  Future<void> cancelSubscription(String subscriptionId, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.subscriptionsCollection)
          .doc(subscriptionId)
          .update({
        'isActive': false,
        'autoRenew': false,
      });
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'subscriptionStatus': false});
    } catch (e) {
      throw 'Abonelik iptal edilemedi: $e';
    }
  }
}
