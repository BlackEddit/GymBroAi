import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter/foundation.dart';
import '../models/equipment.dart';
import '../models/exercise.dart';

class MLService {
  late ObjectDetector _objectDetector;
  bool _isInitialized = false;

  // Equipment mappings based on detected objects
  final Map<String, EquipmentInfo> _equipmentMappings = {
    'dumbbell': EquipmentInfo(
      name: 'Mancuernas',
      category: 'Pesas Libres',
      exercises: [
        Exercise(
          name: 'Press de Hombros',
          description: 'Levanta las mancuernas desde los hombros hacia arriba',
          sets: 3,
          reps: 12,
          restTime: 60,
          muscleGroups: ['Hombros'],
        ),
        Exercise(
          name: 'Curl de Bíceps',
          description: 'Flexiona los brazos levantando las mancuernas',
          sets: 3,
          reps: 15,
          restTime: 45,
          muscleGroups: ['Bíceps'],
        ),
      ],
    ),
    'barbell': EquipmentInfo(
      name: 'Barra',
      category: 'Pesas Libres',
      exercises: [
        Exercise(
          name: 'Press de Banca',
          description: 'Acuéstate y empuja la barra desde el pecho',
          sets: 4,
          reps: 8,
          restTime: 90,
          muscleGroups: ['Pecho', 'Tríceps'],
        ),
        Exercise(
          name: 'Peso Muerto',
          description: 'Levanta la barra desde el suelo manteniendo la espalda recta',
          sets: 3,
          reps: 6,
          restTime: 120,
          muscleGroups: ['Espalda', 'Glúteos', 'Piernas'],
        ),
      ],
    ),
    'bench': EquipmentInfo(
      name: 'Banco',
      category: 'Equipos de Soporte',
      exercises: [
        Exercise(
          name: 'Press de Banca con Mancuernas',
          description: 'Usa el banco para ejercicios de pecho',
          sets: 3,
          reps: 10,
          restTime: 75,
          muscleGroups: ['Pecho'],
        ),
      ],
    ),
    'machine': EquipmentInfo(
      name: 'Máquina de Ejercicios',
      category: 'Máquinas',
      exercises: [
        Exercise(
          name: 'Ejercicio en Máquina',
          description: 'Sigue las instrucciones de la máquina',
          sets: 3,
          reps: 12,
          restTime: 60,
          muscleGroups: ['Múltiples'],
        ),
      ],
    ),
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize object detector with custom options
      final options = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      );
      
      _objectDetector = ObjectDetector(options: options);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing ML service: $e');
      rethrow;
    }
  }

  Future<List<Equipment>> detectObjects(CameraImage image) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Convert CameraImage to InputImage
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return [];

      // Detect objects
      final detectedObjects = await _objectDetector.processImage(inputImage);
      
      // Convert detected objects to Equipment
      return _mapDetectedObjectsToEquipment(detectedObjects);
    } catch (e) {
      debugPrint('Error detecting objects: $e');
      return [];
    }
  }

  List<Equipment> _mapDetectedObjectsToEquipment(List<DetectedObject> objects) {
    final List<Equipment> equipment = [];
    
    for (final object in objects) {
      for (final label in object.labels) {
        final equipmentInfo = _findEquipmentForLabel(label.text.toLowerCase());
        if (equipmentInfo != null && label.confidence > 0.5) {
          equipment.add(Equipment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: equipmentInfo.name,
            category: equipmentInfo.category,
            confidence: label.confidence,
            boundingBox: object.boundingBox,
            suggestedExercises: equipmentInfo.exercises,
            detectedAt: DateTime.now(),
          ));
        }
      }
    }
    
    return equipment;
  }

  EquipmentInfo? _findEquipmentForLabel(String label) {
    // Direct mapping
    if (_equipmentMappings.containsKey(label)) {
      return _equipmentMappings[label];
    }
    
    // Fuzzy matching for common gym equipment
    if (label.contains('weight') || label.contains('dumbbell')) {
      return _equipmentMappings['dumbbell'];
    }
    if (label.contains('bar') || label.contains('barbell')) {
      return _equipmentMappings['barbell'];
    }
    if (label.contains('bench') || label.contains('seat')) {
      return _equipmentMappings['bench'];
    }
    if (label.contains('machine') || label.contains('equipment')) {
      return _equipmentMappings['machine'];
    }
    
    return null;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      // Get camera rotation
      const rotation = InputImageRotation.rotation0deg;
      
      // Get image format
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      // Get plane data
      if (image.planes.isEmpty) return null;
      final plane = image.planes.first;
      
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _objectDetector.close();
      _isInitialized = false;
    }
  }
}

class EquipmentInfo {
  final String name;
  final String category;
  final List<Exercise> exercises;

  const EquipmentInfo({
    required this.name,
    required this.category,
    required this.exercises,
  });
}