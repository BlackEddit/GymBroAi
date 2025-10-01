import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../models/equipment.dart';
import '../models/workout_session.dart';
import '../services/database_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  List<Workout> _workouts = [];
  List<Equipment> _recentEquipment = [];
  WorkoutSession? _currentSession;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Workout> get workouts => _workouts;
  List<Equipment> get recentEquipment => _recentEquipment;
  WorkoutSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSession => _currentSession != null && _currentSession!.isInProgress;

  WorkoutProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadWorkouts();
    await loadRecentEquipment();
  }

  // Workout management
  Future<void> loadWorkouts() async {
    try {
      _setLoading(true);
      _workouts = await _db.getAllWorkouts();
      _clearError();
    } catch (e) {
      _setError('Error loading workouts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createWorkout(Workout workout) async {
    try {
      _setLoading(true);
      await _db.insertWorkout(workout);
      _workouts.add(workout);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error creating workout: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    try {
      _setLoading(true);
      // TODO: Add update method to database service
      final index = _workouts.indexWhere((w) => w.id == workout.id);
      if (index != -1) {
        _workouts[index] = workout;
        notifyListeners();
      }
      _clearError();
    } catch (e) {
      _setError('Error updating workout: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      _setLoading(true);
      // TODO: Add delete method to database service
      _workouts.removeWhere((w) => w.id == workoutId);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error deleting workout: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Equipment management
  Future<void> loadRecentEquipment() async {
    try {
      _recentEquipment = await _db.getRecentEquipment();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent equipment: $e');
    }
  }

  Future<void> saveDetectedEquipment(Equipment equipment) async {
    try {
      await _db.insertEquipment(equipment);
      _recentEquipment.insert(0, equipment);
      
      // Keep only last 20 items
      if (_recentEquipment.length > 20) {
        _recentEquipment = _recentEquipment.take(20).toList();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving detected equipment: $e');
    }
  }

  List<Equipment> getRecentEquipment({int limit = 5}) {
    return _recentEquipment.take(limit).toList();
  }

  // Workout session management
  Future<void> startWorkoutSession(String workoutId, {String? notes}) async {
    try {
      if (hasActiveSession) {
        throw Exception('There is already an active workout session');
      }

      final session = WorkoutSession.start(
        workoutId: workoutId,
        notes: notes,
      );

      await _db.startWorkoutSession(session);
      _currentSession = session;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error starting workout session: $e');
    }
  }

  Future<void> completeWorkoutSession({String? notes}) async {
    try {
      if (_currentSession == null) {
        throw Exception('No active workout session');
      }

      final now = DateTime.now();
      final duration = now.difference(_currentSession!.startedAt).inMinutes;

      await _db.completeWorkoutSession(
        _currentSession!.id,
        now,
        duration,
      );

      _currentSession = _currentSession!.copyWith(
        completedAt: now,
        durationMinutes: duration,
        notes: notes ?? _currentSession!.notes,
      );

      // Clear current session after a delay to show completion
      Future.delayed(const Duration(seconds: 2), () {
        _currentSession = null;
        notifyListeners();
      });

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error completing workout session: $e');
    }
  }

  Future<void> cancelWorkoutSession() async {
    try {
      if (_currentSession == null) {
        throw Exception('No active workout session');
      }

      // TODO: Mark session as cancelled in database
      _currentSession = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error cancelling workout session: $e');
    }
  }

  // Workout generation
  Future<Workout?> generateWorkoutFromEquipment(List<Equipment> equipment) async {
    try {
      if (equipment.isEmpty) return null;

      final exercises = equipment
          .expand((eq) => eq.suggestedExercises)
          .take(6) // Limit to 6 exercises
          .toList();

      if (exercises.isEmpty) return null;

      final workout = Workout.create(
        name: 'Rutina Generada - ${DateTime.now().day}/${DateTime.now().month}',
        description: 'Rutina basada en equipos detectados',
        exercises: exercises,
        tags: ['Generada', 'IA'],
      );

      return workout;
    } catch (e) {
      debugPrint('Error generating workout: $e');
      return null;
    }
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

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}