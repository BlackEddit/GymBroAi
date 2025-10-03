class Exercise {
  final String id;
  final String name;
  final String description;
  final int sets;
  final int reps;
  final int restTime; // in seconds
  final List<String> muscleGroups;
  final String? equipmentId;
  final String? imageUrl;
  final String? videoUrl;
  final String equipment;
  final String difficulty;

  const Exercise({
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.muscleGroups,
    String? id,
    this.equipmentId,
    this.imageUrl,
    this.videoUrl,
    this.equipment = 'Peso corporal',
    this.difficulty = 'Intermedio',
  }) : id = id ?? '';

  // Named constructor for generating ID
  Exercise.withId({
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    required this.restTime,
    required this.muscleGroups,
    this.equipmentId,
    this.imageUrl,
    this.videoUrl,
    this.equipment = 'Peso corporal',
    this.difficulty = 'Intermedio',
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      restTime: map['rest_time'] as int,
      muscleGroups: (map['muscle_groups'] as String).split(','),
      equipmentId: map['equipment_id'] as String?,
      imageUrl: map['image_url'] as String?,
      videoUrl: map['video_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sets': sets,
      'reps': reps,
      'rest_time': restTime,
      'muscle_groups': muscleGroups.join(','),
      'equipment_id': equipmentId,
      'image_url': imageUrl,
      'video_url': videoUrl,
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    int? sets,
    int? reps,
    int? restTime,
    List<String>? muscleGroups,
    String? equipmentId,
    String? imageUrl,
    String? videoUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restTime: restTime ?? this.restTime,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipmentId: equipmentId ?? this.equipmentId,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  // Helper getters
  String get formattedRestTime {
    final minutes = restTime ~/ 60;
    final seconds = restTime % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String get muscleGroupsText => muscleGroups.join(', ');

  String get setsRepsText => '$sets series x $reps reps';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, sets: $sets, reps: $reps, muscleGroups: $muscleGroups}';
  }
}