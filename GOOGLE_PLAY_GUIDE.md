# Instrucciones para generar keystore y subir a Google Play Store

## 1. Generar Keystore (Certificado de Firma)
```bash
keytool -genkey -v -keystore gymai-upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias gymai
```

**Información a completar:**
- Password del keystore: [crear contraseña segura]
- Password del alias: [misma contraseña o diferente]
- First and last name: Tu Nombre
- Organizational unit: GymAI Development
- Organization: Tu Empresa
- City: Tu Ciudad
- State: Tu Estado
- Country code: MX (o tu país)

## 2. Crear archivo key.properties
Crear archivo `android/key.properties`:
```
storePassword=[password del keystore]
keyPassword=[password del alias]
keyAlias=gymai
storeFile=../gymai-upload-keystore.jks
```

## 3. Compilar APK/Bundle para Release
```bash
# APK para testing
flutter build apk --release

# Bundle para Google Play (recomendado)
flutter build appbundle --release
```

## 4. Requisitos para Google Play Store

### Cuenta de Desarrollador
- Crear cuenta en Google Play Console
- Pagar $25 USD (una sola vez)
- Verificar identidad

### Metadatos Requeridos
- Título de la app: "GymAI - Entrenador Personal con IA"
- Descripción corta: "Tu entrenador personal que detecta equipos de gym con IA"
- Descripción larga: Ver archivo app_description.md
- Screenshots (mínimo 2 por cada tamaño)
- Icono de alta resolución (512x512px)
- Banner promocional (1024x500px)

### Políticas
- Política de privacidad (obligatoria)
- Términos de servicio
- Permisos justificados (cámara, almacenamiento)

### Testing
- Crear track de testing interno
- Probar en diferentes dispositivos
- Alpha/Beta testing opcional

## 5. Pasos en Google Play Console

1. **Crear nueva aplicación**
2. **Configurar Store Listing** (descripción, imágenes)
3. **Subir Bundle/APK** a track de producción
4. **Configurar Content Rating**
5. **Configurar Target Audience**
6. **Revisar y publicar**

## 6. Tiempos aproximados
- Revisión inicial: 1-3 días
- Actualizaciones: Pocas horas
- Aprobación: 24-48 horas

## 7. Monetización (opcional)
- Gratuita con anuncios
- Premium por $2-5 USD
- Freemium con funciones premium
- Suscripción mensual