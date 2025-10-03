import 'package:flutter/material.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entrenamientos por Semana',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Simple bar chart placeholder
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _buildChartBars(context),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Week labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                  .map((day) => Text(
                        day,
                        style: Theme.of(context).textTheme.bodySmall,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChartBars(BuildContext context) {
    // Mock data - replace with real data
    final List<int> workoutCounts = [0, 1, 0, 2, 1, 0, 0];
    final maxCount = workoutCounts.reduce((a, b) => a > b ? a : b);
    
    return workoutCounts.map((count) {
      final height = maxCount > 0 ? (count / maxCount) * 150 : 0.0;
      
      return Container(
        width: 24,
        height: height < 10 ? 10 : height, // Minimum height for visibility
        decoration: BoxDecoration(
          color: count > 0 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(4),
          ),
        ),
      );
    }).toList();
  }
}