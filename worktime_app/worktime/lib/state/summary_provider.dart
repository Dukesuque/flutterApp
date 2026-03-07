import 'package:flutter/foundation.dart';
import '../models/summary_model.dart';
import '../services/firestore_service.dart';

/// Provider de resúmenes mensuales con datos reales de Firestore
class SummaryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  SummaryModel? _currentSummary;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  SummaryModel? get currentSummary => _currentSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedPeriod {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[_selectedMonth - 1]} $_selectedYear';
  }

  double get totalHours => _currentSummary?.totalHours ?? 0.0;
  double get expectedHours => _currentSummary?.expectedHours ?? 0.0;
  double get extraHours => _currentSummary?.extraHours ?? 0.0;
  double get progressPercentage => _currentSummary?.completionPercentage ?? 0.0;
  bool get isComplete => _currentSummary?.isComplete ?? false;

  Future<void> loadCurrentSummary(String userId) async {
    await loadSummary(userId, DateTime.now().month, DateTime.now().year);
  }

  Future<void> loadSummary(String userId, int month, int year) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();

    try {
      // Calcular resumen desde las sesiones guardadas en Firestore
      _currentSummary = await _calculateSummaryFromSessions(userId, month, year);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SummaryModel> _calculateSummaryFromSessions(
    String userId,
    int month,
    int year,
  ) async {
    // Obtener historial de sesiones del mes
    final allSessions = await _firestoreService.getSessionHistory(userId);
    
    // Filtrar solo las del mes seleccionado
    final monthSessions = allSessions.where((session) {
      final date = session['startTime'] as DateTime;
      return date.month == month && date.year == year;
    }).toList();

    // Calcular días del mes
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final dailySummaries = <DailySummary>[];
    double totalHours = 0.0;
    double expectedHours = 0.0;

    // Agrupar sesiones por día
    final sessionsByDay = <int, List<Map<String, dynamic>>>{};
    for (final session in monthSessions) {
      final date = session['startTime'] as DateTime;
      final day = date.day;
      sessionsByDay.putIfAbsent(day, () => []).add(session);
    }

    // Generar resumen diario
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isWeekend = date.weekday == DateTime.saturday || 
                       date.weekday == DateTime.sunday;
      
      // Calcular horas trabajadas ese día
      final daySessions = sessionsByDay[day] ?? [];
      double dayHours = 0.0;
      
      for (final session in daySessions) {
        final duration = session['durationSeconds'] as int;
        dayHours += duration / 3600.0; // Convertir segundos a horas
      }

      // Determinar estado del día
      DayStatus status;
      if (dayHours == 0) {
        status = DayStatus.pending;
      } else if (dayHours >= 8.0) {
        status = DayStatus.complete;
      } else {
        status = DayStatus.incomplete;
      }

      totalHours += dayHours;
      if (!isWeekend) {
        expectedHours += 8.0;
      }

      dailySummaries.add(DailySummary(
        date: date,
        hours: dayHours,
        status: status,
      ));
    }

    final extraHours = totalHours - expectedHours;
    final pendingHours = expectedHours > totalHours ? expectedHours - totalHours : 0.0;

    return SummaryModel(
      userId: userId,
      month: month,
      year: year,
      totalHours: totalHours,
      expectedHours: expectedHours,
      extraHours: extraHours,
      pendingHours: pendingHours,
      dailySummaries: dailySummaries,
    );
  }

  Future<void> goToPreviousMonth(String userId) async {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    await loadSummary(userId, _selectedMonth, _selectedYear);
  }

  Future<void> goToNextMonth(String userId) async {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    await loadSummary(userId, _selectedMonth, _selectedYear);
  }

  Future<void> goToCurrentMonth(String userId) async {
    final now = DateTime.now();
    await loadSummary(userId, now.month, now.year);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}