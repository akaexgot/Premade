# Premade - Gaming Duo/Squad Platform

Una aplicación móvil multiplataforma para encontrar compañeros de juego en videojuegos competitivos.

## 🎯 Características

- ✅ Autenticación con email/password y Google Sign In
- ✅ Perfiles de usuario con información detallada
- ✅ Sistema de matching tipo Tinder
- ✅ Chat en tiempo real
- ✅ Sistema social (amigos, bloques, grupos)
- ✅ Búsqueda y filtros avanzados
- ✅ Notificaciones push (Firebase)
- ✅ Integración con Riot API

## 🏗️ Arquitectura

El proyecto sigue la **Clean Architecture** con Riverpod:

```
lib/
├── core/           # Componentes reutilizables
├── data/           # Modelos, datasources, repositories
├── domain/         # Entities, use cases, interfaces
├── application/    # Riverpod providers
└── presentation/   # UI (pages, widgets)
```

## 📦 Dependencias Principales

- **State Management:** Riverpod
- **Backend:** Supabase
- **Notifications:** Firebase Cloud Messaging
- **UI:** Flutter Material 3

## 🚀 Getting Started

```bash
# Clonar y setup
flutter pub get

# Environment
cp .env.example .env
# Configurar variables en .env

# Ejecutar
flutter run
```

## 📝 Licencia

Proyecto para Trabajo de Fin de Grado (TFG) - 2DAM
