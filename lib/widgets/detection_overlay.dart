import 'package:flutter/material.dart';
import '../models/equipment.dart';

class DetectionOverlay extends StatelessWidget {
  final List<Equipment> detectedEquipment;
  final Function(Equipment) onEquipmentTapped;

  const DetectionOverlay({
    Key? key,
    required this.detectedEquipment,
    required this.onEquipmentTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: detectedEquipment.map((equipment) {
        return Positioned(
          left: equipment.boundingBox.left,
          top: equipment.boundingBox.top,
          width: equipment.boundingBox.width,
          height: equipment.boundingBox.height,
          child: GestureDetector(
            onTap: () => onEquipmentTapped(equipment),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getConfidenceColor(equipment.confidence),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Semi-transparent overlay
                  Container(
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(equipment.confidence)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  
                  // Equipment label
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(equipment.confidence),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            equipment.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(equipment.confidence * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Tap indicator
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.touch_app,
                        size: 12,
                        color: _getConfidenceColor(equipment.confidence),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}