import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../data/workout_database.dart';
import '../widgets/workout_card.dart';
import 'active_workout_screen.dart';

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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Rutinas de Entrenamiento',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              // TODO: Implementar búsqueda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Búsqueda próximamente...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filtro de dificultad
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: difficulties.map((difficulty) {
                      final isSelected = selectedDifficulty == difficulty;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(difficulty),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedDifficulty = difficulty;
                            });
                            applyFilters();
                          },
                          selectedColor: theme.colorScheme.primaryContainer,
                          checkmarkColor: theme.colorScheme.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Filtro de categoría
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                            applyFilters();
                          },
                          selectedColor: theme.colorScheme.secondaryContainer,
                          checkmarkColor: theme.colorScheme.secondary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Lista de rutinas
          Expanded(
            child: filteredWorkouts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron rutinas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prueba con otros filtros',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = filteredWorkouts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: WorkoutCard(
                          workout: workout,
                          onTap: () => _showWorkoutDetails(context, workout),
                          onStart: () => _startWorkout(context, workout),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Crear rutina personalizada
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear rutina personalizada próximamente...')),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, Workout workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Título
                      Text(
                        workout.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Descripción
                      Text(
                        workout.description ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Información
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.timer,
                            label: '${workout.calculatedDurationMinutes} min',
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.fitness_center,
                            label: '${workout.exercises.length} ejercicios',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Lista de ejercicios
                      Text(
                        'Ejercicios',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      ...workout.exercises.asMap().entries.map((entry) {
                        final index = entry.key;
                        final exercise = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              exercise.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('${exercise.sets} series × ${exercise.reps} repeticiones'),
                            trailing: Text(
                              '${exercise.restTime}s',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      
                      const SizedBox(height: 20),
                      
                      // Botón comenzar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _startWorkout(context, workout);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Comenzar Rutina',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _startWorkout(BuildContext context, Workout workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutScreen(workout: workout),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}