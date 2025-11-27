class AppConstants {
  // App Info
  static const String appName = 'Öğrenci Takip';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String submissionsCollection = 'submissions';
  static const String messagesCollection = 'messages';
  static const String chatsCollection = 'chats';
  static const String subscriptionsCollection = 'subscriptions';
  static const String classroomsCollection = 'classrooms';

  // Classroom
  static const int classCodeLength = 6;

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String postImagesPath = 'post_images';
  static const String submissionImagesPath = 'submission_images';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';

  // Subscription Plans
  static const String planMonthly = 'monthly';
  static const String planYearly = 'yearly';

  // RevenueCat
  static const String revenueCatApiKey =
      'YOUR_REVENUECAT_API_KEY'; // Kullanıcı kendi key'ini ekleyecek

  // Gemini AI
  static const String geminiApiKey =
      'AIzaSyB3cR8oAME26mmHg_WwotkznKGSVZ8Epdc'; // Kullanıcı kendi key'ini ekleyecek

  // Pomodoro Settings
  static const int pomodoroWorkDuration = 25; // dakika
  static const int pomodoroShortBreak = 5; // dakika
  static const int pomodoroLongBreak = 15; // dakika
  static const int pomodoroSessionsBeforeLongBreak = 4;

  // Image Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 80;

  // Pagination
  static const int postsPerPage = 10;
  static const int messagesPerPage = 50;

  // Cache
  static const String cacheKeyUser = 'cached_user';
  static const String cacheKeyTheme = 'theme_mode';

  // Error Messages
  static const String errorGeneric = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorNetwork = 'İnternet bağlantınızı kontrol edin.';
  static const String errorAuth = 'Giriş yapmanız gerekiyor.';
  static const String errorPermission = 'Bu işlem için yetkiniz yok.';
  static const String errorImageSize = 'Görsel boyutu çok büyük (max 5MB).';

  // Success Messages
  static const String successPostCreated = 'Gönderi başarıyla oluşturuldu!';
  static const String successSubmissionSent = 'Çözümünüz gönderildi!';
  static const String successMessageSent = 'Mesaj gönderildi!';
  static const String successProfileUpdated = 'Profil güncellendi!';
}
