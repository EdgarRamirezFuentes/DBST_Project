-- INIT SCRIPT PARA ESCOM_HOTEL DB

CREATE DATABASE ESCOM_HOTEL;

USE ESCOM_HOTEL;

-------------------------
-- TABLAS PARA USUARIO --
-------------------------

CREATE TABLE Rol (
    idRol INT NOT NULL,
    nombre  VARCHAR(50) NOT NULL,
    -- PRIMARY KEY Rol
    CONSTRAINT PK_Rol_idRol 
    PRIMARY KEY CLUSTERED (idRol)
);


CREATE TABLE Usuario (
    idUsuario INT NOT NULL,
    nombre VARCHAR (100) NOT NULL,
    apPaterno VARCHAR (100) NOT NULL,
    apMaterno VARCHAR (100) NOT NULL,
    fechaNacimiento DATE NOT NULL,
    curp VARCHAR (18),
    rfc VARCHAR (13),
    telefono VARCHAR (10) NOT NULL,
    correo VARCHAR (100) NOT NULL,
    contrasenia VARCHAR (25) NOT NULL,
    idRol INT,
    idDireccion INT,
    idContactoEmergencia INT,
    isActive BIT NOT NULL,
    -- PRIMARY KEY Usuario
    CONSTRAINT PK_Usuario_idUsuario 
    PRIMARY KEY CLUSTERED (idUsuario),
    -- FOREIGN KEY Rol
    CONSTRAINT FK_Usuario_Rol 
    FOREIGN KEY (idRol)
    REFERENCES Rol (idRol)
    ON DELETE SET NULL
);


CREATE TABLE ContactoEmergencia (
    idContactoEmergencia INT NOT NULL,
    nombre VARCHAR (100) NOT NULL,
    apPaterno VARCHAR (50) NOT NULL,
    apMaterno VARCHAR (50) NOT NULL,
    telefono VARCHAR (10) NOT NULL,
    idUsuario INT NOT NULL,
    -- PRIMARY KEY ContactoEmergencia
    CONSTRAINT PK_ContantoEmergencia_idContactoEmergencia 
    PRIMARY KEY CLUSTERED (idContactoEmergencia),
    -- FOREIGN KEY Usuario
    CONSTRAINT FK_ContactoEmergencia_Usuario
    FOREIGN KEY (idUsuario)
    REFERENCES Usuario (idUsuario)
    ON DELETE CASCADE
);


CREATE TABLE Direccion (
    idDireccion INT NOT NULL,
    calle VARCHAR (50) NOT NULL,
    numExterior VARCHAR (15) NOT NULL,
    numInterior VARCHAR (15),
    colonia VARCHAR (50) NOT NULL,
    estado VARCHAR (50) NOT NULL, 
    alcaldia VARCHAR (50) NOT NULL,
    codigoPostal VARCHAR (6) NOT NULL,
    idUsuario INT NOT NULL,
    -- PRIMARY KEY Direccion
    CONSTRAINT PK_Direccion_idDireccion 
    PRIMARY KEY CLUSTERED (idDireccion),
    -- FOREIGN KEY Usuario
    CONSTRAINT FK_Direccion_Usuario
    FOREIGN KEY (idUsuario)
    REFERENCES Usuario (idUsuario)
    ON DELETE CASCADE
);


-------------------------
-- TABLAS PARA CLIENTE --
-------------------------

CREATE TABLE Cliente (
    idCliente INT NOT NULL,
    idUsuario INT NOT NULL,
    idMetodoPago INT,
    -- PRIMARY KEY Cliente
    CONSTRAINT PK_Cliente_idCliente 
    PRIMARY KEY CLUSTERED (idCliente),
    -- FOREIGN KEY Usuario
    CONSTRAINT FK_Cliente_Usuario 
    FOREIGN KEY (idUsuario)
    REFERENCES Usuario (idUsuario)
    ON DELETE CASCADE
);


CREATE TABLE MetodoPago (
    idMetodoPago INT NOT NULL,
    nombreEnTarjeta VARCHAR (100) NOT NULL,
    numeroTarjeta VARCHAR (16) NOT  NULL,
    cvv VARCHAR (3) NOT NULL,
    fechaVencimiento DATE NOT NULL,
    idCliente INT NOT NULL,
    -- PRIMARY KEY MetodoPago
    CONSTRAINT PK_MetodoPago_idMetodoPago
    PRIMARY KEY CLUSTERED (idMetodoPago),
    -- FOREIGN KEY Cliente
    CONSTRAINT FK_MetodoPago_Cliente
    FOREIGN KEY (idCliente)
    REFERENCES Cliente (idCliente)
    ON DELETE CASCADE
);


