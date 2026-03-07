import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

/// Provider para gestionar el contador de tiempo de trabajo
class SessionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isRunning = false;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _userId;

  bool get isRunning => _isRunning;
  Duration get elapsed => _elapsed;
  String get formattedTime => _formatDuration(_elapsed);

  Future<void> initSession(String userId) async {
    _userId = userId;
    await _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    if (_userId == null) return;

    try {
      final activeSession = await _firestoreService.getActiveSession(_userId!);

      if (activeSession != null && activeSession['isActive'] == true) {
        _startTime = activeSession['startTime'] as DateTime;
        _isRunning = true;
        _calculateElapsedTime();
        _startTimer();
      }
    } catch (e) {
      debugPrint('Error al verificar sesión activa: $e');
    }

    notifyListeners();
  }

  Future<void> start() async {
    if (_userId == null || _isRunning) return;

    try {
      _startTime = DateTime.now();
      _isRunning = true;
      _elapsed = Duration.zero;

      final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      await _firestoreService.saveActiveSession(
        userId: _userId!,
        sessionId: sessionId,
        startTime: _startTime!,
      );

      _startTimer();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al iniciar sesión: $e');
      _isRunning = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (_userId == null || !_isRunning) return;

    try {
      _timer?.cancel();
      _isRunning = false;

      final endTime = DateTime.now();
      final durationSeconds = _elapsed.inSeconds;

      await _firestoreService.endActiveSession(
        userId: _userId!,
        endTime: endTime,
        durationSeconds: durationSeconds,
      );

      _startTime = null;
      _elapsed = Duration.zero;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al detener sesión: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateElapsedTime();
      notifyListeners();
    });
  }

  void _calculateElapsedTime() {
    if (_startTime != null) {
      _elapsed = DateTime.now().difference(_startTime!);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<List<Map<String, dynamic>>> getSessionHistory() async {
    if (_userId == null) return [];

    try {
      return await _firestoreService.getSessionHistory(_userId!);
    } catch (e) {
      debugPrint('Error al obtener historial: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}