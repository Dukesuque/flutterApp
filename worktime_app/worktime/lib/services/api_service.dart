/// Servicio de API
/// Preparado para futuras llamadas a API REST
/// Actualmente usa datos mock
class ApiService {
  // Base URL (placeholder para futuro)
  static const String baseUrl = 'https://api.worktime.com';

  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Login de usuario
  /// TODO: Implementar llamada real a API
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock response
    return {
      'success': true,
      'token': 'mock_token_123456',
      'user': {
        'id': '1',
        'email': email,
        'name': 'Usuario Demo',
      },
    };
  }

  /// Obtener perfil de usuario
  /// TODO: Implementar llamada real a API
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'success': true,
      'user': {
        'id': userId,
        'name': 'Juan Pérez',
        'email': 'juan.perez@worktime.com',
        'position': 'Desarrollador Senior',
        'age': 32,
      },
    };
  }

  /// Registrar entrada/salida
  /// TODO: Implementar llamada real a API
  Future<Map<String, dynamic>> clockInOut(String userId, String type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'success': true,
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
    };
  }

  /// Obtener actividades del día
  /// TODO: Implementar llamada real a API
  Future<List<Map<String, dynamic>>> getActivities(String userId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      {
        'id': '1',
        'type': 'clock_in',
        'time': '09:00',
        'description': 'Entrada',
      },
      {
        'id': '2',
        'type': 'break_start',
        'time': '11:30',
        'description': 'Inicio pausa',
      },
    ];
  }

  /// Obtener resumen mensual
  /// TODO: Implementar llamada real a API
  Future<Map<String, dynamic>> getMonthlySummary(String userId, int month, int year) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'success': true,
      'month': month,
      'year': year,
      'totalHours': 160.5,
      'expectedHours': 160.0,
      'extraHours': 0.5,
      'pendingHours': 0.0,
    };
  }
}
