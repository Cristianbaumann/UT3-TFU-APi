"""
Router para gestión de tareas - Componente GestorTareas
Implementa endpoints CRUD con validaciones cruzadas entre usuarios y proyectos.
Servicio sin estado (stateless) - cada request es independiente.
"""

from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.database import get_db
from app.models import Tarea, Usuario, Proyecto
from app.schemas import (
    TareaCreate, TareaUpdate, TareaResponse, 
    AsignarUsuarioTarea, ErrorResponse, SuccessResponse
)

router = APIRouter(
    prefix="/tareas",
    tags=["tareas"],
    responses={404: {"model": ErrorResponse}},
)

@router.post("/", response_model=TareaResponse, status_code=status.HTTP_201_CREATED)
async def crear_tarea(
    tarea: TareaCreate,
    db: Session = Depends(get_db)
):
    """
    Crear una nueva tarea en el sistema.
    Valida que el proyecto especificado exista (validación cruzada con GestorProyectos).
    
    - **titulo**: Título de la tarea (3-200 caracteres)
    - **descripcion**: Descripción opcional de la tarea
    - **estado**: Estado de la tarea (pendiente, en_progreso, completada)
    - **prioridad**: Prioridad de la tarea (alta, media, baja)
    - **fecha_vencimiento**: Fecha de vencimiento (opcional)
    - **proyecto_id**: ID del proyecto al que pertenece (requerido)
    """
    # Verificar que el proyecto existe (validación cruzada con GestorProyectos)
    proyecto = db.query(Proyecto).filter(Proyecto.id == tarea.proyecto_id).first()
    if not proyecto:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Proyecto con ID {tarea.proyecto_id} no encontrado"
        )
    
    try:
        # Crear nueva tarea
        db_tarea = Tarea(**tarea.model_dump())
        db.add(db_tarea)
        db.commit()  # Commit explícito para ACID
        db.refresh(db_tarea)
        
        return db_tarea
        
    except IntegrityError:
        db.rollback()  # Rollback en caso de error para mantener ACID
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Error de integridad en la base de datos"
        )

@router.get("/", response_model=List[TareaResponse])
async def listar_tareas(
    skip: int = 0,
    limit: int = 100,
    proyecto_id: int = None,
    estado: str = None,
    usuario_responsable_id: int = None,
    db: Session = Depends(get_db)
):
    """
    Obtener lista de todas las tareas con filtros opcionales.
    Soporta filtrado por proyecto, estado, usuario responsable y paginación.
    
    - **skip**: Número de registros a omitir (default: 0)
    - **limit**: Número máximo de registros a devolver (default: 100)
    - **proyecto_id**: Filtrar por proyecto específico
    - **estado**: Filtrar por estado (pendiente, en_progreso, completada)
    - **usuario_responsable_id**: Filtrar por usuario responsable
    """
    query = db.query(Tarea)
    
    # Aplicar filtros
    if proyecto_id:
        query = query.filter(Tarea.proyecto_id == proyecto_id)
    if estado:
        query = query.filter(Tarea.estado == estado)
    if usuario_responsable_id:
        query = query.filter(Tarea.usuario_responsable_id == usuario_responsable_id)
    
    tareas = query.offset(skip).limit(limit).all()
    return tareas

@router.get("/{tarea_id}", response_model=TareaResponse)
async def obtener_tarea(
    tarea_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener información detallada de una tarea específica.
    Incluye información del usuario responsable si está asignado.
    
    - **tarea_id**: ID único de la tarea
    """
    tarea = db.query(Tarea).filter(Tarea.id == tarea_id).first()
    
    if not tarea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tarea con ID {tarea_id} no encontrada"
        )
    
    return tarea

@router.put("/{tarea_id}", response_model=TareaResponse)
async def actualizar_tarea(
    tarea_id: int,
    tarea_update: TareaUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar información de una tarea existente.
    Solo actualiza los campos proporcionados (PATCH semantics).
    Valida proyecto_id si se proporciona.
    
    - **tarea_id**: ID único de la tarea
    - **titulo**: Nuevo título (opcional)
    - **descripcion**: Nueva descripción (opcional)
    - **estado**: Nuevo estado (opcional)
    - **prioridad**: Nueva prioridad (opcional)
    - **fecha_vencimiento**: Nueva fecha de vencimiento (opcional)
    - **proyecto_id**: Nuevo proyecto (opcional)
    """
    # Buscar tarea existente
    db_tarea = db.query(Tarea).filter(Tarea.id == tarea_id).first()
    
    if not db_tarea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tarea con ID {tarea_id} no encontrada"
        )
    
    try:
        # Actualizar solo los campos proporcionados
        update_data = tarea_update.model_dump(exclude_unset=True)
        
        # Validar proyecto_id si se está actualizando
        if "proyecto_id" in update_data:
            proyecto = db.query(Proyecto).filter(Proyecto.id == update_data["proyecto_id"]).first()
            if not proyecto:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Proyecto con ID {update_data['proyecto_id']} no encontrado"
                )
        
        # Aplicar actualizaciones
        for field, value in update_data.items():
            setattr(db_tarea, field, value)
        
        db.commit()  # Commit explícito para ACID
        db.refresh(db_tarea)
        
        return db_tarea
        
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Error de integridad en la base de datos"
        )

