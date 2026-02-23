# WorkTime - Aplicación de Fichaje Laboral

Aplicación móvil desarrollada en Flutter para el control y gestión de jornadas laborales.

## 📋 Descripción

WorkTime es una aplicación de fichaje laboral con una interfaz moderna en modo oscuro, diseñada para facilitar el registro de entradas, salidas, pausas y el seguimiento de horas trabajadas. Esta versión es una implementación local de desarrollo con datos mock, preparada para futuras integraciones con backend y Firebase.

## ✨ Características

- **Splash Screen**: Pantalla de inicio con animación
- **Login**: Autenticación de usuario (mock)
- **Home**: Pantalla principal con contador de jornada y botón de fichaje
- **Actividad**: Registro de actividades del día, reuniones y notificaciones
- **Resumen**: Visualización de horas trabajadas con gráficas y calendario mensual
- **Perfil**: Información personal, laboral, horarios, vacaciones y ausencias
- **Navegación**: Bottom navigation bar para acceso rápido a las secciones principales

## 🏗️ Arquitectura

El proyecto sigue una arquitectura limpia y escalable:

```
lib/
 ├── main.dart                 # Punto de entrada
 ├── app.dart                  # Configuración de la app
 │
 ├── core/                     # Núcleo de la aplicación
 │    ├── theme/               # Temas y colores
 │    ├── routes/              # Configuración de rutas
 │    ├── constants/           # Constantes
 │    └── utils/               # Utilidades
 │
 ├── services/                 # Servicios (API, Firebase)
 │    ├── api_service.dart     # Servicio de API (stub)
 │    └── firebase_service.dart # Servicio de Firebase (stub)
 │
 ├── models/                   # Modelos de datos
 │    ├── user_model.dart
 │    ├── activity_model.dart
 │    └── summary_model.dart
 │
 ├── data/                     # Capa de datos
 │    └── mock/                # Datos simulados
 │          └── mock_data.dart
 │
 ├── presentation/             # Capa de presentación
 │    ├── screens/             # Pantallas
 │    │      ├── splash/
 │    │      ├── login/
 │    │      ├── home/
 │    │      ├── activity/
 │    │      ├── summary/
 │    │      └── profile/
 │    │
 │    └── widgets/             # Widgets reutilizables
 │
 └── state/                    # Gestión de estado
```

## 🎨 Diseño

- **Modo**: Oscuro
- **Estilo**: Minimalista y profesional
- **Colores principales**:
  - Fondo: Negro (#000000)
  - Primario: Azul eléctrico (#00A3FF)
  - Éxito: Verde (#00C853)
  - Advertencia: Naranja (#FF9800)
  - Error: Rojo (#F44336)

## 🚀 Instalación y Uso

### Requisitos previos

- Flutter SDK 3.6.0 o superior
- Dart 3.6.0 o superior
- Visual Studio Code (recomendado)
- Extensiones de Flutter y Dart para VS Code

### Instalación

1. Clonar o descargar el proyecto

2. Instalar dependencias:
```bash
flutter pub get
```

3. Ejecutar la aplicación:
```bash
flutter run
```

### Compilación

Para generar un APK de debug:
```bash
flutter build apk --debug
```

Para generar un APK de release:
```bash
flutter build apk --release
```

## 📦 Dependencias

- **flutter**: Framework principal
- **provider**: Gestión de estado
- **go_router**: Navegación declarativa
- **fl_chart**: Gráficas y visualizaciones
- **intl**: Internacionalización y formato de fechas

## 🔒 Alcance de esta versión

### ✅ Implementado

- UI completa y funcional
- Navegación entre pantallas
- Animaciones y transiciones
- Datos mock para todas las pantallas
- Arquitectura preparada para escalabilidad
- Modelos con soporte para JSON

### ❌ NO Implementado (preparado para futuro)

- Backend real
- Firebase real
- Base de datos
- API REST real
- Autenticación real
- Persistencia de datos

## 🛠️ Desarrollo

### Agregar nuevas pantallas

1. Crear carpeta en `lib/presentation/screens/nombre_pantalla/`
2. Crear archivo `nombre_pantalla_screen.dart`
3. Agregar ruta en `lib/core/routes/app_routes.dart`

### Agregar nuevos modelos

1. Crear archivo en `lib/models/nombre_model.dart`
2. Implementar métodos `fromJson()` y `toJson()`
3. Agregar datos mock en `lib/data/mock/mock_data.dart`

### Modificar tema

Editar archivos en `lib/core/theme/`:
- `app_colors.dart`: Colores de la aplicación
- `app_theme.dart`: Configuración del tema

## 📱 Flujo de Navegación

```
Splash (2s) → Login → Home
                       ↓
            Bottom Navigation:
              - Inicio (Home)
              - Actividad
              - Resumen
            
            Desde cualquier pantalla → Perfil (icono superior)
```

## 🧪 Testing

Para ejecutar los tests (cuando se implementen):
```bash
flutter test
```

## 📄 Licencia

Este proyecto es un desarrollo privado para WorkTime.

## 👥 Equipo

Desarrollado para WorkTime - Sistema de control de jornada laboral

## 📞 Soporte

Para soporte o consultas sobre el proyecto, contactar al equipo de desarrollo.

---

**Nota**: Esta es una versión de desarrollo con datos simulados. Para implementar funcionalidades reales de backend, API y Firebase, seguir las indicaciones en los archivos de servicios ubicados en `lib/services/`.
