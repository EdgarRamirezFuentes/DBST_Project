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

INSERT INTO Area (nombre) VALUES ('bar');
GO

INSERT INTO Area (nombre) VALUES ('pasillos');
GO

INSERT INTO Area (nombre) VALUES ('chequeo');
GO

INSERT INTO Area (nombre) VALUES ('medico');
GO

INSERT INTO Area (nombre) VALUES ('chef');
GO

INSERT INTO Area (nombre) VALUES ('contador');
GO

INSERT INTO Area (nombre) VALUES ('Arquitecto');
GO

INSERT INTO Area (nombre) VALUES ('Soporte');
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

EXEC sp_trabajador_crud
  NULL, 'Juan', 'Felix', 'Arce',
  '1974-12-13', 'M', 'AEGA548846DF',
  'AEGA548846DF', '5576473453', 'FELIX@gmail.com', 'felix123',
  2, 'La cruz', '12', '3',
  'EX-NORMAL', 'Mexico', 'TUXTEPEC', '68370',
  'Antonio', 'BENITEZ', 'JUAN',
  '5591287521', 12000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Alma', 'Lilia', 'Arce',
  '1972-12-13', 'F', 'LEGA548846DF',
  'LEGA548846DF', '5576443453', 'alma@gmail.com', 'alma123',
  2, 'La cruz', '12', '3',
  'Dorantes', 'Mexico', 'TUXTEPEC', '63370',
  'Antonio', 'Zavala', 'Romero',
  '5591787521', 12000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Saori', 'Lilith', 'Arce',
  '1985-12-13', 'F', 'LISA548846DF',
  'LISA548846DF', '5570443453', 'lilith@gmail.com', 'li123',
  2, 'Mexico', '12', '3',
  'Dorantes', 'Mexico', 'TUXTEPEC', '62370',
  'Antonio', 'Arce', 'Zavala',
  '5591787529', 12000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Luisa', 'Huitch', 'Gonzales',
  '1995-10-13', 'F', 'HUGL548846DF',
  'HUGL548846DF', '5670443453', 'luisa@gmail.com', 'luisa123',
  2, 'tizimin', '12', '3',
  'Tultepec', 'Mexico', 'TUXTEPEC', '67370',
  'Antonio', 'Arce', 'Zavala',
  '5591787529', 12000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Diana', 'Jaramillo', 'Perez',
  '1999-10-13', 'F', 'JAPD548846DF',
  'JAPD548846DF', '5677443453', 'diana@gmail.com', 'diana123',
  2, 'de los paraderos', '11', '3',
  'ROMA', 'Mexico', 'Cuahutemoc', '48370',
  'Tania', 'tanibeth', 'Romero',
  '5591787530', 12000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Yael', 'Medina', 'Ramirez',
  '1997-10-13', 'M', 'MERY978846DF',
  'MERY978846DF', '5677444153', 'yael@gmail.com', 'yael123',
  2, 'universidad', '10', '3',
  'Cisneros', 'Mexico', 'Tlalpan', '23370',
  'Fernanda', 'Lopez', 'Romero',
  '5516787530', 13250.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Ivan', 'Medina', 'Ramirez',
  '1997-10-13', 'M', 'MERI978846DF',
  'MERI978846DF', '5677444153', 'ivan@gmail.com', 'ivan123',
  2, 'luna', '10', '3',
  'Durazno', 'Mexico', 'Naucalpan', '23371',
  'Angela', 'Aguilar', 'Romero',
  '5516787512', 18000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Angel', 'David', 'Revilla',
  '1985-10-13', 'M', 'DARA978846DF',
  'DARA978846DF', '5614744153', 'angeld@gmail.com', 'angel123',
  2, 'caracas', '10', '3',
  'Narvarte', 'Mexico', 'Miguel Hidalgo', '27371',
  'Federico', 'Angel', 'Romero',
  '5516787762', 18000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Carla', 'Cruz', 'Romero',
  '1996-10-13', 'F', 'CURC978846DF',
  'CURC978846DF', '5614771153', 'carla@gmail.com', 'carla123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516787762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Fabricio', 'Santa', 'Cruz',
  '1996-10-13', 'F', 'SACF978846DF',
  'SACF978846DF', '5617871153', 'fabricio@gmail.com', 'carla123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516787762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Chimino', 'Cruz', 'Cruz',
  '1996-10-13', 'M', 'CUCC978846DF',
  'CUCC978846DF', '5627871153', 'chimino@gmail.com', 'chimino123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516787762', 17000.50, 1, 'INSERT'
