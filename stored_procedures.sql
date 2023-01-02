-- STORED PROCEDURES SCRIPT PARA ESCOM_HOTEL DB

USE ESCOM_HOTEL;

------------------------------
-- HELPER STORED PROCEDURES --
------------------------------


-------------------------------
--  AUTH STORED PROCEDURES --
-------------------------------

CREATE PROCEDURE sp_login(@correo VARCHAR(50), @contrasenia VARCHAR(50))
AS
BEGIN
    BEGIN TRY
        BEGIN
            DECLARE @idUsuario INT;
            DECLARE @rolUsuario VARCHAR(50);

            IF @correo IS NULL OR @contrasenia IS NULL
            OR @correo = '' OR @contrasenia = ''
            BEGIN
                RAISERROR('Email and password are required', 16, 1)
                RETURN
            END

            EXEC @idUsuario = fn_login @correo, @contrasenia;
            EXEC @rolUsuario = fn_obtenerRolUsuario @idUsuario;

            SELECT @idUsuario, @rolUsuario
        END
    END TRY
    BEGIN CATCH
        BEGIN
            RAISERROR('Something went wrong', 16, 1)
        END
    END CATCH
END

GO


----------------------------
-- ROLE STORED PROCEDURES --
----------------------------

CREATE PROCEDURE sp_rol_crud
    @idRol INT,
    @nombre VARCHAR(50),
    @accion NVARCHAR(20) = 'FINDALL'
AS
BEGIN

	DECLARE @ERROR INT;
    DECLARE @data TABLE (
        idRol INT,
        nombre VARCHAR(50)
    );

    IF @accion = 'INSERT'
    BEGIN
        BEGIN TRANSACTION

            INSERT INTO Rol (nombre)
            OUTPUT INSERTED.*
            INTO @data
            VALUES (@nombre)

            SELECT @ERROR = @@ERROR;

            IF @ERROR = 0
            BEGIN
                COMMIT TRANSACTION
                SELECT * FROM @data
            END
            ELSE
            BEGIN
                ROLLBACK TRANSACTION
                RAISERROR('Something went wrong', 16, 1)
            END
    END

    ELSE IF @accion = 'FINDALL'
    BEGIN
        SELECT * FROM Rol
    END

    ELSE IF @accion = 'FIND'
    BEGIN

        IF @idRol IS NULL OR @idRol < 1
        BEGIN
            RAISERROR('The id is required', 16, 1)
            RETURN
        END

        SELECT * FROM Rol WHERE idRol = @idRol
    END

    ELSE IF @accion = 'UPDATE'
    BEGIN
        BEGIN TRANSACTION

            if @idRol IS NULL OR @idRol < 1
            OR @nombre IS NULL OR @nombre = ''
            BEGIN
                ROLLBACK TRANSACTION
                RAISERROR('The role and name are required', 16, 1)
                RETURN
            END

            UPDATE Rol
            SET nombre = @nombre
            OUTPUT INSERTED.*
            INTO @data
            WHERE idRol = @idRol

            SELECT @ERROR = @@ERROR;

            IF @ERROR = 0
            BEGIN
                COMMIT TRANSACTION
                SELECT * FROM @data
            END
            ELSE
            BEGIN
                ROLLBACK TRANSACTION
                RAISERROR('Something went wrong', 16, 1)
            END
    END

    ELSE IF @accion = 'DELETE'
    BEGIN
        BEGIN TRANSACTION

            IF @idRol IS NULL OR @idRol = 0
                ROLLBACK TRANSACTION
                RAISERROR('The id is required', 16, 1)
                RETURN

            DELETE FROM Rol
            OUTPUT DELETED.*
            INTO @data
            WHERE idRol = @idRol

            SELECT @ERROR = @@ERROR;

            IF @ERROR = 0
            BEGIN
                COMMIT TRANSACTION
                SELECT * FROM @data
            END
            ELSE
            BEGIN
                ROLLBACK TRANSACTION
                RAISERROR('Something went wrong', 16, 1)
            END
    END
END


--------------------------------
-- EMPLOYEE STORED PROCEDURES --
--------------------------------

CREATE PROCEDURE sp_trabajador_crud
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
    @accion NVARCHAR(20) = 'FINDALL'
