import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Servicio de autenticación con Firebase
/// Maneja login, logout, registro y verificación de sesión
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Usuario actual de Firebase
  User? get currentUser => _auth.currentUser;

  /// Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login con email y contraseña
  /// Retorna UserModel si el login es exitoso, null si falla
  Future<UserModel?> login(String email, String password) async {
    try {
      // Intentar login con Firebase
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si el login es exitoso, crear UserModel
      if (credential.user != null) {
        return UserModel(
          id: credential.user!.uid,
          name: credential.user!.displayName ?? 'Usuario',
          email: credential.user!.email ?? email,
          position: 'Empleado',
          age: 30, // Valor por defecto, luego se puede obtener de Firestore
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  /// Registro de nuevo usuario
  Future<UserModel?> register(String email, String password, String name) async {
    try {
      // Crear usuario en Firebase
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar el nombre del usuario
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        
        return UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          position: 'Empleado',
          age: 30, // Valor por defecto
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión: $e';
    }
  }

  /// Verificar si hay sesión activa
  Future<UserModel?> checkCurrentUser() async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        return UserModel(
          id: user.uid,
          name: user.displayName ?? 'Usuario',
          email: user.email ?? '',
          position: 'Empleado',
          age: 30, // Valor por defecto
        );
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error al enviar email: $e';
    }
  }

  /// Manejar excepciones de Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}