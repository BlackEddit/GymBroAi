import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../data/exercise_database.dart';

class SuperNinjaTimerScreen extends StatefulWidget {
  @override
  _SuperNinjaTimerScreenState createState() => _SuperNinjaTimerScreenState();
}

class _SuperNinjaTimerScreenState extends State<SuperNinjaTimerScreen>
    with TickerProviderStateMixin {
  
  // Controllers y estado
  Timer? _timer;
  int _seconds = 0;
  bool _isActive = false;
  bool _isResting = false;
  
  // Datos de la rutina
  List<WorkoutExercise> _workoutExercises = [];
  List<CompletedSet> _completedSets = [];
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  
  // Estados del workflow
  String _currentPhase = 'setup'; // setup, exercising, resting, complete
  
  // Animaciones
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  // Ejercicios disponibles
  List<Exercise> _availableExercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
  }

  void _loadExercises() async {
    final exercises = await ExerciseDatabase.getAllExercises();
    setState(() {
      _availableExercises = exercises;
    });
  }

  void _addExerciseToWorkout(Exercise exercise) {
    setState(() {
      _workoutExercises.add(WorkoutExercise(
        exercise: exercise,
        sets: 3, // Default
        restBetweenSets: 180, // 3 minutos por defecto
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _workoutExercises.removeAt(index);
      if (_currentExerciseIndex >= _workoutExercises.length && _workoutExercises.isNotEmpty) {
        _currentExerciseIndex = _workoutExercises.length - 1;
      }
    });
  }

  void _startWorkout() {
    if (_workoutExercises.isEmpty) {
      _showSnackBar('¡Agrega al menos un ejercicio! 💪');
      return;
    }
    
    setState(() {
      _currentPhase = 'exercising';
      _currentExerciseIndex = 0;
      _currentSet = 1;
      _completedSets.clear();
    });
  }

  void _startExerciseTimer() {
    setState(() {
      _isActive = true;
      _isResting = false;
      _seconds = 0;
      _currentPhase = 'exercising';
    });
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _completeSet() {
    if (!_isActive) return;
    
    final currentExercise = _workoutExercises[_currentExerciseIndex];
    _timer?.cancel();
    
    // Mostrar dialog para registrar peso y reps
    _showSetCompletionDialog();
  }

  void _showSetCompletionDialog() {
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_workoutExercises[_currentExerciseIndex].exercise.name}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Serie $_currentSet de ${_workoutExercises[_currentExerciseIndex].sets}',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Peso (kg)',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (weightController.text.isNotEmpty && repsController.text.isNotEmpty) {
                _registerCompletedSet(
                  double.parse(weightController.text),
                  int.parse(repsController.text),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Completar Serie'),
          ),
        ],
      ),
    );
  }

  void _registerCompletedSet(double weight, int reps) {
    final currentExercise = _workoutExercises[_currentExerciseIndex];
    
    // Registrar la serie completada
    _completedSets.add(CompletedSet(
      exerciseName: currentExercise.exercise.name,
      setNumber: _currentSet,
      weight: weight,
      reps: reps,
      duration: _seconds,
      timestamp: DateTime.now(),
    ));
    
    HapticFeedback.heavyImpact();
    
    // Verificar si hay más series del mismo ejercicio
    if (_currentSet < currentExercise.sets) {
      // Más series del mismo ejercicio - iniciar descanso
      _startRestTimer();
      _showSnackBar('¡Serie completada! Descanso de ${_formatTime(currentExercise.restBetweenSets)} 😮‍💨');
    } else {
      // Ejercicio completado - pasar al siguiente
      _completeExercise();
    }
  }

  void _startRestTimer() {
    final restTime = _workoutExercises[_currentExerciseIndex].restBetweenSets;
    
    setState(() {
      _isActive = true;
      _isResting = true;
      _seconds = restTime;
      _currentPhase = 'resting';
    });
    
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _completeRest();
        }
      });
    });
  }

  void _completeRest() {
    _timer?.cancel();
    _pulseController.stop();
    
    setState(() {
      _isActive = false;
      _isResting = false;
      _currentSet++;
      _seconds = 0;
      _currentPhase = 'exercising';
    });
    
    HapticFeedback.mediumImpact();
    _showSnackBar('¡Descanso terminado! Serie $_currentSet 🔥');
  }

  void _completeExercise() {
    setState(() {
      _currentExerciseIndex++;
      _currentSet = 1;
    });
    
    if (_currentExerciseIndex >= _workoutExercises.length) {
      // Workout completado
      _completeWorkout();
    } else {
      // Siguiente ejercicio
      HapticFeedback.heavyImpact();
      _showNextExerciseDialog();
    }
  }

  void _showNextExerciseDialog() {
    final nextExercise = _workoutExercises[_currentExerciseIndex];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.arrow_forward, color: Colors.orange),
            SizedBox(width: 8),
            Text('Siguiente Ejercicio', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nextExercise.exercise.name,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${nextExercise.sets} series',
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 15),
            Text(
              '¡Tómate un momento para prepararte! 💪',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentPhase = 'exercising';
                _seconds = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('¡Empezar!'),
          ),
        ],
      ),
    );
  }

  void _completeWorkout() {
    setState(() {
      _currentPhase = 'complete';
      _isActive = false;
    });
    
    _showWorkoutCompletionDialog();
  }

  void _showWorkoutCompletionDialog() {
    final totalTime = _completedSets.fold(0, (sum, set) => sum + set.duration);
    final totalSets = _completedSets.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('¡Workout Ninja Completado! 🥷', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔥 $totalSets series completadas', style: TextStyle(color: Colors.orange)),
            Text('⏱️ Tiempo total: ${_formatTime(totalTime)}', style: TextStyle(color: Colors.orange)),
            SizedBox(height: 15),
            Text(
              '¡Excelente trabajo, ninja! 💪',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetWorkout();
            },
            child: Text('Nuevo Workout'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Terminar'),
          ),
        ],
      ),
    );
  }

  void _resetWorkout() {
    setState(() {
      _currentPhase = 'setup';
      _currentExerciseIndex = 0;
      _currentSet = 1;
      _completedSets.clear();
      _isActive = false;
      _isResting = false;
      _seconds = 0;
    });
    _timer?.cancel();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.timer, color: Colors.orange),
            SizedBox(width: 8),
            Text('Super Timer Ninja 🥷', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_currentPhase != 'setup')
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.orange),
              onPressed: _resetWorkout,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentPhase) {
      case 'setup':
        return _buildWorkoutSetup();
      case 'exercising':
      case 'resting':
        return _buildActiveWorkout();
      case 'complete':
        return _buildWorkoutComplete();
      default:
        return _buildWorkoutSetup();
    }
  }

  Widget _buildWorkoutSetup() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[600]!, Colors.orange[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.white, size: 30),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crea tu Rutina Ninja',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Agrega ejercicios y personaliza series',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          
          // Rutina actual
          if (_workoutExercises.isNotEmpty) ...[
            Text(
              'Tu Rutina (${_workoutExercises.length} ejercicios)',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...List.generate(_workoutExercises.length, (index) {
              return _buildWorkoutExerciseCard(_workoutExercises[index], index);
            }),
            SizedBox(height: 20),
          ],
          
          // Agregar ejercicio
          _buildAddExerciseSection(),
          SizedBox(height: 30),
          
          // Botón iniciar
          if (_workoutExercises.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _startWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 30),
                    SizedBox(width: 10),
                    Text(
                      '¡EMPEZAR RUTINA NINJA!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutExerciseCard(WorkoutExercise workoutEx, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutEx.exercise.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${workoutEx.sets} series • ${_formatTime(workoutEx.restBetweenSets)} descanso',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeExercise(index),
                icon: Icon(Icons.remove_circle, color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildEditField(
                  'Series',
                  workoutEx.sets.toString(),
                  (value) {
                    setState(() {
                      workoutEx.sets = int.tryParse(value) ?? workoutEx.sets;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildEditField(
                  'Descanso (seg)',
                  workoutEx.restBetweenSets.toString(),
                  (value) {
                    setState(() {
                      workoutEx.restBetweenSets = int.tryParse(value) ?? workoutEx.restBetweenSets;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value),
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAddExerciseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agregar Ejercicio',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: ListView.builder(
            itemCount: _availableExercises.length,
            itemBuilder: (context, index) {
              final exercise = _availableExercises[index];
              return ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.orange),
                title: Text(
                  exercise.name,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  exercise.muscleGroups.join(', '),
                  style: TextStyle(color: Colors.grey[400]),
                ),
                onTap: () => _addExerciseToWorkout(exercise),
                trailing: Icon(Icons.add, color: Colors.green),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveWorkout() {
    if (_workoutExercises.isEmpty) return Container();
    
    final currentExercise = _workoutExercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + 1) / _workoutExercises.length;
    
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Ejercicio ${_currentExerciseIndex + 1} de ${_workoutExercises.length}',
            style: TextStyle(color: Colors.grey[400]),
          ),
          SizedBox(height: 30),
          
          // Ejercicio actual
          Text(
            currentExercise.exercise.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Serie $_currentSet de ${currentExercise.sets}',
            style: TextStyle(color: Colors.orange, fontSize: 18),
          ),
          SizedBox(height: 40),
          
          // Timer principal
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isResting ? _pulseAnimation.value : 1.0,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _isResting ? Colors.blue[600]! : Colors.orange[600]!,
                        _isResting ? Colors.blue[900]! : Colors.orange[900]!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isResting ? Colors.blue : Colors.orange).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_seconds),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _isResting ? 'DESCANSANDO 😮‍💨' : _isActive ? 'TRABAJANDO 💪' : 'LISTO 🥷',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          Spacer(),
          
          // Botones de control
          if (!_isResting) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isActive ? null : _startExerciseTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text('EMPEZAR'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isActive ? _completeSet : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        SizedBox(width: 8),
                        Text('COMPLETAR'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutComplete() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 80),
            SizedBox(height: 20),
            Text(
              '¡Workout Ninja\nCompletado! 🥷',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _resetWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Nueva Rutina'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

class WorkoutExercise {
  final Exercise exercise;
  int sets;
  int restBetweenSets; // en segundos

  WorkoutExercise({
    required this.exercise,
    this.sets = 3,
    this.restBetweenSets = 180, // 3 minutos por defecto
  });
}

class CompletedSet {
  final String exerciseName;
  final int setNumber;
  final double weight;
  final int reps;
  final int duration;
  final DateTime timestamp;

  CompletedSet({
    required this.exerciseName,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.duration,
    required this.timestamp,
  });
}