GO
--
EXEC sp_trabajador_crud
  NULL, 'Yaga', 'Benitez', 'Cruz',
  '1996-10-13', 'M', 'BECY78846DF',
  'BECY978846DF', '5627871153', 'yaga@gmail.com', 'yaga123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516787762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Karin', 'Medina', 'Medina',
  '1996-10-13', 'M', 'MEMK78846DF',
  'MEMK978846DF', '5627871121', 'karin@gmail.com', 'karin123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516787762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Meredi', 'Madrigal', 'Romero',
  '1996-10-13', 'F', 'MARM78846DF',
  'MARM978846DF', '5628871121', 'meredi@gmail.com', 'meredi123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Lucio', 'Madrigal', 'Fedora',
  '1996-10-13', 'M', 'MAFL78846DF',
  'MAFL978846DF', '5621171121', 'lucio@gmail.com', 'lucio123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Pepa', 'Madrigal', 'Henestrosa',
  '1990-10-13', 'F', 'MAHP78846DF',
  'MAHP978846DF', '5621171121', 'pepa@gmail.com', 'pepa123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Bruno', 'Madrigal', 'Hela',
  '1990-10-13', 'M', 'MAHB78846DF',
  'MAHB978846DF', '5621171121', 'bruno@gmail.com', 'bruno123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Dinorah', 'Madrigal', 'Gelacio',
  '1990-10-13', 'F', 'MAGD78846DF',
  'MAGD978846DF', '5621171121', 'dinora@gmail.com', 'dinora123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 17000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Mime', 'Ruiz', 'Gelacio',
  '1990-10-13', 'M', 'RUGM78846DF',
  'RUGM978846DF', '5521171121', 'mime@gmail.com', 'mime123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Eris', 'Lopez', 'Lautaro',
  '1990-10-13', 'F', 'LOLE78846DF',
  'LOLE978846DF', '5521171121', 'eris@gmail.com', 'eris123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Guillermo', 'Lagoañe', 'Lopez',
  '1990-10-13', 'F', 'LALG78846DF',
  'LALG978846DF', '5521171121', 'guillermo@gmail.com', 'guillermo123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Oliver', 'Yoshimar', 'Lopez',
  '1990-10-13', 'M', 'YOLO78846DF',
  'YOLO978846DF', '5511171121', 'oliver@gmail.com', 'oliver123',
  2, 'tinoco', '100', '3',
  'santa fe', 'Mexico', 'Alvaro Obregon', '27381',
  'David', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Renata', 'Alvares', 'Nau',
  '1990-10-13', 'F', 'AANR78846DF',
  'AANR978846DF', '5558171121', 'renata@gmail.com', 'renata123',
  2, 'gondola', '654', '4',
  'dinosaurio', 'Mexico', 'Tlalpan', '97881',
  'Romina', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Federico', 'Gomez', 'Noe',
  '1990-10-13', 'F', 'GONE78846DF',
  'GONE978846DF', '5558171691', 'federico@gmail.com', 'federico123',
  2, 'gondola', '654', '4',
  'dinosaurio', 'Mexico', 'Tlalpan', '97881',
  'Romina', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Morgana', 'Stark', 'Poros',
  '1990-10-13', 'F', 'SAPM78846DF',
  'SAPM978846DF', '5558171691', 'morgana@gmail.com', 'morgana123',
  2, 'gondola', '654', '4',
  'dinosaurio', 'Mexico', 'Tlalpan', '97881',
  'Romina', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Joaquin', 'Hernandez', 'Hernandez',
  '1990-10-13', 'M', 'HEHJ78846DF',
  'HEHJ978846DF', '5558198691', 'joaquin@gmail.com', 'joaquin123',
  2, 'gondola', '654', '4',
  'dinosaurio', 'Mexico', 'Tlalpan', '97881',
  'Romina', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Jenni', 'Hernandez', 'Plutarco',
  '1990-10-13', 'F', 'HEPJ78846DF',
  'HEPJ978846DF', '5558198691', 'jenni@gmail.com', 'jenni123',
  2, 'gondola', '654', '4',
  'dinosaurio', 'Mexico', 'Tlalpan', '97881',
  'Romina', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Luis', 'Mendoza', 'Acevedo',
  '1990-10-13', 'F', 'MEAL78846DF',
  'MEAL978846DF', '5558198871', 'luis@gmail.com', 'luis123',
  2, 'gondola', '654', '4',
  'uppicsa', 'Mexico', 'Iztacalco', '94781',
  'Romina', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

