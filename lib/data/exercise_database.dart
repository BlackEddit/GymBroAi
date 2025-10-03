import '../models/exercise.dart';

// Biblioteca completa de ejercicios predefinidos
class ExerciseDatabase {
  static List<Exercise> getAllExercises() {
    return [
      // PECHO
      Exercise.withId(
        name: 'Press de Banca',
        description: '''
1. Acuéstate en el banco con los pies firmes en el suelo
2. Agarra la barra con las manos separadas al ancho de los hombros
3. Baja la barra hasta tocar el pecho controladamente
4. Empuja hacia arriba hasta extender completamente los brazos
5. Mantén la espalda pegada al banco durante todo el movimiento
        ''',
        sets: 4,
        reps: 8,
        restTime: 90,
        muscleGroups: ['Pecho', 'Tríceps', 'Hombros'],
        equipment: 'Barra y banco',
        difficulty: 'Intermedio',
        imageUrl: 'assets/images/exercises/press_banca.gif',
      ),
      
      Exercise.withId(
        name: 'Flexiones de Pecho',
        description: '''
1. Colócate en posición de plancha con brazos extendidos
2. Manos separadas al ancho de los hombros
3. Baja el cuerpo hasta casi tocar el suelo
4. Empuja hacia arriba hasta la posición inicial
5. Mantén el core activado y el cuerpo recto
        ''',
        sets: 3,
        reps: 15,
        restTime: 60,
        muscleGroups: ['Pecho', 'Tríceps', 'Core'],
        equipment: 'Peso corporal',
        difficulty: 'Principiante',
        imageUrl: 'assets/images/exercises/flexiones.gif',
      ),

      Exercise.withId(
        name: 'Press con Mancuernas',
        description: '''
1. Acuéstate en banco con mancuernas en cada mano
2. Posiciona las mancuernas a la altura del pecho
3. Empuja ambas mancuernas hacia arriba simultáneamente
4. Baja controladamente hasta sentir estiramiento en el pecho
5. Mantén los codos a 45° del cuerpo
        ''',
        sets: 4,
        reps: 10,
        restTime: 75,
        muscleGroups: ['Pecho', 'Tríceps'],
        equipment: 'Mancuernas y banco',
        difficulty: 'Intermedio',
        imageUrl: 'assets/images/exercises/press_mancuernas.gif',
      ),

      // ESPALDA
      Exercise.withId(
        name: 'Dominadas',
        description: '''
1. Cuelga de la barra con agarre prono, manos al ancho de hombros
2. Cruza las piernas y mantén el core activado
3. Tira hacia arriba hasta que la barbilla pase la barra
4. Baja controladamente hasta extensión completa
5. Evita el balanceo del cuerpo
        ''',
        sets: 3,
        reps: 8,
        restTime: 120,
        muscleGroups: ['Espalda', 'Bíceps'],
        equipment: 'Barra de dominadas',
        difficulty: 'Avanzado',
        imageUrl: 'assets/images/exercises/dominadas.gif',
      ),

      Exercise.withId(
        name: 'Remo con Mancuerna',
        description: '''
1. Apoya rodilla y mano en el banco
2. Toma la mancuerna con la mano libre
3. Tira del codo hacia atrás y arriba
4. Contrae el omóplato en la parte superior
5. Baja controladamente hasta extensión
        ''',
        sets: 4,
        reps: 12,
        restTime: 60,
        muscleGroups: ['Espalda', 'Bíceps'],
        equipment: 'Mancuerna y banco',
        difficulty: 'Intermedio',
        imageUrl: 'assets/images/exercises/remo_mancuerna.gif',
      ),

      // PIERNAS
      Exercise.withId(
        name: 'Sentadillas',
        description: '''
1. Pies separados al ancho de hombros
2. Baja como si fueras a sentarte en una silla
3. Mantén el peso en los talones
4. Baja hasta que muslos estén paralelos al suelo
5. Empuja con fuerza para subir
        ''',
        sets: 4,
        reps: 15,
        restTime: 90,
        muscleGroups: ['Cuádriceps', 'Glúteos', 'Core'],
        equipment: 'Peso corporal',
        difficulty: 'Principiante',
        imageUrl: 'assets/images/exercises/sentadillas.gif',
      ),

      Exercise.withId(
        name: 'Peso Muerto',
        description: '''
1. Pies al ancho de caderas, barra sobre medios pies
2. Agarra la barra con manos al ancho de hombros
3. Mantén espalda recta y pecho hacia arriba
4. Levanta empujando con piernas y caderas
5. Termina de pie con hombros hacia atrás
        ''',
        sets: 4,
        reps: 6,
        restTime: 120,
        muscleGroups: ['Espalda', 'Glúteos', 'Isquiotibiales'],
        equipment: 'Barra con discos',
        difficulty: 'Avanzado',
        imageUrl: 'assets/images/exercises/peso_muerto.gif',
      ),

      // HOMBROS
      Exercise.withId(
        name: 'Press de Hombros',
        description: '''
1. De pie con mancuernas a la altura de los hombros
2. Palmas mirando hacia adelante
3. Empuja las mancuernas hacia arriba
4. Extiende completamente sin bloquear codos
5. Baja controladamente a posición inicial
        ''',
        sets: 3,
        reps: 12,
        restTime: 75,
        muscleGroups: ['Hombros', 'Tríceps'],
        equipment: 'Mancuernas',
        difficulty: 'Intermedio',
        imageUrl: 'assets/images/exercises/press_hombros.gif',
      ),

      // BRAZOS
      Exercise.withId(
        name: 'Curl de Bíceps',
        description: '''
1. De pie con mancuernas en cada mano
2. Brazos extendidos a los lados del cuerpo
3. Flexiona un brazo llevando la mancuerna al hombro
4. Contrae el bíceps en la parte superior
5. Baja controladamente y repite con el otro brazo
        ''',
        sets: 3,
        reps: 15,
        restTime: 60,
        muscleGroups: ['Bíceps'],
        equipment: 'Mancuernas',
        difficulty: 'Principiante',
        imageUrl: 'assets/images/exercises/curl_biceps.gif',
      ),

      Exercise.withId(
        name: 'Fondos en Paralelas',
        description: '''
1. Sujétate en las barras paralelas con brazos extendidos
2. Inclínate ligeramente hacia adelante
3. Baja doblando los codos hasta 90°
4. Empuja hacia arriba hasta posición inicial
5. Mantén el core activado durante todo el movimiento
        ''',
        sets: 3,
        reps: 10,
        restTime: 90,
        muscleGroups: ['Tríceps', 'Pecho'],
        equipment: 'Barras paralelas',
        difficulty: 'Intermedio',
        imageUrl: 'assets/images/exercises/fondos.gif',
      ),
    ];
  }

  static List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return getAllExercises()
        .where((exercise) => exercise.muscleGroups.contains(muscleGroup))
        .toList();
  }

  static List<Exercise> getExercisesByEquipment(String equipment) {
    return getAllExercises()
        .where((exercise) => exercise.equipment.toLowerCase().contains(equipment.toLowerCase()))
        .toList();
  }

  static List<Exercise> getExercisesByDifficulty(String difficulty) {
    return getAllExercises()
        .where((exercise) => exercise.difficulty == difficulty)
        .toList();
  }
}

// Agregar campos al modelo Exercise
extension ExerciseExtended on Exercise {
  String get equipment => 'Peso corporal'; // Default, se sobrescribe
  String get difficulty => 'Intermedio'; // Default, se sobrescribe
}