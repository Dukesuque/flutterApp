class SummaryModel {
  final String userId;
  final int month;
  final int year;
  final double totalHours;
  final double expectedHours;
  final double extraHours;
  final double pendingHours;
  final List<DailySummary> dailySummaries;

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

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      userId: json['userId'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      totalHours: (json['totalHours'] as num).toDouble(),
      expectedHours: (json['expectedHours'] as num).toDouble(),
      extraHours: (json['extraHours'] as num).toDouble(),
      pendingHours: (json['pendingHours'] as num).toDouble(),
      dailySummaries: (json['dailySummaries'] as List<dynamic>)
          .map((e) => DailySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

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

  double get completionPercentage {
    if (expectedHours == 0) return 0;
    return (totalHours / expectedHours) * 100;
  }

  String get monthName {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return months[month - 1];
  }

  String get periodFormatted => '$monthName $year';
  bool get isComplete => totalHours >= expectedHours;

  double get averageHoursPerDay {
    final workedDays = dailySummaries.where((d) => d.hours > 0).length;
    if (workedDays == 0) return 0;
    return totalHours / workedDays;
  }
}

class DailySummary {
  final DateTime date;
  final double hours;
  final DayStatus status;

  DailySummary({
    required this.date,
    required this.hours,
    required this.status,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'hours': hours,
      'status': status.toString().split('.').last,
    };
  }

  int get day => date.day;
  int get weekday => date.weekday;
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  String get hoursFormatted {
    if (hours == 0) return '0h';
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    return minutes == 0 ? '${wholeHours}h' : '${wholeHours}h ${minutes}m';
  }
}

enum DayStatus {
  complete,
  incomplete,
  absence,
  pending,
}

extension DayStatusExtension on DayStatus {
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

  int get colorValue {
    switch (this) {
      case DayStatus.complete:
        return 0xFF4CAF50;
      case DayStatus.incomplete:
        return 0xFFFFB300;
      case DayStatus.absence:
        return 0xFFFF5252;
      case DayStatus.pending:
        return 0xFF7C7F85;
    }
  }
}
