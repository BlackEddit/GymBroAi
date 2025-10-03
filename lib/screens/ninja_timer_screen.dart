import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/exercise.dart';
import '../data/exercise_database.dart';

class NinjaTimerScreen extends StatefulWidget {
  @override
  _NinjaTimerScreenState createState() => _NinjaTimerScreenState();
}

class _NinjaTimerScreenState extends State<NinjaTimerScreen>
    with TickerProviderStateMixin {
  
  // Controllers y estado
  Timer? _timer;
  int _seconds = 0;
  bool _isActive = false;
  bool _isResting = false;
  
  // Controladores de formulario
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _restController = TextEditingController(text: '60');
  
  // Variables del ejercicio actual
  Exercise? _selectedExercise;
  List<Exercise> _exercises = [];
  List<WorkoutSet> _currentSets = [];
  int _currentSetNumber = 1;
  
  // Animaciones
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  // Estados de UI
  bool _showExerciseSelector = false;
  String _currentPhase = 'setup'; // setup, working, resting, completed

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
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
  }

  void _loadExercises() async {
    final exercises = await ExerciseDatabase.getAllExercises();
    setState(() {
      _exercises = exercises;
    });
  }

  void _startTimer({bool isRest = false}) {
    setState(() {
      _isActive = true;
      _isResting = isRest;
      _seconds = isRest ? int.parse(_restController.text) : 0;
      _currentPhase = isRest ? 'resting' : 'working';
    });
    
    if (isRest) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (isRest) {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _completeRest();
          }
        } else {
          _seconds++;
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isActive = false;
      _currentPhase = 'setup';
    });
  }

  void _completeSet() {
    if (_selectedExercise == null || 
        _weightController.text.isEmpty || 
        _repsController.text.isEmpty) {
      _showSnackBar('¡Completa todos los datos primero! 💪');
      return;
    }

    // Vibración de éxito
    HapticFeedback.heavyImpact();
    
    final newSet = WorkoutSet(
      exerciseId: _selectedExercise!.id,
      setNumber: _currentSetNumber,
      weight: double.parse(_weightController.text),
      reps: int.parse(_repsController.text),
      duration: _seconds,
      restTime: int.parse(_restController.text),
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _currentSets.add(newSet);
      _currentSetNumber++;
    });
    
    _stopTimer();
    _startTimer(isRest: true);
    _showSnackBar('¡Serie ${_currentSetNumber - 1} completada! 🔥');
  }

  void _completeRest() {
    _stopTimer();
    HapticFeedback.mediumImpact();
    setState(() {
      _seconds = 0;
      _currentPhase = 'setup';
    });
    _showSnackBar('¡Descanso terminado! A darle 💀');
  }

  void _finishWorkout() async {
    if (_currentSets.isEmpty) {
      _showSnackBar('¡Haz al menos una serie! 🤨');
      return;
    }

    // Por ahora solo guardamos local, después integramos con BD
    _showCompletionDialog();
  }

  int _getTotalWorkoutTime() {
    return _currentSets.fold(0, (total, set) => total + set.duration + set.restTime);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.orange),
            SizedBox(width: 8),
            Text('¡Workout Ninja Completado! 🥷'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_selectedExercise?.name}'),
            Text('${_currentSets.length} series completadas'),
            Text('Tiempo total: ${_formatTime(_getTotalWorkoutTime())}'),
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
      _currentSets.clear();
      _currentSetNumber = 1;
      _seconds = 0;
      _currentPhase = 'setup';
      _weightController.clear();
      _repsController.clear();
    });
    _stopTimer();
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
            Text('Timer Ninja 🥷', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_currentSets.isNotEmpty)
            IconButton(
              icon: Icon(Icons.check_circle, color: Colors.green),
              onPressed: _finishWorkout,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Selector de ejercicio
            _buildExerciseSelector(),
            SizedBox(height: 20),
            
            // Timer principal
            _buildMainTimer(),
            SizedBox(height: 30),
            
            // Formulario de datos
            if (_selectedExercise != null) _buildWorkoutForm(),
            SizedBox(height: 20),
            
            // Historial de series
            if (_currentSets.isNotEmpty) _buildSetsHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejercicio',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () => setState(() => _showExerciseSelector = !_showExerciseSelector),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedExercise?.name ?? 'Seleccionar ejercicio...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Icon(
                    _showExerciseSelector ? Icons.expand_less : Icons.expand_more,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          if (_showExerciseSelector) ...[
            SizedBox(height: 10),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return ListTile(
                    title: Text(
                      exercise.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      exercise.muscleGroups.join(', '),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedExercise = exercise;
                        _showExerciseSelector = false;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainTimer() {
    return AnimatedBuilder(
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
                  blurRadius: 20,
                  spreadRadius: 5,
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
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isResting ? 'DESCANSANDO' : _isActive ? 'TRABAJANDO' : 'LISTO',
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
    );
  }

  Widget _buildWorkoutForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Serie #$_currentSetNumber',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _weightController,
                  label: 'Peso (kg)',
                  icon: Icons.fitness_center,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildInputField(
                  controller: _repsController,
                  label: 'Reps',
                  icon: Icons.repeat,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildInputField(
            controller: _restController,
            label: 'Descanso (seg)',
            icon: Icons.timer,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isActive && !_isResting ? null : () => _startTimer(),
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
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isActive && !_isResting ? _completeSet : null,
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildSetsHistory() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Series Completadas 🔥',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          ...List.generate(_currentSets.length, (index) {
            final set = _currentSets[index];
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Serie ${set.setNumber}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${set.weight}kg x ${set.reps}',
                    style: TextStyle(color: Colors.orange),
                  ),
                  Text(
                    _formatTime(set.duration),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }
}

class WorkoutSet {
  final String exerciseId;
  final int setNumber;
  final double weight;
  final int reps;
  final int duration;
  final int restTime;
  final DateTime timestamp;

  WorkoutSet({
    required this.exerciseId,
    required this.setNumber,
    required this.weight,
    required this.reps,
    required this.duration,
    required this.restTime,
    required this.timestamp,
  });
}