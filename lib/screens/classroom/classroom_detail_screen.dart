import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/classroom_model.dart';
import '../../models/user_model.dart';

class ClassroomDetailScreen extends StatefulWidget {
  final ClassroomModel classroom;

  const ClassroomDetailScreen({super.key, required this.classroom});

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();

  void _copyClassCode() {
    Clipboard.setData(ClipboardData(text: widget.classroom.classCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sınıf kodu kopyalandı'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareClassCode() {
    // TODO: Implement share functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınıf Kodu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.classroom.classCode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu kodu öğrencilerinizle paylaşın',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _copyClassCode();
              Navigator.pop(context);
            },
            child: const Text('Kopyala'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeStudent(UserModel student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenciyi Çıkar'),
        content: Text(
          '${student.name} adlı öğrenciyi sınıftan çıkarmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Çıkar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.removeStudentFromClassroom(
          widget.classroom.id,
          student.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Öğrenci sınıftan çıkarıldı'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
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
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isTeacher = authProvider.isTeacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classroom.name),
        actions: [
          if (isTeacher)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareClassCode,
              tooltip: 'Kodu Paylaş',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sınıf Bilgileri Kartı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.classroom.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Öğretmen: ${widget.classroom.teacherName}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.classroom.description != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.classroom.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sınıf Kodu',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.classroom.classCode,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (isTeacher)
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: _copyClassCode,
                          tooltip: 'Kodu Kopyala',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.classroom.studentCount} Öğrenci',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Öğrenci Listesi
          Text('Öğrenciler', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),

          FutureBuilder<List<UserModel>>(
            future: _databaseService.getClassroomStudents(widget.classroom.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }

              final students = snapshot.data ?? [];

              if (students.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz öğrenci yok',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: students.map((student) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          student.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(student.name),
                      subtitle: Text(student.email),
                      trailing: isTeacher
                          ? IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppTheme.errorColor,
                              onPressed: () => _removeStudent(student),
                              tooltip: 'Öğrenciyi Çıkar',
                            )
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