AS
BEGIN
    DECLARE @ERROR INT;
    DECLARE @MSG VARCHAR(50);
    DECLARE @data TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

    IF @accion = 'INSERT'
    BEGIN
        BEGIN TRANSACTION

            IF @nombre IS NULL OR @nombre = '' OR @apPaterno IS NULL OR @apPaterno = ''
            OR @apMaterno IS NULL OR @apMaterno = '' OR @fechaNacimiento IS NULL OR
            @sexo IS NULL OR @sexo = '' OR @curp IS NULL OR @curp = ''
            OR @telefono IS NULL OR @telefono = '' OR @correo IS NULL OR @correo = ''
            OR @contrasenia IS NULL OR @contrasenia = ''
            BEGIN
                SET @MSG = 'The user data is required'
                GOTO TRANSACTION_ERROR
            END

            -- User creation --
            INSERT INTO Usuario
            (
                nombre, apPaterno, apMaterno,
                fechaNacimiento, sexo, curp,
                rfc, telefono, correo, contrasenia,
                idRol, activo
            )
            OUTPUT INSERTED.idUsuario, INSERTED.nombre, INSERTED.apPaterno, INSERTED.apMaterno, INSERTED.activo
            INTO @data
            VALUES
            (
                @nombre, @apPaterno, @apMaterno,
                @fechaNacimiento, @sexo, @curp,
                @rfc, @telefono, @correo, HASHBYTES('SHA2_256', @contrasenia),
                @idRol, 1
            )

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the user data'
                GOTO TRANSACTION_ERROR;
            END

            SET @idUsuario = (SELECT idUsuario FROM @data)

            -- Address creation --

            IF @calle IS NULL OR @calle = '' OR @numeroExterior IS NULL
            OR @numeroExterior = '' OR @colonia IS NULL OR @colonia = ''
            OR @estado IS NULL OR @estado = '' OR @alcaldia IS NULL
            OR @alcaldia = '' OR @codigoPostal IS NULL OR @codigoPostal = ''
            BEGIN
                SET @MSG = 'The address data is required'
                GOTO TRANSACTION_ERROR
            END

            INSERT INTO Direccion
            (
                idUsuario, calle, numExterior,
                numInterior, colonia, estado,
                alcaldia, codigoPostal
            )
            VALUES
            (
                @idUsuario, @calle, @numeroExterior,
                @numeroInterior, @colonia, @estado,
                @alcaldia, @codigoPostal
            )

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the address data'
                GOTO TRANSACTION_ERROR;
            END

            -- Emergency contact creation --

            IF @nombreContacto IS NULL OR @nombreContacto = '' OR @apPaternoContacto IS NULL
            OR @apPaternoContacto = '' OR @apMaternoContacto IS NULL OR @apMaternoContacto = ''
            OR @telefonoContacto IS NULL OR @telefonoContacto = ''
            BEGIN
                SET @MSG = 'The emergency contact data is required'
                GOTO TRANSACTION_ERROR
            END

            INSERT INTO ContactoEmergencia
            (
                idUsuario, nombre, apPaterno,
                apMaterno, telefono
            )
            VALUES
            (
                @idUsuario, @nombreContacto, @apPaternoContacto,
                @apMaternoContacto, @telefonoContacto
            )

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the emergency contact data'
                GOTO TRANSACTION_ERROR;
            END

            -- Employee creation --

            IF @sueldo IS NULL
            BEGIN
                SET @MSG = 'The employee salary is required'
                GOTO TRANSACTION_ERROR
            END

            INSERT INTO Trabajador
            (
                idUsuario, sueldo, idArea
            )
            VALUES
            (
                @idUsuario, @sueldo, @idArea
            )

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the employee data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
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
        SELECT s.idUsuario, s.nombre, s.apPaterno, s.apMaterno ,
        s.fechaNacimiento ,s.sexo AS genero ,s.curp ,
        s.rfc, s.telefono, s.correo,
        a.nombre AS area,
        d.calle, d.numExterior AS numeroExterior,
        d.numInterior AS numeroInterior, d.colonia, d.estado,
        d.alcaldia, d.codigoPostal,ce.nombre AS nombreContactoEmergencia,
        ce.apPaterno AS apPaternoContactoEmergencia, ce.apMaterno AS apMaternoContactoEmergencia,
        ce.telefono AS telefonoContactoEmergencia, t.sueldo AS salario, t.idArea
        FROM Usuario s
        INNER JOIN Trabajador t
        ON s.idUsuario = t.idUsuario
        INNER JOIN Area a
        ON t.idArea = a.idArea
        INNER JOIN Direccion d
        ON d.idUsuario = s.idUsuario
        INNER JOIN ContactoEmergencia ce
        ON ce.idUsuario = s.idUsuario
        WHERE s.activo = 1
        AND s.idUsuario = @idUsuario
    END

    ELSE IF @accion = 'UPDATE'
    BEGIN
        BEGIN TRANSACTION
            IF @idUsuario IS NULL OR @idUsuario < 1
            BEGIN
                SET @MSG = 'The user id is required'
                GOTO TRANSACTION_ERROR
            END

            IF @nombre IS NULL OR @nombre = '' OR @apPaterno IS NULL OR @apPaterno = ''
            OR @apMaterno IS NULL OR @apMaterno = '' OR @fechaNacimiento IS NULL OR
            @sexo IS NULL OR @sexo = '' OR @curp IS NULL OR @curp = ''
            OR @telefono IS NULL OR @telefono = '' OR @correo IS NULL OR @correo = ''
            BEGIN
                SET @MSG = 'The user data is required'
                GOTO TRANSACTION_ERROR
            END

            -- User update --
            UPDATE Usuario
            SET nombre = @nombre, apPaterno = @apPaterno, apMaterno = @apMaterno,
            fechaNacimiento = @fechaNacimiento, sexo = @sexo, curp = @curp,
            rfc = @rfc, telefono = @telefono, correo = @correo
            WHERE idUsuario = @idUsuario

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to update the user data'
                GOTO TRANSACTION_ERROR;
            END

            -- Address update --

            IF @calle IS NULL OR @calle = '' OR @numeroExterior IS NULL
            OR @numeroExterior = '' OR @colonia IS NULL OR @colonia = ''
            OR @estado IS NULL OR @estado = '' OR @alcaldia IS NULL
            OR @alcaldia = '' OR @codigoPostal IS NULL OR @codigoPostal = ''
            BEGIN
                SET @MSG = 'The address data is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE Direccion
            SET calle = @calle, numExterior = @numeroExterior, numInterior = @numeroInterior,
            colonia = @colonia, estado = @estado, alcaldia = @alcaldia,
            codigoPostal = @codigoPostal
            WHERE idUsuario = @idUsuario

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to update the address data'
                GOTO TRANSACTION_ERROR;
            END

            -- Emergency contact update --

            IF @nombreContacto IS NULL OR @nombreContacto = '' OR @apPaternoContacto IS NULL
            OR @apPaternoContacto = '' OR @apMaternoContacto IS NULL OR @apMaternoContacto = ''
            OR @telefonoContacto IS NULL OR @telefonoContacto = ''
            BEGIN
                SET @MSG = 'The emergency contact data is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE ContactoEmergencia
            SET nombre = @nombreContacto, apPaterno = @apPaternoContacto, apMaterno = @apMaternoContacto,
            telefono = @telefonoContacto
            WHERE idUsuario = @idUsuario

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to update the emergency contact data'
                GOTO TRANSACTION_ERROR;
            END

            -- Employee update --

            IF @sueldo IS NULL
            BEGIN
                SET @MSG = 'The employee salary is required'
                GOTO TRANSACTION_ERROR
            END

            INSERT INTO Trabajador
            (
                idUsuario, sueldo, idArea
            )
            VALUES
            (
                @idUsuario, @sueldo, @idArea
            )

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the employee data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
    END

    ELSE IF @accion = 'DELETE'
    BEGIN
        BEGIN TRANSACTION
            IF @idUsuario IS NULL OR @idUsuario < 1
            BEGIN
                SET @MSG = 'The user id is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE Usuario
            SET activo = 0
            OUTPUT INSERTED.idUsuario, INSERTED.nombre,
            INSERTED.apPaterno, INSERTED.apMaterno, INSERTED.activo
            INTO @data
            WHERE idUsuario = @idUsuario

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to delete the user data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
    END

    TRANSACTION_ERROR:
        IF @ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION
            RAISERROR(@MSG, 16, 1)
        END
