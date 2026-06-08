# 🔧 PASO 6: GUÍA TÉCNICA DE IMPLEMENTACIÓN

## 1️⃣ GENERAR CÓDIGO (Freezed + Riverpod)

```bash
# En raíz del proyecto
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Espera confirmación:**
```
[INFO] Running build...
[INFO] Generating build script...
[INFO] Running build script...
[INFO] ... generate freezed entities
[INFO] ... generate riverpod providers
[INFO] Build succeeded
```

---

## 2️⃣ VERIFICAR IMPORTS

Todos los imports están correctos en:

| Archivo | Imports Validados |
|---------|-------------------|
| `chat_page.dart` | ✅ Material, Riverpod, GoRouter, providers, entities |
| `chat_detail_page.dart` | ✅ Mismos que arriba |
| `app_router.dart` | ✅ GoRouter, chat pages |

---

## 3️⃣ VERIFICAR SUPABASE INTEGRATION

### **SupabaseService - Métodos Requeridos**

En `lib/core/network/supabase_service.dart` debe tener:

```dart
// ✅ Ya existen (verificar en archivo)
Future<List<ConversationPreview>> getConversations()
Future<List<Message>> getMessages(String conversationId)
Future<Message> sendMessage(String conversationId, String content, String userId)
Future<Conversation> createConversation(String otherUserId, String currentUserId)
Stream<Message> subscribeToMessages(String conversationId)

// ❓ Verificar estado
Stream<Conversation> subscribeToConversations()
Future<void> markMessagesAsRead(String conversationId)
```

Si falta alguno, avisa para completarlos.

---

## 4️⃣ VERIFICAR SUPABASE DATABASE

Las tablas y permisos RLS deben estar:

```sql
-- ✅ Tabla conversations
CREATE TABLE conversations (
  id UUID PRIMARY KEY,
  is_group BOOLEAN,
  group_id UUID,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- ✅ Tabla conversation_participants
CREATE TABLE conversation_participants (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations,
  user_id UUID REFERENCES auth.users,
  joined_at TIMESTAMP,
  last_read_at TIMESTAMP
);

-- ✅ Tabla messages
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations,
  sender_id UUID REFERENCES auth.users,
  content TEXT,
  created_at TIMESTAMP,
  edited_at TIMESTAMP,
  is_read BOOLEAN
);
```

### **RLS Policies Necesarios**

```sql
-- Conversaciones: usuario solo ve las suyas
CREATE POLICY conversations_select_own
ON conversations FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM conversation_participants
    WHERE conversation_id = id
    AND user_id = auth.uid()
  )
);

-- Mensajes: solo leer en conversaciones donde participas
CREATE POLICY messages_select_participant
ON messages FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM conversation_participants cp
    WHERE cp.conversation_id = messages.conversation_id
    AND cp.user_id = auth.uid()
  )
);

-- Mensajes: insertar solo en conversaciones donde participas
CREATE POLICY messages_insert_participant
ON messages FOR INSERT
WITH CHECK (
  sender_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM conversation_participants cp
    WHERE cp.conversation_id = messages.conversation_id
    AND cp.user_id = auth.uid()
  )
);
```

---

## 5️⃣ FLUJO DE DATOS (Verificación)

### **Flujo GET (Cargar conversaciones)**

```
HomePage/ChatPage
    ↓
conversationsProvider (StateNotifier)
    ↓
ConversationsNotifier.loadConversations()
    ↓
GetConversationsUseCase.call()
    ↓
ChatRepositoryImpl.getConversations()
    ↓
ChatRemoteDataSourceImpl.getConversations()
    ↓
SupabaseService.getConversations()
    ↓
Supabase:
SELECT c.*, cp.user_id, p.nickname, p.avatar, p.is_online
FROM conversations c
JOIN conversation_participants cp ON c.id = cp.conversation_id
JOIN public.profiles p ON cp.user_id = p.id
WHERE cp.user_id = current_user_id
    ↓
Map -> ConversationPreview
    ↓
UI Update (ListView)
```

### **Flujo POST (Enviar mensaje)**

```
ChatDetailPage._sendMessage()
    ↓
SendMessageUseCase.call(params)
    ↓
ChatRepositoryImpl.sendMessage()
    ↓
ChatRemoteDataSourceImpl.sendMessage()
    ↓
SupabaseService.sendMessage()
    ↓
Supabase:
INSERT INTO messages (conversation_id, sender_id, content, created_at)
VALUES (?, ?, ?, NOW())
    ↓
UPDATE conversations SET updated_at = NOW()
(trigger automático)
    ↓
Message retorna con ID
    ↓
MessagesNotifier.addMessage(message)
    ↓
UI agrega a lista + limpia input
```

### **Flujo STREAM (Realtime)**

```
ChatDetailPage.build()
    ↓
ref.listen(messagesStreamProvider(conversationId))
    ↓
messagesStreamProvider
    ↓
ChatRepositoryImpl.subscribeToMessages()
    ↓
SupabaseService.subscribeToMessages()
    ↓
Supabase RealtimeChannel:
SELECT * FROM messages
WHERE conversation_id = ?
(SUBSCRIBE con filter)
    ↓
StreamController emite eventos
    ↓
Front-end recibe Message
    ↓
Si senderId != currentUserId:
   MessagesNotifier.receiveMessage(message)
    ↓
