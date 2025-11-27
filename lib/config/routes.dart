import 'package:flutter/material.dart';

class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String postDetail = '/post-detail';
  static const String createPost = '/create-post';
  static const String submission = '/submission';
  static const String chat = '/chat';
  static const String pomodoro = '/pomodoro';
  static const String subscription = '/subscription';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // SplashScreen - main.dart'ta tanımlı
        );
      
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // LoginScreen - main.dart'ta tanımlı
        );
      
      case '/register':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // RegisterScreen - main.dart'ta tanımlı
        );
      
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // HomeScreen - main.dart'ta tanımlı
        );
      
      case '/post-detail':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // PostDetailScreen eklenecek
        );
      
      case '/create-post':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // CreatePostScreen eklenecek
        );
      
      case '/submission':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // SubmissionScreen eklenecek
        );
      
      case '/chat':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // ChatScreen eklenecek
        );
      
      case '/pomodoro':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // PomodoroScreen - main.dart'ta tanımlı
        );
      
      case '/subscription':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // SubscriptionScreen eklenecek
        );
      
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // ProfileScreen eklenecek
        );
      
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // SettingsScreen eklenecek
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Sayfa bulunamadı: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