----------------------------
-- TABLAS PARA TRABAJADOR --
----------------------------

CREATE TABLE Area (
    idArea INT NOT NULL,
    nombre VARCHAR (100) NOT NULL,
    idEncargado INT,
    CONSTRAINT PK_Area_idArea 
    PRIMARY KEY CLUSTERED (idArea)
);


CREATE TABLE Trabajador (
    idTrabajador INT NOT NULL,
    sueldo MONEY NOT NULL,
    idUsuario INT NOT NULL,
    idArea INT,
    -- PRIMARY KEY Trabajador
    CONSTRAINT PK_Trabajador_idTrabajador
    PRIMARY KEY CLUSTERED (idTrabajador),
    -- FOREIGN KEY Usuario
    CONSTRAINT FK_Trabajador_Usuario 
    FOREIGN KEY (idUsuario)
    REFERENCES Usuario (idUsuario)
    ON DELETE CASCADE,
    -- FOREIGN KEY Area
    CONSTRAINT FK_Trabajador_Area 
    FOREIGN KEY (idArea)
    REFERENCES Area (idArea)
    ON DELETE SET NULL
);


------------------------------
-- TABLAS PARA HABITACIONES --
------------------------------

CREATE TABLE TipoHabitacion (
    idTipoHabitacion INT NOT NULL,
    nombre VARCHAR (50) NOT NULL,
    numCamas INT NOT NULL,
    numPersonas INT NOT NULL,
    precio MONEY NOT NULL,
    -- PRIMARY KEY TipoHabitacion
    CONSTRAINT PK_TipoHabitacion_idTipoHabitacion
    PRIMARY KEY CLUSTERED (idTipoHabitacion)
);


CREATE TABLE Habitacion (
    idHabitacion INT NOT NULL,
    nombre VARCHAR (100) NOT NULL,
    descripcion VARCHAR (100) NOT NULL,
    isActive BIT NOT NULL,
    idTipoHabitacion INT,
    -- PRIMARY KEY Habitacion
    CONSTRAINT PK_Habitacion_idHabitacion
    PRIMARY KEY CLUSTERED (idHabitacion),
    -- FOREIGN KEY TipoHabitacion
    CONSTRAINT FK_Habitacion_TipoHabitacion
    FOREIGN KEY (idTipoHabitacion)
    REFERENCES TipoHabitacion (idTipoHabitacion)
    ON DELETE SET NULL
);


-----------------------------
-- TABLAS PARA Reservacion --
-----------------------------

CREATE TABLE Reservacion (
    idReservacion INT NOT NULL,
    fechaInicio DATE NOT NULL,
    fechaFin DATE NOT NULL,
    idCliente INT NOT NULL,
    idHabitacion INT NOT NULL,
    -- PRIMARY KEY Resevacion
    CONSTRAINT PK_Reservacion_idReservacion
    PRIMARY KEY CLUSTERED (idReservacion),
    -- FOREIGN KEY  Cliente
    CONSTRAINT FK_Reservacion_Cliente
    FOREIGN KEY (idCliente)
    REFERENCES Cliente (idCliente),
    -- FOREIGN KEY Habitacion
    CONSTRAINT FK_Reservacion_Habitacion
    FOREIGN KEY (idHabitacion)
    REFERENCES Habitacion (idHabitacion)
);


CREATE TABLE Ticket (
    idTicket INT NOT NULL,
    fecha DATE NOT NULL,
    total MONEY NOT NULL DEFAULT 0,
    idReservacion INT NOT NULL,
    -- PRIMARY KEY Ticket
    CONSTRAINT PK_Ticket_idTicket
    PRIMARY KEY CLUSTERED (idTicket),
    -- FOREIGN KEY Reservacion
    CONSTRAINT FK_Ticket_Reservacion
    FOREIGN KEY (idReservacion)
    REFERENCES Reservacion (idReservacion)
    ON DELETE CASCADE
);


CREATE TABLE CargoExtra (
    idCargoExtra INT NOT NULL,
    nombre VARCHAR (50) NOT NULL,
    descripcion VARCHAR (100) NOT NULL,
    precio MONEY NOT NULL DEFAULT 0,
    CONSTRAINT PK_CargoExtra_idCargoExtra
    PRIMARY KEY CLUSTERED(idCargoExtra)
);


