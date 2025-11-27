import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/classroom_model.dart';
import 'create_classroom_screen.dart';
import 'join_classroom_screen.dart';
import 'classroom_detail_screen.dart';

class ClassroomsTab extends StatelessWidget {
  const ClassroomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isTeacher = authProvider.isTeacher;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sınıflarım')),
      body: StreamBuilder<List<ClassroomModel>>(
        stream: isTeacher
            ? DatabaseService().getTeacherClassrooms(user.id)
            : DatabaseService().getStudentClassrooms(user.id),
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
                        ? 'Henüz sınıf oluşturmadınız'
                        : 'Henüz sınıfa katılmadınız',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTeacher
                        ? 'Yeni sınıf oluşturmak için\naşağıdaki butona tıklayın'
                        : 'Sınıfa katılmak için\naşağıdaki butona tıklayın',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classrooms.length,
            itemBuilder: (context, index) {
              final classroom = classrooms[index];
              return _ClassroomCard(classroom: classroom, isTeacher: isTeacher);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (isTeacher) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateClassroomScreen(),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JoinClassroomScreen(),
              ),
            );
          }
        },
        icon: Icon(isTeacher ? Icons.add : Icons.login),
        label: Text(isTeacher ? 'Sınıf Oluştur' : 'Sınıfa Katıl'),
      ),
    );
  }
}

class _ClassroomCard extends StatelessWidget {
  final ClassroomModel classroom;
  final bool isTeacher;

  const _ClassroomCard({required this.classroom, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassroomDetailScreen(classroom: classroom),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.class_,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classroom.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTeacher
                              ? 'Kod: ${classroom.classCode}'
                              : 'Öğretmen: ${classroom.teacherName}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.textLight),
                ],
              ),
              if (classroom.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  classroom.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${classroom.studentCount} öğrenci',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