EXEC sp_trabajador_crud
  NULL, 'Michelle', 'Roma', 'Camacho',
  '1996-10-13', 'F', 'ROCM78846DF',
  'ROCM978846DF', '5558198871', 'michelle@gmail.com', 'michelle123',
  2, 'gondola', '654', '4',
  'uppicsa', 'Mexico', 'Iztacalco', '94771',
  'Romina', 'Angel', 'Romero',
  '5516777762', 20000.50, 1, 'INSERT'
GO

--Terminan 20 empleados---


-- ADDING CUSTOMERS --
--Empiezan 40 usuarios---

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

EXEC sp_cliente_crud
  NULL, 'Emiliano', 'Ocampo', 'Arce',
  '2003-01-01', 'M', 'AAAOE', 'AAAOE',
  '5522114478', 'gengiemi@gmail.com', 'emiliano', 3,
  'Durazno', '12', '3', 'la cruz',
  'CDMX', 'magdalena', '10800',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Jimena', 'Lopez', 'Arce',
  '2002-01-01', 'F', 'AAALJ', 'AAALJ',
  '5522114473', 'ARMENA@gmail.com', '123456', 3,
  'Durazno', '12', '3', 'la cruz',
  'CDMX', 'magdalena', '10800',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Gabriela', 'Romero', 'Soria',
  '1992-01-01', 'F', 'RRSGA', 'RRSGA',
  '5522115878', 'sangabus@gmail.com', '123456', 3,
  'av civilizaciones', '12', '3', 'Rosario',
  'EDOMEX', 'Tlalnepantla', '55478',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Victoria', 'Romero', 'Soria',
  '1990-01-01', 'F', 'VVSGA', 'VVSGA',
  '5546115878', 'romerov@gmail.com', '123456', 3,
  'av civilizaciones', '12', '3', 'Rosario',
  'EDOMEX', 'Tlalnepantla', '55478',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Xochilt', 'Romero', 'Soria',
  '1992-01-01', 'F', 'XXSGA', 'XXSGA',
  '5511115878', 'xoch@gmail.com', '123456', 3,
  'av civilizaciones', '12', '3', 'Rosario',
  'EDOMEX', 'Tlalnepantla', '55478',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Ericka', 'Nayelhi', 'Zavala',
  '1990-01-01', 'F', 'EZAVA', 'EZAVA',
  '5522115812', 'ezavalar@gmail.com', '123456', 3,
  'av civilizaciones', '12', '3', 'Rosario',
  'EDOMEX', 'Tlalnepantla', '55478',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Marisol', 'Arce', 'Soria',
  '1988-01-01', 'F', 'ARGA', 'ARGA',
  '5522115878', 'solarce@gmail.com', '123456', 3,
  'av mexico', '12', '3', 'Pedregal',
  'CDMX', 'Tlalpan', '01258',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

<<<<<<< HEAD


