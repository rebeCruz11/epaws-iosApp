# 🐾 ePawss - Plataforma de Rescate y Adopción de Animales

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)

**ePawss** es una aplicación móvil iOS desarrollada en SwiftUI que conecta a usuarios, organizaciones de rescate animal y veterinarias para facilitar el reporte, rescate, atención médica y adopción de animales en situación de calle o peligro.

## 📱 Características Principales

### 👤 Para Usuarios
- **Reportar animales** en peligro o abandonados con ubicación GPS
- **Ver reportes cercanos** de animales que necesitan ayuda
- **Seguimiento de reportes** propios con estado en tiempo real
- **Búsqueda de animales** disponibles para adopción
- **Solicitudes de adopción** con proceso de seguimiento
- **Perfil personalizable** con historial de actividad
- **Notificaciones** sobre el estado de reportes y adopciones

### 🏢 Para Organizaciones de Rescate
- **Dashboard completo** con métricas y estadísticas
- **Gestión de reportes asignados** con cambio de estados
- **Asignación de veterinarias** a casos que requieren atención médica
- **Registro de animales rescatados** con información detallada
- **Gestión de adopciones** y seguimiento de solicitudes
- **Publicidad de la organización** para aumentar visibilidad
- **Control de capacidad** de animales bajo cuidado

### 🏥 Para Veterinarias
- **Dashboard especializado** con casos asignados
- **Gestión de reportes veterinarios** recibidos de organizaciones
- **Registros médicos completos** para cada animal
- **Historial médico** con diagnósticos, tratamientos y medicamentos
- **Actualización de estado** de animales bajo tratamiento
- **Publicidad de servicios** veterinarios
- **Estadísticas** de casos atendidos

## 🏗️ Arquitectura

La aplicación sigue el patrón **MVVM (Model-View-ViewModel)** con una arquitectura limpia y modular:

```
ePawss/
├── Models/              # Modelos de datos (User, Animal, Report, etc.)
├── Views/               # Vistas SwiftUI organizadas por módulo
│   ├── Auth/           # Login, Registro
│   ├── Home/           # Vistas principales por rol
│   ├── Reports/        # Creación y gestión de reportes
│   ├── Animal/         # Detalles y gestión de animales
│   ├── Organization/   # Dashboard y funcionalidades de organización
│   ├── Veterinary/     # Dashboard y funcionalidades veterinarias
│   ├── Advertisements/ # Gestión de publicidad
│   └── Shared/         # Componentes compartidos
├── ViewModel/          # Lógica de negocio y estados
├── Services/           # Servicios de API y lógica de datos
├── Core/               # Networking, errores, endpoints
└── Components/         # Componentes reutilizables
    ├── Buttons/
    ├── Cards/
    ├── TextFields/
    └── ImagePicker/
```

## 🔧 Tecnologías y Frameworks

- **SwiftUI** - Framework de UI declarativo
- **Combine** - Manejo reactivo de datos
- **URLSession** - Networking HTTP
- **CoreLocation** - Servicios de ubicación GPS
- **MapKit** - Visualización de mapas
- **Keychain** - Almacenamiento seguro de tokens
- **Cloudinary** - Gestión y almacenamiento de imágenes
- **PhotosUI** - Selector de imágenes nativo

## 📦 Servicios Implementados

### Networking
- `APIService` - Cliente HTTP centralizado con manejo de errores
- `TokenManager` - Gestión segura de tokens JWT en Keychain
- `EndPoints` - Definición centralizada de endpoints

### Módulos de Negocio
- `AuthService` - Autenticación y gestión de usuarios
- `ReportService` - Gestión de reportes de animales
- `AnimalService` - CRUD de animales y búsqueda
- `AdoptionService` - Proceso de adopción
- `OrganizationService` - Funcionalidades de organizaciones
- `VeterinaryService` - Servicios veterinarios
- `MedicalRecordService` - Historial médico
- `AdvertisementService` - Gestión de publicidad
- `NotificationService` - Sistema de notificaciones
- `CloudinaryService` - Upload de imágenes
- `ImageStorageService` - Gestión local de imágenes

## 🚀 Instalación y Configuración

