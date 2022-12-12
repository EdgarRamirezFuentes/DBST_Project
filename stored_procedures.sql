-- STORED PROCEDURES SCRIPT PARA ESCOM_HOTEL DB

USE ESCOM_HOTEL;

------------------------------
-- HELPER STORED PROCEDURES --
------------------------------

CREATE PROCEDURE sp_obtenerRolUsuario
    @idUsuario INT
AS
BEGIN

	DECLARE @rol VARCHAR(50);

    EXEC @rol = fn_obtenerRolUsuario @idUsuario;

    SELECT @idUsuario AS 'idUsuario', @rol AS 'rol'
END

GO

-------------------------------
--  AUTH STORED PROCEDURES --
-------------------------------

CREATE PROCEDURE sp_login(@correo VARCHAR(50), @contrasenia VARCHAR(50))
AS
BEGIN
    DECLARE @idUsuario INT;
    DECLARE @rolUsuario VARCHAR(50);

    EXEC @idUsuario = fn_login @correo, @contrasenia;
    EXEC @rolUsuario = fn_obtenerRolUsuario @idUsuario;

    SELECT @idUsuario, @rolUsuario
END

GO


----------------------------
-- ROLE STORED PROCEDURES --
----------------------------

CREATE PROCEDURE sp_rol_crud
    @idRol INT,
    @nombre VARCHAR(50),
    @accion NVARCHAR(20) = ''
AS
BEGIN
    IF @accion = 'INSERT'
    BEGIN
        DECLARE @inserted TABLE (
            idRol INT,
            nombre VARCHAR(50)
        );

        INSERT INTO Rol (nombre)
        OUTPUT INSERTED.*
        INTO @inserted
        VALUES (@nombre)

        SELECT * FROM @inserted
    END

    ELSE IF @accion = 'FINDALL'
    BEGIN
        SELECT * FROM Rol
    END

    ELSE IF @accion = 'FIND'
    BEGIN
        SELECT * FROM Rol WHERE idRol = @idRol
    END

    ELSE IF @accion = 'UPDATE'
    BEGIN
        DECLARE @updated TABLE (
            idRol INT,
            nombre VARCHAR(50)
        );

        UPDATE Rol
        SET nombre = @nombre
        OUTPUT INSERTED.*
        INTO @updated
        WHERE idRol = @idRol

        SELECT * FROM @updated
    END

    ELSE IF @accion = 'DELETE'
    BEGIN
        DECLARE @deleted TABLE (
            idRol INT,
            nombre VARCHAR(50)
        );

        DELETE FROM Rol
        OUTPUT DELETED.*
        INTO @deleted
        WHERE idRol = @idRol

        SELECT * FROM @deleted
    END
END

GO

----------------------------
-- USER STORED PROCEDURES --
----------------------------

CREATE PROCEDURE sp_usuario_crud
    @idUsuario INT,
    @nombre VARCHAR(50),
    @apPaterno VARCHAR(50),
    @apMaterno VARCHAR(50),
    @fechaNacimiento DATE,
    @sexo VARCHAR(1),
    @curp VARCHAR(18),
    @rfc VARCHAR(13),
    @telefono VARCHAR(10),
    @correo VARCHAR(50),
    @contrasenia VARCHAR(50),
    @idRol INT,
    @accion NVARCHAR(20) = ''
