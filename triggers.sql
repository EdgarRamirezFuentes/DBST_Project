----------------------------
-- Habitacion TRIGGERS --
----------------------------
-- INSERT --
CREATE TRIGGER TR_INS_Habitacion
ON Habitacion
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO bitacora_habitacion (operacion, fecha, usuario, query)
  SELECT 'INSERT', GETDATE(), SUSER_NAME(), CONCAT('INSERT INTO Habitacion (nombre, descripcion, isActive, idTipoHabitacion) VALUES (',nombre,', ',descripcion,', ',isActive,', ',idTipoHabitacion,');')
  FROM INSERTED
END;

GO

-- UPDATE --
CREATE TRIGGER TR_UPD_Habitacion
ON Habitacion
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO bitacora_habitacion (operacion, fecha, usuario, query)
  SELECT 'UPDATE', GETDATE(), SUSER_NAME(), CONCAT('UPDATE Habitacion SET nombre = ',nombre,', descripcion =',descripcion,', idTipoHabitacion = ',idTipoHabitacion,');')
  FROM INSERTED
END;

GO



--------------------------
-- Reservacion TRIGGERS --
--------------------------
-- INSERT --
CREATE TRIGGER TR_INS_Reservacion
ON Reservacion
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO bitacora_reservacion (operacion, fecha, usuario, query)
  SELECT 'INSERT', GETDATE(), SUSER_NAME(), CONCAT('INSERT INTO Reservacion (fechaInicio, fechaFin, idCliente, idHabitacion) VALUES (',fechaInicio,', ',fechaFin,', ',idCliente,', ',idHabitacion,');')
  FROM INSERTED
END;

GO

-- UPDATE --
CREATE TRIGGER TR_UPD_Reservacion
ON Reservacion
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO bitacora_reservacion (operacion, fecha, usuario, query)
  SELECT 'UPDATE', GETDATE(), SUSER_NAME(), CONCAT('UPDATE Reservacion SET fechaInicio = ',fechaInicio,', fechaFin =',fechaFin,', idHabitacion = ',idHabitacion,', idCliente = ',idCliente, 'WHERE idReservacion =',idReservacion)
  FROM INSERTED
END;

GO

-- DELETE --
CREATE TRIGGER TR_DEL_Reservacion
ON Reservacion
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO bitacora_reservacion (operacion, fecha, usuario, query)
  SELECT 'DELETE', GETDATE(), SUSER_NAME(), CONCAT('DELETE Reservacion WHERE idReservacion = ',idReservacion)
  FROM DELETED
END;

GO


-----------------------------
-- TipoHabitacion TRIGGERS --
-----------------------------

-- DELETE --
CREATE TRIGGER TR_DEL_TipoHabitacion
ON TipoHabitacion
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO bitacora_tipohabitacion (operacion, fecha, usuario, query)
  SELECT 'DELETE', GETDATE(), SUSER_NAME(), CONCAT('DELETE TipoHabitacion WHERE idTipoHabitacion = ',idTipoHabitacion)
  FROM DELETED
END;

GO
