import 'package:flutter/material.dart';
import '../models/equipment.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback? onTap;
  final bool showConfidence;

  const EquipmentCard({
    Key? key,
    required this.equipment,
    this.onTap,
    this.showConfidence = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Equipment icon
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getEquipmentIcon(equipment.category),
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Equipment name
                Text(
                  equipment.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Category
                Text(
                  equipment.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (showConfidence) ...[
                  const SizedBox(height: 8),
                  
                  // Confidence indicator
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 12,
                        color: _getConfidenceColor(equipment.confidence),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(equipment.confidence * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getConfidenceColor(equipment.confidence),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Exercise count
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${equipment.suggestedExercises.length} ejercicios',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getEquipmentIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pesas libres':
        return Icons.fitness_center;
      case 'máquinas':
        return Icons.precision_manufacturing;
      case 'cardio':
        return Icons.directions_run;
      case 'equipos de soporte':
        return Icons.event_seat;
      default:
        return Icons.sports_gymnastics;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}