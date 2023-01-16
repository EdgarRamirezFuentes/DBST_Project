-- INIT SCRIPT FOR ESCOM_HOTEL DB
USE MASTER;

DROP DATABASE IF EXISTS ESCOM_HOTEL;

GO; 

CREATE DATABASE ESCOM_HOTEL;

USE ESCOM_HOTEL;

-----------------
-- USER TABLES --
-----------------

CREATE TABLE Rol (
    idRol INT IDENTITY(1,1) NOT NULL,
    nombre  VARCHAR(50) NOT NULL,
    -- PRIMARY KEY Rol
    CONSTRAINT PK_Rol_idRol
    PRIMARY KEY CLUSTERED (idRol)
);

GO

CREATE TABLE Usuario (
    idUsuario INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR (100) NOT NULL,
    apPaterno VARCHAR (100) NOT NULL,
    apMaterno VARCHAR (100) NOT NULL,
    fechaNacimiento DATE NOT NULL,
    sexo VARCHAR (1) NOT NULL,
    curp VARCHAR (18) NOT NULL UNIQUE,
    rfc VARCHAR (13) UNIQUE,
    telefono VARCHAR (10) NOT NULL,
    correo VARCHAR (100) NOT NULL,
    contrasenia BINARY(64) NOT NULL,
    idRol INT,
    fechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
    activo BIT NOT NULL DEFAULT 1,
    -- PRIMARY KEY Usuario
    CONSTRAINT PK_Usuario_idUsuario
    PRIMARY KEY CLUSTERED (idUsuario),
    -- FOREIGN KEY Rol
    CONSTRAINT FK_Usuario_Rol
    FOREIGN KEY (idRol)
    REFERENCES Rol (idRol)
    ON DELETE SET NULL
);

GO

