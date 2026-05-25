# ⚙️ CONFIGURACIÓN: Environment Variables y Credenciales

Esta guía te muestra cómo configurar todas las credenciales necesarias en tu proyecto Flutter.

## 📋 PASO 1: Crear archivo `.env` en la raíz del proyecto

Copia el contenido de `.env.example` a un nuevo archivo `.env`:

```bash
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJI...
SUPABASE_SERVICE_KEY=eyJhbGciOiJI...

FIREBASE_WEB_API_KEY=your_firebase_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id

RIOT_API_KEY=your_riot_api_key

CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_preset
```

## 🔐 PASO 2: Cargar variables de entorno en Flutter

Instala el package `flutter_dotenv`:

```bash
flutter pub add flutter_dotenv
```

En `pubspec.yaml`, añade la sección de assets:

```yaml
flutter:
  assets:
    - .env
```

### Crear archivo `lib/core/config/env_config.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseServiceKey => dotenv.env['SUPABASE_SERVICE_KEY'] ?? '';

  // Firebase
  static String get firebaseWebApiKey => dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  // Riot API
  static String get riotApiKey => dotenv.env['RIOT_API_KEY'] ?? '';

  // Cloudinary
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
}
```

## 🚀 PASO 3: Inicializar en `main.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/env_config.dart';
import 'core/network/supabase_service.dart';
import 'core/network/firebase_messaging_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar variables de entorno
  await dotenv.load();

  // 2. Inicializar Supabase
  await SupabaseService().initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // 3. Inicializar Firebase
  await FirebaseMessagingService().initialize();

  // 4. Obtener token FCM
  final fcmToken = await FirebaseMessagingService().getDeviceToken();
  print('FCM Token: $fcmToken');

  runApp(const ProviderScope(child: PremadeApp()));
}

class PremadeApp extends ConsumerWidget {
  const PremadeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premade',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashPage(),
    );
  }
}
```

## 📱 PASO 4: Configuración específica por plataforma

### Android (`android/app/build.gradle`)

Asegurar que el `compileSdkVersion` es al menos 33:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

Añadir configuración de Kotlin en `android/app/build.gradle`:

```gradle
dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}
```

### iOS (`ios/Podfile`)

Asegurar que el `platform` es iOS 12.0 o superior:

```ruby
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1'
      ]
    end
  end
end
```

### iOS: Permisos en `ios/Runner/Info.plist`

```xml
<key>NSUserNotificationAlertStyle</key>
<string>alert</string>

<key>NSUserNotificationsUsageDescription</key>
<string>Usamos notificaciones para alertarte sobre matches, mensajes y solicitudes de amistad</string>
```

## 🔑 PASO 5: Credenciales de Supabase

### Obtener `SUPABASE_URL` y `SUPABASE_ANON_KEY`:

1. En proyecto Supabase → **Settings → API**
2. Copiar `Project URL` → `SUPABASE_URL`
3. Copiar `anon public key` → `SUPABASE_ANON_KEY`

### `SUPABASE_SERVICE_KEY` (solo para backend):

1. En mismo lugar → `service_role key`
2. ⚠️ **NUNCA compartir en cliente** - solo para operaciones administrativas en backend

## 🔥 PASO 6: Credenciales de Firebase

### Crear proyecto en Firebase Console:

1. Ir a https://console.firebase.google.com
2. Create Project → Nombre: `premade`
3. Desactivar Google Analytics (opcional)

### Registrar app Android:

1. En Project → Android icon
2. Descargar `google-services.json`
3. Copiar a `android/app/`

### Registrar app iOS:

1. En Project → iOS icon
2. Descargar `GoogleService-Info.plist`
3. Copiar a `ios/Runner/` y agregar a Xcode

### Obtener credenciales:

1. Project Settings → Cloud Messaging
2. Copiar `Server API Key` → Guardar en backend
3. `Sender ID` → `FIREBASE_MESSAGING_SENDER_ID`

## 🎨 PASO 7: Credenciales de Cloudinary (Opcional)

Si quieres usar Cloudinary para avatares (alternativa a Supabase Storage):

1. Registrarse en https://cloudinary.com
2. Dashboard → Copiar `Cloud Name`
3. Settings → API Keys → Copiar `API Key`
4. Settings → Upload → Crear `Unsigned Preset`

```
CLOUDINARY_CLOUD_NAME=xxxxx
CLOUDINARY_API_KEY=xxxxx
CLOUDINARY_UPLOAD_PRESET=community
```

## 🏴 PASO 8: Credenciales de Riot API (Futuro)

Cuando integres con Riot API (para traer datos de LoL automáticamente):

1. Ir a https://developer.riotgames.com
2. Create API Key
3. Copiar a `.env`:

```
RIOT_API_KEY=xxxx-xxxx-xxxx
```

## 🧪 PASO 9: Verificar configuración

Crea un archivo `lib/core/config/config_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'env_config.dart';

class ConfigTest extends StatelessWidget {
  const ConfigTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Config Test')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Supabase URL'),
            subtitle: Text(EnvConfig.supabaseUrl.isEmpty 
              ? '❌ No configurado' 
              : '✅ ${EnvConfig.supabaseUrl.substring(0, 20)}...'),
          ),
          ListTile(
            title: const Text('Supabase Anon Key'),
            subtitle: Text(EnvConfig.supabaseAnonKey.isEmpty 
              ? '❌ No configurado' 
              : '✅ ${EnvConfig.supabaseAnonKey.substring(0, 20)}...'),
          ),
          ListTile(
            title: const Text('Firebase App ID'),
            subtitle: Text(EnvConfig.firebaseAppId.isEmpty 
              ? '❌ No configurado' 
              : '✅ ${EnvConfig.firebaseAppId.substring(0, 20)}...'),
          ),
        ],
      ),
    );
  }
}
```

## 🔐 SEGURIDAD: Checklist

- ✅ `.env` está en `.gitignore` (nunca commitear)
- ✅ `.env.example` contiene placeholders (para documentación)
- ✅ `SUPABASE_SERVICE_KEY` nunca se usa en cliente
- ✅ Las credenciales se cargan en `main()` antes de iniciar la app
- ✅ No hay hardcoding de credenciales en el código

## 🚫 ERRORES COMUNES

| Error | Causa | Solución |
|-------|-------|----------|
| `NoSuchMethodError: The getter 'supabaseUrl' was called on null` | `.env` no está cargado | Llamar `await dotenv.load()` antes de usarlo |
| `Invalid Supabase URL` | URL mal copiada | Verificar URL exacta en Dashboard de Supabase |
| `Unauthenticated` | Anon key inválida | Copiar `anon public key` correctamente |
| `Firebase not initialized` | Firebase no se inicializó | Llamar `await FirebaseMessagingService().initialize()` |

## 📚 Recursos

- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Flutter Environment Variables](https://pub.dev/packages/flutter_dotenv)
- [Security Best Practices](https://flutter.dev/docs/testing/best-practices)

---

**Estado:** ✅ Configuración lista
**Último actualizado:** 23/04/2026
