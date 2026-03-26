-- BDs de sistema y usuario
-- ========================
SHOW DATABASES;
-- Para ver las BDs de sistema gráficamente:
-- Workbench: Edit - Preferences - SQL Editor - Show Metadata and Internal Schemas
-- DBeaver: clic derecho en la conexión - Connection view - Show system objects

SHOW Tables;

-- Selección de una tabla
-- ======================
-- especificando la BD
SELECT * FROM TrabGrad.Trabajos;

-- sin especificar la BD (toma la BD predeterminada)
SELECT * FROM Trabajos;

-- Sobre el directorio de datos
-- ============================
SHOW VARIABLES LIKE 'datadir';

-- Tipos de tablas
-- ===============
SHOW ENGINES;

-- Creación y borrado de BD
-- ========================
DROP DATABASE IF EXISTS LBD2026;
CREATE DATABASE IF NOT EXISTS LBD2026;

USE LBD2026;

-- Tabla con tipos de datos numéricos
-- ==================================
SET @d1 = CAST(0.1 AS DECIMAL(10, 4)); -- se guarda como número exacto (0.1)
SET @d2 = CAST(0.2 AS DECIMAL(10, 4)); -- se guarda como número exacto (0.2)
SET @f1 = CAST(0.1 AS FLOAT); -- se guarda en binario, coma flotante (0.10000000149011612 aprox.)
SET @f2 = CAST(0.2 AS FLOAT);

SELECT 
	@f1, @f2; -- precisión exacta (se usa para dinero, cantidades, etc)

SELECT 
	@d1 + @d2 AS suma_decimal, -- precisión exacta (se usa para dinero, cantidades, etc)
	@f1 + @f2 AS suma_float; -- precisión aproximada (se usa para cálculos científicos, gráficos, etc)

-- Comparaciones	
SELECT 
	(@d1 + @d2) = 0.3 AS son_iguales_decimal,
	(@f1 + @f2) = 0.3 AS son_iguales_float;


-- Atributos para los tipos numéricos
-- ==================================

CREATE TABLE IF NOT EXISTS Tabla1 (
	colInt INT, -- 10 es el valor predeterminado del ancho de visualización
    colInt3 INT(3),
    colIntUnsigned INT UNSIGNED ZEROFILL -- de 0 a 4294967295 4294967295
) ENGINE=INNODB;

INSERT INTO Tabla1 VALUES(1, 1, 1);
INSERT INTO Tabla1 VALUES(10, 10, 10);
INSERT INTO Tabla1 VALUES(100, 100, 100);
INSERT INTO Tabla1 VALUES(1000, 1000, 1000);
INSERT INTO Tabla1 VALUES(10000, 10000, 10000);
INSERT INTO Tabla1 VALUES(1, 1, -2147483648); -- fuera de rango
INSERT INTO Tabla1 VALUES(1, 1, 4294967295); -- bien
INSERT INTO Tabla1 VALUES(1, 1, 4294967296); -- fuera de rango

SELECT * FROM Tabla1;

-- Atributo AUTO_INCREMENT (columna entera)

CREATE TABLE IF NOT EXISTS Tabla2 (
	colInt INT,
    colIntAutoIncrement INT AUTO_INCREMENT,
    PRIMARY KEY (colIntAutoIncrement)
) ENGINE=INNODB;

INSERT INTO Tabla2 (colInt) VALUES (100);
INSERT INTO Tabla2 (colInt) VALUES (200);
INSERT INTO Tabla2 (colInt) VALUES (300);

SELECT * FROM Tabla2;
SELECT LAST_INSERT_ID();

INSERT INTO Tabla2 (colInt, colIntAutoIncrement) VALUES (400, 10);
INSERT INTO Tabla2 (colInt) VALUES (500);

SELECT * FROM Tabla2;
SELECT LAST_INSERT_ID();
INSERT INTO Tabla2 (colInt, colIntAutoIncrement) VALUES (600, 9);
INSERT INTO Tabla2 (colInt) VALUES (700);
SELECT * FROM Tabla2;
SELECT LAST_INSERT_ID();