AS
BEGIN
    IF @accion = 'INSERT'
    BEGIN
        DECLARE @inserted TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

        INSERT INTO Usuario
        (
            nombre, apPaterno,
            apMaterno, fechaNacimiento,
            sexo, curp, rfc, telefono,
            correo, contrasenia, idRol
        )
        OUTPUT INSERTED.idUsuario, INSERTED.nombre, INSERTED.apPaterno, INSERTED.apMaterno, INSERTED.activo
        INTO @inserted
        VALUES
        (
            @nombre, @apPaterno,
            @apMaterno, @fechaNacimiento,
            @sexo, @curp, @rfc, @telefono,
            @correo, HASHBYTES('SHA2_256', @contrasenia), @idRol
        )

        SELECT * FROM @inserted
    END
    ELSE IF @accion = 'FINDALL'
    BEGIN
        SELECT idUsuario, nombre,
        apPaterno, apMaterno,
        fechaNacimiento, sexo,
        curp, rfc, telefono, correo,
        idRol, activo
        FROM Usuario
    END
    ELSE IF @accion = 'FIND'
    BEGIN
        SELECT idUsuario, nombre,
        apPaterno, apMaterno,
        fechaNacimiento, sexo,
        curp, rfc, telefono, correo,
        idRol, activo
        FROM Usuario
        WHERE idUsuario = @idUsuario
    END
    ELSE IF @accion = 'UPDATE'
    BEGIN
        DECLARE @updated TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

        UPDATE Usuario
        SET nombre = @nombre,
            apPaterno = @apPaterno,
            apMaterno = @apMaterno,
            fechaNacimiento = @fechaNacimiento,
            sexo = @sexo,
            curp = @curp,
            rfc = @rfc,
            telefono = @telefono,
            correo = @correo,
            idRol = @idRol
        OUTPUT INSERTED.idUsuario, INSERTED.nombre, INSERTED.apPaterno, INSERTED.apMaterno, INSERTED.activo
        INTO @updated
        WHERE idUsuario = @idUsuario

        SELECT * FROM @updated
    END
    ELSE IF @accion = 'DELETE'
    BEGIN
        DECLARE @deleted TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

        UPDATE Usuario
        SET activo = 0
        OUTPUT INSERTED.idUsuario, INSERTED.nombre, INSERTED.apPaterno, INSERTED.apMaterno, INSERTED.activo
        INTO @deleted
        WHERE idUsuario = @idUsuario

        SELECT * FROM @deleted
    END
END

GO

--------------------------------
-- EMPLOYEE STORED PROCEDURES --
--------------------------------

CREATE PROCEDURE sp_empleado_crud
    -- Usuario Data --
    @idUsuario INT,
    @nombre VARCHAR(50),
    @apPaterno VARCHAR(50),
    @apMaterno VARCHAR(50),
    @fechaNacimiento DATE,
    @sexo VARCHAR(1),
    @curp VARCHAR(18),
    @rfc VARCHAR(13),
    @telefono VARCHAR(10),
    @correo VARCHAR(50),
    @contrasenia VARCHAR(50),
    @idRol INT,
    -- Direccion Data --
    @calle VARCHAR(50),
    @numeroExterior VARCHAR(10),
    @numeroInterior VARCHAR(10),
    @colonia VARCHAR(50),
    @estado VARCHAR(50),
    @alcaldia VARCHAR(50),
    @codigoPostal VARCHAR(5),
    -- Contacto emergencia Data --
    @nombreContacto VARCHAR(50),
    @apPaternoContacto VARCHAR(50),
    @apMaternoContacto VARCHAR(50),
    @telefonoContacto VARCHAR(10),
    -- Trabajador Data --
    @sueldo MONEY,
    @idArea INT,
    @accion NVARCHAR(20) = ''
