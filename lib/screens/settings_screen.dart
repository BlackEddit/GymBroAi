import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoDetection = true;
  bool _darkMode = false;
  double _detectionSensitivity = 0.7;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoDetection = prefs.getBool('auto_detection') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _detectionSensitivity = prefs.getDouble('detection_sensitivity') ?? 0.7;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('auto_detection', _autoDetection);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setDouble('detection_sensitivity', _detectionSensitivity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Perfil del usuario
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca para editar perfil',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Editar perfil
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Configuración de Detección
          Text(
            'Detección de Equipos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Detección Automática'),
                  subtitle: const Text('Detectar equipos continuamente'),
                  value: _autoDetection,
                  onChanged: (value) {
                    setState(() {
                      _autoDetection = value;
                    });
                    _saveSettings();
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sensibilidad de Detección',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _detectionSensitivity,
                        min: 0.3,
                        max: 0.9,
                        divisions: 6,
                        label: '${(_detectionSensitivity * 100).round()}%',
                        onChanged: (value) {
                          setState(() {
                            _detectionSensitivity = value;
                          });
                        },
                        onChangeEnd: (value) {
                          _saveSettings();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Configuración General
          Text(
            'General',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notificaciones'),
                  subtitle: const Text('Recordatorios y actualizaciones'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Modo Oscuro'),
                  subtitle: const Text('Cambiar apariencia de la app'),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    _saveSettings();
                    // TODO: Aplicar tema oscuro
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Datos y Privacidad
          Text(
            'Datos y Privacidad',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Exportar Datos'),
                  subtitle: const Text('Descargar tus datos de entrenamiento'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Exportar datos
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Borrar Todos los Datos', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Eliminar permanentemente todos los datos'),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
                  onTap: () {
                    _showDeleteDataDialog();
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Acerca de
          Text(
            'Acerca de',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Versión de la App'),
                  subtitle: const Text('1.0.0'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Mostrar información de versión
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Ayuda y Soporte'),
                  subtitle: const Text('Preguntas frecuentes y contacto'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Mostrar ayuda
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Política de Privacidad'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Mostrar política de privacidad
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar Todos los Datos'),
        content: const Text(
          'Esta acción eliminará permanentemente todos tus datos de entrenamiento, progreso y configuraciones. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar borrado de datos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad próximamente disponible'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }
}