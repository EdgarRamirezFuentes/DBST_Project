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

        INSERT INTO @inserted EXEC sp_usuario_crud
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
        SELECT s.idUsuario, s.nombre, s.apPaterno, s.apMaterno ,
        s.fechaNacimiento ,s.sexo AS genero ,s.curp ,s.rfc, s.telefono, s.correo,
        a.nombre AS area,
        d.calle, d.numExterior AS numeroExterior, d.numInterior AS numeroInterior, d.colonia, d.estado, d.alcaldia, d.codigoPostal,
        ce.nombre AS nombreContactoEmergencia, ce.apPaterno AS apPaternoContactoEmergencia, ce.apMaterno AS apMaternoContactoEmergencia,
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
        DECLARE @updated TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

        INSERT INTO @updated EXEC sp_usuario_crud
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
         DECLARE @customerID INT;

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
         INSERT INTO Cliente
         (
             idUsuario
         )
         VALUES
         (
             @userID
         )
         SELECT * FROM @inserted
     END

     ELSE IF @accion = 'FINDALL'
     BEGIN
        SELECT s.idUsuario, CONCAT(s.nombre, ' ', s.apPaterno, ' ', s.apMaterno) AS Nombre, s.telefono ,s.correo
        FROM Usuario s
        INNER JOIN Cliente c
        ON s.idUsuario = c.idUsuario
        WHERE s.activo = 1
     END

     ELSE IF @accion = 'FIND'
    BEGIN
        SELECT
		u.idUsuario, u.nombre, u.apPaterno, u.apMaterno, u.fechaNacimiento, u.sexo AS genero, u.curp, u.rfc, u.telefono, u.correo, u.fechaRegistro,
		d.calle, d.numExterior AS numeroExterior, d.numInterior AS numeroInterior, d.colonia, d.estado, d.alcaldia, d.codigoPostal,
        ce.nombre AS nombreContactoEmergencia, ce.apPaterno AS apPaternoContactoEmergencia, ce.apMaterno AS apMaternoContactoEmergencia,
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
        DECLARE @updated TABLE (
            idUsuario INT,
            nombre VARCHAR(50),
            apPaterno VARCHAR(50),
            apMaterno VARCHAR(50),
            activo BIT
        );

        INSERT INTO @updated EXEC sp_usuario_crud
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
---------------------------------
-- Type Room STORED PROCEDURES --
---------------------------------


CREATE PROCEDURE sp_tipo_habitacion_crud
@idTipoHabitacion INT,
@nombre VARCHAR(50),
@numCamas INT,
@numPersonas INT,
@precio MONEY,
@accion VARCHAR(15)
AS
BEGIN
	IF @accion = 'FINDALL'
	BEGIN
		SELECT * FROM TipoHabitacion
	END
	ELSE IF @accion = 'INSERT'
	BEGIN
		DECLARE @inserted TABLE (
            idTipoHabitacion INT,
            nombre VARCHAR(50),
            numCamas INT,
			numPersonas INT,
			precio MONEY
        );
        INSERT INTO TipoHabitacion(nombre,numCamas,numPersonas,precio)
        OUTPUT INSERTED.*
        INTO @inserted
        VALUES (@nombre, @numCamas, @numPersonas, @precio)

        SELECT * FROM @inserted
	END
	ELSE IF @accion = 'FIND'
	BEGIN
		SELECT * FROM TipoHabitacion where idTipoHabitacion = @idTipoHabitacion
	END
	ELSE IF @accion = 'UPDATE'
	BEGIN
		DECLARE @updated TABLE (
            idTipoHabitacion INT,
            nombre VARCHAR(50),
            numCamas INT,
            numPersonas INT,
            precio MONEY
        );

        UPDATE TipoHabitacion
        SET nombre = @nombre,
        numCamas = @numCamas,
        numPersonas = @numPersonas,
        precio = @precio
        OUTPUT INSERTED.*
        INTO @updated
        WHERE idTipoHabitacion = @idTipoHabitacion

        SELECT * FROM @updated
	END
	ELSE IF @accion = 'DELETE'
    BEGIN
        DECLARE @deleted TABLE (
            idRol INT,
            nombre VARCHAR(50),
            numCamas INT,
            numPersonas INT,
            precio MONEY
        );

        DELETE FROM TipoHabitacion
        OUTPUT DELETED.*
        INTO @deleted
        WHERE idTipoHabitacion = @idTipoHabitacion

        SELECT * FROM @deleted
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
	IF @accion = 'FINDALL'
	BEGIN
		SELECT h.idHabitacion, h.nombre, h.descripcion, h.isActive, th.nombre as 'tipoHabitacion', h.idTipoHabitacion
        FROM Habitacion h
        INNER JOIN TipoHabitacion th
		ON th.idTipoHabitacion = h.idTipoHabitacion
		WHERE h.isActive = 1
	END
	ELSE IF @accion = 'INSERT'
	BEGIN
		DECLARE @inserted TABLE (
            idHabitacion INT,
            nombre VARCHAR(50),
            descripcion VARCHAR(50),
            isActive BIT,
            idTipoHabitacion INT
        );

        INSERT INTO Habitacion (nombre,descripcion,isActive,idTipoHabitacion)
        OUTPUT INSERTED.*
        INTO @inserted
        VALUES (@nombre,@descripcion,@isActive,@idTipoHabitacion)

        SELECT * FROM @inserted
	END
    ELSE IF @accion = 'FIND'
	BEGIN
		SELECT h.idHabitacion,h.nombre,h.descripcion, th.nombre AS 'tipoHabitacion', th.numCamas, th.numPersonas, th.precio
		FROM Habitacion h
		INNER JOIN TipoHabitacion th
		ON th.idTipoHabitacion = h.idTipoHabitacion
		where h.idHabitacion  = @idHabitacion
		and h.isActive = 1
	END
	ELSE IF @accion = 'UPDATE'
	BEGIN
		DECLARE @updated TABLE (
            idHabitacion INT,
            nombre VARCHAR(100),
            descripcion VARCHAR(100),
            isActive BIT,
            idTipoHabitacion INT
        );

        UPDATE Habitacion
        SET nombre = @nombre,
        descripcion  = @descripcion,
        isActive = @isActive,
        idTipoHabitacion  = @idTipoHabitacion
        OUTPUT INSERTED.*
        INTO @updated
        WHERE idHabitacion = @idHabitacion

        SELECT * FROM @updated
	END
    ELSE IF @accion = 'DELETE'
	BEGIN
		DECLARE @deleted TABLE (
            idHabitacion INT,
            nombre VARCHAR(100),
            descripcion VARCHAR(100),
            isActive BIT,
            idTipoHabitacion INT
        );

        DELETE FROM Habitacion
        OUTPUT DELETED.*
        INTO @deleted
        WHERE idHabitacion = @idHabitacion

        SELECT * FROM @deleted
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

        UPDATE Reservacion
        SET fechaInicio = @fechaInicio,
        fechaFin  = @fechaFin,
        idHabitacion = @idHabitacion,
        idCliente  = @idCliente
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