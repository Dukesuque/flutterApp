# WorkTime - Aplicación de Fichaje Laboral

Aplicación móvil desarrollada en Flutter para el control y gestión de jornadas laborales.

## 📋 Descripción

WorkTime es una aplicación de fichaje laboral con una interfaz moderna en modo oscuro, diseñada para facilitar el registro de entradas, salidas, pausas y el seguimiento de horas trabajadas. Cuenta con gestión de estado mediante Provider y arquitectura preparada para integración con Firebase.

## ✨ Características Principales

### Pantallas
- **Splash Screen**: Pantalla de inicio con animación y navegación automática
- **Login**: Autenticación con validación de formularios
- **Home**: Dashboard con botón de fichaje inteligente y resumen del día
- **Actividad**: Historial completo con filtros por tipo de actividad
- **Resumen**: Estadísticas mensuales con navegación entre períodos
- **Perfil**: Información del usuario y gestión de sesión

### Funcionalidades
- **Fichaje inteligente**: Botón que detecta el estado actual (entrada/salida/pausa)
- **Actividades manuales**: Diálogo para registrar actividades con fecha y hora personalizadas
- **Filtros avanzados**: Búsqueda por tipo de actividad
- **Navegación fluida**: Bottom navigation bar con 4 secciones principales
- **Gestión de estado reactiva**: Actualización automática de datos en toda la app

## 🏗️ Arquitectura

El proyecto sigue una arquitectura limpia y escalable con separación de responsabilidades:

```
lib/
 ├── main.dart                      # Punto de entrada con MultiProvider
 │
 ├── core/                          # Núcleo de la aplicación
 │    ├── theme/                    # Temas y colores personalizados
 │    │    ├── app_colors.dart
 │    │    └── app_theme.dart
 │    └── routes/                   # Configuración de rutas con GoRouter
 │         └── app_routes.dart
 │
 ├── models/                        # Modelos de datos con serialización JSON
 │    ├── user_model.dart
 │    ├── activity_model.dart
 │    └── summary_model.dart
 │
 ├── state/                         # Gestión de estado con Provider
 │    ├── auth_provider.dart        # Autenticación y usuario actual
 │    ├── activity_provider.dart    # Gestión de actividades
 │    └── summary_provider.dart     # Resúmenes mensuales
 │
 ├── presentation/                  # Capa de presentación
 │    ├── screens/                  # Pantallas principales
 │    │    ├── splash_screen.dart
 │    │    ├── login_screen.dart
 │    │    ├── home_screen.dart
 │    │    ├── activity_screen.dart
 │    │    ├── summary_screen.dart
 │    │    └── profile_screen.dart
 │    │
 │    └── widgets/                  # Widgets reutilizables
 │         ├── app_bottom_nav_bar.dart
 │         ├── clock_in_button.dart
 │         └── add_activity_dialog.dart
 │
 └── services/                      # Servicios (preparados para Firebase)
      ├── auth_service.dart         # Autenticación Firebase
      └── firestore_service.dart    # Base de datos en nube
```

## 🧠 Gestión de Estado

Utiliza **Provider** para gestión reactiva de estado:

### Providers Implementados

- **AuthProvider**: 
  - Login/Logout
  - Usuario actual
  - Estado de autenticación
  - Verificación de sesión

- **ActivityProvider**: 
  - CRUD de actividades
  - Filtros por tipo
  - Actividades del día
  - Última actividad registrada

- **SummaryProvider**: 
  - Resumen mensual
  - Navegación entre meses
  - Cálculo de horas trabajadas
  - Estadísticas y progreso

## 🎨 Diseño

### Tema
- **Modo**: Oscuro
- **Estilo**: Minimalista y profesional
- **Tipografía**: Sistema nativo con jerarquía clara

### Paleta de Colores
- **Fondo Primary**: `#0F0F10`
- **Fondo Secondary**: `#161718`
- **Fondo Card**: `#1E1F21`
- **Primary**: `#4DA3FF` (Azul moderno)
- **Success**: `#4CAF50` (Verde)
- **Warning**: `#FFB300` (Amarillo)
- **Error**: `#FF5252` (Rojo)
- **Text Primary**: `#F5F5F7`
- **Text Secondary**: `#B0B3B8`

## 🚀 Instalación y Uso

### Requisitos Previos

- **Flutter SDK**: 3.6.0 o superior
- **Dart**: 3.6.0 o superior
- **Java JDK**: 11 o superior (para Android)
- **IDE**: Visual Studio Code (recomendado) o Android Studio
- **Extensiones**: Flutter y Dart para VS Code

### Instalación

1. **Clonar el repositorio**:
```bash
git clone [url-del-repositorio]
cd worktime
```

2. **Instalar dependencias**:
```bash
flutter pub get
```

3. **Verificar configuración**:
```bash
flutter doctor
```

4. **Ejecutar en modo debug**:
```bash
# Para Chrome (desarrollo rápido)
flutter run -d chrome

# Para Android (requiere dispositivo conectado o emulador)
flutter run

# Para dispositivo específico
flutter devices
flutter run -d [device-id]
```

### Compilación

**APK de Debug**:
```bash
flutter build apk --debug
```

**APK de Release**:
```bash
flutter build apk --release
```

**App Bundle (para Google Play)**:
```bash
flutter build appbundle --release
```

## 📦 Dependencias

