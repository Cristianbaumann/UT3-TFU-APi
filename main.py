"""
Aplicación principal FastAPI - Mini Gestor de Proyectos
Implementa arquitectura modular con componentes independientes y sin estado.
Cumple con principios ACID, escalabilidad horizontal y despliegue en contenedores.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import uvicorn
import os

# Importar configuración de base de datos y modelos
from app.database import create_tables

# Importar routers de cada componente
from app.routers import usuarios, proyectos, tareas

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Gestión del ciclo de vida de la aplicación.
    Crea las tablas al inicio y limpia recursos al final.
    """
    # Startup: Crear tablas de base de datos
    create_tables()
    print("✅ Tablas de base de datos creadas/verificadas")
    print("🚀 API Mini Gestor de Proyectos iniciada")
    
    yield
    
    # Shutdown: Limpiar recursos si es necesario
    print("🛑 API Mini Gestor de Proyectos detenida")

# Crear instancia de FastAPI con configuración
app = FastAPI(
    title="Mini Gestor de Proyectos API",
    description="""
    ## API REST para gestión de proyectos, usuarios y tareas
    
    Esta API implementa tres componentes modulares principales:
    
    ### 🧑‍💼 GestorUsuarios
    - Gestión CRUD completa de usuarios
    - Validación de emails únicos
    - Roles de usuario (admin, manager, desarrollador)
    
    ### 📋 GestorProyectos  
    - Gestión CRUD completa de proyectos
    - Asignación/desasignación de usuarios a proyectos
    - Estados de proyecto (activo, pausado, completado)
    
    ### ✅ GestorTareas
    - Gestión CRUD completa de tareas
    - Asignación de responsables con validación cruzada
    - Estados y prioridades de tareas
    - Validación de pertenencia usuario-proyecto
    
    ### 🏗️ Arquitectura
    - **Servicios sin estado**: Cada request es independiente
    - **Escalabilidad horizontal**: Puede ejecutarse en múltiples instancias
    - **ACID**: Transacciones consistentes con PostgreSQL
    - **Modular**: Componentes independientes con interfaces claras
    - **Contenedores**: Preparado para Docker y orquestación
    """,
    version="1.0.0",
    contact={
        "name": "Equipo de Desarrollo",
        "email": "desarrollo@minigestor.com",
    },
    license_info={
        "name": "MIT License",
        "url": "https://opensource.org/licenses/MIT",
    },
    lifespan=lifespan
)

# Configurar CORS para permitir requests desde diferentes orígenes
# Útil para desarrollo y testing con Postman/Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios específicos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registrar routers de cada componente con prefijos específicos
app.include_router(
    usuarios.router,
    prefix="/api/v1",
    tags=["GestorUsuarios"]
)

app.include_router(
    proyectos.router,
    prefix="/api/v1", 
    tags=["GestorProyectos"]
)

app.include_router(
    tareas.router,
    prefix="/api/v1",
    tags=["GestorTareas"] 
)

# Endpoint raíz para verificación de estado
@app.get("/", tags=["Sistema"])
async def root():
    """
    Endpoint raíz para verificar que la API está funcionando.
    Útil para health checks en contenedores.
    """
    return {
        "message": "Mini Gestor de Proyectos API",
        "status": "🟢 Operacional",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc",
        "componentes": [
            "GestorUsuarios (/api/v1/usuarios)",
            "GestorProyectos (/api/v1/proyectos)", 
            "GestorTareas (/api/v1/tareas)"
        ]
    }

# Endpoint de health check para Docker
@app.get("/health", tags=["Sistema"])
async def health_check():
    """
    Health check endpoint para monitoreo de contenedores.
    Verifica que la aplicación esté respondiendo correctamente.
    """
    return {
        "status": "healthy",
        "service": "mini-gestor-proyectos-api"
    }

# Manejo global de errores
@app.exception_handler(404)
async def not_found_handler(request, exc):
    return {
        "detail": "Endpoint no encontrado",
        "path": str(request.url),
        "method": request.method
    }

@app.exception_handler(500)
async def internal_error_handler(request, exc):
    return {
        "detail": "Error interno del servidor",
        "message": "Por favor contacte al administrador del sistema"
    }

# Punto de entrada para ejecutar la aplicación
if __name__ == "__main__":
    # Configuración para desarrollo
    # En producción, usar un servidor ASGI como Gunicorn + Uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",  # Escuchar en todas las interfaces (necesario para Docker)
        port=8000,
        reload=True,     # Recarga automática en desarrollo
        log_level="info"
    )