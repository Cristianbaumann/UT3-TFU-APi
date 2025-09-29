@echo off
REM Script de demostración completa - Mini Gestor de Proyectos API (Windows)
REM Demuestra todos los conceptos: ACID, Escalabilidad, Contenedores, Componentes

echo 🚀 INICIANDO DEMOSTRACIÓN COMPLETA - MINI GESTOR DE PROYECTOS API
echo ==================================================================

REM URL base de la API
set API_BASE=http://localhost:8000/api/v1

echo.
echo 🏥 1. VERIFICACIÓN DE ESTADO DE LA API
echo ======================================
echo 📌 Estado general de la API
curl -s http://localhost:8000/
echo.

echo 📌 Health check para contenedores
curl -s http://localhost:8000/health
echo.

echo.
echo 👥 2. DEMOSTRACIÓN GESTOR USUARIOS (Componente Modular)
echo =======================================================

echo 📌 Crear usuario manager
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Ana García\", \"email\": \"ana.garcia@empresa.com\", \"rol\": \"manager\"}" %API_BASE%/usuarios
echo.

echo 📌 Crear usuario desarrollador
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Carlos López\", \"email\": \"carlos.lopez@empresa.com\", \"rol\": \"desarrollador\"}" %API_BASE%/usuarios
echo.

echo 📌 Crear otro usuario desarrollador
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"María Rodríguez\", \"email\": \"maria.rodriguez@empresa.com\", \"rol\": \"desarrollador\"}" %API_BASE%/usuarios
echo.

echo 📌 Listar todos los usuarios
curl -s %API_BASE%/usuarios
echo.

echo 📌 Paginación: primeros 2 usuarios
curl -s "%API_BASE%/usuarios?limit=2"
echo.

echo 📌 Obtener usuario por ID
curl -s %API_BASE%/usuarios/1
echo.

echo 📌 Actualizar rol de usuario (transacción ACID)
curl -s -X PUT -H "Content-Type: application/json" -d "{\"rol\": \"admin\"}" %API_BASE%/usuarios/1
echo.

echo.
echo 📋 3. DEMOSTRACIÓN GESTOR PROYECTOS (Interfaces Claras)
echo =======================================================

echo 📌 Crear proyecto de inventario
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Sistema de Inventario\", \"descripcion\": \"Desarrollo de sistema web para gestión de inventario\", \"estado\": \"activo\"}" %API_BASE%/proyectos
echo.

echo 📌 Crear proyecto mobile
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"App Mobile E-commerce\", \"descripcion\": \"Aplicación móvil para comercio electrónico\", \"estado\": \"activo\"}" %API_BASE%/proyectos
echo.

echo 📌 Listar todos los proyectos
curl -s %API_BASE%/proyectos
echo.

echo 📌 Asignar Ana (manager) al proyecto de inventario
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 1}" %API_BASE%/proyectos/1/asignar_usuario
echo.

echo 📌 Asignar Carlos (dev) al proyecto de inventario
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 2}" %API_BASE%/proyectos/1/asignar_usuario
echo.

echo 📌 Asignar María (dev) al proyecto mobile
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 3}" %API_BASE%/proyectos/2/asignar_usuario
echo.

echo 📌 Ver proyecto 1 con usuarios asignados
curl -s %API_BASE%/proyectos/1
echo.

echo.
echo ✅ 4. DEMOSTRACIÓN GESTOR TAREAS (Servicios Sin Estado)
echo ======================================================

echo 📌 Crear tarea de diseño BD
curl -s -X POST -H "Content-Type: application/json" -d "{\"titulo\": \"Diseñar base de datos\", \"descripcion\": \"Crear esquema de BD para inventario\", \"estado\": \"pendiente\", \"prioridad\": \"alta\", \"proyecto_id\": 1}" %API_BASE%/tareas
echo.

echo 📌 Crear tarea de API
curl -s -X POST -H "Content-Type: application/json" -d "{\"titulo\": \"Implementar API REST\", \"descripcion\": \"Desarrollar endpoints principales\", \"estado\": \"pendiente\", \"prioridad\": \"alta\", \"proyecto_id\": 1}" %API_BASE%/tareas
echo.

