import 'package:flutter/foundation.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';

class ActivityProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;
  ActivityType? _filterType;
  String? _userId;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ActivityType? get filterType => _filterType;

  List<ActivityModel> get filteredActivities {
    if (_filterType == null) return _activities;
    return _activities.where((a) => a.type == _filterType).toList();
  }

  List<ActivityModel> get todayActivities {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _activities.where((a) {
      final activityDate = DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day);
      return activityDate == today;
    }).toList();
  }

  ActivityModel? get lastActivity => _activities.isEmpty ? null : _activities.first;

  Future<void> loadActivities(String userId) async {
    _userId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _firestoreService.getActivities(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addActivity(ActivityModel activity) async {
    if (_userId == null) return false;

    try {
      await _firestoreService.saveActivity(_userId!, activity);
      _activities.add(activity);
      _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilter(ActivityType? type) {
    _filterType = type;
    notifyListeners();
  }

  void clearFilter() {
    _filterType = null;
    notifyListeners();
  }

}
