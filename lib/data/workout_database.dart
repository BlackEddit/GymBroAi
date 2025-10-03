import '../models/workout.dart';
import '../models/exercise.dart';
import 'exercise_database.dart';

class WorkoutDatabase {
  static List<Workout> getPredefinedWorkouts() {
    final exercises = ExerciseDatabase.getAllExercises();
    
    return [
      // RUTINA PRINCIPIANTE - CUERPO COMPLETO
      Workout.create(
        name: '💪 Principiante - Cuerpo Completo',
        description: 'Rutina ideal para comenzar. Trabaja todo el cuerpo con ejercicios básicos.',
        exercises: [
          exercises.firstWhere((e) => e.name == 'Flexiones de Pecho'),
          exercises.firstWhere((e) => e.name == 'Sentadillas'),
          exercises.firstWhere((e) => e.name == 'Curl de Bíceps'),
          _modifyExercise(exercises.firstWhere((e) => e.name == 'Press de Hombros'), sets: 2, reps: 10),
        ],
        estimatedDurationMinutes: 30,
        tags: ['Principiante', 'Cuerpo Completo', 'Casa'],
      ),

      // RUTINA INTERMEDIO - PUSH
      Workout.create(
        name: '🔥 Push - Empuje (Intermedio)',
        description: 'Enfoque en pecho, hombros y tríceps. Perfecta para desarrollar fuerza de empuje.',
        exercises: [
          exercises.firstWhere((e) => e.name == 'Press de Banca'),
          exercises.firstWhere((e) => e.name == 'Press con Mancuernas'),
          exercises.firstWhere((e) => e.name == 'Press de Hombros'),
          exercises.firstWhere((e) => e.name == 'Fondos en Paralelas'),
          _modifyExercise(exercises.firstWhere((e) => e.name == 'Flexiones de Pecho'), sets: 2, reps: 12),
        ],
        estimatedDurationMinutes: 45,
        tags: ['Intermedio', 'Push', 'Pecho', 'Hombros'],
      ),

      // RUTINA INTERMEDIO - PULL  
      Workout.create(
        name: '⬆️ Pull - Tirón (Intermedio)',
        description: 'Trabaja espalda y bíceps. Fortalece toda la cadena posterior.',
        exercises: [
          exercises.firstWhere((e) => e.name == 'Dominadas'),
          exercises.firstWhere((e) => e.name == 'Remo con Mancuerna'),
          _modifyExercise(exercises.firstWhere((e) => e.name == 'Curl de Bíceps'), sets: 4, reps: 12),
          _modifyExercise(exercises.firstWhere((e) => e.name == 'Remo con Mancuerna'), sets: 3, reps: 15, name: 'Remo con Mancuerna (Ligero)'),
        ],
        estimatedDurationMinutes: 40,
        tags: ['Intermedio', 'Pull', 'Espalda', 'Bíceps'],
      ),

      // RUTINA PIERNAS
      Workout.create(
        name: '🦵 Día de Piernas (Intermedio)',
        description: 'Rutina completa para tren inferior. Cuádriceps, glúteos e isquiotibiales.',
        exercises: [
          exercises.firstWhere((e) => e.name == 'Sentadillas'),
          exercises.firstWhere((e) => e.name == 'Peso Muerto'),
          _modifyExercise(exercises.firstWhere((e) => e.name == 'Sentadillas'), sets: 3, reps: 20, name: 'Sentadillas de Resistencia'),
          _createCustomExercise(
            name: 'Zancadas',
            description: '''
1. Da un paso grande hacia adelante
2. Baja hasta que ambas rodillas estén a 90°
3. Empuja con la pierna delantera para volver
4. Alterna las piernas en cada repetición
            ''',
            sets: 3,
            reps: 12,
            restTime: 60,
            muscleGroups: ['Cuádriceps', 'Glúteos'],
          ),
        ],
        estimatedDurationMinutes: 50,
        tags: ['Intermedio', 'Piernas', 'Fuerza'],
      ),

      // RUTINA AVANZADO
      Workout.create(
        name: '🔥 Beast Mode (Avanzado)',
        description: 'Rutina intensa para atletas experimentados. Alta intensidad y volumen.',
        exercises: [
          exercises.firstWhere((e) => e.name == 'Press de Banca'),
          exercises.firstWhere((e) => e.name == 'Peso Muerto'),
          exercises.firstWhere((e) => e.name == 'Dominadas'),
          _modifyExercise(exercises.firstWhere((e) => e.name == 'Press de Hombros'), sets: 5, reps: 8),
          _modifyExercise(exercises.firstWhere((e) => e.name == 'Fondos en Paralelas'), sets: 4, reps: 12),
        ],
        estimatedDurationMinutes: 60,
        tags: ['Avanzado', 'Fuerza', 'Intenso'],
      ),

      // RUTINA CARDIO-FUERZA
      Workout.create(
        name: '❤️ Cardio + Fuerza (30min)',
        description: 'Combina ejercicios de fuerza con cardio. Quema grasa mientras construyes músculo.',
        exercises: [
          _createCustomExercise(
            name: 'Burpees',
            description: '''
1. Desde posición de pie, baja a cuclillas
2. Coloca las manos en el suelo y salta hacia atrás
3. Haz una flexión de pecho
4. Salta hacia adelante y luego hacia arriba
            ''',
            sets: 3,
            reps: 10,
            restTime: 45,
            muscleGroups: ['Cuerpo Completo', 'Cardio'],
          ),
          exercises.firstWhere((e) => e.name == 'Flexiones de Pecho'),
          exercises.firstWhere((e) => e.name == 'Sentadillas'),
          _createCustomExercise(
            name: 'Mountain Climbers',
            description: '''
1. Posición de plancha alta
2. Lleva una rodilla al pecho alternadamente
3. Mantén un ritmo rápido pero controlado
4. Mantén el core activado
            ''',
            sets: 3,
            reps: 20,
            restTime: 30,
            muscleGroups: ['Core', 'Cardio'],
          ),
        ],
        estimatedDurationMinutes: 30,
        tags: ['Cardio', 'HIIT', 'Quemagrasas'],
      ),

      // RUTINA EN CASA
      Workout.create(
        name: '🏠 Entreno en Casa',
        description: 'Sin equipos, sin excusas. Rutina completa usando solo tu peso corporal.',
        exercises: [
          exercises.firstWhere((e) => e.name == 'Flexiones de Pecho'),
          exercises.firstWhere((e) => e.name == 'Sentadillas'),
          _createCustomExercise(
            name: 'Plancha',
            description: '''
1. Posición boca abajo, apóyate en antebrazos y pies
2. Mantén el cuerpo recto como una tabla
3. Contrae abdominales y glúteos
4. Respira normalmente y mantén la posición
            ''',
            sets: 3,
            reps: 45, // segundos
            restTime: 60,
            muscleGroups: ['Core', 'Hombros'],
          ),
          _createCustomExercise(
            name: 'Sentadillas Salto',
            description: '''
1. Haz una sentadilla normal
2. Al subir, explota con un salto hacia arriba
3. Aterriza suavemente en posición de sentadilla
4. Repite inmediatamente
            ''',
            sets: 3,
            reps: 15,
            restTime: 75,
            muscleGroups: ['Piernas', 'Cardio'],
          ),
        ],
        estimatedDurationMinutes: 25,
        tags: ['Casa', 'Sin Equipos', 'Peso Corporal'],
      ),
    ];
  }

