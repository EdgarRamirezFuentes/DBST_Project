-- MS SQL SERVER INIT SCRIPT
-- This script is used to create the database and tables for the application

-- TEST DB

-- Create the database
CREATE DATABASE ESCOM_HOTEL;

USE ESCOM_HOTEL;

-- Create the tables
CREATE TABLE Hotels (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(50),
);

CREATE TABLE Hotelslog (
    id INT IDENTITY(1,1) PRIMARY KEY,
    idHotel INT,
    CONSTRAINT FK_Hotel FOREIGN KEY (idHotel)
    REFERENCES Hotels(id)
);

CREATE TRIGGER Hotelslog_trigger ON Hotels AFTER INSERT AS
BEGIN
    DECLARE @idHotel INT
    SELECT @idHotel = id FROM inserted
    INSERT INTO Hotelslog (idHotel) VALUES (@idHotel)
END