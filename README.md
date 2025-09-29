# README - Mini Gestor de Proyectos API

## 🎯 Descripción del Proyecto

API REST completa para un mini gestor de proyectos que implementa tres componentes modulares:
- **GestorUsuarios**: Gestión de usuarios del sistema
- **GestorProyectos**: Gestión de proyectos y asignación de usuarios
- **GestorTareas**: Gestión de tareas con validaciones cruzadas

## 🏗️ Conceptos Arquitectónicos Implementados

### 1. Componentes e Interfaces
- **Separación de responsabilidades**: Cada componente maneja su dominio específico
- **APIs REST claras**: Endpoints bien definidos para cada operación
- **Validación de entrada/salida**: Schemas Pydantic para consistencia

### 2. Propiedades ACID
- **Atomicidad**: Transacciones completas o rollback automático
- **Consistencia**: Validaciones de integridad referencial
- **Aislamiento**: Sesiones de base de datos independientes
- **Durabilidad**: Persistencia en PostgreSQL

### 3. Escalabilidad Horizontal
- **Servicios sin estado**: No hay variables de sesión en memoria
- **Stateless**: Cada request es completamente independiente
- **Paginación**: Soporte para grandes volúmenes de datos
- **Múltiples instancias**: Puede ejecutarse en paralelo

### 4. Contenedores
- **Docker**: Aplicación completamente containerizada
- **Orquestación**: docker-compose para múltiples servicios
- **Networking**: Red privada para comunicación entre contenedores
- **Volúmenes persistentes**: Datos de BD no se pierden

## 📁 Estructura del Proyecto

```
UT3-TFU-APi/
├── app/
│   ├── __init__.py
│   ├── database.py          # Configuración SQLAlchemy y sesiones ACID
│   ├── models.py            # Modelos ORM (Usuario, Proyecto, Tarea)
│   ├── schemas.py           # Validación Pydantic
│   └── routers/
│       ├── __init__.py
│       ├── usuarios.py      # GestorUsuarios - CRUD usuarios
│       ├── proyectos.py     # GestorProyectos - CRUD proyectos + asignaciones
│       └── tareas.py        # GestorTareas - CRUD tareas + validaciones
├── scripts/
│   ├── demo_completa.sh     # Script demostración (Linux/Mac)
│   ├── demo_completa.bat    # Script demostración (Windows)
│   └── README.md            # Documentación de scripts
├── main.py                  # Aplicación FastAPI principal
├── requirements.txt         # Dependencias Python
├── Dockerfile              # Imagen Docker para la API
├── docker-compose.yaml     # Orquestación completa
├── .env                    # Variables de entorno
├── .dockerignore           # Archivos ignorados por Docker
├── init-db.sql             # Script inicialización PostgreSQL
└── README.md               # Este archivo
```

## 🚀 Instrucciones de Despliegue

### Prerrequisitos
- Docker y docker-compose instalados
- Puerto 8000, 5432 y 8080 disponibles

### Despliegue con Docker

1. **Clonar/Descargar el proyecto**
   ```bash
   # Si está en Git
   git clone <repository-url>
   cd UT3-TFU-APi
   ```

2. **Construir y ejecutar los contenedores**
   ```bash
   docker-compose up --build -d
   ```

3. **Verificar que los servicios están ejecutándose**
   ```bash
   docker-compose ps
   ```

4. **Verificar la API**
   ```bash
   curl http://localhost:8000/health
   ```

### Servicios Disponibles

- **API FastAPI**: http://localhost:8000
  - Documentación: http://localhost:8000/docs
  - ReDoc: http://localhost:8000/redoc
- **PostgreSQL**: localhost:5432
  - Usuario: postgres
  - Contraseña: password
  - Base de datos: gestor_proyectos
- **Adminer** (Administrador BD): http://localhost:8080

## 📋 Endpoints Principales

### GestorUsuarios (`/api/v1/usuarios`)
- `POST /` - Crear usuario
- `GET /` - Listar usuarios (con paginación)
- `GET /{id}` - Obtener usuario específico
- `PUT /{id}` - Actualizar usuario
- `DELETE /{id}` - Eliminar usuario

### GestorProyectos (`/api/v1/proyectos`)
- `POST /` - Crear proyecto
- `GET /` - Listar proyectos (con filtros)
- `GET /{id}` - Obtener proyecto específico
- `PUT /{id}` - Actualizar proyecto
- `DELETE /{id}` - Eliminar proyecto
- `POST /{id}/asignar_usuario` - Asignar usuario a proyecto
- `DELETE /{id}/desasignar_usuario/{user_id}` - Desasignar usuario

