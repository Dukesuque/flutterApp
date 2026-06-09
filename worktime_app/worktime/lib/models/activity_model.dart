class ActivityModel {
  final String id;
  final String userId;
  final ActivityType type;
  final DateTime timestamp;
  final String description;
  final String? location;
  final String? notes;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.timestamp,
    required this.description,
    this.location,
    this.notes,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
        orElse: () => ActivityType.clockIn,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'location': location,
      'notes': notes,
    };
  }

  ActivityModel copyWith({
    String? id,
    String? userId,
    ActivityType? type,
    DateTime? timestamp,
    String? description,
    String? location,
    String? notes,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
  }
}

enum ActivityType {
  clockIn,
  clockOut,
  breakStart,
  breakEnd,
  meeting,
  absence,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.clockIn:
        return 'Entrada';
      case ActivityType.clockOut:
        return 'Salida';
      case ActivityType.breakStart:
        return 'Inicio pausa';
      case ActivityType.breakEnd:
        return 'Fin pausa';
      case ActivityType.meeting:
        return 'Reunión';
      case ActivityType.absence:
        return 'Ausencia';
    }
  }

  String get iconName {
    switch (this) {
      case ActivityType.clockIn:
        return 'login';
      case ActivityType.clockOut:
        return 'logout';
      case ActivityType.breakStart:
        return 'pause';
      case ActivityType.breakEnd:
        return 'play';
      case ActivityType.meeting:
        return 'meeting';
      case ActivityType.absence:
        return 'cancel';
    }
  }

  int get colorValue {
    switch (this) {
      case ActivityType.clockIn:
        return 0xFF4CAF50;
      case ActivityType.clockOut:
        return 0xFFFF5252;
      case ActivityType.breakStart:
        return 0xFFFFB300;
      case ActivityType.breakEnd:
        return 0xFF4DA3FF;
      case ActivityType.meeting:
        return 0xFF42A5F5;
      case ActivityType.absence:
        return 0xFF7C7F85;
    }
  }
}