END

GO

--------------------------------
-- CUSTOMER STORED PROCEDURES --
--------------------------------

CREATE PROCEDURE sp_cliente_crud
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
    @accion NVARCHAR(20) = 'FINDALL'
AS
BEGIN
    DECLARE @MSG VARCHAR(50);
    DECLARE @ERROR INT;
    DECLARE @data TABLE (
        idUsuario INT,
        nombre VARCHAR(50),
        apPaterno VARCHAR(50),
        apMaterno VARCHAR(50),
        activo BIT
    );

    IF @accion = 'INSERT'
    BEGIN
        BEGIN TRANSACTION

            IF @nombre IS NULL OR @nombre = '' OR @apPaterno IS NULL OR @apPaterno = ''
            OR @apMaterno IS NULL OR @apMaterno = '' OR @fechaNacimiento IS NULL OR
            @sexo IS NULL OR @sexo = '' OR @curp IS NULL OR @curp = ''
            OR @telefono IS NULL OR @telefono = '' OR @correo IS NULL OR @correo = ''
            OR @contrasenia IS NULL OR @contrasenia = ''
            BEGIN
                SET @MSG = 'The user data is required'
                GOTO TRANSACTION_ERROR
            END

            -- User creation --
            INSERT INTO Usuario
            (
                nombre, apPaterno, apMaterno,
                fechaNacimiento, sexo, curp,
                rfc, telefono, correo, contrasenia,
                idRol, activo
            )
            OUTPUT INSERTED.idUsuario, INSERTED.nombre, INSERTED.apPaterno, INSERTED.apMaterno, INSERTED.activo
            INTO @data
            VALUES
            (
                @nombre, @apPaterno, @apMaterno,
                @fechaNacimiento, @sexo, @curp,
                @rfc, @telefono, @correo, HASHBYTES('SHA2_256', @contrasenia),
                @idRol, 1
            )

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the user data'
                GOTO TRANSACTION_ERROR;
            END

            SET @idUsuario = (SELECT idUsuario FROM @data)

            -- Address creation --

            IF @calle IS NULL OR @calle = '' OR @numeroExterior IS NULL
            OR @numeroExterior = '' OR @colonia IS NULL OR @colonia = ''
            OR @estado IS NULL OR @estado = '' OR @alcaldia IS NULL
            OR @alcaldia = '' OR @codigoPostal IS NULL OR @codigoPostal = ''
            BEGIN
                SET @MSG = 'The address data is required'
                GOTO TRANSACTION_ERROR
            END

            INSERT INTO Direccion
            (
                idUsuario, calle, numExterior,
                numInterior, colonia, estado,
                alcaldia, codigoPostal
            )
            VALUES
            (
                @idUsuario, @calle, @numeroExterior,
                @numeroInterior, @colonia, @estado,
                @alcaldia, @codigoPostal
            )

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the address data'
                GOTO TRANSACTION_ERROR;
            END

            -- Emergency contact creation --

            IF @nombreContacto IS NULL OR @nombreContacto = '' OR @apPaternoContacto IS NULL
            OR @apPaternoContacto = '' OR @apMaternoContacto IS NULL OR @apMaternoContacto = ''
            OR @telefonoContacto IS NULL OR @telefonoContacto = ''
            BEGIN
                SET @MSG = 'The emergency contact data is required'
                GOTO TRANSACTION_ERROR
            END

            INSERT INTO ContactoEmergencia
            (
                idUsuario, nombre, apPaterno,
                apMaterno, telefono
            )
            VALUES
            (
                @idUsuario, @nombreContacto, @apPaternoContacto,
                @apMaternoContacto, @telefonoContacto
            )

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the emergency contact data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the employee data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
    END

    ELSE IF @accion = 'FINDALL'
    BEGIN
        SELECT s.idUsuario,
        CONCAT(s.nombre, ' ', s.apPaterno, ' ', s.apMaterno) AS Nombre,
        s.telefono ,s.correo
        FROM Usuario s
        INNER JOIN Cliente c
        ON s.idUsuario = c.idUsuario
        WHERE s.activo = 1
    END

    ELSE IF @accion = 'FIND'
    BEGIN
        IF @idUsuario IS NULL OR @idUsuario < 1
        BEGIN
            RAISERROR('The id is required', 16, 1)
            RETURN
        END

        SELECT
        u.idUsuario, u.nombre, u.apPaterno,
        u.apMaterno, u.fechaNacimiento,
        u.sexo AS genero, u.curp, u.rfc,
        u.telefono, u.correo, u.fechaRegistro,
        d.calle, d.numExterior AS numeroExterior,
        d.numInterior AS numeroInterior, d.colonia,
        d.estado, d.alcaldia, d.codigoPostal,
        ce.nombre AS nombreContactoEmergencia,
        ce.apPaterno AS apPaternoContactoEmergencia,
        ce.apMaterno AS apMaternoContactoEmergencia,
        ce.telefono AS telefonoContactoEmergencia
        FROM Usuario u
        INNER JOIN Direccion d
        ON d.idUsuario = u.idUsuario
        INNER JOIN ContactoEmergencia ce
        ON ce.idUsuario = u.idUsuario
        WHERE u.activo = 1
        AND u.idUsuario = @idUsuario
    END

    ELSE IF @accion = 'UPDATE'
    BEGIN
        BEGIN TRANSACTION
            IF @idUsuario IS NULL OR @idUsuario < 1
            BEGIN
                SET @MSG = 'The user id is required'
                GOTO TRANSACTION_ERROR
            END

            IF @nombre IS NULL OR @nombre = '' OR @apPaterno IS NULL OR @apPaterno = ''
            OR @apMaterno IS NULL OR @apMaterno = '' OR @fechaNacimiento IS NULL OR
            @sexo IS NULL OR @sexo = '' OR @curp IS NULL OR @curp = ''
            OR @telefono IS NULL OR @telefono = '' OR @correo IS NULL OR @correo = ''
            BEGIN
                SET @MSG = 'The user data is required'
                GOTO TRANSACTION_ERROR
            END

            -- User update --
            UPDATE Usuario
            SET nombre = @nombre, apPaterno = @apPaterno, apMaterno = @apMaterno,
            fechaNacimiento = @fechaNacimiento, sexo = @sexo, curp = @curp,
            rfc = @rfc, telefono = @telefono, correo = @correo
            OUTPUT INSERTED.idUsuario, INSERTED.nombre, INSERTED.apPaterno, INSERTED.apMaterno, INSERTED.activo
            INTO @data
            WHERE idUsuario = @idUsuario

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to update the user data'
                GOTO TRANSACTION_ERROR;
            END

            -- Address update --

            IF @calle IS NULL OR @calle = '' OR @numeroExterior IS NULL
            OR @numeroExterior = '' OR @colonia IS NULL OR @colonia = ''
            OR @estado IS NULL OR @estado = '' OR @alcaldia IS NULL
            OR @alcaldia = '' OR @codigoPostal IS NULL OR @codigoPostal = ''
            BEGIN
                SET @MSG = 'The address data is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE Direccion
            SET calle = @calle, numExterior = @numeroExterior, numInterior = @numeroInterior,
            colonia = @colonia, estado = @estado, alcaldia = @alcaldia,
            codigoPostal = @codigoPostal
            WHERE idUsuario = @idUsuario

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to update the address data'
                GOTO TRANSACTION_ERROR;
            END

            -- Emergency contact update --

            IF @nombreContacto IS NULL OR @nombreContacto = '' OR @apPaternoContacto IS NULL
            OR @apPaternoContacto = '' OR @apMaternoContacto IS NULL OR @apMaternoContacto = ''
            OR @telefonoContacto IS NULL OR @telefonoContacto = ''
            BEGIN
                SET @MSG = 'The emergency contact data is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE ContactoEmergencia
            SET nombre = @nombreContacto, apPaterno = @apPaternoContacto, apMaterno = @apMaternoContacto,
            telefono = @telefonoContacto
            WHERE idUsuario = @idUsuario

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to update the emergency contact data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
    END

    ELSE IF @accion = 'DELETE'
    BEGIN
        BEGIN TRANSACTION
            IF @idUsuario IS NULL OR @idUsuario < 1
            BEGIN
                SET @MSG = 'The user id is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE Usuario
            SET activo = 0
            OUTPUT INSERTED.idUsuario, INSERTED.nombre,
            INSERTED.apPaterno, INSERTED.apMaterno, INSERTED.activo
            INTO @data
            WHERE idUsuario = @idUsuario

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to delete the user data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
    END

    TRANSACTION_ERROR:
        IF @ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION
            RAISERROR(@MSG, 16, 1)
        END
