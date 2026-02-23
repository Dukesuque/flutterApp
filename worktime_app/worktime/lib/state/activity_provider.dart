import 'package:flutter/foundation.dart';
import '../models/activity_model.dart';

/// Activity Provider
/// Gestiona el estado de las actividades del usuario
/// Maneja la lista de actividades, filtros y operaciones CRUD
class ActivityProvider extends ChangeNotifier {
  // ============================================
  // PROPIEDADES PRIVADAS
  // ============================================
  
  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;
  ActivityType? _filterType; // Filtro por tipo de actividad

  // ============================================
  // GETTERS PÚBLICOS
  // ============================================
  
  /// Lista de todas las actividades
  List<ActivityModel> get activities => _activities;
  
  /// Lista de actividades filtradas
  List<ActivityModel> get filteredActivities {
    if (_filterType == null) {
      return _activities;
    }
    return _activities.where((a) => a.type == _filterType).toList();
  }
  
  /// ¿Está cargando?
  bool get isLoading => _isLoading;
  
  /// Mensaje de error
  String? get errorMessage => _errorMessage;
  
  /// Filtro actual
  ActivityType? get filterType => _filterType;
  
  /// Total de actividades
  int get totalActivities => _activities.length;
  
  /// Actividades de hoy
  List<ActivityModel> get todayActivities {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _activities.where((activity) {
      final activityDate = DateTime(
        activity.timestamp.year,
        activity.timestamp.month,
        activity.timestamp.day,
      );
      return activityDate == today;
    }).toList();
  }
  
  /// Última actividad
  ActivityModel? get lastActivity {
    if (_activities.isEmpty) return null;
    return _activities.first;
  }

  // ============================================
  // MÉTODOS CRUD
  // ============================================

  /// Cargar actividades desde el servidor
  Future<void> loadActivities(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 1));

      // Datos de ejemplo (en producción vendrían del backend)
      _activities = _generateMockActivities(userId);
      
      // Ordenar por fecha (más reciente primero)
      _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar actividades: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Añadir una nueva actividad
  Future<bool> addActivity(ActivityModel activity) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simular llamada a API
      await Future.delayed(const Duration(milliseconds: 500));

      // Añadir al inicio de la lista
      _activities.insert(0, activity);

      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = 'Error al añadir actividad: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualizar una actividad existente
  Future<bool> updateActivity(ActivityModel updatedActivity) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simular llamada a API
      await Future.delayed(const Duration(milliseconds: 500));

      // Buscar y actualizar
      final index = _activities.indexWhere((a) => a.id == updatedActivity.id);
      if (index != -1) {
        _activities[index] = updatedActivity;
      }

      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar actividad: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Eliminar una actividad
  Future<bool> deleteActivity(String activityId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simular llamada a API
      await Future.delayed(const Duration(milliseconds: 500));

      // Eliminar de la lista
      _activities.removeWhere((a) => a.id == activityId);

      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar actividad: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // FILTROS
  // ============================================

  /// Aplicar filtro por tipo de actividad
  void setFilter(ActivityType? type) {
    _filterType = type;
    notifyListeners();
  }

  /// Limpiar filtro
  void clearFilter() {
    _filterType = null;
    notifyListeners();
  }

  // ============================================
  // UTILIDADES
  // ============================================

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar todas las actividades
  void clear() {
    _activities = [];
    _filterType = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Generar actividades de ejemplo
  List<ActivityModel> _generateMockActivities(String userId) {
    final now = DateTime.now();
    
    return [
      // Hoy
      ActivityModel(
        id: '1',
        userId: userId,
        type: ActivityType.clockIn,
        timestamp: DateTime(now.year, now.month, now.day, 9, 0),
        description: 'Entrada al trabajo',
        location: 'Oficina Central',
      ),
      ActivityModel(
        id: '2',
        userId: userId,
        type: ActivityType.breakStart,
        timestamp: DateTime(now.year, now.month, now.day, 11, 30),
        description: 'Inicio de pausa - Café',
      ),
      ActivityModel(
        id: '3',
        userId: userId,
        type: ActivityType.breakEnd,
        timestamp: DateTime(now.year, now.month, now.day, 11, 45),
        description: 'Fin de pausa',
      ),
      ActivityModel(
        id: '4',
        userId: userId,
        type: ActivityType.breakStart,
        timestamp: DateTime(now.year, now.month, now.day, 14, 0),
        description: 'Inicio de pausa - Almuerzo',
      ),
      ActivityModel(
        id: '5',
        userId: userId,
        type: ActivityType.breakEnd,
        timestamp: DateTime(now.year, now.month, now.day, 15, 0),
        description: 'Fin de pausa',
      ),
      ActivityModel(
        id: '6',
        userId: userId,
        type: ActivityType.clockOut,
        timestamp: DateTime(now.year, now.month, now.day, 18, 0),
        description: 'Salida del trabajo',
        location: 'Oficina Central',
      ),
      
      // Ayer
      ActivityModel(
        id: '7',
        userId: userId,
        type: ActivityType.clockIn,
        timestamp: DateTime(now.year, now.month, now.day - 1, 9, 15),
        description: 'Entrada al trabajo',
        location: 'Oficina Central',
      ),
      ActivityModel(
        id: '8',
        userId: userId,
        type: ActivityType.meeting,
        timestamp: DateTime(now.year, now.month, now.day - 1, 10, 0),
        description: 'Reunión de equipo',
        notes: 'Sprint planning',
      ),
      ActivityModel(
        id: '9',
        userId: userId,
        type: ActivityType.clockOut,
        timestamp: DateTime(now.year, now.month, now.day - 1, 17, 30),
        description: 'Salida del trabajo',
      ),
      
      // Hace 2 días
      ActivityModel(
        id: '10',
        userId: userId,
        type: ActivityType.clockIn,
        timestamp: DateTime(now.year, now.month, now.day - 2, 9, 0),
        description: 'Entrada al trabajo',
      ),
      ActivityModel(
        id: '11',
        userId: userId,
        type: ActivityType.clockOut,
        timestamp: DateTime(now.year, now.month, now.day - 2, 18, 15),
        description: 'Salida del trabajo',
      ),
    ];
  }

  /// Debug: Imprimir estado actual
  void debugPrintState() {
    debugPrint('=== ACTIVITY STATE ===');
    debugPrint('Total activities: ${_activities.length}');
    debugPrint('Today activities: ${todayActivities.length}');
    debugPrint('Filter: ${_filterType?.displayName ?? "none"}');
    debugPrint('isLoading: $_isLoading');
    debugPrint('errorMessage: $_errorMessage');
    debugPrint('======================');
  }
}