import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Provider de autenticación con Firebase
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userName => _currentUser?.name ?? 'Usuario';

  AuthProvider() {
    checkAuthStatus();
  }

  /// Login con Firebase
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);

      if (user != null) {
        // Intentar cargar perfil completo desde Firestore
        final fullProfile = await _firestoreService.getUserProfile(user.id);
        
        if (fullProfile != null) {
          _currentUser = fullProfile;
        } else {
          // Si no existe perfil en Firestore, usar datos básicos y guardarlos
          _currentUser = user;
          await _firestoreService.saveUserProfile(user);
        }
        
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Registro de nuevo usuario
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(email, password, name);

      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        
        // Guardar perfil en Firestore
        await _firestoreService.saveUserProfile(user);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error al registrar usuario';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verificar si hay sesión activa
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.checkCurrentUser();

      if (user != null) {
        // Intentar cargar perfil completo desde Firestore
        final fullProfile = await _firestoreService.getUserProfile(user.id);
        
        if (fullProfile != null) {
          _currentUser = fullProfile;
        } else {
          _currentUser = user;
          await _firestoreService.saveUserProfile(user);
        }
        
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualizar datos del usuario
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestoreService.saveUserProfile(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}