=======
EXEC sp_cliente_crud
  NULL, 'Juan', 'Arce', 'Garduño',
  '1988-01-01', 'F', 'AEGJ', 'AEGJ',
  '5572915878', 'juan@gmail.com', '123456j', 3,
  'av mexico', '12', '3', 'Pedregal',
  'CDMX', 'Magdalena Contreras', '1258',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Sabina', 'Lopez', 'Alejo',
  '1988-01-01', 'F', 'LOAS', 'LOAS',
  '5572911778', 'sabi@gmail.com', 'sabi', 3,
  'luis donaldo', '12', '3', 'Pedregal',
  'CDMX', 'Tlalpan', '1258',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Erandi', 'Flores', 'Nuño',
  '1988-01-01', 'F', 'FONE', 'FONE',
  '5572915885', 'erandi@gmail.com', 'erandi', 3,
  'civilizaciones', '12', '3', 'Pedregal',
  'CDMX', 'Xochimilco', '12544',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Manuel', 'Lule', 'Guzman',
  '1988-01-01', 'F', 'LUGM', 'LUGM',
  '5572915870', 'manuel@gmail.com', 'manuel', 3,
  'filantrop', '1', '3', 'Ozuna',
  'CDMX', 'Tlalpan', '12580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Sabina', 'Lopez', 'Alejo',
  '1988-01-01', 'F', 'LOAS', 'LOAS',
  '5572911778', 'sabi@gmail.com', 'sabi', 3,
  'luis donaldo', '12', '3', 'Pedregal',
  'CDMX', 'Tlalpan', '1258',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Erandi', 'Flores', 'Nuño',
  '1988-01-01', 'F', 'FONE', 'FONE',
  '5572915885', 'erandi@gmail.com', 'erandi', 3,
  'civilizaciones', '12', '3', 'Pedregal',
  'CDMX', 'Xochimilco', '12544',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Nicandro', 'Castillo', 'Guzman',
  '1988-01-01', 'F', 'CAGN', 'CAGN',
  '5577915870', 'nicandro@gmail.com', 'nicandro', 3,
  'de la luz', '1', '3', 'Ozuna',
  'CDMX', 'Tlalpan', '12580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Enrique', 'Castillo', 'Guzman',
  '1998-01-01', 'M', 'CAGE', 'CAGE',
  '5577915850', 'enrique@gmail.com', 'enrique', 3,
  'lince', '1', '3', 'Natura',
  'CDMX', 'Tlalpan', '12580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Jazmine', 'Carrillo', 'Gondola',
  '1998-01-01', 'M', 'CAGJ', 'CAGJ',
  '5577915850', 'jazmine@gmail.com', 'jazmine', 3,
  'de los doctores', '1', '3', 'Natura',
  'CDMX', 'Tlalpan', '12580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Ana', 'Ramirez', 'Norte',
  '1988-01-01', 'M', 'RANA', 'RANA',
  '5577915850', 'ana@gmail.com', 'ana', 3,
  'bosques', '10', '3', 'Natura',
  'CDMX', 'Tlalpan', '29580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Claudia', 'Ivette', 'Miranda',
  '1988-01-01', 'M', 'IEMC', 'IEMC',
  '5577917850', 'claudia@gmail.com', 'claudia', 3,
  'bosques', '10', '3', 'Natura',
  'CDMX', 'Tlalpan', '29580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Carlos', 'Roma', 'Cisneros',
  '1988-01-01', 'M', 'ROCC', 'ROCC',
  '5577115550', 'carlos@gmail.com', 'carlos', 3,
  'bosques', '10', '3', 'Natura',
  'CDMX', 'Tlalpan', '29580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Ary', 'Shared', 'Carrillo',
  '1988-01-01', 'M', 'SACA', 'SACA',
  '5577905850', 'ary@gmail.com', 'ary', 3,
  'politecnico', '10', '3', 'Natura',
  'CDMX', 'Gustavo Madero', '54947',
  'Antonio', 'Arce', 'Gudiño', '144745135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Claudia', 'Ivette', 'Miranda',
  '1988-01-01', 'M', 'IEMC', 'IEMC',
  '5577917850', 'claudia@gmail.com', 'claudia', 3,
  'bosques', '10', '3', 'Natura',
  'CDMX', 'Tlalpan', '29580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Carlos', 'Roma', 'Cisneros',
  '1988-01-01', 'M', 'ROCC', 'ROCC',
  '5577115550', 'carlos@gmail.com', 'carlos', 3,
  'bosques', '10', '3', 'Natura',
  'CDMX', 'Tlalpan', '29580',
  'Antonio', 'Arce', 'Gudiño', '144845135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Mario', 'Ramirez', 'Odette',
  '1988-01-01', 'M', 'RAOM', 'RAOM',
  '5577904110', 'mario@gmail.com', 'mario', 3,
  'politecnico', '10', '3', 'Natura',
  'CDMX', 'Gustavo Madero', '54947',
  'Antonio', 'Arce', 'Gudiño', '144745135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Estefania', 'Nuño', 'Morales',
  '1988-01-01', 'M', 'NUME', 'NUME',
  '5577905850', 'estefani@gmail.com', 'estefani', 3,
  'politecnico', '10', '3', 'Natura',
  'CDMX', 'Gustavo Madero', '54947',
  'Antonio', 'Arce', 'Gudiño', '144745135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Xiadani', 'Mora', 'Morales',
  '1988-01-01', 'M', 'MOMX', 'MOMX',
  '5577905851', 'xiadani@gmail.com', 'xiadani', 3,
  'arbustos', '100', '3', 'Natura',
  'CDMX', 'Azcapotzalco', '54947',
  'Antonio', 'Arce', 'Gudiño', '144745135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Brigguite', 'Gray', 'Morales',
  '1988-01-01', 'F', 'GAMB', 'GAMB',
  '5577905851', 'brig@gmail.com', 'brig', 3,
  'arbustos', '25', '3', 'Natura',
  'CDMX', 'Azcapotzalco', '54947',
  'Antonio', 'Arce', 'Gudiño', '144745135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Raquel', 'Bigorra', 'Sanchez',
  '1985-01-01', 'F', 'BISR', 'BISR',
  '5577901851', 'raquel@gmail.com', 'raquel', 3,
  'arbustos', '25', '3', 'Natura',
  'CDMX', 'Azcapotzalco', '54947',
  'Antonio', 'Arce', 'Gudiño', '144745135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Rocio', 'Sanchez', 'Azuara',
  '1985-01-01', 'F', 'SAAR', 'SAAR',
  '5587901851', 'rocio@gmail.com', 'rocio', 3,
  'aztecas', '25', '3', 'Polanco',
  'CDMX', 'Miguel Hidalgo', '54947',
  'Antonio', 'Arce', 'Gudiño', '141745135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Maria', 'Aguirre', 'Sanchez',
  '1985-01-01', 'F', 'AGSM', 'AGSM',
  '5577901851', 'maria@gmail.com', 'maria', 3,
  'mani', '250', '3', 'glorieta',
  'CDMX', 'Azcapotzalco', '51247',
  'Antonio', 'Arce', 'Gudiño', '144745135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Jose', 'Jose', 'Perez',
  '1985-01-01', 'M', 'JOPJ', 'JOPJ',
  '5577901851', 'jose@gmail.com', 'jose', 3,
  'mani', '250', '3', 'glorieta',
  'CDMX', 'Cuahutemoc', '14247',
  'Antonio', 'Arce', 'Gudiño', '144365135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Sara', 'Jay', 'Portales',
  '1985-01-01', 'F', 'JAPS', 'JAPS',
  '5577901851', 'sara@gmail.com', 'sara', 3,
  'york', '250', '3', 'San Nicolas',
  'CDMX', 'Tlalpan', '14247',
  'Antonio', 'Arce', 'Gudiño', '144365135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Karla', 'Rosas', 'Duran',
  '1985-01-01', 'M', 'RODK', 'RODK',
  '5577901851', 'karla@gmail.com', 'karla', 3,
  'mani', '250', '3', 'glorieta',
  'CDMX', 'Cuahutemoc', '14247',
  'Antonio', 'Arce', 'Gudiño', '144365135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Roxana', 'Morales', 'Casas',
  '1985-01-01', 'M', 'MOCR', 'MOCR',
  '5577901851', 'roxana@gmail.com', 'roxana', 3,
  'mani', '250', '3', 'glorieta',
  'CDMX', 'Cuahutemoc', '14247',
  'Antonio', 'Arce', 'Gudiño', '144365135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Alberto', 'Alcantara', 'Duran',
  '1985-01-01', 'M', 'AADA', 'AADA',
  '5577901851', 'alberto@gmail.com', 'alberto', 3,
  'mani', '250', '3', 'glorieta',
  'CDMX', 'Cuahutemoc', '14247',
  'Antonio', 'Arce', 'Gudiño', '144365135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Yazmin', 'Gonzales', 'Dinamarca',
  '1985-01-01', 'F', 'GODY', 'GODY',
  '5577901851', 'yazmin@gmail.com', 'yazmin', 3,
  'mani', '250', '3', 'glorieta',
  'CDMX', 'Cuahutemoc', '14247',
  'Antonio', 'Arce', 'Gudiño', '144365135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Johny', 'Ruiz', 'Duran',
  '1990-01-01', 'M', 'RUDJ', 'RUDJ',
  '5577901851', 'johny@gmail.com', 'johny', 3,
  'mani', '250', '3', 'glorieta',
  'CDMX', 'Cuahutemoc', '14247',
  'Antonio', 'Arce', 'Gudiño', '144365135', 'INSERT'
