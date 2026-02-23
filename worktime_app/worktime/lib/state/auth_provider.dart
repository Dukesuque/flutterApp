import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Auth Provider
/// Gestiona el estado de autenticación de la aplicación
/// Maneja login, logout y el usuario actual
class AuthProvider extends ChangeNotifier {
  // ============================================
  // PROPIEDADES PRIVADAS
  // ============================================
  
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ============================================
  // GETTERS PÚBLICOS
  // ============================================
  
  /// Usuario actualmente autenticado (puede ser null)
  UserModel? get currentUser => _currentUser;
  
  /// ¿El usuario está autenticado?
  bool get isAuthenticated => _isAuthenticated;
  
  /// ¿Está cargando alguna operación?
  bool get isLoading => _isLoading;
  
  /// Mensaje de error (si existe)
  String? get errorMessage => _errorMessage;
  
  /// Obtener el nombre del usuario o "Usuario" por defecto
  String get userName => _currentUser?.name ?? 'Usuario';

  // ============================================
  // MÉTODOS DE AUTENTICACIÓN
  // ============================================

  /// Iniciar sesión
  /// Simula una llamada a API
  Future<bool> login(String email, String password) async {
    try {
      // Indicar que está cargando
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simular llamada a API (2 segundos)
      await Future.delayed(const Duration(seconds: 2));

      // Validación básica (en producción esto se hace en el backend)
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Por favor, completa todos los campos';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Simular usuario autenticado
      // En producción, esto vendría del backend
      _currentUser = UserModel(
        id: '1',
        name: 'Juan Pérez',
        email: email,
        position: 'Desarrollador Flutter',
        age: 28,
        phone: '+34 600 123 456',
        department: 'Tecnología',
        startDate: DateTime(2023, 1, 15),
      );

      _isAuthenticated = true;
      _isLoading = false;
      
      // Notificar a todos los widgets que escuchan
      notifyListeners();
      
      return true;
    } catch (e) {
      // Manejar errores
      _errorMessage = 'Error al iniciar sesión: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simular llamada a API
      await Future.delayed(const Duration(milliseconds: 500));

      // Limpiar datos del usuario
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verificar si hay una sesión activa
  /// Útil para auto-login al abrir la app
  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simular verificación de token guardado
      await Future.delayed(const Duration(seconds: 1));

      // Por ahora, siempre retorna no autenticado
      // En producción, aquí verificarías un token guardado
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al verificar sesión: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualizar información del usuario
  void updateUser(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Debug: Imprimir estado actual
  void debugPrintState() {
    debugPrint('=== AUTH STATE ===');
    debugPrint('isAuthenticated: $_isAuthenticated');
    debugPrint('currentUser: ${_currentUser?.name ?? "null"}');
    debugPrint('isLoading: $_isLoading');
    debugPrint('errorMessage: $_errorMessage');
    debugPrint('==================');
  }
}