AS
BEGIN
    IF @accion = 'INSERT'
    BEGIN
        DECLARE @inserted TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

        DECLARE @userID INT;

        INSERT @inserted EXEC sp_usuario_crud
            @idUsuario, @nombre, @apPaterno,
            @apMaterno, @fechaNacimiento, @sexo,
            @curp, @rfc, @telefono, @correo,
            @contrasenia, @idRol, 'INSERT'

        SET @userID = (SELECT idUsuario FROM @inserted)

        INSERT INTO Direccion
        (
            idUsuario, calle, numExterior,
            numInterior, colonia, estado,
            alcaldia, codigoPostal
        )
        VALUES
        (
            @userID, @calle, @numeroExterior,
            @numeroInterior, @colonia, @estado,
            @alcaldia, @codigoPostal
        )

        INSERT INTO ContactoEmergencia
        (
            idUsuario, nombre, apPaterno,
            apMaterno, telefono
        )
        VALUES
        (
            @userID, @nombreContacto, @apPaternoContacto,
            @apMaternoContacto, @telefonoContacto
        )

        INSERT INTO Trabajador
        (
            idUsuario, sueldo, idArea
        )
        VALUES
        (
            @userID, @sueldo, @idArea
        )

        SELECT * FROM @inserted
    END

    ELSE IF @accion = 'FINDALL'
    BEGIN
        SELECT s.idUsuario, CONCAT(s.nombre, ' ', s.apPaterno, ' ', s.apMaterno) AS Nombre, a.nombre AS area
        FROM Usuario s
        INNER JOIN Trabajador t
        ON s.idUsuario = t.idUsuario
        INNER JOIN Area a
        ON t.idArea = a.idArea
        WHERE s.activo = 1
    END

    ELSE IF @accion = 'FIND'
    BEGIN
        SELECT s.idUsuario, CONCAT(s.nombre, ' ', s.apPaterno, ' ', s.apMaterno) AS Nombre, a.nombre AS area
        FROM Usuario s
        INNER JOIN Trabajador t
        ON s.idUsuario = t.idUsuario
        INNER JOIN Area a
        ON t.idArea = a.idArea
        WHERE s.activo = 1
        AND s.idUsuario = @idUsuario
    END
    ELSE IF @accion = 'UPDATE'
    BEGIN
        DECLARE @updated TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

        INSERT @updated EXEC sp_usuario_crud
            @idUsuario, @nombre, @apPaterno,
            @apMaterno, @fechaNacimiento, @sexo,
            @curp, @rfc, @telefono, @correo,
            NULL, @idRol, 'UPDATE'

        UPDATE Direccion
        SET calle = @calle,
            numExterior = @numeroExterior,
            numInterior = @numeroInterior,
            colonia = @colonia,
            estado = @estado,
            alcaldia = @alcaldia,
            codigoPostal = @codigoPostal
        WHERE idUsuario = @idUsuario

        UPDATE ContactoEmergencia
        SET nombre = @nombreContacto,
            apPaterno = @apPaternoContacto,
            apMaterno = @apMaternoContacto,
            telefono = @telefonoContacto
        WHERE idUsuario = @idUsuario

        UPDATE Trabajador
        SET sueldo = @sueldo,
            idArea = @idArea
        WHERE idUsuario = @idUsuario

        SELECT * FROM @updated
    END
    ELSE IF @accion = 'DELETE'
    BEGIN
        DECLARE @deleted TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

        INSERT @deleted EXEC sp_usuario_crud
            @idUsuario, NULL, NULL,
            NULL, NULL, NULL,
            NULL, NULL, NULL, NULL,
            NULL, NULL, 'DELETE'

        SELECT * FROM @deleted
    END
END

GO

--------------------------------
-- CUSTOMER STORED PROCEDURES --
--------------------------------

-- CREATE PROCEDURE sp_cliente_crud
--     -- Usuario Data --
--     @idUsuario INT,
--     @nombre VARCHAR(50),
--     @apPaterno VARCHAR(50),
--     @apMaterno VARCHAR(50),
--     @fechaNacimiento DATE,
--     @sexo VARCHAR(1),
--     @curp VARCHAR(18),
--     @rfc VARCHAR(13),
--     @telefono VARCHAR(10),
--     @correo VARCHAR(50),
--     @contrasenia VARCHAR(50),
--     @idRol INT,
--     -- Direccion Data --
--     @calle VARCHAR(50),
--     @numeroExterior VARCHAR(10),
--     @numeroInterior VARCHAR(10),
--     @colonia VARCHAR(50),
--     @estado VARCHAR(50),
--     @alcaldia VARCHAR(50),
--     @codigoPostal VARCHAR(5),
--     -- Contacto emergencia Data --
--     @nombreContacto VARCHAR(50),
--     @apPaternoContacto VARCHAR(50),
--     @apMaternoContacto VARCHAR(50),
--     @telefonoContacto VARCHAR(10),
--     @accion NVARCHAR(20) = ''
-- AS
-- BEGIN
--     IF @accion = 'INSERT'
--     BEGIN
--         DECLARE @inserted TABLE (
--             idUsuario INT,
--             nombre VARCHAR(50),
--             apPaterno VARCHAR(50),
--             apMaterno VARCHAR(50),
--             activo BIT
--         );