GO 

EXEC sp_cliente_crud
  NULL, 'Rusty', 'Cage', 'Morat',
  '1985-01-01', 'M', 'CAMR', 'CAMR',
  '5577901851', 'rusty@gmail.com', 'rusty', 3,
  'clark 11', '25', '3', 'apple big',
  'CDMX', 'Magdalena Contreras', '14247',
  'Antonio', 'Arce', 'Gudiño', '144365135', 'INSERT'
GO 
>>>>>>> 15e8f51e3f0145cbc3df0b7c6afa2d145c180199

-- ADDING TYPE ROOMS --
--Empiezan 10 Tipos de Habitaciones---

--1--
EXEC sp_tipo_habitacion_crud
  NULL, 'Economica Estudiantes', 1, 1, 300, 'INSERT'
GO

--2--
EXEC sp_tipo_habitacion_crud
  NULL, 'Economica General', 1, 2, 600, 'INSERT'
GO

--3--
EXEC sp_tipo_habitacion_crud
  NULL, 'Estandar Individual', 1, 1, 650, 'INSERT'
GO

--4--
EXEC sp_tipo_habitacion_crud
  NULL, 'Estandar Inicial', 2, 2, 900, 'INSERT'
GO

--5--
EXEC sp_tipo_habitacion_crud
  NULL, 'Estandar Media', 2, 3, 1600, 'INSERT'
