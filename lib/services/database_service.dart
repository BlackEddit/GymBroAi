import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/equipment.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gym_ai.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Equipment table
    await db.execute('''
      CREATE TABLE equipment (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        confidence REAL NOT NULL,
        bounding_box_left REAL NOT NULL,
        bounding_box_top REAL NOT NULL,
        bounding_box_right REAL NOT NULL,
        bounding_box_bottom REAL NOT NULL,
        detected_at INTEGER NOT NULL,
        gym_location TEXT
      )
    ''');

    // Exercises table
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        sets INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        rest_time INTEGER NOT NULL,
        muscle_groups TEXT NOT NULL,
        equipment_id TEXT,
        FOREIGN KEY (equipment_id) REFERENCES equipment (id)
      )
    ''');

    // Workouts table
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Workout exercises junction table
    await db.execute('''
      CREATE TABLE workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id),
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    // Workout sessions table
    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        workout_id TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        completed_at INTEGER,
        duration_minutes INTEGER,
        notes TEXT,
        FOREIGN KEY (workout_id) REFERENCES workouts (id)
      )
    ''');

    // Exercise sets table
    await db.execute('''
      CREATE TABLE exercise_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        set_number INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL,
        rest_time INTEGER,
        completed_at INTEGER,
        FOREIGN KEY (session_id) REFERENCES workout_sessions (id),
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    // User progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL,
        weight REAL,
        body_fat_percentage REAL,
        muscle_mass REAL,
        notes TEXT
      )
    ''');

    // Gym mapping table
    await db.execute('''
      CREATE TABLE gym_mapping (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipment_id TEXT NOT NULL,
        x_coordinate REAL NOT NULL,
        y_coordinate REAL NOT NULL,
        floor_level INTEGER DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (equipment_id) REFERENCES equipment (id)
      )
    ''');
  }

  // Equipment operations
  Future<String> insertEquipment(Equipment equipment) async {
    final db = await instance.database;
    
    await db.insert('equipment', {
      'id': equipment.id,
      'name': equipment.name,
      'category': equipment.category,
      'confidence': equipment.confidence,
      'bounding_box_left': equipment.boundingBox.left,
      'bounding_box_top': equipment.boundingBox.top,
      'bounding_box_right': equipment.boundingBox.right,
      'bounding_box_bottom': equipment.boundingBox.bottom,
      'detected_at': equipment.detectedAt.millisecondsSinceEpoch,
      'gym_location': equipment.gymLocation,
    });

    // Insert suggested exercises
    for (final exercise in equipment.suggestedExercises) {
      await insertExercise(exercise, equipment.id);
    }

    return equipment.id;
  }

  Future<List<Equipment>> getRecentEquipment({int limit = 10}) async {
    final db = await instance.database;
    
    final maps = await db.query(
      'equipment',
      orderBy: 'detected_at DESC',
      limit: limit,
    );

    return maps.map((map) => Equipment.fromMap(map)).toList();
  }

  // Exercise operations
  Future<String> insertExercise(Exercise exercise, [String? equipmentId]) async {
    final db = await instance.database;
    
    await db.insert('exercises', {
      'id': exercise.id,
      'name': exercise.name,
      'description': exercise.description,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'rest_time': exercise.restTime,
      'muscle_groups': exercise.muscleGroups.join(','),
      'equipment_id': equipmentId,
    });

    return exercise.id;
  }

  // Workout operations
  Future<String> insertWorkout(Workout workout) async {
    final db = await instance.database;
    
    await db.insert('workouts', {
      'id': workout.id,
      'name': workout.name,
      'description': workout.description,
      'created_at': workout.createdAt.millisecondsSinceEpoch,
      'updated_at': workout.updatedAt.millisecondsSinceEpoch,
      'is_favorite': workout.isFavorite ? 1 : 0,
    });

    // Insert workout exercises
    for (int i = 0; i < workout.exercises.length; i++) {
      await db.insert('workout_exercises', {
        'workout_id': workout.id,
        'exercise_id': workout.exercises[i].id,
        'order_index': i,
      });
    }

    return workout.id;
  }

  Future<List<Workout>> getAllWorkouts() async {
    final db = await instance.database;
    
    final maps = await db.query(
      'workouts',
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  // Workout session operations
  Future<String> startWorkoutSession(WorkoutSession session) async {
    final db = await instance.database;
    
    await db.insert('workout_sessions', {
      'id': session.id,
      'workout_id': session.workoutId,
      'started_at': session.startedAt.millisecondsSinceEpoch,
      'notes': session.notes,
    });

    return session.id;
  }

  Future<void> completeWorkoutSession(
    String sessionId,
    DateTime completedAt,
    int durationMinutes,
  ) async {
    final db = await instance.database;
    
    await db.update(
      'workout_sessions',
      {
        'completed_at': completedAt.millisecondsSinceEpoch,
        'duration_minutes': durationMinutes,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Progress operations
  Future<void> insertProgressEntry({
    required DateTime date,
    double? weight,
    double? bodyFatPercentage,
    double? muscleMass,
    String? notes,
  }) async {
    final db = await instance.database;
    
    await db.insert('user_progress', {
      'date': date.millisecondsSinceEpoch,
      'weight': weight,
      'body_fat_percentage': bodyFatPercentage,
      'muscle_mass': muscleMass,
      'notes': notes,
    });
  }

  // Statistics operations
  Future<Map<String, dynamic>> getWorkoutStats() async {
    final db = await instance.database;
    
    // Total workouts
    final totalWorkouts = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_sessions WHERE completed_at IS NOT NULL'
    );
    
    // Total time
    final totalTime = await db.rawQuery(
      'SELECT SUM(duration_minutes) as total FROM workout_sessions WHERE completed_at IS NOT NULL'
    );
    
    // This week's workouts
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMs = DateTime(weekStart.year, weekStart.month, weekStart.day).millisecondsSinceEpoch;
    
    final thisWeekWorkouts = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_sessions WHERE completed_at >= ? AND completed_at IS NOT NULL',
      [weekStartMs],
    );
    
    return {
      'totalWorkouts': totalWorkouts.first['count'] ?? 0,
      'totalTimeMinutes': totalTime.first['total'] ?? 0,
      'thisWeekWorkouts': thisWeekWorkouts.first['count'] ?? 0,
    };
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}