  static Exercise _modifyExercise(Exercise original, {
    int? sets,
    int? reps,
    String? name,
    int? restTime,
  }) {
    return Exercise.withId(
      name: name ?? original.name,
      description: original.description,
      sets: sets ?? original.sets,
      reps: reps ?? original.reps,
      restTime: restTime ?? original.restTime,
      muscleGroups: original.muscleGroups,
      equipment: original.equipment,
      difficulty: original.difficulty,
      imageUrl: original.imageUrl,
    );
  }

  static Exercise _createCustomExercise({
    required String name,
    required String description,
    required int sets,
    required int reps,
    required int restTime,
    required List<String> muscleGroups,
    String equipment = 'Peso corporal',
    String difficulty = 'Intermedio',
  }) {
    return Exercise.withId(
      name: name,
      description: description,
      sets: sets,
      reps: reps,
      restTime: restTime,
      muscleGroups: muscleGroups,
      equipment: equipment,
      difficulty: difficulty,
    );
  }

  static List<Workout> getWorkoutsByDifficulty(String difficulty) {
    return getPredefinedWorkouts()
        .where((workout) => workout.tags?.contains(difficulty) == true)
        .toList();
  }

  static List<Workout> getWorkoutsByTag(String tag) {
    return getPredefinedWorkouts()
        .where((workout) => workout.tags?.contains(tag) == true)
        .toList();
  }

  static List<Workout> getWorkoutsByDuration(int maxMinutes) {
    return getPredefinedWorkouts()
        .where((workout) => workout.calculatedDurationMinutes <= maxMinutes)
        .toList();
  }
}