END

GO

---------------------------------
-- Type Room STORED PROCEDURES --
---------------------------------


CREATE PROCEDURE sp_tipo_habitacion_crud
@idTipoHabitacion INT,
@nombre VARCHAR(50),
@numCamas INT,
@numPersonas INT,
@precio MONEY,
@accion VARCHAR(15) = 'FINDALL'
AS
BEGIN
    DECLARE @MSG VARCHAR(100);
    DECLARE @ERROR INT;
    DECLARE @data TABLE (
        idTipoHabitacion INT,
        nombre VARCHAR(50),
        numCamas INT,
        numPersonas INT,
        precio MONEY
    );

	IF @accion = 'FINDALL'
	BEGIN
		SELECT * FROM TipoHabitacion
	END

	ELSE IF @accion = 'INSERT'
	BEGIN
		BEGIN TRANSACTION
            IF @nombre IS NULL OR @nombre = '' OR @numCamas IS NULL OR @numCamas < 1
            OR @numPersonas IS NULL OR @numPersonas < 1 OR @precio IS NULL OR @precio < 1
            BEGIN
                SET @MSG = 'The room type data is required'
                GOTO TRANSACTION_ERROR
            END

            INSERT INTO TipoHabitacion (nombre, numCamas, numPersonas, precio)
            OUTPUT INSERTED.*
            INTO @data
            VALUES (@nombre, @numCamas, @numPersonas, @precio)

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the room type';
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
	END

	ELSE IF @accion = 'FIND'
	BEGIN
        IF @idTipoHabitacion IS NULL OR @idTipoHabitacion < 1
        BEGIN
            SET @MSG = 'The room type id is required'
            GOTO TRANSACTION_ERROR
        END

		SELECT * FROM TipoHabitacion
        WHERE idTipoHabitacion = @idTipoHabitacion
	END

	ELSE IF @accion = 'UPDATE'
	BEGIN
		BEGIN TRANSACTION
            IF @idTipoHabitacion IS NULL OR @idTipoHabitacion < 1
            BEGIN
                SET @MSG = 'The room type id is required'
                GOTO TRANSACTION_ERROR
            END

            IF @nombre IS NULL OR @nombre = '' OR @numCamas IS NULL OR @numCamas < 1
            OR @numPersonas IS NULL OR @numPersonas < 1 OR @precio IS NULL OR @precio < 1
            BEGIN
                SET @MSG = 'The room type data is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE TipoHabitacion
            SET nombre = @nombre, numCamas = @numCamas,
            numPersonas = @numPersonas, precio = @precio
            OUTPUT INSERTED.*
            INTO @data
            WHERE idTipoHabitacion = @idTipoHabitacion

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to update the room type data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
	END

	ELSE IF @accion = 'DELETE'
    BEGIN
        BEGIN TRANSACTION
            IF @idTipoHabitacion IS NULL OR @idTipoHabitacion < 1
            BEGIN
                SET @MSG = 'The room type id is required'
                GOTO TRANSACTION_ERROR
            END

            DELETE FROM TipoHabitacion
            OUTPUT DELETED.*
            INTO @data
            WHERE idTipoHabitacion = @idTipoHabitacion

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to delete the room type data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
    END

    TRANSACTION_ERROR:
        IF @ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION
            RAISERROR(@MSG, 16, 1)
        END
