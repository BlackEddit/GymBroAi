class WorkoutSession {
  final String id;
  final String workoutId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationMinutes;
  final String? notes;
  final List<ExerciseSet> exerciseSets;

  const WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.startedAt,
    this.completedAt,
    this.durationMinutes,
    this.notes,
    this.exerciseSets = const [],
  });

  // Named constructor for starting new session
  WorkoutSession.start({
    required this.workoutId,
    this.notes,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        startedAt = DateTime.now(),
        completedAt = null,
        durationMinutes = null,
        exerciseSets = [];

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      workoutId: map['workout_id'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
      durationMinutes: map['duration_minutes'] as int?,
      notes: map['notes'] as String?,
      exerciseSets: [], // Will be loaded separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'started_at': startedAt.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'duration_minutes': durationMinutes,
      'notes': notes,
    };
  }

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationMinutes,
    String? notes,
    List<ExerciseSet>? exerciseSets,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      exerciseSets: exerciseSets ?? this.exerciseSets,
    );
  }

  // Helper methods
  bool get isCompleted => completedAt != null;
  
  bool get isInProgress => !isCompleted;

  Duration get currentDuration {
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  int get completedSets => exerciseSets.where((set) => set.isCompleted).length;

  int get totalSets => exerciseSets.length;

  double get progressPercentage {
    if (totalSets == 0) return 0.0;
    return completedSets / totalSets;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WorkoutSession{id: $id, workoutId: $workoutId, isCompleted: $isCompleted}';
  }
}

class ExerciseSet {
  final int id;
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final int reps;
  final double? weight;
  final int? restTime;
  final DateTime? completedAt;

  const ExerciseSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    this.weight,
    this.restTime,
    this.completedAt,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] as int,
      sessionId: map['session_id'] as String,
      exerciseId: map['exercise_id'] as String,
      setNumber: map['set_number'] as int,
      reps: map['reps'] as int,
      weight: map['weight'] as double?,
      restTime: map['rest_time'] as int?,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'rest_time': restTime,
      'completed_at': completedAt?.millisecondsSinceEpoch,
    };
  }

  ExerciseSet copyWith({
    int? id,
    String? sessionId,
    String? exerciseId,
    int? setNumber,
    int? reps,
    double? weight,
    int? restTime,
    DateTime? completedAt,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isCompleted => completedAt != null;

  String get weightText {
    if (weight == null) return 'Peso corporal';
    return '${weight!.toStringAsFixed(1)} kg';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseSet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}