/// Modelo de Resumen
/// Representa el resumen de horas trabajadas en un período (generalmente un mes)
class SummaryModel {
  final String userId;                    // ID del usuario
  final int month;                        // Mes (1-12)
  final int year;                         // Año
  final double totalHours;                // Total de horas trabajadas
  final double expectedHours;             // Horas esperadas/contractuales
  final double extraHours;                // Horas extra (puede ser negativo)
  final double pendingHours;              // Horas pendientes por trabajar
  final List<DailySummary> dailySummaries; // Resumen día por día

  SummaryModel({
    required this.userId,
    required this.month,
    required this.year,
    required this.totalHours,
    required this.expectedHours,
    required this.extraHours,
    required this.pendingHours,
    required this.dailySummaries,
  });

  /// Crear desde JSON
  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      userId: json['userId'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      totalHours: (json['totalHours'] as num).toDouble(),
      expectedHours: (json['expectedHours'] as num).toDouble(),
      extraHours: (json['extraHours'] as num).toDouble(),
      pendingHours: (json['pendingHours'] as num).toDouble(),
      // Convertir lista de JSON a lista de DailySummary
      dailySummaries: (json['dailySummaries'] as List<dynamic>)
          .map((e) => DailySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'month': month,
      'year': year,
      'totalHours': totalHours,
      'expectedHours': expectedHours,
      'extraHours': extraHours,
      'pendingHours': pendingHours,
      'dailySummaries': dailySummaries.map((e) => e.toJson()).toList(),
    };
  }

  /// Obtener porcentaje de horas completadas
  /// Retorna un valor entre 0 y 100 (o más si hay horas extra)
  double get completionPercentage {
    if (expectedHours == 0) return 0;
    return (totalHours / expectedHours) * 100;
  }

  /// Obtener el nombre del mes en español
  String get monthName {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  /// Obtener período formateado (ej: "Febrero 2024")
  String get periodFormatted {
    return '$monthName $year';
  }

  /// Verificar si se han cumplido las horas esperadas
  bool get isComplete {
    return totalHours >= expectedHours;
  }

  /// Obtener el promedio de horas por día trabajado
  double get averageHoursPerDay {
    final workedDays = dailySummaries.where((d) => d.hours > 0).length;
    if (workedDays == 0) return 0;
    return totalHours / workedDays;
  }

  @override
  String toString() {
    return 'SummaryModel(period: $periodFormatted, hours: $totalHours/$expectedHours)';
  }
}

/// Resumen diario
/// Representa las horas trabajadas en un día específico
class DailySummary {
  final DateTime date;      // Fecha del día
  final double hours;       // Horas trabajadas ese día
  final DayStatus status;   // Estado del día

  DailySummary({
    required this.date,
    required this.hours,
    required this.status,
  });

  /// Crear desde JSON
  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: DateTime.parse(json['date'] as String),
      hours: (json['hours'] as num).toDouble(),
      status: DayStatus.values.firstWhere(
        (e) => e.toString() == 'DayStatus.${json['status']}',
        orElse: () => DayStatus.pending,
      ),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'hours': hours,
      'status': status.toString().split('.').last,
    };
  }

  /// Obtener el día del mes (1-31)
  int get day => date.day;

  /// Obtener el día de la semana (1-7, donde 1 = lunes)
  int get weekday => date.weekday;

  /// Verificar si es fin de semana
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Obtener nombre corto del día (L, M, X, J, V, S, D)
  String get dayShortName {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  /// Obtener nombre completo del día
  String get dayFullName {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  /// Obtener horas formateadas (ej: "8.5h" o "8h 30m")
  String get hoursFormatted {
    if (hours == 0) return '0h';
    
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    
    if (minutes == 0) {
      return '${wholeHours}h';
    } else {
      return '${wholeHours}h ${minutes}m';
    }
  }

  @override
  String toString() {
    return 'DailySummary(date: ${date.day}/${date.month}, hours: $hours, status: ${status.displayName})';
  }
}

/// Estado del día en el sistema de fichaje
enum DayStatus {
  complete,    // Jornada completa (cumplió las horas esperadas)
  incomplete,  // Jornada incompleta (trabajó pero no lo suficiente)
  absence,     // Ausencia/Falta
  pending,     // Sin fichar / No hay datos
}

/// Extensión para obtener información del estado del día
extension DayStatusExtension on DayStatus {
  /// Nombre para mostrar en la UI
  String get displayName {
    switch (this) {
      case DayStatus.complete:
        return 'Jornada completa';
      case DayStatus.incomplete:
        return 'Jornada incompleta';
      case DayStatus.absence:
        return 'Ausencia';
      case DayStatus.pending:
        return 'Sin fichar';
    }
  }

  /// Color asociado al estado
  int get colorValue {
    switch (this) {
      case DayStatus.complete:
        return 0xFF4CAF50;  // Verde (success)
      case DayStatus.incomplete:
        return 0xFFFFB300;  // Amarillo (warning)
      case DayStatus.absence:
        return 0xFFFF5252;  // Rojo (error)
      case DayStatus.pending:
        return 0xFF7C7F85;  // Gris (textTertiary)
    }
  }

  /// Descripción corta para tooltips
  String get description {
    switch (this) {
      case DayStatus.complete:
        return 'Has completado tu jornada';
      case DayStatus.incomplete:
        return 'Jornada parcial';
      case DayStatus.absence:
        return 'No trabajaste este día';
      case DayStatus.pending:
        return 'Aún no has fichado';
    }
  }
}