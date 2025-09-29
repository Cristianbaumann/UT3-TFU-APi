@echo off
REM Script de demostracion completa - Mini Gestor de Proyectos API (Windows)
REM Compatible con Windows PowerShell - sin emojis ni caracteres especiales

echo ===============================================================
echo      DEMOSTRACION COMPLETA - MINI GESTOR DE PROYECTOS API
echo ===============================================================

REM URL base de la API
set API_BASE=http://localhost:8000/api/v1

echo.
echo [1] VERIFICACION DE ESTADO DE LA API
echo ====================================
echo [*] Estado general de la API
curl -s http://localhost:8000/
echo.

echo [*] Health check para contenedores
curl -s http://localhost:8000/health
echo.

echo.
echo [2] GESTOR USUARIOS (Componente Modular)
echo ========================================

echo [*] Crear usuario manager
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Ana Garcia\", \"email\": \"ana.garcia@empresa.com\", \"rol\": \"manager\"}" %API_BASE%/usuarios
echo.

echo [*] Crear usuario desarrollador
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Carlos Lopez\", \"email\": \"carlos.lopez@empresa.com\", \"rol\": \"desarrollador\"}" %API_BASE%/usuarios
echo.

echo [*] Crear otro usuario desarrollador
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Maria Rodriguez\", \"email\": \"maria.rodriguez@empresa.com\", \"rol\": \"desarrollador\"}" %API_BASE%/usuarios
echo.

echo [*] Listar todos los usuarios
curl -s %API_BASE%/usuarios
echo.

echo [*] Paginacion: primeros 2 usuarios
curl -s "%API_BASE%/usuarios?limit=2"
echo.

echo [*] Obtener usuario por ID
curl -s %API_BASE%/usuarios/1
echo.

echo [*] Actualizar rol de usuario (transaccion ACID)
curl -s -X PUT -H "Content-Type: application/json" -d "{\"rol\": \"admin\"}" %API_BASE%/usuarios/1
echo.

echo.
echo [3] GESTOR PROYECTOS (Interfaces Claras)
echo =========================================

echo [*] Crear proyecto de inventario
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Sistema de Inventario\", \"descripcion\": \"Desarrollo de sistema web\", \"estado\": \"activo\"}" %API_BASE%/proyectos
echo.

echo [*] Crear proyecto mobile
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"App Mobile E-commerce\", \"descripcion\": \"Aplicacion movil\", \"estado\": \"activo\"}" %API_BASE%/proyectos
echo.

echo [*] Listar todos los proyectos
curl -s %API_BASE%/proyectos
echo.

echo [*] Asignar Ana (manager) al proyecto de inventario
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 1}" %API_BASE%/proyectos/1/asignar_usuario
echo.

echo [*] Asignar Carlos (dev) al proyecto de inventario
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 2}" %API_BASE%/proyectos/1/asignar_usuario
echo.

echo [*] Asignar Maria (dev) al proyecto mobile
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 3}" %API_BASE%/proyectos/2/asignar_usuario
echo.

echo [*] Ver proyecto 1 con usuarios asignados
curl -s %API_BASE%/proyectos/1
echo.

echo.
echo [4] GESTOR TAREAS (Servicios Sin Estado)
echo ========================================

echo [*] Crear tarea de diseno BD
curl -s -X POST -H "Content-Type: application/json" -d "{\"titulo\": \"Disenar base de datos\", \"descripcion\": \"Crear esquema de BD\", \"estado\": \"pendiente\", \"prioridad\": \"alta\", \"proyecto_id\": 1}" %API_BASE%/tareas
echo.

echo [*] Crear tarea de API
curl -s -X POST -H "Content-Type: application/json" -d "{\"titulo\": \"Implementar API REST\", \"descripcion\": \"Desarrollar endpoints\", \"estado\": \"pendiente\", \"prioridad\": \"alta\", \"proyecto_id\": 1}" %API_BASE%/tareas
echo.