UI actualiza en vivo
```

---

## 6️⃣ TESTING CHECKLIST

### **Test 1: Cargar Conversaciones**
```
[ ] Abrir app
[ ] Ir a menu → Mensajes
[ ] ✅ Se abre ChatPage
[ ] ✅ Conversaciones cargan (spinner mientras)
[ ] ✅ Se muestra lista con avatares, nombres, mensajes
[ ] ✅ Si no hay, se muestra empty state
```

### **Test 2: Abrir Conversación**
```
[ ] Click en una conversación
[ ] ✅ Navega a /chat/{conversationId}
[ ] ✅ Se carga ChatDetailPage
[ ] ✅ Mensajes históricos aparecen
[ ] ✅ Burbujas diferenciadas (yo/otro)
[ ] ✅ Timestamps en cada mensaje
```

### **Test 3: Enviar Mensaje**
```
[ ] Escribir en input: "Hola"
[ ] Presionar botón enviar
[ ] ✅ Input se limpia
[ ] ✅ Mensaje aparece en derecha (propio)
[ ] ✅ Se marca con timestamp
[ ] ✅ No hay duplicados (1 solo mensaje)
```

### **Test 4: Recibir Mensaje en Vivo**
```
[ ] En otra pestaña/device, conectar mismo usuario
[ ] Usuario A envía mensaje a Usuario B
[ ] ✅ En app de B, ChatDetailPage abierta
[ ] ✅ Nuevo mensaje aparece a la izquierda (del otro)
[ ] ✅ Sin recargar, en tiempo real
[ ] ✅ No duplicado
```

### **Test 5: Volver a Conversaciones**
```
[ ] Click en back o <- en ChatDetailPage
[ ] ✅ Vuelve a ChatPage
[ ] ✅ Última conversación se actualiza
[ ] ✅ Último mensaje es el nuevo
[ ] ✅ Badge de no leídos desaparece si se leyó
```

---

## 7️⃣ POSIBLES ERRORES Y SOLUCIONES

### **Error: "conversationId is null"**
```
Causa: RouteState no pasó parámetro
Solución: Verificar app_router.dart línea de /chat/:conversationId
```

### **Error: "No conversations found" (pero existen)**
```
Causa: RLS policy bloquea acceso
Solución: Verificar permisos en Supabase → Security → RLS
```

### **Mensajes no aparecen en vivo**
```
Causa: Stream no se suscribió
Solución: Verificar supabaseService.subscribeToMessages() existe
Solución: Verificar ref.listen() en ChatDetailPage
```

### **Duplicados de mensajes**
```
Causa: Se agrega vía POST + STREAM
Solución: En ref.listen(), verificar: if (message.senderId != currentUserId)
```

### **Input deshabilitado**
```
Causa: isSending = true
Solución: Verificar catch() limpia estado: sendingMessageProvider.state = false
```

---

## 8️⃣ BUILD & RUN

```bash
# Limpiar
flutter clean
flutter pub get

# Generar código
dart run build_runner build --delete-conflicting-outputs

# Correr app
flutter run

# O en Android/iOS específico
flutter run -d emulator-5554
flutter run -d "iPhone 15 Plus"
```

---

## 9️⃣ DEBUGGING

### **Ver logs de Supabase**
```dart
// En SupabaseService.subscribeToMessages():
final channel = supabase.realtime.channel('messages:$conversationId');
channel.onMessage((payload) {
  print('🔥 Realtime event: $payload');
});
```

### **Ver estado de Riverpod**
```bash
flutter pub add riverpod_generator
# En main.dart:
ProviderContainer(child: MyApp());
```

### **Test desde Supabase Console**
```sql
-- Insertar test
INSERT INTO messages (id, conversation_id, sender_id, content, created_at)
VALUES (gen_random_uuid(), 'conv-uuid', 'user-uuid', 'Test', NOW());

-- Ver subscriptores en Realtime
SELECT * FROM messages
WHERE conversation_id = 'conv-uuid'
ORDER BY created_at DESC;
```

---

## 🔟 DESPUÉS DE PASO 6

### **Verificar Antes de PASO 7:**
- ✅ `dart run build_runner build` sin errores
- ✅ App compila: `flutter run` sin crashes
- ✅ Conversaciones cargan
- ✅ Mensajes se envían y reciben
- ✅ Router navega correctamente

### **Si Todo OK:**
```
→ PASO 7: Search & Filter System
→ PASO 8: User Profiles Advanced
→ PASO 9: Notifications & Badges
```

---

## 📋 CHECKLIST ANTES DE CONTINUAR

- [ ] ¿Se ejecutó `dart run build_runner build`?
- [ ] ¿No hay errores de compilación?
- [ ] ¿Supabase database existe con tablas?
- [ ] ¿RLS policies están en el lugar?
- [ ] ¿SupabaseService tiene los métodos?
- [ ] ¿La app compila en Flutter?
- [ ] ¿ChatPage abre desde menu?
- [ ] ¿ChatDetailPage abre al click?
- [ ] ¿Mensajes se envían?
- [ ] ¿Recibes mensajes en vivo?

**Si todo ✅ → Listo para PASO 7**

---

```
¿Necesitas ayuda con algún error específico o test?
Responde y continúa con el siguiente PASO
```
