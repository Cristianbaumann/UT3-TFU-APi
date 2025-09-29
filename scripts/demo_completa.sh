#!/bin/bash
# Script de demostración completa - Mini Gestor de Proyectos API
# Demuestra todos los conceptos: ACID, Escalabilidad, Contenedores, Componentes

echo "🚀 INICIANDO DEMOSTRACIÓN COMPLETA - MINI GESTOR DE PROYECTOS API"
echo "=================================================================="

# URL base de la API
API_BASE="http://localhost:8000/api/v1"

# Función para hacer peticiones con manejo de errores
make_request() {
    local method=$1
    local url=$2
    local data=$3
    local description=$4
    
    echo ""
    echo "📌 $description"
    echo "-----------------------------------"
    echo "🔄 $method $url"
    
    if [ -n "$data" ]; then
        echo "📤 Datos: $data"
        response=$(curl -s -X $method -H "Content-Type: application/json" -d "$data" "$url")
    else
        response=$(curl -s -X $method "$url")
    fi
    
    echo "📥 Respuesta:"
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    
    # Extraer ID si existe (para uso posterior)
    if echo "$response" | grep -q '"id"'; then
        echo "$response" | python3 -c "import sys, json; print('ID extraído:', json.load(sys.stdin)['id'])" 2>/dev/null
    fi
}

echo ""
echo "🏥 1. VERIFICACIÓN DE ESTADO DE LA API"
echo "======================================"
make_request "GET" "http://localhost:8000/" "" "Estado general de la API"
make_request "GET" "http://localhost:8000/health" "" "Health check para contenedores"

echo ""
echo "👥 2. DEMOSTRACIÓN GESTOR USUARIOS (Componente Modular)"
echo "======================================================="

# Crear usuarios
make_request "POST" "$API_BASE/usuarios" '{
    "nombre": "Ana García",
    "email": "ana.garcia@empresa.com",
    "rol": "manager"
}' "Crear usuario manager"

make_request "POST" "$API_BASE/usuarios" '{
    "nombre": "Carlos López",
    "email": "carlos.lopez@empresa.com", 
    "rol": "desarrollador"
}' "Crear usuario desarrollador"

make_request "POST" "$API_BASE/usuarios" '{
    "nombre": "María Rodríguez",
    "email": "maria.rodriguez@empresa.com",
    "rol": "desarrollador"
}' "Crear otro usuario desarrollador"

# Listar usuarios (demostrar paginación para escalabilidad)
make_request "GET" "$API_BASE/usuarios" "" "Listar todos los usuarios"
make_request "GET" "$API_BASE/usuarios?limit=2" "" "Paginación: primeros 2 usuarios"

# Obtener usuario específico
make_request "GET" "$API_BASE/usuarios/1" "" "Obtener usuario por ID"

# Actualizar usuario (demostrar transacciones ACID)
make_request "PUT" "$API_BASE/usuarios/1" '{
    "rol": "admin"
}' "Actualizar rol de usuario (transacción ACID)"

echo ""
echo "📋 3. DEMOSTRACIÓN GESTOR PROYECTOS (Interfaces Claras)"
echo "======================================================="

# Crear proyectos
make_request "POST" "$API_BASE/proyectos" '{
    "nombre": "Sistema de Inventario",
    "descripcion": "Desarrollo de sistema web para gestión de inventario",
    "estado": "activo"
}' "Crear proyecto de inventario"

make_request "POST" "$API_BASE/proyectos" '{
    "nombre": "App Mobile E-commerce", 
    "descripcion": "Aplicación móvil para comercio electrónico",
    "estado": "activo"
}' "Crear proyecto mobile"

# Listar proyectos
make_request "GET" "$API_BASE/proyectos" "" "Listar todos los proyectos"

# Asignar usuarios a proyectos (demostrar validación cruzada)
make_request "POST" "$API_BASE/proyectos/1/asignar_usuario" '{
    "usuario_id": 1
}' "Asignar Ana (manager) al proyecto de inventario"

make_request "POST" "$API_BASE/proyectos/1/asignar_usuario" '{
    "usuario_id": 2
}' "Asignar Carlos (dev) al proyecto de inventario"

make_request "POST" "$API_BASE/proyectos/2/asignar_usuario" '{
    "usuario_id": 3
}' "Asignar María (dev) al proyecto mobile"

# Verificar asignaciones
make_request "GET" "$API_BASE/proyectos/1" "" "Ver proyecto 1 con usuarios asignados"

echo ""
echo "✅ 4. DEMOSTRACIÓN GESTOR TAREAS (Servicios Sin Estado)"
echo "======================================================="

# Crear tareas
make_request "POST" "$API_BASE/tareas" '{
    "titulo": "Diseñar base de datos",
    "descripcion": "Crear esquema de BD para inventario",
    "estado": "pendiente",
    "prioridad": "alta",
    "proyecto_id": 1
}' "Crear tarea de diseño BD"

