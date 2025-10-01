# 📱 GymAI - Instrucciones para Celular

## 🛠️ **1. INSTALAR FLUTTER (Si no lo tienes)**

### Opción A: Instalación Rápida
```bash
# Descargar Flutter
https://docs.flutter.dev/get-started/install/windows

# Extraer a:
C:\flutter

# Agregar al PATH:
C:\flutter\bin
```

### Opción B: Verificar instalación
```bash
flutter --version
flutter doctor
```

---

## 🏗️ **2. COMPILAR APK**

### Método 1: Script Automático (Recomendado)
```bash
# Ejecutar en la carpeta del proyecto
build_android.bat
```

### Método 2: Manual
```bash
cd "D:\Proyectos\Gym"
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📱 **3. INSTALAR EN CELULAR**

### Pasos:
1. **Encontrar APK**: `build\app\outputs\flutter-apk\app-release.apk`
2. **Copiar a celular**: Via USB, Google Drive, WhatsApp, etc.
3. **Habilitar instalación**:
   - Ve a **Configuración > Seguridad**
   - Habilita **"Orígenes desconocidos"** o **"Instalar apps desconocidas"**
4. **Instalar**:
   - Abre explorador de archivos en tu celular
   - Busca el APK descargado
   - Toca el archivo APK
   - Toca **"Instalar"**

---

## 🎯 **4. PROBAR LA APP**

### ✅ **Funcionalidades a probar:**

#### **Navegación Principal**:
- [x] Pantalla de inicio (Home)
- [x] Rutinas de entrenamiento
- [x] Navegación entre pestañas

#### **Rutinas**:
- [x] Ver 7 rutinas predefinidas
- [x] Filtrar por dificultad (Principiante/Intermedio/Avanzado)
- [x] Filtrar por categoría (Push/Pull/Piernas/etc.)
- [x] Ver detalles de rutina en modal
- [x] Botón "Comenzar rutina"

#### **Cronómetro de Entrenamiento**:
- [x] Iniciar rutina desde lista
- [x] Ver ejercicio actual con instrucciones
- [x] Completar series
- [x] Cronómetro de descanso automático
- [x] Vibración al terminar descanso
- [x] Navegar entre ejercicios (Anterior/Siguiente)
- [x] Completar workout completo

#### **Extras**:
- [x] Tema Material Design 3
- [x] Interfaz responsive
- [x] Funcionamiento offline (sin internet)

---

## 🐛 **5. SOLUCIÓN DE PROBLEMAS**

### **Error al compilar:**
```bash
# Limpiar cache
flutter clean
flutter pub get

# Verificar doctor
flutter doctor

# Si falta Android SDK:
# Instalar Android Studio primero
```

### **Error al instalar APK:**
- Verifica que **"Orígenes desconocidos"** esté habilitado
- El APK puede estar corrupto, recompila
- Algunos antivirus bloquean APKs, deshabilita temporalmente

### **App no abre:**
- El celular debe ser Android 5.0+ (API 21+)
- Verifica que tengas al menos 50MB libres
- Reinicia el celular e intenta de nuevo

---

## 📋 **6. CHECKLIST FINAL**

Antes de probar en celular, verifica:
- [ ] Flutter instalado correctamente
- [ ] APK compilado sin errores
- [ ] APK copiado al celular
- [ ] Permisos de instalación habilitados
- [ ] App instalada correctamente

### **Si todo funciona:**
🎉 **¡Felicidades! Tu app GymAI está funcionando en tu celular**

### **Próximos pasos:**
1. Probar todas las rutinas
2. Usar el cronómetro en un entrenamiento real
3. Reportar bugs o mejoras
4. Preparar para Google Play Store

---

## 🚀 **7. COMANDOS ÚTILES**

```bash
# Ver dispositivos conectados
flutter devices

# Instalar directamente (si celular conectado via USB)
flutter install

# Ver logs en tiempo real
flutter logs

# Build para diferentes arquitecturas
flutter build apk --split-per-abi
```

---

## 📞 **8. CONTACTO**

Si tienes problemas:
1. Revisa esta documentación
2. Verifica `flutter doctor`
3. Consulta los logs de error
4. ¡Pregunta lo que necesites!

**¡A entrenar con tu nueva app! 💪**