INSERT INTO Tabla2 (colInt, colIntAutoIncrement) VALUES (1800, 3);


-- Atributo AUTO_INCREMENT (columna flotante)
CREATE TABLE IF NOT EXISTS Tabla3 (
	colInt INT,
    colFloatAutoIncrement FLOAT(4, 2) AUTO_INCREMENT,
    PRIMARY KEY (colFloatAutoIncrement)
) ENGINE=INNODB;

INSERT INTO Tabla3 (colInt) VALUES (100);
INSERT INTO Tabla3 (colInt) VALUES (200);
INSERT INTO Tabla3 (colInt) VALUES (300);

SELECT * FROM Tabla3;
SELECT LAST_INSERT_ID();

INSERT INTO Tabla3 (colInt, colFloatAutoIncrement) VALUES (400, 10.00);
INSERT INTO Tabla3 (colInt) VALUES (500);

SELECT * FROM Tabla3;
SELECT LAST_INSERT_ID();

-- Tabla con tipos de datos para fechas
-- ====================================

-- Para ver la zona horaria actual
SELECT @@global.time_zone, @@session.time_zone;
-- SYSTEM: MySQL está usando la zona horaria del sistema operativo, esto se puede ver haciendo:

select now(), utc_timestamp();
-- now(): muestra fecha y hora según la zona horaria actual del sistema
-- utc_timestamp(): muestra la hora en UTC

DROP TABLE IF EXISTS Tabla4;

CREATE TABLE IF NOT EXISTS Tabla4 (
	colIntAutoIncrement INT AUTO_INCREMENT,
    colDateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    colTimeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (colIntAutoIncrement)
) ENGINE = INNODB;

INSERT INTO Tabla4 () VALUES (); -- fecha/hora actual

SELECT * FROM Tabla4;
-- colDateTime guarda fecha y hora actual
-- colTimeStamp guarda fecha y hora actual en UTC y al mostrarla lo hace según la zona horaria actual

-- Se cambia la zona horaria a UTC:
SET time_zone = '+00:00';
SELECT * FROM Tabla4;

-- Se vuelve a la zona horaria (por ejemplo, a Buenos Aires)
SET time_zone = 'SYSTEM';
SELECT * FROM Tabla4;


-- Tabla con tipos de datos CHAR y BINARY
-- ======================================
DROP TABLE IF EXISTS Tabla5;

CREATE TABLE IF NOT EXISTS Tabla5 (
	colVarchar VARCHAR(10), -- compara cadenas usando una collation
    colVarbinary VARBINARY(10) -- compara cadenas usando bytes
) ENGINE = INNODB;

-- Para saber el collation de una tabla:
SHOW TABLE STATUS WHERE Name = 'Tabla5';
-- collation: utf8mb4_0900_ai_ci
-- utf8mb4: Unicode completo (incluye emojis y caracteres especiales, a diferencia del viejo utf8 que es limitado)
-- 0900: versión del estándar de Unicode
-- ai: accent insensitive (no distingue acentos)
-- ci: case insensitive (no distingue mayúsculas y minúsculas)

-- Para saber el collation de las columnas de una tabla:
SHOW FULL COLUMNS FROM Tabla5;
-- colVarchar: utf8mb4_0900_ai_ci
-- colVarBinary: null

-- Para ver todos los juegos de caracteres:
SHOW CHARACTER SET;

-- Para ver todas las collations:
SHOW COLLATION;

INSERT INTO Tabla5 VALUES ('Mundo', 'Mundo');
INSERT INTO Tabla5 VALUES ('mundo', 'mundo');
INSERT INTO Tabla5 VALUES ('hola', 'hola');
INSERT INTO Tabla5 VALUES ('Hola', 'Hola');
INSERT INTO Tabla5 VALUES ('jabon', 'jabon');
INSERT INTO Tabla5 VALUES ('JABON', 'jabon');

