# ✅ CHECKLIST: PASO 2 - SUPABASE & DATABASE

Usa este checklist para verificar que todo está configurado correctamente.

## 📋 ANTES DE EMPEZAR

- [ ] Tienes acceso a Supabase.io (cuenta creada)
- [ ] Tienes acceso a Firebase.google.com (cuenta creada)
- [ ] Cloudinary es opcional (para avatares)

---

## 1️⃣ SUPABASE - CREAR PROYECTO

- [ ] Ir a https://app.supabase.com
- [ ] Click "New Project"
- [ ] Nombre: `premade-production`
- [ ] Región: La más cercana (ej: Frankfurt)
- [ ] Esperar 2-5 minutos a que se cree
- [ ] Dashboard abierto

**Credenciales a copiar:**
- [ ] **URL:** Settings → API → Project URL
  - Formato: `https://xxxxx.supabase.co`
- [ ] **Anon Key:** Settings → API → anon public
  - Formato: `eyJhbGciOiJI...` (muy largo)
- [ ] **Service Key:** Settings → API → service_role
  - Formato: `eyJhbGciOiJI...` (even más largo)

---

## 2️⃣ EJECUTAR SQL - DATABASE SCHEMA

### Opción A: SQL Editor (Recomendado)

- [ ] En Supabase, abrir **SQL Editor**
- [ ] Click **"New Query"**
- [ ] Abrir archivo `premade/database/schema.sql`
- [ ] Copiar TODO el contenido
- [ ] Pegar en el editor
- [ ] Click **"Run"** (o `Ctrl+Enter`)
- [ ] ✅ Sin errores

### Opción B: Terminal

```bash
cd premade
psql postgresql://postgres:[password]@xxxxx.supabase.co:5432/postgres < database/schema.sql
```

---

## 3️⃣ VERIFICAR INSTALACIÓN SQL

En Supabase SQL Editor, ejecutar estos queries:

```sql
-- 1. Ver tablas creadas
SELECT tablename FROM pg_tables WHERE schemaname = 'public';
```
- [ ] Deberías ver 17 tablas

```sql
-- 2. Ver juegos
SELECT id, title FROM public.games;
```
- [ ] Deberías ver "League of Legends" y "Valorant"

```sql
-- 3. Ver roles de LoL
SELECT gr.role_name 
FROM public.game_roles gr
JOIN public.games g ON g.id = gr.game_id
WHERE g.title = 'League of Legends';
```
- [ ] Deberías ver: Top, Jungle, Mid, ADC, Support

```sql
-- 4. Ver rangos de Valorant
SELECT rank_tier FROM public.game_ranks gr
JOIN public.games g ON g.id = gr.game_id
WHERE g.title = 'Valorant'
ORDER BY rank_order;
```
- [ ] Deberías ver: Iron, Bronze, Silver, Gold, Platinum, Diamond, Ascendant, Radiant

---

## 4️⃣ FIREBASE - CREAR PROYECTO

- [ ] Ir a https://console.firebase.google.com
- [ ] Click **"Create Project"**
- [ ] Nombre: `premade`
- [ ] ✅ Crear proyecto
- [ ] Esperar a que se cree

### Registrar App Android

- [ ] En Project Overview, click Android icon
- [ ] Package name: `com.premade.app`
- [ ] Debug signing certificate SHA-1 (opcional para desarrollo)
- [ ] Download `google-services.json`
- [ ] Copiar a `android/app/google-services.json`

### Registrar App iOS

- [ ] En Project Overview, click iOS icon
- [ ] Bundle ID: `com.premade.app`
- [ ] Download `GoogleService-Info.plist`
- [ ] Copiar a `ios/Runner/GoogleService-Info.plist`
- [ ] Abrir `ios/Runner.xcworkspace` y drag-drop el archivo en Xcode

### Habilitar Firebase Messaging

- [ ] En Consola, ir a **Cloud Messaging**
- [ ] Copiar `Sender ID` → `FIREBASE_MESSAGING_SENDER_ID`

---

## 5️⃣ CONFIGURAR .env EN FLUTTER

En `premade/.env`:

```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJI...
SUPABASE_SERVICE_KEY=eyJhbGciOiJI...

FIREBASE_APP_ID=1:123456789:android:xxxxxxxx
FIREBASE_MESSAGING_SENDER_ID=123456789

RIOT_API_KEY=opcional-por-ahora
CLOUDINARY_CLOUD_NAME=opcional-por-ahora
CLOUDINARY_UPLOAD_PRESET=opcional-por-ahora
```

- [ ] `.env` creado en raíz de proyecto
- [ ] `.env` añadido a `.gitignore`
- [ ] `.env.example` actualizado si es necesario

---

## 6️⃣ AGREGAR DEPENDENCIAS EN pubspec.yaml

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

- [ ] `flutter pub add flutter_dotenv`
- [ ] En `pubspec.yaml` → `flutter:` → `assets:` → Añadir `- .env`

```yaml
flutter:
  assets:
    - .env
```

---

## 7️⃣ VERIFICAR EN CODE

### Crear archivo `lib/core/config/env_config.dart`

- [ ] Archivo creado (ver `CONFIG_GUIDE.md` para código)

### Actualizar `main.dart`

- [ ] Importar `flutter_dotenv`
- [ ] Llamar `await dotenv.load()`
- [ ] Inicializar `SupabaseService().initialize(...)`
- [ ] Inicializar `FirebaseMessagingService().initialize()`

---

## 8️⃣ TEST: Compilar y ejecutar

```bash
cd premade

# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Compilar
flutter pub run build_runner build  # Si usas Freezed/JSON

# Ejecutar
flutter run
```

- [ ] `flutter pub get` - Sin errores
- [ ] `flutter run` - Sin errores de compilación
- [ ] App inicia sin crash
- [ ] Console muestra FCM Token

---

## 9️⃣ VERIFICACIÓN FINAL EN APP

Al ejecutar la app, debería:

- [ ] Iniciar SplashPage
- [ ] FirebaseMessaging muestra token en consola
- [ ] No hay errores de autenticación de Supabase

Si todo falla, revisar:
- [ ] ¿.env está en la carpeta correcta (raíz)?
- [ ] ¿Las credenciales están copiadas correctamente?
- [ ] ¿flutter_dotenv está en pubspec.yaml?
- [ ] ¿Ejecutaste `flutter pub get` después de cambios?

---

## 🔐 SEGURIDAD - FINAL CHECK

- [ ] `.env` NO está en Git
- [ ] `.env` SI está en `.gitignore`
- [ ] `SUPABASE_SERVICE_KEY` no se usa en código cliente
- [ ] `google-services.json` SI está en `android/app/`
- [ ] `GoogleService-Info.plist` SI está en `ios/Runner/`
- [ ] No hay logs con credenciales visibles

---

## 🎉 TODO COMPLETADO!

Si todos los checkboxes están ✅, estás listo para el **PASO 3: Autenticación**

**Próximo:**
- Sistema de register con email/password
- Login con Google
- Providers de Riverpod para auth
- UI completa (LoginPage, RegisterPage, SplashPage)

---

**Necesitas ayuda?** Revisa:
- `database/SETUP_GUIDE.md` - Problemas con BD
- `CONFIG_GUIDE.md` - Problemas con credenciales
- `PASO2_SUMMARY.md` - Resumen de lo creado
