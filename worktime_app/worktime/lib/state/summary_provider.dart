import 'package:flutter/foundation.dart';
import '../models/summary_model.dart';
import '../services/firestore_service.dart';

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
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${months[_selectedMonth - 1]} $_selectedYear';
  }

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
      _currentSummary = await _calculateSummaryFromSessions(userId, month, year);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SummaryModel> _calculateSummaryFromSessions(String userId, int month, int year) async {
    final allSessions = await _firestoreService.getSessionHistory(userId);

    final monthSessions = allSessions.where((session) {
      final date = session['startTime'] as DateTime;
      return date.month == month && date.year == year;
    }).toList();

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final dailySummaries = <DailySummary>[];
    double totalHours = 0.0;
    double expectedHours = 0.0;

    final sessionsByDay = <int, List<Map<String, dynamic>>>{};
    for (final session in monthSessions) {
      final date = session['startTime'] as DateTime;
      sessionsByDay.putIfAbsent(date.day, () => []).add(session);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

      final daySessions = sessionsByDay[day] ?? [];
      double dayHours = 0.0;

      for (final session in daySessions) {
        dayHours += (session['durationSeconds'] as int) / 3600.0;
      }

      DayStatus status;
      if (dayHours == 0) {
        status = DayStatus.pending;
      } else if (dayHours >= 8.0) {
        status = DayStatus.complete;
      } else {
        status = DayStatus.incomplete;
      }

      totalHours += dayHours;
      if (!isWeekend) expectedHours += 8.0;

      dailySummaries.add(DailySummary(date: date, hours: dayHours, status: status));
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

}
