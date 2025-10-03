import 'dart:ui';
import 'exercise.dart';

class Equipment {
  final String id;
  final String name;
  final String category;
  final double confidence;
  final Rect boundingBox;
  final List<Exercise> suggestedExercises;
  final DateTime detectedAt;
  final String? gymLocation;

  const Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.confidence,
    required this.boundingBox,
    required this.suggestedExercises,
    required this.detectedAt,
    this.gymLocation,
  });

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      boundingBox: Rect.fromLTRB(
        (map['bounding_box_left'] as num).toDouble(),
        (map['bounding_box_top'] as num).toDouble(),
        (map['bounding_box_right'] as num).toDouble(),
        (map['bounding_box_bottom'] as num).toDouble(),
      ),
      suggestedExercises: [], // Will be loaded separately
      detectedAt: DateTime.fromMillisecondsSinceEpoch(map['detected_at'] as int),
      gymLocation: map['gym_location'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'confidence': confidence,
      'bounding_box_left': boundingBox.left,
      'bounding_box_top': boundingBox.top,
      'bounding_box_right': boundingBox.right,
      'bounding_box_bottom': boundingBox.bottom,
      'detected_at': detectedAt.millisecondsSinceEpoch,
      'gym_location': gymLocation,
    };
  }

  Equipment copyWith({
    String? id,
    String? name,
    String? category,
    double? confidence,
    Rect? boundingBox,
    List<Exercise>? suggestedExercises,
    DateTime? detectedAt,
    String? gymLocation,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      boundingBox: boundingBox ?? this.boundingBox,
      suggestedExercises: suggestedExercises ?? this.suggestedExercises,
      detectedAt: detectedAt ?? this.detectedAt,
      gymLocation: gymLocation ?? this.gymLocation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Equipment{id: $id, name: $name, category: $category, confidence: $confidence}';
  }
}