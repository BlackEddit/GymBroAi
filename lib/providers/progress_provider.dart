import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class ProgressProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  Map<String, dynamic> _workoutStats = {};
  List<ProgressEntry> _progressEntries = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic> get workoutStats => _workoutStats;
  List<ProgressEntry> get progressEntries => _progressEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Quick stats getters
  int get totalWorkouts => _workoutStats['totalWorkouts'] ?? 0;
  int get totalTimeMinutes => _workoutStats['totalTimeMinutes'] ?? 0;
  int get thisWeekWorkouts => _workoutStats['thisWeekWorkouts'] ?? 0;
  
  String get totalTimeFormatted {
    if (totalTimeMinutes < 60) {
      return '${totalTimeMinutes}min';
    }
    final hours = totalTimeMinutes ~/ 60;
    final minutes = totalTimeMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  ProgressProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadWorkoutStats();
    await loadProgressEntries();
  }

  // Workout statistics
  Future<void> loadWorkoutStats() async {
    try {
      _setLoading(true);
      _workoutStats = await _db.getWorkoutStats();
      _clearError();
    } catch (e) {
      _setError('Error loading workout stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Progress tracking
  Future<void> loadProgressEntries() async {
    try {
      // TODO: Implement getProgressEntries in database service
      _progressEntries = [];
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error loading progress entries: $e');
    }
  }

  Future<void> addProgressEntry({
    required DateTime date,
    double? weight,
    double? bodyFatPercentage,
    double? muscleMass,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      
      await _db.insertProgressEntry(
        date: date,
        weight: weight,
        bodyFatPercentage: bodyFatPercentage,
        muscleMass: muscleMass,
        notes: notes,
      );

      // Add to local list
      _progressEntries.add(ProgressEntry(
        date: date,
        weight: weight,
        bodyFatPercentage: bodyFatPercentage,
        muscleMass: muscleMass,
        notes: notes,
      ));

      // Sort by date (newest first)
      _progressEntries.sort((a, b) => b.date.compareTo(a.date));
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error adding progress entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Analytics and insights
  double? get currentWeight {
    final weightEntries = _progressEntries
        .where((entry) => entry.weight != null)
        .toList();
    return weightEntries.isNotEmpty ? weightEntries.first.weight : null;
  }

  double? get weightChange {
    final weightEntries = _progressEntries
        .where((entry) => entry.weight != null)
        .toList();
    
    if (weightEntries.length < 2) return null;
    
    return weightEntries.first.weight! - weightEntries[1].weight!;
  }

  Map<String, int> getWorkoutsByWeek() {
    // TODO: Implement weekly workout breakdown
    return {
      'Lun': 0,
      'Mar': 0,
      'Mié': 0,
      'Jue': 0,
      'Vie': 0,
      'Sáb': 0,
      'Dom': 0,
    };
  }

  List<ChartData> getWeightTrend({int days = 30}) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    final recentEntries = _progressEntries
        .where((entry) => 
            entry.weight != null && 
            entry.date.isAfter(cutoffDate))
        .toList();
    
    // Sort by date (oldest first for chart)
    recentEntries.sort((a, b) => a.date.compareTo(b.date));
    
    return recentEntries.map((entry) => ChartData(
      date: entry.date,
      value: entry.weight!,
    )).toList();
  }

  // Achievements
  List<Achievement> getUnlockedAchievements() {
    final List<Achievement> unlocked = [];
    
    // First scan achievement
    if (_workoutStats['equipmentScanned'] != null && 
        _workoutStats['equipmentScanned'] > 0) {
      unlocked.add(Achievement(
        id: 'first_scan',
        title: 'Primer Escaneo',
        description: 'Detectaste tu primer equipo',
        unlockedAt: DateTime.now(), // TODO: Get actual unlock date
      ));
    }
    
    // First workout achievement
    if (totalWorkouts > 0) {
      unlocked.add(Achievement(
        id: 'first_workout',
        title: 'Primera Rutina',
        description: 'Completaste tu primer entrenamiento',
        unlockedAt: DateTime.now(), // TODO: Get actual unlock date
      ));
    }
    
    return unlocked;
  }

  List<Achievement> getLockedAchievements() {
    final List<Achievement> locked = [];
    
    // Explorer achievement (10 different equipment)
    if ((_workoutStats['uniqueEquipment'] ?? 0) < 10) {
      locked.add(Achievement(
        id: 'explorer',
        title: 'Explorador',
        description: 'Detecta 10 equipos diferentes',
        progress: _workoutStats['uniqueEquipment'] ?? 0,
        target: 10,
      ));
    }
    
    // Consistency achievement (7 days streak)
    if ((_workoutStats['currentStreak'] ?? 0) < 7) {
      locked.add(Achievement(
        id: 'consistent',
        title: 'Constante',
        description: 'Entrena 7 días seguidos',
        progress: _workoutStats['currentStreak'] ?? 0,
        target: 7,
      ));
    }
    
    return locked;
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([
      loadWorkoutStats(),
      loadProgressEntries(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Data models for progress tracking
class ProgressEntry {
  final DateTime date;
  final double? weight;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final String? notes;

  const ProgressEntry({
    required this.date,
    this.weight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.notes,
  });
}

class ChartData {
  final DateTime date;
  final double value;

  const ChartData({
    required this.date,
    required this.value,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime? unlockedAt;
  final int? progress;
  final int? target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.unlockedAt,
    this.progress,
    this.target,
  });

  bool get isUnlocked => unlockedAt != null;
  
  double get progressPercentage {
    if (progress == null || target == null) return 0.0;
    return (progress! / target!).clamp(0.0, 1.0);
  }
}