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
    AND contrasenia = HASHBYTES('SHA2_256', @contrasenia);

    IF @idUsuario IS NULL
        SET @idUsuario = -1

     RETURN @idUsuario;
END

GO

