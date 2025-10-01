@echo off
echo 🚀 GymAI - Build para Android
echo.

echo 📱 Verificando Flutter...
flutter --version
if %errorlevel% neq 0 (
    echo ❌ Flutter no está instalado o no está en el PATH
    echo.
    echo 📋 Instrucciones para instalar Flutter:
    echo 1. Ve a https://docs.flutter.dev/get-started/install/windows
    echo 2. Descarga Flutter SDK
    echo 3. Extrae el zip a C:\flutter
    echo 4. Agrega C:\flutter\bin al PATH de Windows
    echo 5. Reinicia esta terminal
    pause
    exit /b 1
)

echo.
echo 🔧 Limpiando proyecto...
flutter clean

echo.
echo 📦 Obteniendo dependencias...
flutter pub get

echo.
echo 🔨 Compilando APK...
flutter build apk --release

if %errorlevel% eq 0 (
    echo.
    echo ✅ APK compilado exitosamente!
    echo 📁 Ubicación: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 📱 Para instalar en tu celular:
    echo 1. Copia el APK a tu celular
    echo 2. Habilita "Orígenes desconocidos" en Configuración > Seguridad
    echo 3. Abre el APK desde el explorador de archivos
    echo 4. Toca "Instalar"
    echo.
    echo 🎉 ¡Listo para probar en tu celular!
) else (
    echo.
    echo ❌ Error al compilar APK
    echo 🔍 Revisa los errores arriba
)

echo.
pause