@router.delete("/{tarea_id}", status_code=status.HTTP_204_NO_CONTENT)
async def eliminar_tarea(
    tarea_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar una tarea del sistema.
    
    - **tarea_id**: ID único de la tarea a eliminar
    """
    db_tarea = db.query(Tarea).filter(Tarea.id == tarea_id).first()
    
    if not db_tarea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tarea con ID {tarea_id} no encontrada"
        )
    
    try:
        db.delete(db_tarea)
        db.commit()  # Commit explícito para ACID
        
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No se puede eliminar la tarea debido a dependencias"
        )

@router.post("/{tarea_id}/asignar_usuario", response_model=SuccessResponse)
async def asignar_usuario_tarea(
    tarea_id: int,
    asignacion: AsignarUsuarioTarea,
    db: Session = Depends(get_db)
):
    """
    Asignar un usuario responsable a una tarea.
    Valida que tanto la tarea como el usuario existan y que el usuario
    esté asignado al proyecto de la tarea (validación cruzada completa).
    
    - **tarea_id**: ID único de la tarea
    - **usuario_id**: ID único del usuario a asignar como responsable
    """
    # Verificar que la tarea existe
    tarea = db.query(Tarea).filter(Tarea.id == tarea_id).first()
    if not tarea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tarea con ID {tarea_id} no encontrada"
        )
    
    # Verificar que el usuario existe (validación cruzada con GestorUsuarios)
    usuario = db.query(Usuario).filter(Usuario.id == asignacion.usuario_id).first()
    if not usuario:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Usuario con ID {asignacion.usuario_id} no encontrado"
        )
    
    # Verificar que el usuario está asignado al proyecto de la tarea
    # (validación cruzada completa entre los tres componentes)
    proyecto = tarea.proyecto
    if usuario not in proyecto.usuarios:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"El usuario {usuario.nombre} no está asignado al proyecto {proyecto.nombre}. " +
                   f"Debe asignarse al proyecto antes de asignar tareas."
        )
    
    # Verificar si la tarea ya tiene un responsable asignado
    if tarea.usuario_responsable_id is not None:
        usuario_actual = db.query(Usuario).filter(Usuario.id == tarea.usuario_responsable_id).first()
        if usuario_actual:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"La tarea ya tiene asignado como responsable a {usuario_actual.nombre}. " +
                       f"Use PUT para cambiar el responsable."
            )
    
    try:
        # Asignar usuario responsable a la tarea
        tarea.usuario_responsable_id = asignacion.usuario_id
        db.commit()  # Commit explícito para ACID
        
        return SuccessResponse(
            message=f"Usuario {usuario.nombre} asignado como responsable de la tarea '{tarea.titulo}'",
            data={
                "tarea_id": tarea_id,
                "usuario_id": asignacion.usuario_id,
                "tarea_titulo": tarea.titulo,
                "usuario_nombre": usuario.nombre,
                "proyecto_nombre": proyecto.nombre
            }
        )
        
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Error al asignar usuario responsable a la tarea"
        )

@router.delete("/{tarea_id}/desasignar_usuario", response_model=SuccessResponse)
async def desasignar_usuario_tarea(
    tarea_id: int,
    db: Session = Depends(get_db)
):
    """
    Desasignar el usuario responsable de una tarea.
    
    - **tarea_id**: ID único de la tarea
    """
    # Verificar que la tarea existe
    tarea = db.query(Tarea).filter(Tarea.id == tarea_id).first()
    if not tarea:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Tarea con ID {tarea_id} no encontrada"
        )
    
    # Verificar si la tarea tiene un responsable asignado
    if tarea.usuario_responsable_id is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"La tarea '{tarea.titulo}' no tiene un usuario responsable asignado"
        )
    
    # Obtener información del usuario antes de desasignar
    usuario_responsable = tarea.usuario_responsable
    usuario_nombre = usuario_responsable.nombre if usuario_responsable else "Usuario eliminado"
    
    try:
        # Desasignar usuario responsable
        tarea.usuario_responsable_id = None
        db.commit()  # Commit explícito para ACID
        
        return SuccessResponse(
            message=f"Usuario {usuario_nombre} desasignado como responsable de la tarea '{tarea.titulo}'",
            data={
                "tarea_id": tarea_id,
                "tarea_titulo": tarea.titulo,
                "usuario_anterior": usuario_nombre
            }
        )
        
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Error al desasignar usuario responsable de la tarea"
        )