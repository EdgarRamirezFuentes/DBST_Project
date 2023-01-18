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

-- TABLA ESTADO TAREA
INSERT INTO EstadoTarea (nombre) VALUES ('ASIGNADA');
INSERT INTO EstadoTarea (nombre) VALUES ('EN PROGRESO');
INSERT INTO EstadoTarea (nombre) VALUES ('TERMINADA');
INSERT INTO EstadoTarea (nombre) VALUES ('BLOQUEADA');

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
--Inician 10 empleados--
EXEC sp_trabajador_crud
  NULL, 'Adam', 'Álvarez', 'Andrade',
  '1974-12-13', 'M', 'AAAA741213HDFLND06',
  'AAAA74121301', '5576433453', 'adam@gmail.com', 'adam123',
  2, 'AGUSTIN', '69', '3',
  'EX-NORMAL', 'Mexico', 'TUXTEPEC', '68370',
  'MATEO', 'BENITEZ', 'JUAN',
  '5591287527', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'JOSEFINA', 'ENRIQUEZ', 'PEÑA',
  '1975-11-20', 'F', 'EIPJ751120MDFNNS04',
  'EIPJ75112078', '558676765212', 'josefina@gmail.com', 'josefa123',
  2, 'AV.INDEPENDENCIA', '241', '1',
  'CENTRO', 'Mexico', 'TUXTEPEC', '68300',
  'AGUSTINA', 'CARRERA', 'NEGRETE',
  '5672062836', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'VICTORIA', 'CUEVAS', 'JIMENEZ',
  '1976-09-15', 'F', 'CUJV760915MDFVMC02',
  'CUJV76091534', '5512098276', 'victoria@gmail.com', 'victoria123',
  2, 'AV.20 DE NOVIEMBRE', '1024', '11',
  'CENTRO', 'Mexico', 'TUXTEPEC', '68300',
  'CAMILO', 'MORA', 'MUÑOZ',
  '5612086776', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'ISIDRO', 'BRAVO', 'UBIETA',
  '1977-10-15', 'M', 'BAUI771015MDFRBS02',
  'BAUI77101509', '5512084998', 'isidro@gmail.com', 'isidro123',
  2, 'ZARAGOZA', '1010', '11',
  'LA PIRAGUA', 'MEXICO', 'TUXTEPEC', '68380',
  'IBIS', 'JUAREZ', 'GAVITO',
  '5698797653', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'HECTOR', 'GOMEZ', 'FUENTES',
  '1980-09-15', 'M', 'GOFH800915HDFMNC01',
  'GOFH800915R1', '5587236320', 'hector@gmail.com', 'hector123',
  2, 'AV. 20 DE NOVIEMBRE', '859', 'B',
  'CENTRO', 'MEXICO', 'TLALNEPANTLA', '68335',
  'IVONNE', 'GAVITO', 'GOMEZ',
  '5587632784', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'MARIA', 'ARREOLA', 'FEREGRINO',
  '1981-02-20', 'F', 'AEFM810220MDFRRR02',
  'AEFM810220A1', '5598652120', 'maria@gmail.com', 'maria123',
  2, 'ALDAMA', '156', '20',
  'LAZARO CARDENAS', 'MEXICO', 'LINDAVISTA', '68340',
  'ISAIAS', 'PANTALEON', 'HERNANDEZ',
  '5609384720', 7000.50, 2, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'RUBEN', 'HURBIDE', 'AGUELLEZ',
  '1988-07-15', 'M', 'HUAR880715HDFRGB05',
  'HUAR880715Q1', '5590374435', 'ruben@gmail.com', 'ruben123',
  2, 'MATAMOROS', '2', 'A',
  'REPOSO', 'MEXICO', 'ECATEPEC', '68320',
  'ESMERALDA', 'VASQUEZ', 'IRRA',
  '5690387472', 7000.50, 2, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'MANUEL', 'NORIEGA', 'DEL TORO',
  '1980-06-23', 'M', 'NOTM800623HDFRRN08',
  'NOTM800623L9', '5593245439', 'manuel@gmail.com', 'manuel123',
  2, 'FRANCISCO I. MADERO', '182', '14',
  'MA.EUGENIA', 'MEXICO', 'TLAXCALA', '68350',
  'CLAUDIA', 'CASTELLANOS', 'BARRERA',
  '5672023246', 7000.50, 2, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'ELENA', 'CEJA', 'ARANO',
  '1989-03-20', 'F', 'CEAE890320MDFJRL07',
  'CEAE890320L9', '5512023487', 'elena@gmail.com', 'elena123',
  2, 'AV 3 ESQUINA', '2', '110',
  'COSTA VERDE', 'MEXICO', 'ECATEPEC', '68310',
  'JESUS', 'GAMERO', 'LUNA',
  '5602342472', 7000.50, 2, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'JAIME', 'ANDRADE', 'REYES',
  '1990-05-30', 'M', 'AARJ900530HDFNYM08',
  'AARJ900530A4', '5543812120', 'jaime@gmail.com', 'jaime123',
  2, 'AV. LIBERTAD', '1961', '20',
  'LA PIRAGUA', 'MEXICO', 'MIGUEL HIDALGO', '81000',
  'JOSE', 'SILVA', 'LOPEZ',
  '5672123240', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'HILDA', 'LOPEZ', 'PALMA',
  '1995-08-21', 'F', 'LOPH950821MDFPLL04',
  'LOPH950821Q2', '5524354120', 'hilda@gmail.com', 'hilda123',
  2, 'AV. 1O. DE MAYO', '108', 'A',
  'MARIA LUISA', 'MEXICO', 'ECATEPEC', '38000',
  'GUADALUPE', 'CRUZ', 'CASTRO',
  '5609347472', 17000.50, 1, 'INSERT'
GO

--Terminan 10 empleados---
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
  '551578751', 'felipe@test.com', '123456', 3,
  'Durazno', '12', '3', 'la cruz',
  'CDMX', 'magdalena', '10800',
  'Edgar', 'Ramirez', 'Fuentes', '144845135', 'INSERT'
GO 

----