### Requisitos Previos
- macOS 13.0 o superior
- Xcode 15.0 o superior
- iOS 16.0 o superior (dispositivo o simulador)
- Cuenta de desarrollador de Apple (opcional para dispositivos físicos)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/rebeCruz11/epaws-iosApp.git
   cd epaws-iosApp
   ```

2. **Abrir el proyecto en Xcode**
   ```bash
   open ePawss.xcodeproj
   ```

3. **Configurar el Backend URL**
   
   Edita el archivo `Core/Network/APIService.swift` y actualiza la URL base:
   ```swift
   static let baseURL = "https://tu-backend-url.com"
   ```

4. **Configurar Cloudinary (Opcional)**
   
   Si usas Cloudinary para imágenes, actualiza las credenciales en `Services/CloudinaryService.swift`:
   ```swift
   private let cloudName = "tu-cloud-name"
   private let uploadPreset = "tu-upload-preset"
   ```

5. **Seleccionar el Target y Ejecutar**
   - Selecciona el esquema `ePawss`
   - Elige un simulador o dispositivo
   - Presiona `Cmd + R` para compilar y ejecutar

## 🔐 Autenticación

La aplicación implementa autenticación basada en **JWT (JSON Web Tokens)**:

- Tokens almacenados de forma segura en **Keychain**
- Refresh automático en llamadas API
- Logout limpia el token y redirige al login
- Soporte para tres roles: `user`, `organization`, `veterinary`

## 📊 Modelos de Datos Principales

### User
```swift
- id: String
- email: String
- name: String
- role: UserRole (user, organization, veterinary)
- phone, address, profilePhotoUrl
- organizationDetails / veterinaryDetails
```

### Animal
```swift
- id, name, species, breed, gender
- ageEstimate, size, color, story
- photoUrls, videoUrl
- status: available, pending_adoption, adopted, deceased
- healthInfo: vaccinated, sterilized, dewormed
```

### Report
```swift
- id, description, urgencyLevel
- animalType, status
- location (GeoJSON), photoUrls
- reporterId, organizationId, veterinaryId
- Información poblada de reportero/organización/veterinaria
```

### MedicalRecord
```swift
- id, animalId, veterinaryId
- diagnosis, treatment, medications
- notes, followUpDate
- documents (URLs de archivos médicos)
```

## 🎨 Componentes Reutilizables

### Botones
- `PrimaryButton` - Botón principal con estilo consistente
- `ActionButton` - Botones de acción (Aceptar, Rechazar, etc.)
- `EstadoFilterButton` - Filtros de estado con chips

### Cards
- `ReporteCard` - Tarjeta de reporte con imagen, ubicación y urgencia
- `SolicitudCard` - Tarjeta de solicitud de adopción
- `DashboardCard` - Métricas en dashboard
- `OrganizationReporteCard` - Reportes asignados a organización

### TextFields
- `CustomTextField` - TextField personalizado con validación

### ImagePicker
- `AdvertisementImagePicker` - Selector de múltiples imágenes

## 🗺️ Características de Ubicación

- **Mapas interactivos** con marcadores de reportes
- **Búsqueda por proximidad** de animales y veterinarias
- **Reverse geocoding** para obtener direcciones
- **Permisos de ubicación** manejados correctamente

## 📸 Gestión de Imágenes

- **Upload a Cloudinary** con compresión automática
- **Caché local** de imágenes descargadas
- **AsyncImage** para carga eficiente
- **Múltiples imágenes** por animal/reporte

## 🔔 Sistema de Notificaciones

- Notificaciones sobre cambios de estado en reportes
- Alertas de nuevas solicitudes de adopción
- Actualizaciones de registros médicos
- Notificaciones push (preparado para integración)

## 🧪 Testing

El proyecto incluye:
- **Unit Tests** en `ePawssTests/`
- **UI Tests** en `ePawssUITests/`

Ejecutar tests:
```bash
# Desde Xcode: Cmd + U
# O desde terminal:
xcodebuild test -scheme ePawss -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📱 Compatibilidad

- **iOS**: 16.0+
- **Orientación**: Soporta Portrait y Landscape
- **Dispositivos**: iPhone y iPad (optimizado para iPhone)
- **Modo oscuro**: Soportado automáticamente

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request


## 👥 Equipo

Desarrollado por estudiantes de UNICAES - Ciclo 8

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 📞 Contacto

Para preguntas o sugerencias, por favor abre un issue en el repositorio.

---

<div align="center">
  <p>Hecho con ❤️ para ayudar a los animales sin hogar</p>
  <p>🐾 Cada adopción salva una vida 🐾</p>
</div>