make_request "POST" "$API_BASE/tareas" '{
    "titulo": "Implementar API REST",
    "descripcion": "Desarrollar endpoints principales",
    "estado": "pendiente", 
    "prioridad": "alta",
    "proyecto_id": 1
}' "Crear tarea de API"

make_request "POST" "$API_BASE/tareas" '{
    "titulo": "Diseñar UI/UX",
    "descripcion": "Crear mockups de la app mobile",
    "estado": "pendiente",
    "prioridad": "media",
    "proyecto_id": 2
}' "Crear tarea de diseño UI"

# Asignar responsables (demostrar validación cruzada completa)
make_request "POST" "$API_BASE/tareas/1/asignar_usuario" '{
    "usuario_id": 2
}' "Asignar Carlos como responsable de diseño BD"

make_request "POST" "$API_BASE/tareas/2/asignar_usuario" '{
    "usuario_id": 2  
}' "Asignar Carlos como responsable de API"

# Listar tareas con filtros
make_request "GET" "$API_BASE/tareas" "" "Listar todas las tareas"
make_request "GET" "$API_BASE/tareas?proyecto_id=1" "" "Filtrar tareas del proyecto 1"
make_request "GET" "$API_BASE/tareas?usuario_responsable_id=2" "" "Filtrar tareas de Carlos"

echo ""
echo "🔍 5. DEMOSTRACIÓN DE VALIDACIONES CRUZADAS"
echo "==========================================="

# Intentar asignar usuario inexistente a proyecto
make_request "POST" "$API_BASE/proyectos/1/asignar_usuario" '{
    "usuario_id": 999
}' "❌ Intentar asignar usuario inexistente (debe fallar)"

# Intentar crear tarea en proyecto inexistente
make_request "POST" "$API_BASE/tareas" '{
    "titulo": "Tarea inválida",
    "proyecto_id": 999
}' "❌ Intentar crear tarea en proyecto inexistente (debe fallar)"

# Intentar asignar usuario no asignado al proyecto
make_request "POST" "$API_BASE/tareas/3/asignar_usuario" '{
    "usuario_id": 2
}' "❌ Intentar asignar Carlos a tarea del proyecto 2 (no está asignado)"

echo ""
echo "💾 6. DEMOSTRACIÓN PROPIEDADES ACID"
echo "==================================="

# Actualizar múltiples campos en transacción
make_request "PUT" "$API_BASE/tareas/1" '{
    "estado": "en_progreso",
    "descripcion": "Crear esquema de BD para inventario - EN DESARROLLO"
}' "Actualización transaccional de tarea (ACID)"

# Intentar actualizar con email duplicado (debe fallar y hacer rollback)
make_request "POST" "$API_BASE/usuarios" '{
    "nombre": "Usuario Duplicado",
    "email": "ana.garcia@empresa.com"
}' "❌ Intentar crear usuario con email duplicado (rollback)"

echo ""
echo "📈 7. DEMOSTRACIÓN ESCALABILIDAD HORIZONTAL"
echo "=========================================="

echo "✅ API Sin Estado (Stateless):"
echo "   - Cada request es independiente"
echo "   - No hay variables de sesión en memoria"
echo "   - Puede ejecutarse en múltiples instancias simultáneamente"

make_request "GET" "$API_BASE/usuarios?limit=1&skip=0" "" "Request independiente 1"
make_request "GET" "$API_BASE/usuarios?limit=1&skip=1" "" "Request independiente 2"

echo ""
echo "🐳 8. VERIFICACIÓN DE CONTENEDORES"
echo "=================================="

echo "✅ Contenedores ejecutándose:"
echo "   - API FastAPI: localhost:8000"
echo "   - PostgreSQL: localhost:5432" 
echo "   - Adminer: localhost:8080"

make_request "GET" "http://localhost:8000/health" "" "Health check de contenedor API"

echo ""  
echo "🏁 DEMOSTRACIÓN COMPLETADA"
echo "========================="
echo ""
echo "📊 RESUMEN DE CONCEPTOS DEMOSTRADOS:"
echo "✅ Componentes modulares: GestorUsuarios, GestorProyectos, GestorTareas"
echo "✅ Interfaces claras: APIs REST bien definidas"
echo "✅ ACID: Transacciones, rollbacks, integridad referencial"
echo "✅ Escalabilidad horizontal: API stateless, paginación"
echo "✅ Contenedores: Docker, networking, health checks"
echo "✅ Validaciones cruzadas: Verificación entre componentes"
echo ""
echo "🔗 Enlaces útiles:"
echo "   - Documentación: http://localhost:8000/docs"
echo "   - ReDoc: http://localhost:8000/redoc"
echo "   - Adminer (BD): http://localhost:8080"
echo ""
echo "🎯 La demostración ha finalizado exitosamente!"