### GestorTareas (`/api/v1/tareas`)
- `POST /` - Crear tarea
- `GET /` - Listar tareas (con filtros múltiples)
- `GET /{id}` - Obtener tarea específica
- `PUT /{id}` - Actualizar tarea
- `DELETE /{id}` - Eliminar tarea
- `POST /{id}/asignar_usuario` - Asignar responsable
- `DELETE /{id}/desasignar_usuario` - Desasignar responsable

## 🧪 Ejecutar Demostración

Los scripts de demostración prueban todos los conceptos implementados:

### Linux/Mac:
```bash
chmod +x scripts/demo_completa.sh
./scripts/demo_completa.sh
```

### Windows:
```cmd
scripts\demo_completa.bat
```

### Con Postman:
Importar la colección desde: http://localhost:8000/docs → "Download OpenAPI schema"

## 🔍 Validaciones Implementadas

### Validaciones de Integridad
- **Emails únicos**: No se permiten usuarios con emails duplicados
- **Nombres de proyecto únicos**: Evita proyectos duplicados
- **Referencias válidas**: IDs de usuario/proyecto deben existir

### Validaciones Cruzadas
- **Asignación a proyecto**: Usuario debe existir antes de asignar
- **Responsable de tarea**: Usuario debe estar asignado al proyecto de la tarea
- **Eliminación en cascada**: Eliminar proyecto elimina sus tareas

### Validaciones de Negocio
- **Estados válidos**: Solo estados predefinidos para proyectos/tareas
- **Roles válidos**: Solo admin, manager, desarrollador
- **Prioridades válidas**: Solo alta, media, baja

## 🛠️ Tecnologías Utilizadas

- **Backend**: FastAPI 0.104.1
- **Base de Datos**: PostgreSQL 15
- **ORM**: SQLAlchemy 2.0.23
- **Validación**: Pydantic 2.5.0
- **Contenedores**: Docker + docker-compose
- **Servidor**: Uvicorn
- **Administrador BD**: Adminer

## 📊 Métricas de Escalabilidad

- **Stateless**: ✅ Sin estado en memoria
- **Paginación**: ✅ Límite configurable de resultados
- **Conexiones BD**: ✅ Pool de conexiones optimizado
- **Health Checks**: ✅ Monitoreo de contenedores
- **Horizontal Scaling**: ✅ Múltiples instancias compatibles

## 🐳 Comandos Docker Útiles

```bash
# Ver logs de la API
docker-compose logs api

# Ver logs de PostgreSQL
docker-compose logs db

# Reiniciar servicios
docker-compose restart

# Parar servicios
docker-compose down

# Limpiar volúmenes (¡Atención: elimina datos!)
docker-compose down -v

# Reconstruir imágenes
docker-compose build --no-cache
```

## 🔧 Variables de Entorno

Configurables en `.env`:
```
DATABASE_URL=postgresql://postgres:password@db:5432/gestor_proyectos
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=gestor_proyectos
```

## 📈 Monitoreo y Logs

- **Health Check API**: http://localhost:8000/health
- **Logs en tiempo real**: `docker-compose logs -f`
- **Estado de contenedores**: `docker-compose ps`
- **Uso de recursos**: `docker stats`

## 🎓 Evaluación de Conceptos

### ✅ Componentes e Interfaces
- [x] Separación clara en GestorUsuarios, GestorProyectos, GestorTareas
- [x] APIs REST bien definidas para cada componente
- [x] Interfaces consistentes con schemas Pydantic

### ✅ ACID
- [x] Transacciones explícitas con commit/rollback
- [x] Integridad referencial con claves foráneas
- [x] Validaciones para mantener consistencia
- [x] PostgreSQL como base ACID completa

### ✅ Escalabilidad Horizontal
- [x] API completamente stateless
- [x] Sin variables de sesión o estado compartido
- [x] Puede ejecutarse en múltiples instancias
- [x] Paginación para grandes volúmenes

### ✅ Contenedores
- [x] Dockerfile optimizado para producción
- [x] docker-compose con orquestación completa
- [x] Networking privado entre servicios
- [x] Volúmenes persistentes para datos
- [x] Health checks para monitoreo

---

## 📞 Soporte

Para preguntas sobre la implementación o conceptos, revisar:
1. Documentación interactiva: http://localhost:8000/docs
2. Scripts de demostración en `/scripts/`
3. Logs de la aplicación: `docker-compose logs api`

**¡La API está lista para demostrar todos los conceptos de la Unidad 3!** 🎯