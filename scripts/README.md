# Scripts de Demostración - Mini Gestor de Proyectos API

Este directorio contiene scripts para demostrar todos los conceptos implementados en la API:

## 🧑‍💼 GestorUsuarios
- **Componente modular**: Gestión independiente de usuarios
- **CRUD completo**: Crear, leer, actualizar y eliminar usuarios
- **Validación de datos**: Emails únicos, roles válidos
- **Escalabilidad**: Paginación en listados

## 📋 GestorProyectos  
- **Interfaces claras**: Separación de responsabilidades
- **Relaciones**: Asignación muchos-a-muchos con usuarios
- **Validación cruzada**: Verificar existencia de usuarios antes de asignar

## ✅ GestorTareas
- **Servicios sin estado**: Cada request es independiente
- **Validación completa**: Usuario debe estar en proyecto para ser responsable
- **Integridad referencial**: Tareas pertenecen a proyectos válidos

## 🏗️ Conceptos Arquitectónicos Demostrados

### ACID (Atomicidad, Consistencia, Aislamiento, Durabilidad)
- Transacciones explícitas con commit/rollback
- Integridad referencial con claves foráneas
- Validaciones para mantener consistencia

### Escalabilidad Horizontal
- API stateless: sin estado en memoria
- Puede ejecutarse en múltiples instancias
- Base de datos centralizada para coherencia

### Contenedores
- Dockerfile optimizado para producción
- docker-compose para orquestación
- Networking y volúmenes persistentes
- Health checks para monitoreo

### Componentes e Interfaces
- Separación clara de responsabilidades
- APIs REST bien definidas
- Validación de entrada/salida con Pydantic
- Manejo de errores consistente

## 📁 Archivos de Scripts

- `demo_completa.sh/bat`: Script completo de demostración
- `test_usuarios.sh/bat`: Pruebas específicas de usuarios
- `test_proyectos.sh/bat`: Pruebas específicas de proyectos
- `test_tareas.sh/bat`: Pruebas específicas de tareas
- `test_validaciones.sh/bat`: Pruebas de validaciones cruzadas