--         DECLARE @userID INT;
--         DECLARE @customerID INT;

--         INSERT @inserted EXEC sp_usuario_crud
--             @idUsuario, @nombre, @apPaterno,
--             @apMaterno, @fechaNacimiento, @sexo,
--             @curp, @rfc, @telefono, @correo,
--             @contrasenia, @idRol, 'INSERT'

--         SET @userID = (SELECT idUsuario FROM @inserted)

--         INSERT INTO Direccion
--         (
--             idUsuario, calle, numExterior,
--             numInterior, colonia, estado,
--             alcaldia, codigoPostal
--         )
--         VALUES
--         (
--             @userID, @calle, @numeroExterior,
--             @numeroInterior, @colonia, @estado,
--             @alcaldia, @codigoPostal
--         )

--         INSERT INTO ContactoEmergencia
--         (
--             idUsuario, nombre, apPaterno,
--             apMaterno, telefono
--         )
--         VALUES
--         (
--             @userID, @nombreContacto, @apPaternoContacto,
--             @apMaternoContacto, @telefonoContacto
--         )

--         INSERT INTO Cliente
--         (
--             idUsuario
--         )
--         VALUES
--         (
--             @userID
--         )

--         SELECT * FROM @inserted
--     END
--     ELSE IF @accion = 'FINDALL'
--     BEGIN
--         SELECT * FROM Usuario
--         INNER JOIN Cliente
--         ON Usuario.idUsuario = Cliente.idUsuario
--         INNER JOIN Direccion
--         ON Usuario.idUsuario = Direccion.idUsuario
--         INNER JOIN ContactoEmergencia
--         ON Usuario.idUsuario = ContactoEmergencia.idUsuario
--         WHERE Usuario.idUsuario = @idUsuario
--     END
--     ELSE IF @accion = 'UPDATE'
--     BEGIN
--         DECLARE @updated TABLE (
--             idUsuario INT,
--             nombre VARCHAR(50),
--             apPaterno VARCHAR(50),
--             apMaterno VARCHAR(50),
--             activo BIT
--         );

--         INSERT @updated EXEC sp_usuario_crud
--             @idUsuario, @nombre, @apPaterno,
--             @apMaterno, @fechaNacimiento, @sexo,
--             @curp, @rfc, @telefono, @correo,
--             NULL, @idRol, 'UPDATE'

--         UPDATE Direccion
--         SET calle = @calle, numExterior = @numeroExterior,
--             numInterior = @numeroInterior, colonia = @colonia,
--             estado = @estado, alcaldia = @alcaldia, codigoPostal = @codigoPostal
--         WHERE idUsuario = @idUsuario

--         UPDATE ContactoEmergencia
--         SET nombre = @nombreContacto, apPaterno = @apPaternoContacto,
--             apMaterno = @apMaternoContacto, telefono = @telefonoContacto
--         WHERE idUsuario = @idUsuario

--         SELECT * FROM @updated
--     END

--     ELSE IF @accion = 'DELETE'
--     BEGIN
--         DECLARE @deleted TABLE (
--             idUsuario INT,
--             nombre VARCHAR(50),
--             apPaterno VARCHAR(50),
--             apMaterno VARCHAR(50),
--             activo BIT
--         );

--         INSERT @deleted EXEC sp_usuario_crud
--             @idUsuario, NULL, NULL,
--             NULL, NULL, NULL,
--             NULL, NULL, NULL, NULL,
--             NULL, NULL, 'DELETE'

--         SELECT * FROM @deleted
--     END
-- END