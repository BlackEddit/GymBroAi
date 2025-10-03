import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../data/workout_database.dart';
import '../widgets/workout_card.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String selectedDifficulty = 'Todos';
  String selectedCategory = 'Todos';
  List<Workout> allWorkouts = [];
  List<Workout> filteredWorkouts = [];

  final List<String> difficulties = [
    'Todos',
    'Principiante', 
    'Intermedio',
    'Avanzado'
  ];

  final List<String> categories = [
    'Todos',
    'Cuerpo Completo',
    'Push',
    'Pull', 
    'Piernas',
    'Cardio',
    'Casa'
  ];

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  void loadWorkouts() {
    allWorkouts = WorkoutDatabase.getPredefinedWorkouts();
    applyFilters();
  }

  void applyFilters() {
    setState(() {
      filteredWorkouts = allWorkouts.where((workout) {
        bool matchesDifficulty = selectedDifficulty == 'Todos' ||
            workout.tags?.contains(selectedDifficulty) == true;
        
        bool matchesCategory = selectedCategory == 'Todos' ||
            workout.tags?.contains(selectedCategory) == true;
            
        return matchesDifficulty && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Rutinas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateWorkoutDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          final workouts = workoutProvider.workouts;
          
          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes rutinas aún',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera rutina personalizada',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateWorkoutDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Rutina'),
                  ),
                ],
              ),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rutina sugerida del día
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rutina Sugerida Hoy',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Basada en tus últimos entrenamientos',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Generar rutina automatica
                            },
                            child: const Text('Ver Rutina Sugerida'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  'Mis Rutinas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      return WorkoutCard(
                        workout: workouts[index],
                        onTap: () {
                          // TODO: Navegar a detalles de rutina
                        },
                        onStart: () {
                          // TODO: Iniciar rutina
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showCreateWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Rutina'),
        content: const Text('Funcionalidad próximamente disponible'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}