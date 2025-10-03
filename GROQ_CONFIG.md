# 🔒 CONFIGURACIÓN LOCAL - GROQ API

Para usar el asistente de IA en desarrollo local:

## Opción 1: Variable de Entorno (Recomendado)
```bash
# En PowerShell (Windows):
$env:GROQ_API_KEY="your_groq_api_key_here"
flutter run

# En Terminal (Linux/Mac):
export GROQ_API_KEY="your_groq_api_key_here"
flutter run
```

## Opción 2: Android Studio
1. Run/Debug Configurations
2. Environment Variables: `GROQ_API_KEY=your_actual_key`

## 🚫 NO SUBIR CLAVES AL REPOSITORIO
- Las claves están protegidas por .gitignore
- Solo usar variables de entorno
- Nunca hardcodear claves en el código

## ⚡ Para Testing Local
- Obtén tu clave de: https://console.groq.com/keys
- Usa el modelo: mixtral-8x7b-32768