END

GO

---------------------------------
---- Room STORED PROCEDURES -----
---------------------------------

CREATE PROCEDURE sp_habitacion_crud
@idHabitacion INT,
@nombre VARCHAR(100),
@descripcion VARCHAR(100),
@isActive BIT,
@idTipoHabitacion INT,
@accion VARCHAR(50)
AS
BEGIN
    DECLARE @MSG VARCHAR(100);
    DECLARE @ERROR INT;
    DECLARE @data TABLE (
        idHabitacion INT,
        nombre VARCHAR(50),
        descripcion VARCHAR(50),
        isActive BIT,
        idTipoHabitacion INT
    );

	IF @accion = 'FINDALL'
	BEGIN
		SELECT h.idHabitacion, h.nombre,
        h.descripcion, h.isActive,
        th.nombre as 'tipoHabitacion', h.idTipoHabitacion
        FROM Habitacion h
        INNER JOIN TipoHabitacion th
		ON th.idTipoHabitacion = h.idTipoHabitacion
		WHERE h.isActive = 1
	END

    ELSE IF @accion = 'FINDALLINACTIVE'
    BEGIN
        SELECT h.idHabitacion, h.nombre,
        h.descripcion, h.isActive,
        th.nombre as 'tipoHabitacion', h.idTipoHabitacion
        FROM Habitacion h
        INNER JOIN TipoHabitacion th
        ON th.idTipoHabitacion = h.idTipoHabitacion
        WHERE h.isActive = 0
    END

	ELSE IF @accion = 'INSERT'
	BEGIN
        BEGIN TRANSACTION
            IF @nombre IS NULL OR @nombre = '' OR @descripcion IS NULL OR @descripcion = ''
            OR @idTipoHabitacion IS NULL OR @idTipoHabitacion < 1
            BEGIN
                SET @MSG = 'The room data is required'
                GOTO TRANSACTION_ERROR
            END

            INSERT INTO Habitacion (nombre, descripcion, isActive, idTipoHabitacion)
            OUTPUT INSERTED.*
            INTO @data
            VALUES (@nombre, @descripcion, 1, @idTipoHabitacion)

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to insert the room'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
	END

    ELSE IF @accion = 'FIND'
	BEGIN
		SELECT h.idHabitacion,h.nombre,h.descripcion,
        th.nombre AS 'tipoHabitacion', th.numCamas,
        th.numPersonas, th.precio
		FROM Habitacion h
		INNER JOIN TipoHabitacion th
		ON th.idTipoHabitacion = h.idTipoHabitacion
		WHERE h.idHabitacion  = @idHabitacion
		AND h.isActive = 1
	END

    ELSE IF @accion = 'FINDINACTIVE'
    BEGIN
        SELECT h.idHabitacion,h.nombre,h.descripcion,
        th.nombre AS 'tipoHabitacion', th.numCamas,
        th.numPersonas, th.precio
        FROM Habitacion h
        INNER JOIN TipoHabitacion th
        ON th.idTipoHabitacion = h.idTipoHabitacion
        WHERE h.idHabitacion  = @idHabitacion
        AND h.isActive = 0
    END

	ELSE IF @accion = 'UPDATE'
	BEGIN
		BEGIN TRANSACTION
            IF @idHabitacion IS NULL OR @idHabitacion < 1
            BEGIN
                SET @MSG = 'The room id is required'
                GOTO TRANSACTION_ERROR
            END

            IF @nombre IS NULL OR @nombre = '' OR @descripcion IS NULL OR @descripcion = ''
            OR @idTipoHabitacion IS NULL OR @idTipoHabitacion < 1
            BEGIN
                SET @MSG = 'The room data is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE Habitacion
            SET nombre = @nombre, descripcion = @descripcion,
            idTipoHabitacion = @idTipoHabitacion
            OUTPUT INSERTED.*
            INTO @data
            WHERE idHabitacion = @idHabitacion

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to update the room data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
	END

    ELSE IF @accion = 'DELETE'
	BEGIN
		BEGIN TRANSACTION
            IF @idHabitacion IS NULL OR @idHabitacion < 1
            BEGIN
                SET @MSG = 'The room id is required'
                GOTO TRANSACTION_ERROR
            END

            UPDATE Habitacion
            SET isActive = 0
            OUTPUT INSERTED.*
            INTO @data
            WHERE idHabitacion = @idHabitacion

            SELECT @ERROR = @@ERROR;

            IF @ERROR <> 0
            BEGIN
                SET @MSG = 'There was an error trying to delete the room data'
                GOTO TRANSACTION_ERROR;
            END

            SELECT * FROM @data
            COMMIT TRANSACTION
	END

    TRANSACTION_ERROR:
        IF @ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION
            RAISERROR(@MSG, 16, 1)
        END
