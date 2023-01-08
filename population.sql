-- POPULATION SCRIPT PARA ESCOM_HOTEL DB

USE ESCOM_HOTEL;

-- TABLA ROL

INSERT INTO Rol (nombre) VALUES ('administrador');

GO

INSERT INTO Rol (nombre) VALUES ('trabajador');

GO

INSERT INTO Rol (nombre) VALUES ('cliente');

GO

-- TABLA AREA
INSERT INTO Area (nombre) VALUES ('recepcion');

GO

INSERT INTO Area (nombre) VALUES ('limpieza');

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

GO

-- ADDING EMPLOYEES --
EXEC sp_trabajador_crud
  NULL, 'test uno', 'test last name', 'test second last name',
  '1990-09-15', 'F', 'EEEE000000EEEEEE01',
  'EEEE000000EE1', '5512084633', 'test1@test.com', '123456',
  2, 'test street', '12', '115',
  'test neighborhood', 'test state', 'test district', '00000',
  'test contact name', 'test contact last name', 'test contact second last name',
  '5672064621', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'test dos', 'test last name', 'test second last name',
  '1990-09-15', 'F', 'EEEE000000EEEEEE02',
  'EEEE000000EE2', '5512084633', 'test2@test.com', '123456',
  2, 'test street', '12', '115',
  'test neighborhood', 'test state', 'test district', '00000',
  'test contact name', 'test contact last name', 'test contact second last name',
  '5672064621', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'test tres', 'test last name', 'test second last name',
  '1990-09-15', 'F', 'EEEE000000EEEEEE03',
  'EEEE000000EE3', '5512084633', 'test3@test.com', '123456',
  2, 'test street', '12', '115',
  'test neighborhood', 'test state', 'test district', '00000',
  'test contact name', 'test contact last name', 'test contact second last name',
  '5672064621', 17000.50, 1, 'INSERT'
GO

-- ADDING CUSTOMERS --

EXEC sp_cliente_crud
  NULL, 'Edgar', 'Martinez', 'Ruiz',
  '1997-01-01', 'M', 'IIIIE', 'IIIIIE',
  '551578751', 'edgar@test.com', '123456', 3,
  'Durazno', '12', '3', 'la cruz',
  'CDMX', 'magdalena', '10800',
  'Edgar', 'Ramirez', 'Fuentes', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Pedro', 'Campo', 'Juarez',
  '1997-01-01', 'M', 'IIIIP', 'IIIIIP',
  '551578751', 'pedro@test.com', '123456', 3,
  'Durazno', '12', '3', 'la cruz',
  'CDMX', 'magdalena', '10800',
  'Edgar', 'Ramirez', 'Fuentes', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Felipe', 'Cano', 'Nuño',
  '1997-01-01', 'M', 'IIIIF', 'IIIIIF',
  '551578751', 'edgar@test.com', '123456', 3,
  'Durazno', '12', '3', 'la cruz',
  'CDMX', 'magdalena', '10800',
  'Edgar', 'Ramirez', 'Fuentes', '144845135', 'INSERT'
GO 