echo [*] Crear tarea de diseno UI
curl -s -X POST -H "Content-Type: application/json" -d "{\"titulo\": \"Disenar UI/UX\", \"descripcion\": \"Crear mockups\", \"estado\": \"pendiente\", \"prioridad\": \"media\", \"proyecto_id\": 2}" %API_BASE%/tareas
echo.

echo [*] Asignar Carlos como responsable de diseno BD
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 2}" %API_BASE%/tareas/1/asignar_usuario
echo.

echo [*] Asignar Carlos como responsable de API
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 2}" %API_BASE%/tareas/2/asignar_usuario
echo.

echo [*] Listar todas las tareas
curl -s %API_BASE%/tareas
echo.

echo [*] Filtrar tareas del proyecto 1
curl -s "%API_BASE%/tareas?proyecto_id=1"
echo.

echo [*] Filtrar tareas de Carlos
curl -s "%API_BASE%/tareas?usuario_responsable_id=2"
echo.

echo.
echo [5] VALIDACIONES CRUZADAS
echo =========================

echo [*] [ERROR] Intentar asignar usuario inexistente (debe fallar)
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 999}" %API_BASE%/proyectos/1/asignar_usuario
echo.

echo [*] [ERROR] Intentar crear tarea en proyecto inexistente (debe fallar)
curl -s -X POST -H "Content-Type: application/json" -d "{\"titulo\": \"Tarea invalida\", \"proyecto_id\": 999}" %API_BASE%/tareas
echo.

echo [*] [ERROR] Intentar asignar Carlos a tarea del proyecto 2 (validacion)
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 2}" %API_BASE%/tareas/3/asignar_usuario
echo.

echo.
echo [6] PROPIEDADES ACID
echo ====================

echo [*] Actualizacion transaccional de tarea (ACID)
curl -s -X PUT -H "Content-Type: application/json" -d "{\"estado\": \"en_progreso\", \"descripcion\": \"Crear esquema de BD - EN DESARROLLO\"}" %API_BASE%/tareas/1
echo.

echo [*] [ERROR] Intentar crear usuario con email duplicado (rollback)
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Usuario Duplicado\", \"email\": \"ana.garcia@empresa.com\"}" %API_BASE%/usuarios
echo.

echo.
echo [7] ESCALABILIDAD HORIZONTAL
echo ============================
echo [OK] API Sin Estado (Stateless):
echo      - Cada request es independiente
echo      - No hay variables de sesion en memoria
echo      - Puede ejecutarse en multiples instancias

echo [*] Request independiente 1
curl -s "%API_BASE%/usuarios?limit=1&skip=0"
echo.

echo [*] Request independiente 2
curl -s "%API_BASE%/usuarios?limit=1&skip=1"
echo.

echo.
echo [8] CONTENEDORES
echo ===============
echo [OK] Contenedores ejecutandose:
echo      - API FastAPI: localhost:8000
echo      - PostgreSQL: localhost:5433
echo      - Adminer: localhost:8081

echo [*] Health check de contenedor API
curl -s http://localhost:8000/health
echo.

echo.
echo ========================================
echo    DEMOSTRACION COMPLETADA CON EXITO
echo ========================================
echo.
echo [RESUMEN] CONCEPTOS DEMOSTRADOS:
echo [OK] Componentes modulares: GestorUsuarios, GestorProyectos, GestorTareas
echo [OK] Interfaces claras: APIs REST bien definidas
echo [OK] ACID: Transacciones, rollbacks, integridad referencial
echo [OK] Escalabilidad horizontal: API stateless, paginacion
echo [OK] Contenedores: Docker, networking, health checks
echo [OK] Validaciones cruzadas: Verificacion entre componentes
echo.
echo Enlaces utiles:
echo - Documentacion: http://localhost:8000/docs
echo - ReDoc: http://localhost:8000/redoc
echo - Adminer (BD): http://localhost:8081
echo.
echo *** LA DEMOSTRACION HA FINALIZADO EXITOSAMENTE ***

pause