"""
Configuración de la base de datos PostgreSQL con SQLAlchemy.
Implementa patrón Singleton para la conexión y gestión de sesiones.
"""

import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# URL de conexión a PostgreSQL
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@localhost:5432/gestor_proyectos")

# Crear el motor de base de datos con configuración para ACID
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,  # Verificar conexión antes de usar
    pool_recycle=300,    # Reciclar conexiones cada 5 minutos
    echo=False           # No mostrar SQL queries en producción
)

# Factory de sesiones para transacciones ACID
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para modelos ORM
Base = declarative_base()

def get_db():
    """
    Generador de sesiones de base de datos.
    Asegura que las transacciones se cierren correctamente (ACID).
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_tables():
    """
    Crear todas las tablas definidas en los modelos.
    Se ejecuta al inicio de la aplicación.
    """
    Base.metadata.create_all(bind=engine)