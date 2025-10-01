import 'exercise.dart';

class Workout {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final int? estimatedDurationMinutes;
  final List<String>? tags;

  const Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.estimatedDurationMinutes,
    this.tags,
  });

  // Named constructor for creating new workout
  Workout.create({
    required this.name,
    required this.description,
    required this.exercises,
    this.isFavorite = false,
    this.estimatedDurationMinutes,
    this.tags,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      exercises: [], // Will be loaded separately
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isFavorite: (map['is_favorite'] as int) == 1,
      estimatedDurationMinutes: map['estimated_duration_minutes'] as int?,
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'tags': tags?.join(','),
    };
  }

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    List<Exercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    int? estimatedDurationMinutes,
    List<String>? tags,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      tags: tags ?? this.tags,
    );
  }

  // Helper getters
  int get totalExercises => exercises.length;

  int get totalSets => exercises.fold(0, (sum, exercise) => sum + exercise.sets);

  int get calculatedDurationMinutes {
    if (estimatedDurationMinutes != null) return estimatedDurationMinutes!;
    
    // Calculate based on exercises and rest times
    int totalTime = 0;
    for (final exercise in exercises) {
      // Assume 30 seconds per set + rest time
      totalTime += (exercise.sets * 30) + (exercise.sets - 1) * exercise.restTime;
    }
    return (totalTime / 60).ceil();
  }

  List<String> get uniqueMuscleGroups {
    final Set<String> muscles = {};
    for (final exercise in exercises) {
      muscles.addAll(exercise.muscleGroups);
    }
    return muscles.toList()..sort();
  }

  String get muscleGroupsText => uniqueMuscleGroups.join(', ');

  String get durationText {
    final duration = calculatedDurationMinutes;
    if (duration < 60) {
      return '${duration}min';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      return '${hours}h ${minutes}min';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workout && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Workout{id: $id, name: $name, exercises: ${exercises.length}}';
  }
}