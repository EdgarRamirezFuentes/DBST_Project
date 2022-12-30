-- FUNCTIONS SCRIPT FOR ESCOM_HOTEL DB

USE ESCOM_HOTEL;

-----------------------
--  HELPER FUNCTIONS --
-----------------------

CREATE FUNCTION fn_obtenerRolUsuario
(
    @idUsuario INT
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @rol VARCHAR(50);
    SELECT @rol = nombre
    FROM Rol
    WHERE idRol = (SELECT idRol FROM Usuario WHERE idUsuario = @idUsuario)
    RETURN @rol
END

GO

--------------------
-- AUTH FUNCTIONS --
--------------------

CREATE FUNCTION fn_login
(
    @correo VARCHAR(50),
    @contrasenia VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @idUsuario INT;

    SELECT @idUsuario = idUsuario
    FROM Usuario
    WHERE correo = @correo
    AND contrasenia = HASHBYTES('SHA2_256', @contrasenia)
    AND activo = 1;

    IF @idUsuario IS NULL
        SET @idUsuario = -1

     RETURN @idUsuario;
END

GO


---------------------------
-- RESERVATION FUNCTIONS --
---------------------------

CREATE FUNCTION fn_obtenerHabitacionesDisponibles
(
    @fechaInicio DATETIME,
    @fechaFin DATETIME
)
RETURNS @habitacionesDisponibles TABLE
(
	idHabitacion INT,
	nombre VARCHAR(50),
    descripcion VARCHAR(50),
    nombreTipo VARCHAR(50),
    numCamas INT,
    numPersonas INT,
    precio MONEY
)
AS
BEGIN
    INSERT INTO @habitacionesDisponibles
    SELECT h.idHabitacion, h.nombre, h.descripcion,
    th.nombre AS nombreTipo, th.numCamas, th.numPersonas, th.precio FROM Habitacion h
    LEFT JOIN Reservacion r
    ON h.idHabitacion = r.idHabitacion
    INNER JOIN TipoHabitacion th
    ON h.idTipoHabitacion = th.idTipoHabitacion
    WHERE
    r.idHabitacion IS NULL -- NOT RESERVED
    OR
    ( -- AVAILABLE IN THAT DATE
    @fechaInicio NOT BETWEEN r.fechaInicio AND DATEADD(DAY, -1, r.fechaFin)
    AND
    @fechaFin NOT BETWEEN DATEADD(DAY, 1, r.fechaInicio) AND r.fechaFin
    )
    RETURN
END

GO