SELECT * FROM Tabla5 ORDER BY colVarchar;
-- Para poder ver una columna BINARY: preferencias - “SQL Execution” - “Treat Binary/Varbinary as nonbinary character string”


SELECT * FROM Tabla5 ORDER BY colVarbinary;
-- Hola, Mundo, hola, mundo: según el valor numérico de las cadenas

SELECT * FROM Tabla5 
WHERE colVarchar = 'hola'; -- coincide con 'Hola' y 'hola' (si el collation lo permite)


SELECT * FROM Tabla5 
WHERE colVarbinary = BINARY 'hola'; -- no coincide con 'Hola'

-- Para cambiar el collation de una columna específica
-- ALTER TABLE Tabla5 
-- MODIFY colVarchar VARCHAR(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Para cambiar el collation de una tabla entera:
-- ALTER TABLE Tabla5 CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- Tabla con tipo de dato Enum
-- =========================== 	

CREATE TABLE IF NOT EXISTS Tabla6 (
    marca VARCHAR(40) NOT NULL,
    tamanio ENUM('Small', 'Medium', 'Large')
) ENGINE=INNODB;

INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca1', 'Small'); -- posición = 1
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca2', 'Medium'); -- posición = 2
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca3', 'Medium'); -- posición = 2
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca4', 'Small'); -- posición = 1
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca5', 'Medium'); -- posición = 2
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca6', 'Large'); -- posición = 3
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca7', 'large'); -- valor válido, posición = 3
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca8', NULL); -- valor válido, posición = NULL
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca9', ''); -- valor inválido, posición = 0 (modo estricto debe estar deshabilitado. Se habilita mediante el archivo my.ini)
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca10', 'Otro valor'); -- valor inválido
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca11', 0); -- valor inválido
INSERT INTO Tabla6 (marca, tamanio) VALUES ('Marca12', 1); -- posición = 1
-- Si la columna tamanio se hubiera declarado como VARCHAR, 
-- insertar un millón de filas con el valor ‘medium’ requeriría 6 millones de bytes
-- Al declararse como ENUM se requieren 1 millón

SELECT marca, tamanio, tamanio + 0 as 'Posición' FROM Tabla6;

SELECT * FROM Tabla6
ORDER BY tamanio; 
-- ordena según la posición


-- Tabla con tipo de dato Set
-- ==========================

CREATE TABLE IF NOT EXISTS Tabla7 (
    idAlumno INT NOT NULL,
    turnos SET('Turno1', 'Turno2', 'Turno3')
) ENGINE=INNODB;

INSERT INTO Tabla7 (idAlumno, turnos) VALUES (1, 'Turno1'); -- valor válido
INSERT INTO Tabla7 (idAlumno, turnos) VALUES (2, 'Turno1,Turno2'); -- valor válido
INSERT INTO Tabla7 (idAlumno, turnos) VALUES (3, 'Turno1, Turno2'); -- valor inválido (espacio en blanco)
INSERT INTO Tabla7 (idAlumno, turnos) VALUES (4, 'Turno2,Turno1'); -- valor válido
INSERT INTO Tabla7 (idAlumno, turnos) VALUES (5, 'Turno1,Turno2,Turno3'); -- valor válido
INSERT INTO Tabla7 (idAlumno, turnos) VALUES (6, 'Turno1,Turno2,Turno3,Turno3'); -- valor válido
INSERT INTO Tabla7 (idAlumno, turnos) VALUES (7, ''); -- valor válido
INSERT INTO Tabla7 (idAlumno, turnos) VALUES (8, 'Turno1,Turno2,Turno3,Turno4'); -- valor inválido
INSERT INTO Tabla7 (idAlumno, turnos) VALUES (9, 'Turno4'); -- valor inválido

INSERT INTO Tabla7 (idAlumno, turnos) VALUES (10, 1); 

SELECT * FROM Tabla7;


-- Borrado de tabla
-- ================
DROP TABLE IF EXISTS Tabla; 