### Core
```yaml
flutter:
  sdk: flutter

# Gestión de estado
provider: ^6.1.2

# Navegación
go_router: ^14.6.2

# Internacionalización
intl: ^0.19.0
```

### UI
```yaml
# Gráficas y visualizaciones
fl_chart: ^0.70.1
```

### Firebase (En integración)
```yaml
# Núcleo de Firebase
firebase_core: ^3.8.1

# Autenticación
firebase_auth: ^5.3.3

# Base de datos en nube
cloud_firestore: ^5.5.1
```

## 🎯 Estado del Proyecto

### ✅ Implementado

#### UI/UX
- [x] Splash screen con animaciones
- [x] Login con validación de formularios
- [x] Home con dashboard completo
- [x] Sistema de navegación entre pantallas
- [x] Bottom navigation bar
- [x] Transiciones y animaciones

#### Funcionalidad
- [x] Botón de fichaje inteligente
- [x] Gestión de actividades (CRUD)
- [x] Filtros por tipo de actividad
- [x] Diálogo de actividad manual
- [x] Resumen mensual con estadísticas
- [x] Navegación entre meses
- [x] Perfil de usuario

#### Arquitectura
- [x] Gestión de estado con Provider
- [x] Modelos con serialización JSON
- [x] Navegación declarativa con GoRouter
- [x] Separación de responsabilidades
- [x] Widgets reutilizables

### 🔄 En Desarrollo

- [ ] Integración con Firebase Authentication
- [ ] Sincronización con Cloud Firestore
- [ ] Persistencia de sesión
- [ ] Datos en tiempo real
- [ ] Modo offline

### 📋 Planificado

- [ ] Notificaciones push
- [ ] Exportación de reportes (PDF)
- [ ] Calendario visual interactivo
- [ ] Gráficas avanzadas con fl_chart
- [ ] Solicitud de ausencias/vacaciones
- [ ] Multi-idioma (i18n)
- [ ] Testing unitario e integración

## 🛠️ Guía de Desarrollo

### Agregar Nueva Pantalla

1. Crear archivo en `lib/presentation/screens/`:
```dart
// ejemplo_screen.dart
import 'package:flutter/material.dart';

class EjemploScreen extends StatelessWidget {
  const EjemploScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo')),
      body: Center(child: Text('Nueva pantalla')),
    );
  }
}
```

2. Agregar ruta en `lib/core/routes/app_routes.dart`:
```dart
static const String ejemplo = '/ejemplo';

GoRoute(
  path: ejemplo,
  name: 'ejemplo',
  builder: (context, state) => const EjemploScreen(),
),
```

### Agregar Nuevo Provider

1. Crear archivo en `lib/state/`:
```dart
// ejemplo_provider.dart
import 'package:flutter/foundation.dart';

class EjemploProvider extends ChangeNotifier {
  String _data = '';
  
  String get data => _data;
  
  void updateData(String newData) {
    _data = newData;
    notifyListeners();
  }
}
```

2. Registrar en `main.dart`:
```dart
MultiProvider(
  providers: [
    // ... providers existentes
    ChangeNotifierProvider(create: (_) => EjemploProvider()),
  ],
  // ...
)
```

### Modificar Tema

Editar archivos en `lib/core/theme/`:
- `app_colors.dart`: Definir nuevos colores
- `app_theme.dart`: Configurar componentes del tema

## 📱 Flujo de Usuario

```
┌─────────────┐
│   Splash    │ (3 segundos con animación)
│   Screen    │
└──────┬──────┘
       ↓
┌─────────────┐
│    Login    │ (Validación de formularios)
│   Screen    │
└──────┬──────┘
       ↓
┌─────────────────────────────────────┐
│          Home Screen                │
│  ┌─────────────────────────────┐  │
│  │  • Estado actual            │  │
│  │  • Botón de fichaje         │  │
│  │  • Resumen del día          │  │
│  │  • Últimas actividades      │  │
│  └─────────────────────────────┘  │
└─────────────────────────────────────┘
       ↓
┌───────────────────────────────────────────────┐
│        Bottom Navigation Bar                  │
│  ┌──────┬──────────┬─────────┬─────────┐    │
│  │ Home │ Actividad│ Resumen │ Perfil  │    │
│  └──────┴──────────┴─────────┴─────────┘    │
└───────────────────────────────────────────────┘
```

## 🧪 Testing

### Ejecutar Tests
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Coverage
flutter test --coverage
```

## 🔧 Troubleshooting

### Problemas comunes

**Error de Gradle (Android)**:
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

**Error de dependencias**:
```bash
flutter pub cache repair
flutter pub get
```

**Hot reload no funciona**:
```bash
# Reiniciar app
r

# Full restart
R
```

## 📄 Licencia

Este proyecto es un desarrollo privado para WorkTime.

## 👥 Equipo de Desarrollo

Desarrollado como proyecto académico - Sistema de control de jornada laboral

## 🤝 Contribución

Este es un proyecto académico. Para consultas o sugerencias, contactar al equipo de desarrollo.

## 📞 Soporte

Para soporte técnico o consultas sobre el proyecto, contactar a través de los canales establecidos.

---

## 📌 Notas Importantes

- **Versión actual**: 1.0.0 (Desarrollo)
- **Estado**: En desarrollo activo
- **Plataformas soportadas**: Android, iOS, Web
- **Plataforma principal**: Android
- **Firebase**: Integración en progreso

---

**Última actualización**: Febrero 2025