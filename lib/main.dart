import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/pomodoro/pomodoro_screen.dart';
import 'screens/post/post_detail_screen.dart';
import 'screens/post/create_post_screen.dart';
import 'screens/post/submission_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/new_chat_screen.dart';
import 'screens/subscription/subscription_screen.dart';
import 'models/post_model.dart';
import 'models/message_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp();

  // Bildirimleri başlat
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initializeAuthListener(),
        ),
      ],
      child: MaterialApp(
        title: 'Öğrenci Takip',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return MaterialPageRoute(builder: (_) => const SplashScreen());

            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const LoginScreen());

            case AppRoutes.register:
              return MaterialPageRoute(builder: (_) => const RegisterScreen());

            case AppRoutes.home:
              return MaterialPageRoute(builder: (_) => const HomeScreen());

            case AppRoutes.pomodoro:
              return MaterialPageRoute(builder: (_) => const PomodoroScreen());

            case AppRoutes.postDetail:
              final post = settings.arguments as PostModel;
              return MaterialPageRoute(
                builder: (_) => PostDetailScreen(post: post),
              );

            case AppRoutes.createPost:
              return MaterialPageRoute(
                builder: (_) => const CreatePostScreen(),
              );

            case AppRoutes.submission:
              final post = settings.arguments as PostModel;
              return MaterialPageRoute(
                builder: (_) => SubmissionScreen(post: post),
              );

            case AppRoutes.chat:
              return MaterialPageRoute(
                builder: (_) =>
                    ChatScreen(chat: settings.arguments as ChatModel),
              );

            case AppRoutes.newChat:
              return MaterialPageRoute(builder: (_) => const NewChatScreen());

            case AppRoutes.subscription:
              return MaterialPageRoute(
                builder: (_) => const SubscriptionScreen(),
              );

            default:
              return AppRoutes.generateRoute(settings);
          }
        },
      ),
    );
  }
}
