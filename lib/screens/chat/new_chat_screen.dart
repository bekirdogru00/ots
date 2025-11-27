import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/classroom_model.dart';
import '../../models/user_model.dart';
import '../../models/message_model.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _startChat(UserModel otherUser, bool isTeacher) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    try {
      // Chat oluştur veya getir
      final chat = await _databaseService.getOrCreateChat(
        studentId: isTeacher ? otherUser.id : currentUser.id,
        teacherId: isTeacher ? currentUser.id : otherUser.id,
        studentName: isTeacher ? otherUser.name : currentUser.name,
        teacherName: isTeacher ? currentUser.name : otherUser.name,
        studentImageUrl: isTeacher
            ? otherUser.profileImageUrl
            : currentUser.profileImageUrl,
        teacherImageUrl: isTeacher
            ? currentUser.profileImageUrl
            : otherUser.profileImageUrl,
      );

      if (mounted) {
        // Chat ekranına git
        Navigator.of(
          context,
        ).pushReplacementNamed(AppRoutes.chat, arguments: chat);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isTeacher = authProvider.isTeacher;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(isTeacher ? 'Öğrenci Seç' : 'Öğretmen Seç')),
      body: StreamBuilder<List<ClassroomModel>>(
        stream: isTeacher
            ? _databaseService.getTeacherClassrooms(user.id)
            : _databaseService.getStudentClassrooms(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final classrooms = snapshot.data ?? [];

          if (classrooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTeacher ? Icons.school_outlined : Icons.class_outlined,
                    size: 80,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isTeacher
                        ? 'Henüz sınıfınız yok'
                        : 'Henüz sınıfa katılmadınız',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTeacher
                        ? 'Önce sınıf oluşturun'
                        : 'Önce bir sınıfa katılın',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
            );
          }

          // Tüm sınıflardan kullanıcıları topla
          return FutureBuilder<List<UserModel>>(
            future: _getAllUsersFromClassrooms(classrooms, isTeacher),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = userSnapshot.data ?? [];

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 80,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isTeacher
                            ? 'Sınıflarınızda henüz öğrenci yok'
                            : 'Sınıflarınızda henüz öğretmen yok',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final otherUser = users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        backgroundImage: otherUser.profileImageUrl != null
                            ? NetworkImage(otherUser.profileImageUrl!)
                            : null,
                        child: otherUser.profileImageUrl == null
                            ? Text(
                                otherUser.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              )
                            : null,
                      ),
                      title: Text(otherUser.name),
                      subtitle: Text(otherUser.email),
                      trailing: const Icon(Icons.chat_bubble_outline),
                      onTap: () => _startChat(otherUser, isTeacher),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<UserModel>> _getAllUsersFromClassrooms(
    List<ClassroomModel> classrooms,
    bool isTeacher,
  ) async {
    final Set<String> userIds = {};
    final List<UserModel> users = [];

    if (isTeacher) {
      // Öğretmen için: tüm sınıflardan öğrencileri topla
      for (final classroom in classrooms) {
        userIds.addAll(classroom.studentIds);
      }

      // Öğrencileri getir
      for (final userId in userIds) {
        final user = await _databaseService.getUser(userId);
        if (user != null) {
          users.add(user);
        }
      }
    } else {
      // Öğrenci için: tüm sınıflardan öğretmenleri topla
      for (final classroom in classrooms) {
        userIds.add(classroom.teacherId);
      }

      // Öğretmenleri getir
      for (final userId in userIds) {
        final user = await _databaseService.getUser(userId);
        if (user != null) {
          users.add(user);
        }
      }
    }

    return users;
  }
}
