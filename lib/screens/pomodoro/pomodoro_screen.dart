import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final CountDownController _controller = CountDownController();
  
  bool _isWorkTime = true;
  bool _isRunning = false;
  int _completedSessions = 0;
  int _currentDuration = AppConstants.pomodoroWorkDuration * 60;

  @override
  void dispose() {
    _controller.pause();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _controller.start();
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _controller.pause();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _completedSessions = 0;
      _isWorkTime = true;
      _currentDuration = AppConstants.pomodoroWorkDuration * 60;
    });
    _controller.restart(duration: _currentDuration);
  }

  void _onTimerComplete() {
    setState(() {
      _isRunning = false;
      
      if (_isWorkTime) {
        _completedSessions++;
        
        // Uzun mola mı kısa mola mı?
        if (_completedSessions % AppConstants.pomodoroSessionsBeforeLongBreak == 0) {
          _currentDuration = AppConstants.pomodoroLongBreak * 60;
        } else {
          _currentDuration = AppConstants.pomodoroShortBreak * 60;
        }
        _isWorkTime = false;
      } else {
        _currentDuration = AppConstants.pomodoroWorkDuration * 60;
        _isWorkTime = true;
      }
    });
    
    _controller.restart(duration: _currentDuration);
    
    // Bildirim göster
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isWorkTime ? '🎉 Mola Bitti!' : '✅ Çalışma Tamamlandı!'),
        content: Text(
          _isWorkTime
              ? 'Mola süresi doldu. Çalışmaya hazır mısın?'
              : 'Harika! Bir çalışma seansını tamamladın. Mola zamanı!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
            child: const Text('Başlat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showPomodoroInfo();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // İstatistikler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Tamamlanan',
                  value: '$_completedSessions',
                  color: AppTheme.secondaryColor,
                ),
                _buildStatCard(
                  icon: Icons.timer_outlined,
                  label: 'Durum',
                  value: _isWorkTime ? 'Çalışma' : 'Mola',
                  color: _isWorkTime ? AppTheme.primaryColor : AppTheme.accentColor,
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Timer
            Expanded(
              child: Center(
                child: CircularCountDownTimer(
                  controller: _controller,
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  duration: _currentDuration,
                  fillColor: _isWorkTime
                      ? AppTheme.primaryColor
                      : AppTheme.accentColor,
                  ringColor: AppTheme.backgroundColor,
                  strokeWidth: 20,
                  strokeCap: StrokeCap.round,
                  textStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                  isReverse: true,
                  isReverseAnimation: true,
                  onComplete: _onTimerComplete,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Kontroller
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset butonu
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  iconSize: 32,
                  color: AppTheme.textSecondary,
                ),
                
                const SizedBox(width: 40),
                
                // Play/Pause butonu
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: 48,
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                  ),
                ),
                
                const SizedBox(width: 40),
                
                // Skip butonu
                IconButton(
                  onPressed: () {
                    _onTimerComplete();
                  },
                  icon: const Icon(Icons.skip_next),
                  iconSize: 32,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Açıklama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isWorkTime ? Icons.work_outline : Icons.coffee_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isWorkTime
                          ? 'Odaklan ve çalış! ${AppConstants.pomodoroWorkDuration} dakika boyunca dikkatini dağıtma.'
                          : 'Mola zamanı! ${_currentDuration ~/ 60} dakika dinlen.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showPomodoroInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pomodoro Tekniği'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pomodoro Tekniği, zaman yönetimi için etkili bir yöntemdir.',
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                '1. Çalışma',
                '${AppConstants.pomodoroWorkDuration} dakika odaklanarak çalış',
              ),
              _buildInfoItem(
                '2. Kısa Mola',
                '${AppConstants.pomodoroShortBreak} dakika dinlen',
              ),
              _buildInfoItem(
                '3. Tekrarla',
                '${AppConstants.pomodoroSessionsBeforeLongBreak} seans sonra uzun mola',
              ),
              _buildInfoItem(
                '4. Uzun Mola',
                '${AppConstants.pomodoroLongBreak} dakika dinlen',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
