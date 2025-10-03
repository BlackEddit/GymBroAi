import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../services/ml_service.dart';
import '../models/equipment.dart';
import '../widgets/detection_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isDetecting = false;
  List<Equipment> _detectedEquipment = [];
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraService = context.read<CameraService>();
      _cameraController = await cameraService.initializeCamera();
      
      if (_cameraController != null) {
        await _cameraController!.startImageStream(_processCameraImage);
        setState(() {
          _statusMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error inicializando cámara: $e';
      });
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    
    setState(() {
      _isDetecting = true;
    });

    try {
      final mlService = context.read<MLService>();
      final detectedObjects = await mlService.detectObjects(image);
      
      setState(() {
        _detectedEquipment = detectedObjects;
      });
    } catch (e) {
      print('Error detecting objects: $e');
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  void _onEquipmentTapped(Equipment equipment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildEquipmentBottomSheet(equipment),
    );
  }

  Widget _buildEquipmentBottomSheet(Equipment equipment) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confianza: ${(equipment.confidence * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ejercicios Sugeridos:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...equipment.suggestedExercises.map(
                        (exercise) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.fitness_center),
                            title: Text(exercise.name),
                            subtitle: Text('${exercise.sets} series x ${exercise.reps} reps'),
                            trailing: IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () {
                                Navigator.pop(context);
                                // TODO: Iniciar rutina con este ejercicio
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Guardar equipo detectado
                          },
                          child: const Text('Guardar Equipo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Escanear Equipos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isDetecting ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Toggle detection
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

          // Error message
          if (_statusMessage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeCamera,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Detection overlay
          if (_cameraController != null && _cameraController!.value.isInitialized)
            DetectionOverlay(
              detectedEquipment: _detectedEquipment,
              onEquipmentTapped: _onEquipmentTapped,
            ),

          // Detection indicator
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isDetecting ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isDetecting ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isDetecting ? 'Detectando' : 'Pausado',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Equipment counter
          if (_detectedEquipment.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_detectedEquipment.length} equipo(s) detectado(s)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}