GO

EXEC sp_tipo_habitacion_crud
  NULL, 'Estandar Alta', 2, 4, 2000, 'INSERT'
GO

EXEC sp_tipo_habitacion_crud
  NULL, 'Estandar Lujo', 2, 5, 2000, 'INSERT'
GO

--8--
EXEC sp_tipo_habitacion_crud
  NULL, 'Estandar Para Fiesta', 2, 5, 3000, 'INSERT'
GO

--9--
EXEC sp_tipo_habitacion_crud
  NULL, 'Estandar para Trabajo', 3, 5, 2800, 'INSERT'
GO

--10--
EXEC sp_tipo_habitacion_crud
  NULL, 'Estandar Familiar', 3, 6, 3200, 'INSERT'
GO


-- ADDING ROOMS --
--Empiezan 40 Habitaciones---

EXEC sp_habitacion_crud
  NULL, 'Economica para chavos','Habitacion para estudiantes de 18 a 27',
  1,1,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Economica para parejitas','Habitacion para pareja con una cama',
  1,2,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Economica Forever Alone','Habitacion para una sola persona con una cama',
  1,3,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Economica De paso','Habitacion para una sola persona con una cama',
  1,3,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion best friends','Habitacion para 2 personas con camas separadas',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion Viaje en Familia','Habitacion con 3 camas para familias 6 integrantes',
  1,10,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion Saca la Chamba','Habitacion para grupo de 5 personas paratrabajar',
  1,9,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion Relajacion','Habitacion para grupo de 5 personas de wasa',
  1,8,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion escape ','Habitacion para estudiantes de paso a buen precio',
  1,1,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion grupito','Habitacion para 3 con servicios de relajacion',
  1,5,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion game','Habitacion para 3 con servicios gaming',
  1,5,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion doble c','Habitacion para 2 parejas citas',
  1,5,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion derroche','Habitacion para 5 con bebidas',
  1,7,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion borrachos','Habitacion para 5 con bebidas',
  1,7,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion despedida','Habitacion para 5 estilo fiesta',
  1,8,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion graduacion','Habitacion ambientada estudiantes $',
  1,7,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion amigos','Habitacion para 2 camas indiv',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion solo pa mi','Habitacion con dos camas ',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion estudiambre','Cuarto estudiante solo 1 cama',
  1,1,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion MATRIMONIO','Habitacion para pareja economica',
  1,2,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion amigos','Habitacion para 2 camas indiv',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion solo pa mi','Habitacion con dos camas ',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion estudiambre','Cuarto estudiante solo 1 cama',
  1,1,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion toy solo','Habitacion 1 cama solo dormir',
  1,3,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion solitario','Habitacion 1 cama 1 persona',
  1,3,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion lujito','Habitacion para 4 personas bebida',
  1,6,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion no mas','Habitacion para 4 personas comida',
  1,6,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion pa eso trabajo','Habitacion para 4 personas comida',
  1,6,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion reunion','Habitacion para 4 personas buffet',
  1,6,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion como jijos no','Habitacion para 5 bebida y comida',
  1,7,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion nosotros','Habitacion para pareja comida',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion inclusiva','Habitacion lgbt',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion luna miel','Habitacion para pareja casada',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion preboda','Habitacion para pareja-solteras!',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion solo amigos','Habitacion para pareja amigos ',
  1,4,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion juegos','Habitacion para fam con hijos',
  1,10,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion ya grandes','Habitacion fam hijos jovenes ',
  1,10,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion mezclas','Habitacion familiar peques y jovenes ',
  1,10,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion childfree','Habitacion para familia sin niños ',
  1,10,'INSERT'
GO

EXEC sp_habitacion_crud
  NULL, 'Habitacion compadres','Habitacion para carnita asada',
  1,5,'INSERT'
GO


----