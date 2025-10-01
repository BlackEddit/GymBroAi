# GymAI - Tu Entrenador Personal con IA

Una aplicación móvil Flutter que utiliza inteligencia artificial y computer vision para reconocer equipos de gimnasio y sugerir rutinas de ejercicios personalizadas.

## 🎯 Características Principales

### 🔍 Computer Vision
- **Detección en Tiempo Real**: Reconoce equipos de gimnasio usando la cámara
- **ML Kit Integration**: Utiliza Google ML Kit para detección de objetos
- **Alta Precisión**: Identifica mancuernas, barras, máquinas y más
- **Confianza Visual**: Muestra porcentaje de confianza en detecciones

### 🏋️ Rutinas Inteligentes
- **Sugerencias Automáticas**: Genera ejercicios basados en equipos detectados
- **Rutinas Personalizadas**: Crea entrenamientos adaptados a tu nivel
- **Seguimiento de Progreso**: Registra series, repeticiones y peso
- **Cronómetro Integrado**: Controla tiempos de descanso

### 📊 Análisis y Progreso
- **Estadísticas Detalladas**: Tiempo total, entrenamientos completados
- **Gráficos Visuales**: Tendencias semanales y mensuales  
- **Registro de Peso**: Seguimiento de peso corporal
- **Sistema de Logros**: Desbloquea achievements por constancia

### 🗺️ Mapeo del Gym
- **Ubicación de Equipos**: Mapea la disposición del gimnasio
- **Navegación Visual**: Encuentra equipos fácilmente
- **Historial de Uso**: Equipos más utilizados

## 🚀 Tecnologías Utilizadas

- **Flutter** - Framework de desarrollo móvil
- **Dart** - Lenguaje de programación
- **Google ML Kit** - Computer Vision y detección de objetos
- **Camera Plugin** - Acceso a cámara del dispositivo
- **SQLite** - Base de datos local para almacenamiento offline
- **Provider** - Gestión de estado
- **Material Design 3** - Interfaz moderna y atractiva

## 📱 Pantallas de la App

### 🏠 Inicio
- Panel de bienvenida personalizado
- Acceso rápido a funciones principales
- Resumen de entrenamientos recientes
- Estadísticas de progreso

### 📷 Cámara/Escaneo
- Vista en tiempo real de la cámara
- Detección automática de equipos
- Overlays informativos con confianza
- Sugerencias instantáneas de ejercicios

### 💪 Rutinas
- Biblioteca de entrenamientos personalizados
- Rutinas sugeridas por IA
- Temporizador de ejercicios
- Seguimiento de series y repeticiones

### 📈 Progreso
- Gráficos de tendencias
- Estadísticas semanales/mensuales
- Registro de peso corporal
- Sistema de logros y achievements

### ⚙️ Configuración
- Ajustes de sensibilidad de detección
- Preferencias de notificaciones
- Gestión de datos y privacidad
- Tema claro/oscuro

## 🛠️ Instalación y Configuración

### Prerrequisitos
- Flutter SDK (>= 3.0.0)
- Android Studio / VS Code
- Android SDK para desarrollo Android
- Xcode para desarrollo iOS (solo macOS)

### Instalación
1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/gym-ai.git
cd gym-ai
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura los permisos (Android):
   - Cámara: ya configurado en `android/app/src/main/AndroidManifest.xml`
   - Almacenamiento: ya configurado

4. Ejecuta la aplicación:
```bash
flutter run
```

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── equipment.dart        # Modelo de equipos detectados
│   ├── exercise.dart         # Modelo de ejercicios
│   ├── workout.dart          # Modelo de rutinas
│   └── workout_session.dart  # Modelo de sesiones de entrenamiento
├── screens/                  # Pantallas de la aplicación
│   ├── home_screen.dart      # Pantalla principal
│   ├── camera_screen.dart    # Pantalla de cámara/detección
│   ├── workouts_screen.dart  # Pantalla de rutinas
│   ├── progress_screen.dart  # Pantalla de progreso
│   └── settings_screen.dart  # Pantalla de configuración
├── services/                 # Servicios de la aplicación
│   ├── camera_service.dart   # Gestión de cámara
│   ├── ml_service.dart       # Computer Vision y ML
│   └── database_service.dart # Base de datos local
├── providers/                # Gestión de estado
│   ├── workout_provider.dart # Estado de rutinas y equipos
│   └── progress_provider.dart# Estado de progreso
└── widgets/                  # Componentes reutilizables
    ├── equipment_card.dart   # Tarjeta de equipo
    ├── workout_card.dart     # Tarjeta de rutina
    ├── detection_overlay.dart# Overlay de detección
    ├── progress_chart.dart   # Gráfico de progreso
    └── achievement_card.dart # Tarjeta de logro
```

## 🎯 Funcionalidades Implementadas

### ✅ Core Features
- [x] Estructura base de Flutter
- [x] Navegación entre pantallas
- [x] Configuración de cámara
- [x] Integración de ML Kit
- [x] Base de datos SQLite
- [x] Gestión de estado con Provider
- [x] UI/UX con Material Design 3

### 🔄 En Desarrollo
- [ ] Entrenamiento de modelos personalizados
- [ ] Sincronización con la nube
- [ ] Compartir rutinas entre usuarios
- [ ] Análisis avanzado de forma
- [ ] Integración con wearables

### 🎨 Equipos Detectables
- **Pesas Libres**: Mancuernas, barras, discos
- **Máquinas**: Equipos de resistencia, poleas
- **Cardio**: Cintas, bicicletas, elípticas
- **Accesorios**: Bancos, racks, barras de dominadas

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: Amazing Feature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 👨‍💻 Autor

**Tu Nombre** - [GitHub](https://github.com/tu-usuario)

## 🙏 Agradecimientos

- Google ML Kit por las herramientas de Computer Vision
- Flutter team por el framework
- Comunidad de desarrolladores Flutter

---

*¡Deja de depender de entrenadores distraídos y empieza a entrenar con IA! 🤖💪*