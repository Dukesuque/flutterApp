import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';

/// Servicio de Firestore para gestión de datos en la nube
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================
  // GESTIÓN DE USUARIOS
  // ============================================

  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('profile')
          .doc('data')
          .set(user.toJson());
    } catch (e) {
      throw 'Error al guardar perfil: $e';
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data')
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Error al cargar perfil: $e';
    }
  }

  // ============================================
  // GESTIÓN DE ACTIVIDADES
  // ============================================

  Future<void> saveActivity(String userId, ActivityModel activity) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activity.id)
          .set(activity.toJson());
    } catch (e) {
      throw 'Error al guardar actividad: $e';
    }
  }

  Future<List<ActivityModel>> getActivities(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ActivityModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Error al cargar actividades: $e';
    }
  }

  Future<void> deleteActivity(String userId, String activityId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activityId)
          .delete();
    } catch (e) {
      throw 'Error al eliminar actividad: $e';
    }
  }

  // ============================================
  // GESTIÓN DE SESIONES (CONTADOR)
  // ============================================

  Future<void> saveActiveSession({
    required String userId,
    required String sessionId,
    required DateTime startTime,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .doc('active')
          .set({
        'sessionId': sessionId,
        'startTime': Timestamp.fromDate(startTime),
        'isActive': true,
      });
    } catch (e) {
      throw 'Error al guardar sesión: $e';
    }
  }

  Future<void> endActiveSession({
    required String userId,
    required DateTime endTime,
    required int durationSeconds,
  }) async {
    try {
      final activeDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .doc('active')
          .get();

      if (activeDoc.exists && activeDoc.data() != null) {
        final sessionId = activeDoc.data()!['sessionId'] as String;
        final startTime = (activeDoc.data()!['startTime'] as Timestamp).toDate();

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .doc(sessionId)
            .set({
          'startTime': Timestamp.fromDate(startTime),
          'endTime': Timestamp.fromDate(endTime),
          'durationSeconds': durationSeconds,
          'isActive': false,
        });

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .doc('active')
            .delete();
      }
    } catch (e) {
      throw 'Error al finalizar sesión: $e';
    }
  }

  Future<Map<String, dynamic>?> getActiveSession(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .doc('active')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'sessionId': data['sessionId'] as String,
          'startTime': (data['startTime'] as Timestamp).toDate(),
          'isActive': data['isActive'] as bool,
        };
      }
      return null;
    } catch (e) {
      throw 'Error al obtener sesión activa: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getSessionHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sessions')
          .where('isActive', isEqualTo: false)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'sessionId': doc.id,
          'startTime': (data['startTime'] as Timestamp).toDate(),
          'endTime': (data['endTime'] as Timestamp).toDate(),
          'durationSeconds': data['durationSeconds'] as int,
        };
      }).toList();
    } catch (e) {
      throw 'Error al obtener historial: $e';
    }
  }
}