echo 📌 Crear tarea de diseño UI
curl -s -X POST -H "Content-Type: application/json" -d "{\"titulo\": \"Diseñar UI/UX\", \"descripcion\": \"Crear mockups de la app mobile\", \"estado\": \"pendiente\", \"prioridad\": \"media\", \"proyecto_id\": 2}" %API_BASE%/tareas
echo.

echo 📌 Asignar Carlos como responsable de diseño BD
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 2}" %API_BASE%/tareas/1/asignar_usuario
echo.

echo 📌 Asignar Carlos como responsable de API
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 2}" %API_BASE%/tareas/2/asignar_usuario
echo.

echo 📌 Listar todas las tareas
curl -s %API_BASE%/tareas
echo.

echo 📌 Filtrar tareas del proyecto 1
curl -s "%API_BASE%/tareas?proyecto_id=1"
echo.

echo 📌 Filtrar tareas de Carlos
curl -s "%API_BASE%/tareas?usuario_responsable_id=2"
echo.

echo.
echo 🔍 5. DEMOSTRACIÓN DE VALIDACIONES CRUZADAS
echo ===========================================

echo 📌 ❌ Intentar asignar usuario inexistente (debe fallar)
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 999}" %API_BASE%/proyectos/1/asignar_usuario
echo.

echo 📌 ❌ Intentar crear tarea en proyecto inexistente (debe fallar)
curl -s -X POST -H "Content-Type: application/json" -d "{\"titulo\": \"Tarea inválida\", \"proyecto_id\": 999}" %API_BASE%/tareas
echo.

echo 📌 ❌ Intentar asignar Carlos a tarea del proyecto 2 (no está asignado)
curl -s -X POST -H "Content-Type: application/json" -d "{\"usuario_id\": 2}" %API_BASE%/tareas/3/asignar_usuario
echo.

echo.
echo 💾 6. DEMOSTRACIÓN PROPIEDADES ACID
echo ===================================

echo 📌 Actualización transaccional de tarea (ACID)
curl -s -X PUT -H "Content-Type: application/json" -d "{\"estado\": \"en_progreso\", \"descripcion\": \"Crear esquema de BD para inventario - EN DESARROLLO\"}" %API_BASE%/tareas/1
echo.

echo 📌 ❌ Intentar crear usuario con email duplicado (rollback)
curl -s -X POST -H "Content-Type: application/json" -d "{\"nombre\": \"Usuario Duplicado\", \"email\": \"ana.garcia@empresa.com\"}" %API_BASE%/usuarios
echo.

echo.
echo 📈 7. DEMOSTRACIÓN ESCALABILIDAD HORIZONTAL
echo ==========================================
echo ✅ API Sin Estado (Stateless):
echo    - Cada request es independiente
echo    - No hay variables de sesión en memoria
echo    - Puede ejecutarse en múltiples instancias simultáneamente

echo 📌 Request independiente 1
curl -s "%API_BASE%/usuarios?limit=1&skip=0"
echo.

echo 📌 Request independiente 2
curl -s "%API_BASE%/usuarios?limit=1&skip=1"
echo.

echo.
echo 🐳 8. VERIFICACIÓN DE CONTENEDORES
echo ==================================
echo ✅ Contenedores ejecutándose:
echo    - API FastAPI: localhost:8000
echo    - PostgreSQL: localhost:5432
echo    - Adminer: localhost:8080

echo 📌 Health check de contenedor API
curl -s http://localhost:8000/health
echo.

echo.
echo 🏁 DEMOSTRACIÓN COMPLETADA
echo =========================
echo.
echo 📊 RESUMEN DE CONCEPTOS DEMOSTRADOS:
echo ✅ Componentes modulares: GestorUsuarios, GestorProyectos, GestorTareas
echo ✅ Interfaces claras: APIs REST bien definidas
echo ✅ ACID: Transacciones, rollbacks, integridad referencial
echo ✅ Escalabilidad horizontal: API stateless, paginación
echo ✅ Contenedores: Docker, networking, health checks
echo ✅ Validaciones cruzadas: Verificación entre componentes
echo.
echo 🔗 Enlaces útiles:
echo    - Documentación: http://localhost:8000/docs
echo    - ReDoc: http://localhost:8000/redoc
echo    - Adminer (BD): http://localhost:8080
echo.
echo 🎯 La demostración ha finalizado exitosamente!

pause