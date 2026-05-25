# 📊 INSTRUCCIONES: Configuración de BASE DE DATOS - SUPABASE

## 🚀 PASO 1: CREAR PROYECTO EN SUPABASE

1. Ir a https://app.supabase.com
2. Hacer clic en "New Project"
3. Seleccionar una organización o crear una
4. Completar:
   - **Project Name:** `premade-production`
   - **Password:** (Generar y guardar en contraseñero)
   - **Region:** Elegir más cercana (ej: Europe - Frankfurt)
   - **Database Edition:** Free (para desarrollo) o Pro (producción)

5. **Esperar 2-5 minutos** a que se cree el proyecto

## 🔑 PASO 2: OBTENER CREDENCIALES

Dentro del proyecto creado:

1. Ir a **Settings → API**
2. Copiar y guardar:
   - `Project URL`: Ej: `https://xxxxx.supabase.co`
   - `anon public key`: Ej: `eyJhbGciOiJI...`
   - `service_role key`: Ej: `eyJhbGciOiJI...` (MÁS SECRETO - Solo backend)

3. Ir a **Settings → Database**
4. Copiar:
   - `Connection string` (si es necesario para migraciones)

## 📝 PASO 3: EJECUTAR SQL

### Opción A: Usando Supabase SQL Editor (Recomendado para desarrollo)

1. En el proyecto de Supabase, ir a **SQL Editor**
2. Hacer clic en **"New Query"**
3. Copiar TODO el contenido de `schema.sql`
4. Pegar en el editor
5. Hacer clic en **"Run"** (o `Cmd+Enter`)
6. ✅ Verificar que se ejecutó sin errores

### Opción B: Usando CLI (Para automatización)

```bash
# 1. Instalar Supabase CLI
npm install -g supabase

# 2. Link con tu proyecto
supabase link --project-ref xxxxx

# 3. Ejecutar migraciones
supabase db pull  # Descargar schema actual
supabase db push  # Subir cambios

# O ejecutar archivo directamente:
psql "postgresql://postgres:[password]@xxxxx.supabase.co:5432/postgres" < schema.sql
```

### Opción C: Usando pgAdmin (Terminal PostgreSQL)

```bash
# Conectar a PostgreSQL de Supabase
psql postgresql://postgres:[password]@xxxxx.supabase.co:5432/postgres

# Una vez conectado, ejecutar el archivo:
\i schema.sql
```

## 🔐 PASO 4: CONFIGURAR ROW LEVEL SECURITY (RLS)

El SQL ya incluye RLS. Para habilitarlo correctamente:

1. En Supabase Dashboard → **Authentication → Policies**
2. Verificar que las políticas están creadas
3. En **Settings → Database**, el "RLS" debe estar habilitado en tablas

## ✅ VERIFICACIÓN: Confirmar que todo está correcto

```sql
-- Ejecutar estos queries en Supabase SQL Editor:

-- 1. Ver todas las tablas
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- 2. Ver si los juegos fueron insertados
SELECT id, title FROM public.games;

-- 3. Ver roles de LoL
SELECT gr.role_name, g.title 
FROM public.game_roles gr
JOIN public.games g ON g.id = gr.game_id
WHERE g.title = 'League of Legends';

-- 4. Ver rangos de LoL
SELECT gr.rank_tier 
FROM public.game_ranks gr
JOIN public.games g ON g.id = gr.game_id
WHERE g.title = 'League of Legends'
ORDER BY gr.rank_order;

-- 5. Ver políticas RLS
SELECT * FROM pg_policies;
```

## 📦 PASO 5: CONFIGURAR VARIABLES DE ENTORNO EN FLUTTER

En tu archivo `.env`:

```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJI...
SUPABASE_SERVICE_KEY=eyJhbGciOiJI...
```

## ⚡ PASO 6: CREAR BUCKET PARA AVATARES (Cloudinary/Supabase Storage)

### Opción A: Usando Supabase Storage

```sql
-- Supabase crea buckets automáticamente cuando se sube un archivo
-- O ir a Storage → Create bucket → Nombre: "avatars"
-- Configurar públicamente para lectura
```

### Opción B: Cloudinary (Recomendado para TFG)

1. Crear cuenta en https://cloudinary.com
2. Ir a **Settings → API Keys**
3. Copiar:
   - Cloud Name
   - API Key
   - API Secret
   - Upload Preset (crear uno)

4. Guardar en `.env`:
```
CLOUDINARY_CLOUD_NAME=xxx
CLOUDINARY_API_KEY=xxx
CLOUDINARY_UPLOAD_PRESET=xxx
```

## 🔔 PASO 7: CONFIGURAR FIREBASE (Notificaciones Push)

1. Ir a https://console.firebase.google.com
2. Crear nuevo proyecto (Nombre: `premade`)
3. Registrar app Flutter:
   - **Android**: Descargar `google-services.json`
   - **iOS**: Descargar `GoogleService-Info.plist`

4. Habilitar Firebase Messaging:
   - En Consola → **Cloud Messaging**
   - Crear clave de servidor

5. Guardar credenciales en `.env`

## 🧪 PASO 8: TESTING - Funciones SQL

```sql
-- Test 1: Insertar un usuario TEST (solo para verificación)
-- NO hacer esto en producción directamente

-- Test 2: Probar función de compatibilidad
SELECT calculate_match_compatibility(
  (SELECT id FROM users LIMIT 1),
  (SELECT id FROM users LIMIT 1 OFFSET 1)
);

-- Test 3: Probar función get_match_candidates
SELECT * FROM get_match_candidates(
  (SELECT id FROM users LIMIT 1),
  'Spain'::varchar,
  NULL,
  5
);
```

## 📊 MONITOREO Y MANTENIMIENTO

### Ver logs de Supabase:
- Dashboard → **Logs** → Ver queries ejecutadas

### Backup automático:
- Settings → **Backups** → Configurar frecuencia

### Performance:
- Tools → **Realtime** → Monitorear conexiones
- Tools → **Reports** → Ver uso

## ⚠️ SEGURIDAD

✅ **Ya incluido en schema.sql:**
- Row Level Security (RLS) habilitado
- Políticas de acceso por usuario
- Foreign keys con cascadas apropiadas
- Validaciones en constraints

❌ **NUNCA:**
- Exponer `service_role_key` en cliente (solo backend)
- Usar contraseña de BD en frontend
- Queryar directamente sin RLS

## 🐛 SOLUCIÓN DE PROBLEMAS

### Error: "relation already exists"
```sql
-- Si el schema ya existe, dropearlo:
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
-- Crear tablas nuevas
```

### Error: "permission denied"
- Verificar RLS está habilitado correctamente
- Usar `service_role` key para operaciones administrativas

### Error: "Foreign key constraint"
- Asegurar que los IDs existen en tablas referenciadas
- Verificar orden de inserción de datos

## 📚 RECURSOS ÚTILES

- [Supabase Docs](https://supabase.com/docs)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [RLS Best Practices](https://supabase.com/docs/guides/auth/row-level-security)
- [Real-time Subscriptions](https://supabase.com/docs/guides/realtime)

---

**Estado:** ✅ Base de datos lista para implementación
**Último actualizado:** 23/04/2026
