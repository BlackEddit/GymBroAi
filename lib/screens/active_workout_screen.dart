import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/workout.dart';
import '../models/exercise.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int currentExerciseIndex = 0;
  int currentSet = 1;
  bool isResting = false;
  bool isTimerRunning = false;
  int timeRemaining = 0;
  Timer? _timer;

  Exercise get currentExercise => widget.workout.exercises[currentExerciseIndex];
  bool get isLastExercise => currentExerciseIndex >= widget.workout.exercises.length - 1;
  bool get isLastSet => currentSet >= currentExercise.sets;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer(int seconds) {
    setState(() {
      timeRemaining = seconds;
      isTimerRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeRemaining > 0) {
          timeRemaining--;
        } else {
          timer.cancel();
          isTimerRunning = false;
          _onTimerComplete();
        }
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      isTimerRunning = false;
      timeRemaining = 0;
    });
  }

  void _onTimerComplete() {
    // Vibrar cuando termine el timer
    HapticFeedback.heavyImpact();
    
    if (isResting) {
      setState(() {
        isResting = false;
      });
      
      // Mostrar que el descanso terminó
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Descanso terminado! Siguiente serie'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void completeSet() {
    if (isLastSet) {
      // Último set del ejercicio
      nextExercise();
    } else {
      // Empezar descanso
      setState(() {
        currentSet++;
        isResting = true;
      });
      startTimer(currentExercise.restTime);
    }
  }

  void nextExercise() {
    if (isLastExercise) {
      // Workout completo
      _showWorkoutComplete();
    } else {
      setState(() {
        currentExerciseIndex++;
        currentSet = 1;
        isResting = false;
      });
      stopTimer();
    }
  }

  void previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
        currentSet = 1;
        isResting = false;
      });
      stopTimer();
    }
  }

  void _showWorkoutComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 ¡Workout Completado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Felicidades por completar "${widget.workout.name}"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.workout.exercises.length} ejercicios completados',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Volver a rutinas
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.workout.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Terminar entrenamiento?'),
                  content: const Text('¿Estás seguro de que quieres salir del entrenamiento?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continuar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar diálogo
                        Navigator.pop(context); // Salir del workout
                      },
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Salir'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progreso del workout
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Ejercicio ${currentExerciseIndex + 1} de ${widget.workout.exercises.length}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (currentExerciseIndex + 1) / widget.workout.exercises.length,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del ejercicio actual
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentExercise.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Serie $currentSet de ${currentExercise.sets}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentExercise.reps} repeticiones',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cronómetro de descanso
                  if (isResting) ...[
                    Card(
                      color: theme.colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 48,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tiempo de descanso',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatTime(timeRemaining),
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: isTimerRunning ? stopTimer : () => startTimer(currentExercise.restTime),
                                  child: Text(isTimerRunning ? 'Pausar' : 'Reanudar'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    stopTimer();
                                    setState(() {
                                      isResting = false;
                                    });
                                  },
                                  child: const Text('Saltar descanso'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Instrucciones del ejercicio
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instrucciones',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentExercise.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Controles principales
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (!isResting) ...[
                    // Botón principal para completar serie
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: completeSet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isLastSet 
                            ? (isLastExercise ? 'Finalizar Workout' : 'Siguiente Ejercicio')
                            : 'Serie Completada',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                  ],

                  // Navegación entre ejercicios
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: currentExerciseIndex > 0 ? previousExercise : null,
                          icon: const Icon(Icons.skip_previous),
                          label: const Text('Anterior'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: !isLastExercise ? nextExercise : null,
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Siguiente'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}