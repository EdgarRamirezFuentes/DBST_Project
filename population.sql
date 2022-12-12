-- POPULATION SCRIPT PARA ESCOM_HOTEL DB

USE ESCOM_HOTEL;

-- TABLA ROL

INSERT INTO Rol (nombre) VALUES ('administrador');

GO

INSERT INTO Rol (nombre) VALUES ('Trabajador');

GO

INSERT INTO Rol (nombre) VALUES ('cliente');

GO


-- ADDING ADMIN USER --
INSERT INTO Usuario
(
nombre, apPaterno,
apMaterno, fechaNacimiento,
sexo, curp,
rfc, telefono,
correo, contrasenia,
idRol, activo
)
VALUES
(
'Admin', 'Admin',
'Admin', '1990-01-01',
'F', 'AAAA000000AAAAAA00',
'AAAA000000AAA', '0000000000',
'admin@admin.com', HASHBYTES('SHA2_256', 'sudoDBST2022Ñ'),
1, 1
);
