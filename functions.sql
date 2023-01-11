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

CREATE FUNCTION fn_obtenerNombreUsuario
(
    @idUsuario int
)
RETURNS VARCHAR(250)
AS
BEGIN
    DECLARE @nombre VARCHAR(250)
    SELECT @nombre = nombre
    FROM Usuario
    WHERE idUsuario = @idUsuario

    IF @idUsuario IS NULL
        SET @idUsuario = 'SETROC'
    
    RETURN @nombre;
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



---------------------------
-- TICKET  FUNCTIONS ------
---------------------------
CREATE FUNCTION fn_obtenerNoches
(
    @idReservacion INT
)
RETURNS INT
AS
BEGIN
    DECLARE @noches INT
    SELECT @noches = DATEDIFF(DAY,fechaInicio,fechaFin)
    FROM Reservacion
    WHERE idReservacion = @idReservacion
    RETURN @noches
END

CREATE FUNCTION fn_obtenerPrecio
(
    @idHabitacion INT
)
RETURNS MONEY
AS
BEGIN
	DECLARE @idTipoHabitacion INT
		SELECT @idTipoHabitacion = idTipoHabitacion 
		FROM Habitacion WHERE idHabitacion = @idHabitacion
    DECLARE @precio MONEY
    SELECT @precio = precio
    FROM TipoHabitacion
    WHERE idTipoHabitacion = @idTipoHabitacion
    RETURN @precio
END

----
CREATE FUNCTION fn_SubTotal
(
@idReservacion INT
)
RETURNS MONEY
AS
BEGIN
	DECLARE @idHabitacion INT
		SELECT @idHabitacion = idHabitacion
		FROM Reservacion
		WHERE idReservacion = @idReservacion
	DECLARE @precioNoche MONEY
		SELECT @precioNoche = dbo.fn_obtenerPrecio(@idHabitacion)
	DECLARE @noches INT
		SELECT @noches = dbo.fn_obtenerNoches(@idReservacion) 
	DECLARE @subTotal MONEY
		SELECT @subTotal = CAST((CAST(@precioNoche AS INT)) * @noches AS MONEY)
	RETURN @subTotal
END

GO

CREATE FUNCTION fn_obtenerSubTotal
(
@idTicket INT
)
RETURNS MONEY
AS
BEGIN
	DECLARE @subTotal MONEY
		SELECT @subTotal = subTotal
		FROM Ticket WHERE idTicket = @idTicket
	RETURN @subTotal
END

GO

CREATE FUNCTION fn_totalCargosExtra
(
@idCargosExtra VARCHAR(100)
)
RETURNS MONEY
AS
BEGIN
	DECLARE @len INT
		SELECT @len = CAST(LEN(@idCargosExtra) AS INT);
	DECLARE @count INT = 1;
	DECLARE @auxPrecio MONEY;
	DECLARE @totalCargos MONEY = 0;
	DECLARE @idAUX INT;
	WHILE (@count <= @len)
	BEGIN
		SELECT @idAUX = CAST(SUBSTRING(@idCargosExtra,@count,1) AS INT);
		SELECT @auxPrecio = precio FROM CargoExtra WHERE idCargoExtra =  @idAUX;
        SET @totalCargos = @totalCargos + @auxPrecio;
		SET @count = @count + 1;
	END;
			
	RETURN @totalCargos;
END