CREATE TABLE ContactoEmergencia (
    idContactoEmergencia INT IDENTITY(1,1) NOT NULL,
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

GO

CREATE TABLE Direccion (
    idDireccion INT IDENTITY(1,1) NOT NULL,
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

GO


---------------------
-- CUSTOMER TABLES --
---------------------

CREATE TABLE Cliente (
    idCliente INT IDENTITY(1,1) NOT NULL,
    idUsuario INT NOT NULL,
    -- PRIMARY KEY Cliente
    CONSTRAINT PK_Cliente_idCliente
    PRIMARY KEY CLUSTERED (idCliente),
    -- FOREIGN KEY Usuario
    CONSTRAINT FK_Cliente_Usuario
    FOREIGN KEY (idUsuario)
    REFERENCES Usuario (idUsuario)
    ON DELETE CASCADE
);

GO

CREATE TABLE MetodoPago (
    idMetodoPago INT IDENTITY(1,1) NOT NULL,
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

GO

--------------------
-- EMPLOYEE TABLE --
--------------------

CREATE TABLE Area (
    idArea INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR (100) NOT NULL,
    idEncargado INT,
    CONSTRAINT PK_Area_idArea
    PRIMARY KEY CLUSTERED (idArea)
);

GO

CREATE TABLE Trabajador (
    idTrabajador INT IDENTITY(1,1) NOT NULL,
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

GO

-----------------
-- ROOM TABLES --
-----------------

CREATE TABLE TipoHabitacion (
    idTipoHabitacion INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR (50) NOT NULL,
    numCamas INT NOT NULL,
    numPersonas INT NOT NULL,
    precio MONEY NOT NULL,
    -- PRIMARY KEY TipoHabitacion
    CONSTRAINT PK_TipoHabitacion_idTipoHabitacion
    PRIMARY KEY CLUSTERED (idTipoHabitacion)
);

GO

CREATE TABLE Habitacion (
    idHabitacion INT IDENTITY(1,1) NOT NULL,
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

GO

------------------------
-- RESERVATION TABLES --
------------------------

CREATE TABLE Reservacion (
    idReservacion INT IDENTITY(1,1) NOT NULL,
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

GO

CREATE TABLE Ticket (
    idTicket INT IDENTITY(1,1) NOT NULL,
    fecha DATE NOT NULL,
    -- total MONEY NOT NULL DEFAULT 0,
    idReservacion INT NOT NULL,
    --subTotal MONEY NOT NULL DEFAULT 0,
    total MONEY NOT NULL DEFAULT 0,
    -- PRIMARY KEY Ticket
    CONSTRAINT PK_Ticket_idTicket
    PRIMARY KEY CLUSTERED (idTicket),
    -- FOREIGN KEY Reservacion
    CONSTRAINT FK_Ticket_Reservacion
    FOREIGN KEY (idReservacion)
    REFERENCES Reservacion (idReservacion)
    ON DELETE CASCADE
);

GO

CREATE TABLE CargoExtra (
    idCargoExtra INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR (50) NOT NULL,
    descripcion VARCHAR (100) NOT NULL,
    precio MONEY NOT NULL DEFAULT 0,
    CONSTRAINT PK_CargoExtra_idCargoExtra
    PRIMARY KEY CLUSTERED(idCargoExtra)
);

GO

CREATE TABLE ReservacionCargoExtra (
    idReservacionCargoExtra INT IDENTITY(1,1) NOT NULL,
    idCargoExtra INT NOT NULL,
    idReservacion INT NOT NULL,
    -- PRIMARY KEY 
    CONSTRAINT PK_ReservacionCargoExtra_idReservacionCargoExtra
    PRIMARY KEY CLUSTERED (idReservacionCargoExtra),
    -- FOREIGN KEY Cargo Extra
    CONSTRAINT FK_ReservacionCargoExtra_idCargoExtra
    FOREIGN KEY (idCargoExtra)
    REFERENCES CargoExtra (idCargoExtra)
    ON DELETE CASCADE,
    -- FOREIGN KEY Reservacion
    CONSTRAINT FK_ReservacionCargoExtra_idReservacion
    FOREIGN KEY (idReservacion)
    REFERENCES Reservacion (idReservacion)
    ON DELETE CASCADE
);

GO

-----------------
-- TASK TABLES --
-----------------

CREATE TABLE EstadoTarea (
    idEstadoTarea INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR (50) NOT NULL,
    -- PRIMARY KEY EstadoTarea
    CONSTRAINT PK_EstadoTarea_idEstadoTarea
    PRIMARY KEY CLUSTERED (idEstadoTarea)
);

GO

CREATE TABLE Tarea (
    idTarea INT IDENTITY(1,1) NOT NULL,
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

GO

----------------
-- LOG TABLES --
----------------

CREATE TABLE HabitacionLogs (
    idHabitacionLogs INT IDENTITY(1,1) NOT NULL,
    idTrabajador INT,
    idHabitacion INT NOT NULL,
    fecha TIMESTAMP NOT NULL,
    -- PRIMARY KEY  Habitacionlogs
    CONSTRAINT PK_HabitacionLogs_idHabitacionLogs
    PRIMARY KEY CLUSTERED (idHabitacionLogs),
    -- FOREIGN KEY Habitacion
    CONSTRAINT FK_HabitacionLogs_Habitacion
    FOREIGN KEY (idHabitacion)
    REFERENCES Habitacion (idHabitacion)
    ON DELETE CASCADE,
    -- FOREIGN KEY Trabajador
    CONSTRAINT FK_HabitacionesLogs_Trabajador
    FOREIGN KEY (idTrabajador)
    REFERENCES Trabajador (idTrabajador)
    ON DELETE SET NULL
);

GO

CREATE TABLE TareaLogs (
    idTareaLogs INT IDENTITY(1,1) NOT NULL,
    idTarea INT NOT NULL,
    idTrabajador INT,
    fecha TIMESTAMP NOT NULL,
    -- PRIMARY KEY TareaLogs
    CONSTRAINT PK_TareaLogs_idTareaLogs
    PRIMARY KEY CLUSTERED (idTareaLogs),
    -- FOREIGN KEY Tarea
    CONSTRAINT FK_TareaLogs_Tarea
    FOREIGN KEY (idTarea)
    REFERENCES Tarea (idTarea)
    ON DELETE CASCADE,
    -- FOREIGN KEY Trabajador
    CONSTRAINT FK_TareaLogs_Trabajador
    FOREIGN KEY (idTrabajador)
    REFERENCES Trabajador (idTrabajador)
    ON DELETE SET NULL
);

GO

CREATE TABLE ReservacionLogs (
    idReservacionLogs INT IDENTITY(1,1) NOT NULL,
    idReservacion INT NOT NULL,
    idTrabajador INT,
    fecha TIMESTAMP NOT NULL,
    -- PRIMARY KEY ReservacionLogs
    CONSTRAINT PK_ReservacionLogs_idReservacionLogs
    PRIMARY KEY CLUSTERED (idReservacionLogs),
    -- FOREIGN KEY Reservacion
    CONSTRAINT FK_ReservacionLogs_Reservacion
    FOREIGN KEY (idReservacion)
    REFERENCES Reservacion (idReservacion)
    ON DELETE CASCADE,
    -- FOREIGN KEY Trabajador
    CONSTRAINT FK_ReservacionLogs_Trabajador
    FOREIGN KEY (idTrabajador)
    REFERENCES Trabajador (idTrabajador)
    ON DELETE SET NULL
);

GO