END

GO


----------------------------
-- RESERVATION PROCEDURES --
----------------------------

CREATE PROCEDURE sp_reservacion_crud
@idReservacion INT,
@fechaInicio DATE,
@fechaFin DATE,
@idHabitacion INT,
@idCliente INT,
@accion VARCHAR(50)
AS
BEGIN
    IF @accion = 'FINDALL'
    BEGIN
        SELECT r.idReservacion, r.fechaInicio, r.fechaFin, r.idHabitacion, r.idCliente,
        h.nombre as 'habitacion', u.nombre, u.apPaterno, u.apMaterno
        FROM Reservacion r
        INNER JOIN Habitacion h
        ON h.idHabitacion = r.idHabitacion
        INNER JOIN Cliente c
        ON c.idCliente = r.idCliente
        INNER JOIN Usuario u
        ON u.idUsuario = c.idUsuario
        WHERE r.fechaFin >= GETDATE()
        ORDER BY r.fechaInicio DESC
    END
    ELSE IF @accion = 'FINDALLACTIVE'
    BEGIN
        SELECT r.idReservacion, r.fechaInicio, r.fechaFin, r.idHabitacion, r.idCliente,
        h.nombre as 'habitacion', u.nombre, u.apPaterno, u.apMaterno
        FROM Reservacion r
        INNER JOIN Habitacion h
        ON h.idHabitacion = r.idHabitacion
        INNER JOIN Cliente c
        ON c.idCliente = r.idCliente
        INNER JOIN Usuario u
        ON u.idUsuario = c.idUsuario
        WHERE r.fechaFin >= GETDATE()
        ORDER BY r.fechaInicio DESC
    END
    ELSE IF @accion = 'FINDALLBYUSER'
    BEGIN
        SELECT r.idReservacion, r.fechaInicio, r.fechaFin, r.idHabitacion, r.idCliente,
        h.nombre as 'habitacion', u.nombre, u.apPaterno, u.apMaterno
        FROM Reservacion r
        INNER JOIN Habitacion h
        ON h.idHabitacion = r.idHabitacion
        INNER JOIN Cliente c
        ON c.idCliente = r.idCliente
        INNER JOIN Usuario u
        ON u.idUsuario = c.idUsuario
        WHERE r.idCliente = @idCliente
        ORDER BY r.fechaInicio DESC
    END
    ELSE IF @accion = 'INSERT'
    BEGIN
        DECLARE @inserted TABLE (
            idReservacion INT,
            fechaInicio DATE,
            fechaFin DATE,
            idHabitacion INT,
            idCliente INT
        );

        INSERT INTO Reservacion (fechaInicio,fechaFin,idHabitacion,idCliente)
        OUTPUT INSERTED.*
        INTO @inserted
        VALUES (@fechaInicio,@fechaFin,@idHabitacion,@idCliente)

        SELECT * FROM @inserted
    END
    ELSE IF @accion = 'FIND'
    BEGIN
        SELECT r.idReservacion, r.fechaInicio, r.fechaFin, r.idHabitacion, r.idCliente,
        h.nombre as 'habitacion', u.nombre, u.apPaterno, u.apMaterno
        FROM Reservacion r
        INNER JOIN Habitacion h
        ON h.idHabitacion = r.idHabitacion
        INNER JOIN Cliente c
        ON c.idCliente = r.idCliente
        INNER JOIN Usuario u
        ON u.idUsuario = c.idUsuario
        where r.idReservacion = @idReservacion
    END
    ELSE IF @accion = 'UPDATE'
    BEGIN
        DECLARE @updated TABLE (
            idReservacion INT,
            fechaInicio DATE,
            fechaFin DATE,
            idHabitacion INT,
            idCliente INT
        );

        DECLARE @fechaInicioAnterior DATE;
        DECLARE @fechaFinAnterior DATE;
        DECLARE @fechaActual DATE = GETDATE();

        SELECT @fechaInicioAnterior = fechaInicio FROM Reservacion WHERE idReservacion = @idReservacion;
        SELECT @fechaFinAnterior = fechaFin FROM Reservacion WHERE idReservacion = @idReservacion;

        if @fechaInicio < @fechaActual OR @fechaFin < @fechaActual OR @fechaInicio > @fechaFin OR
        DATEDIFF(DAY, @fechaActual, @fechaInicioAnterior) > 7
        BEGIN
            RAISERROR('It does not fulfill the requirements to update the reservation.', 16, 1)
            RETURN
        END

        UPDATE Reservacion
        SET fechaInicio = @fechaInicio,
            fechaFin = @fechaFin,
            idHabitacion = @idHabitacion,
            idCliente = @idCliente
        OUTPUT INSERTED.*
        INTO @updated
        WHERE idReservacion = @idReservacion

        SELECT * FROM @updated
    END
    ELSE IF @accion = 'DELETE'
    BEGIN
        DECLARE @deleted TABLE (
            idReservacion INT,
            fechaInicio DATE,
            fechaFin DATE,
            idHabitacion INT,
            idCliente INT
        );

        DELETE FROM Reservacion
        OUTPUT DELETED.*
        INTO @deleted
        WHERE idReservacion = @idReservacion

        SELECT * FROM @deleted
    END
END

GO

CREATE PROCEDURE sp_obtenerHabitacionesDisponibles
@fechaInicio DATE,
@fechaFin DATE
AS
BEGIN
    SELECT * FROM fn_obtenerHabitacionesDisponibles(@fechaInicio,@fechaFin)
END

GO