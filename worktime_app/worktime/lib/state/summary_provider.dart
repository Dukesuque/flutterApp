import 'package:flutter/foundation.dart';
import '../models/summary_model.dart';

/// Summary Provider
/// Gestiona el estado de los resúmenes mensuales del usuario
/// Maneja cálculos de horas, estadísticas y cambio de período
class SummaryProvider extends ChangeNotifier {
  // ============================================
  // PROPIEDADES PRIVADAS
  // ============================================
  
  SummaryModel? _currentSummary;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // ============================================
  // GETTERS PÚBLICOS
  // ============================================
  
  /// Resumen actual
  SummaryModel? get currentSummary => _currentSummary;
  
  /// ¿Está cargando?
  bool get isLoading => _isLoading;
  
  /// Mensaje de error
  String? get errorMessage => _errorMessage;
  
  /// Mes seleccionado
  int get selectedMonth => _selectedMonth;
  
  /// Año seleccionado
  int get selectedYear => _selectedYear;
  
  /// Período formateado
  String get selectedPeriod {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[_selectedMonth - 1]} $_selectedYear';
  }
  
  /// Horas totales trabajadas
  double get totalHours => _currentSummary?.totalHours ?? 0;
  
  /// Horas esperadas
  double get expectedHours => _currentSummary?.expectedHours ?? 0;
  
  /// Horas extras (pueden ser negativas)
  double get extraHours => _currentSummary?.extraHours ?? 0;
  
  /// Porcentaje de progreso
  double get progressPercentage => _currentSummary?.completionPercentage ?? 0;
  
  /// ¿Está completo el mes?
  bool get isComplete => _currentSummary?.isComplete ?? false;

  // ============================================
  // MÉTODOS PRINCIPALES
  // ============================================

  /// Cargar resumen del mes actual
  Future<void> loadCurrentSummary(String userId) async {
    await loadSummary(userId, _selectedMonth, _selectedYear);
  }

  /// Cargar resumen de un mes/año específico
  Future<void> loadSummary(String userId, int month, int year) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _selectedMonth = month;
      _selectedYear = year;
      notifyListeners();

      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 1));

      // Generar datos de ejemplo
      _currentSummary = _generateMockSummary(userId, month, year);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar resumen: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambiar al mes anterior
  Future<void> goToPreviousMonth(String userId) async {
    if (_selectedMonth == 1) {
      await loadSummary(userId, 12, _selectedYear - 1);
    } else {
      await loadSummary(userId, _selectedMonth - 1, _selectedYear);
    }
  }

  /// Cambiar al mes siguiente
  Future<void> goToNextMonth(String userId) async {
    if (_selectedMonth == 12) {
      await loadSummary(userId, 1, _selectedYear + 1);
    } else {
      await loadSummary(userId, _selectedMonth + 1, _selectedYear);
    }
  }

  /// Volver al mes actual
  Future<void> goToCurrentMonth(String userId) async {
    final now = DateTime.now();
    await loadSummary(userId, now.month, now.year);
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar datos
  void clear() {
    _currentSummary = null;
    _errorMessage = null;
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    notifyListeners();
  }

  /// Generar resumen de ejemplo
  SummaryModel _generateMockSummary(String userId, int month, int year) {
    // Generar días del mes
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<DailySummary> dailySummaries = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final weekday = date.weekday;
      
      // Datos de ejemplo
      double hours = 0;
      DayStatus status = DayStatus.pending;

      // Si es fin de semana, no hay trabajo
      if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        hours = 0;
        status = DayStatus.pending;
      }
      // Si es un día futuro, marcar como pendiente
      else if (date.isAfter(DateTime.now())) {
        hours = 0;
        status = DayStatus.pending;
      }
      // Días trabajados (simulados)
      else {
        // Algunos días completos, otros incompletos
        if (day % 7 == 0) {
          // Cada 7 días, jornada incompleta
          hours = 6.5;
          status = DayStatus.incomplete;
        } else if (day % 11 == 0) {
          // Cada 11 días, ausencia
          hours = 0;
          status = DayStatus.absence;
        } else {
          // Resto, jornada completa
          hours = 8.0;
          status = DayStatus.complete;
        }
      }

      dailySummaries.add(DailySummary(
        date: date,
        hours: hours,
        status: status,
      ));
    }

    // Calcular totales
    final totalHours = dailySummaries
        .map((d) => d.hours)
        .reduce((a, b) => a + b);
    
    const expectedHoursPerDay = 8.0;
    final workDaysInMonth = dailySummaries
        .where((d) => !d.isWeekend && !d.date.isAfter(DateTime.now()))
        .length;
    final expectedHours = workDaysInMonth * expectedHoursPerDay;
    
    final extraHours = totalHours - expectedHours;
    final pendingHours = expectedHours - totalHours;

    return SummaryModel(
      userId: userId,
      month: month,
      year: year,
      totalHours: totalHours,
      expectedHours: expectedHours,
      extraHours: extraHours,
      pendingHours: pendingHours > 0 ? pendingHours : 0,
      dailySummaries: dailySummaries,
    );
  }

  /// Obtener horas de un día específico
  double? getHoursForDay(int day) {
    if (_currentSummary == null) return null;
    
    try {
      final dailySummary = _currentSummary!.dailySummaries
          .firstWhere((d) => d.day == day);
      return dailySummary.hours;
    } catch (e) {
      return null;
    }
  }

  /// Obtener estado de un día específico
  DayStatus? getStatusForDay(int day) {
    if (_currentSummary == null) return null;
    
    try {
      final dailySummary = _currentSummary!.dailySummaries
          .firstWhere((d) => d.day == day);
      return dailySummary.status;
    } catch (e) {
      return null;
    }
  }

  /// Debug: Imprimir estado actual
  void debugPrintState() {
    debugPrint('=== SUMMARY STATE ===');
    debugPrint('Period: $selectedPeriod');
    debugPrint('Total hours: $totalHours');
    debugPrint('Expected hours: $expectedHours');
    debugPrint('Extra hours: $extraHours');
    debugPrint('Progress: ${progressPercentage.toStringAsFixed(1)}%');
    debugPrint('Is complete: $isComplete');
    debugPrint('isLoading: $_isLoading');
    debugPrint('errorMessage: $_errorMessage');
    debugPrint('=====================');
  }
}