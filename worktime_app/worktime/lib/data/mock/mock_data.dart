import '../../models/user_model.dart';
import '../../models/activity_model.dart';
import '../../models/summary_model.dart';

/// Clase para proporcionar datos iniciales vacíos o mínimos
class MockData {
  /// Usuario inicial vacío
  static final UserModel mockUser = UserModel(
    id: '1',
    name: 'Usuario',
    email: 'usuario@worktime.com',
    position: 'Puesto de trabajo',
    age: 0,
  );

  /// Lista de actividades vacía
  static List<ActivityModel> getMockActivities() {
    return [];
  }

  /// Lista de reuniones vacía
  static List<Map<String, dynamic>> getMockMeetings() {
    return [];
  }

  /// Lista de notificaciones vacía
  static List<Map<String, dynamic>> getMockNotifications() {
    return [];
  }

  /// Horario laboral por defecto
  static Map<String, dynamic> getMockWorkSchedule() {
    return {
      'startTime': '00:00',
      'endTime': '00:00',
      'dailyHours': 0.0,
      'weeklyHours': 0.0,
      'breakTime': '0 min',
      'workDays': <String>[],
    };
  }

  /// Vacaciones vacías
  static Map<String, dynamic> getMockVacations() {
    return {
      'totalDays': 0,
      'usedDays': 0,
      'remainingDays': 0,
      'upcomingVacations': [],
    };
  }

  /// Ausencias vacías
  static List<Map<String, dynamic>> getMockAbsences() {
    return [];
  }

  /// Resumen mensual vacío
  static SummaryModel getMockMonthlySummary() {
    final now = DateTime.now();
    
    return SummaryModel(
      userId: '1',
      month: now.month,
      year: now.year,
      totalHours: 0.0,
      expectedHours: 0.0,
      extraHours: 0.0,
      pendingHours: 0.0,
      dailySummaries: [],
    );
  }
}
