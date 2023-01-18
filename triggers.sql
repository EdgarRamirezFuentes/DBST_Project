-- INSERT --
CREATE TRIGGER TR_INS_Habitacion
ON habitacion
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO bitacora_habitacion (operacion, fecha, usuario, query)
  VALUES (
    'INSERT',
    GETDATE(),
    SUSER_NAME(),
    CONCAT('INSERT INTO Habitacion (nombre, descripcion, isActive, idTipoHabitacion) VALUES (',NEW.nombre,', ',NEW.descripcion,', ',NEW.isActive,', ',NEW.idTipoHabitacion,');')
  )
END;

-- UPDATE --
