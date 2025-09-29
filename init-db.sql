-- Script de inicialización opcional para PostgreSQL
-- Crea extensiones y configuraciones adicionales si es necesario

-- Crear extensión UUID para generar IDs únicos (opcional)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Configurar timezone
SET timezone = 'UTC';

-- Mensaje de confirmación
SELECT 'Base de datos Mini Gestor de Proyectos inicializada correctamente' AS status;