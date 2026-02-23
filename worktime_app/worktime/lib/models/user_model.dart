/// Modelo de Usuario
/// Representa los datos de un usuario de la aplicación
class UserModel {
  final String id;
  final String name;
  final String email;
  final String position;
  final int age;
  final String? avatarUrl;
  final String? phone;
  final String? department;
  final DateTime? startDate;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.age,
    this.avatarUrl,
    this.phone,
    this.department,
    this.startDate,
  });

  /// Crear desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      position: json['position'] as String,
      age: json['age'] as int,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      department: json['department'] as String?,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String)
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'position': position,
      'age': age,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'department': department,
      'startDate': startDate?.toIso8601String(),
    };
  }

  /// Copiar con modificaciones
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? position,
    int? age,
    String? avatarUrl,
    String? phone,
    String? department,
    DateTime? startDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      position: position ?? this.position,
      age: age ?? this.age,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      startDate: startDate ?? this.startDate,
    );
  }
}