CREATE TABLE TicketCargoExtra (
    idTicketCargoExtra INT NOT NULL,
    fecha DATE NOT NULL,
    idTicket INT NOT NULL,
    idCargoExtra INT NOT NULL,
    -- PRIMARY KEY TicketCargoExtra
    CONSTRAINT PK_TicketCargoExtra_idTicketCargoExtra
    PRIMARY KEY CLUSTERED (idTicketCargoExtra),
    -- FOREIGN KEY Ticket
    CONSTRAINT FK_TicketCargoExtra_Ticket
    FOREIGN KEY (idTicket)
    REFERENCES Ticket (idTicket)
    ON DELETE CASCADE,
    -- FOREIGN KEY Cargo Extra
    CONSTRAINT FK_TicketCargoExtra_CargoExtra
    FOREIGN KEY (idCargoExtra)
    REFERENCES CargoExtra (idCargoExtra)
    ON DELETE CASCADE
);


-----------------------
-- TABLAS PARA Tarea --
-----------------------

CREATE TABLE EstadoTarea (
    idEstadoTarea INT NOT NULL,
    nombre VARCHAR (50) NOT NULL,
    -- PRIMARY KEY EstadoTarea
    CONSTRAINT PK_EstadoTarea_idEstadoTarea
    PRIMARY KEY CLUSTERED (idEstadoTarea)
);


CREATE TABLE Tarea (
    idTarea INT NOT NULL,
    idTrabajador INT NOT NULL,
    idHabitacion INT NOT NULL,
    idEstadoTarea INT NOT NULL,
    -- PRIMARY KEY Tarea
    CONSTRAINT PK_Tarea_idTarea
    PRIMARY KEY CLUSTERED (idTarea),
    -- FOREIGN KEY Trabajador
    CONSTRAINT FK_Tarea_Trabajador
    FOREIGN KEY (idTrabajador)
    REFERENCES Trabajador (idTrabajador),
    -- FOREIGN KEY Habitacion
    CONSTRAINT FK_Tarea_Habitacion
    FOREIGN KEY (idHabitacion)
    REFERENCES Habitacion (idHabitacion),
    -- FOREIGN KEY EstadoTarea
    CONSTRAINT FK_Tarea_EstadoTarea
    FOREIGN KEY (idEstadoTarea)
    REFERENCES EstadoTarea (idEstadoTarea)
);


----------------------
-- TABLAS PARA Logs --
----------------------

CREATE TABLE HabitacionLogs (
    idHabitacionLogs INT NOT NULL,
    idUsuario INT NOT NULL, 
    idHabitacion INT NOT NULL, 
    fecha TIMESTAMP NOT NULL,
    -- PRIMARY KEY  Habitacionlogs
    CONSTRAINT PK_HabitacionLogs_idHabitacionLogs
    PRIMARY KEY CLUSTERED (idHabitacionLogs)
);


CREATE TABLE TareaLogs (
    idTareaLogs INT NOT NULL, 
    idTarea INT NOT NULL, 
    idTrabajador INT NOT NULL, -- El último que actualizó la tarea
    estadoTarea VARCHAR (50) NOT NULL, -- Estado actual de la tarea
    fecha TIMESTAMP NOT NULL, 
    -- PRIMARY KEY TareaLogs
    CONSTRAINT PK_TareaLogs_idTareaLogs
    PRIMARY KEY CLUSTERED (idTareaLogs)
);


CREATE TABLE ReservacionLogs (
    idReservacionLogs INT NOT NULL,
    idReservacion INT NOT NULL,
    idTrabajador INT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    -- PRIMARY KEY ReservacionLogs
    CONSTRAINT PK_ReservacionLogs_idReservacionLogs
    PRIMARY KEY CLUSTERED (idReservacionLogs)
);


CREATE TABLE ClienteLogs (
    idClienteLogs INT NOT NULL,
    idUsuario INT NOT NULL,
    idCliente INT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    -- PRIMARY KEY ClienteLogs
    CONSTRAINT PK_ClienteLogs_idClienteLogs
    PRIMARY KEY CLUSTERED (idClienteLogs)
);


CREATE TABLE UsuarioLogs (
    idUsuarioLogs INT NOT NULL,
    idUsuario INT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    -- PRIMARY KEY UsuariosLogs
    CONSTRAINT PK_UsuariosLogs_idUsuariosLogs
    PRIMARY KEY CLUSTERED (idUsuarioLogs)
);

--------------
-- TRIGGERS --
--------------