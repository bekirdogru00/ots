import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  // Bildirimleri başlat
  Future<void> initialize() async {
    // İzin iste
    await _requestPermission();
    
    // Local notifications ayarla
    await _initializeLocalNotifications();
    
    // FCM token al
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    
    // Foreground mesajları dinle
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Background mesaj handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Bildirime tıklandığında
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }
  
  // İzin iste
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Bildirim izni: ${settings.authorizationStatus}');
  }
  
  // Local notifications başlat
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  // Foreground mesajları işle
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground mesaj alındı: ${message.notification?.title}');
    
    // Local notification göster
    _showLocalNotification(
      title: message.notification?.title ?? 'Bildirim',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }
  
  // Mesaj açıldığında
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Bildirime tıklandı: ${message.data}');
    // Burada ilgili sayfaya yönlendirme yapılabilir
  }
  
  // Local notification göster
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Genel Bildirimler',
      channelDescription: 'Uygulama bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // Bildirime tıklandığında
  void _onNotificationTapped(NotificationResponse response) {
    print('Bildirim tıklandı: ${response.payload}');
    // Burada ilgili sayfaya yönlendirme yapılabilir
  }
  
  // Topic'e abone ol
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('Topic\'e abone olundu: $topic');
  }
  
  // Topic aboneliğinden çık
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('Topic aboneliğinden çıkıldı: $topic');
  }
  
  // FCM token al
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

// Background mesaj handler (top-level function olmalı)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background mesaj alındı: ${message.notification?.title}');
}
