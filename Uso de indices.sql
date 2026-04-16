-- Tablas
SHOW TABLES;

-- Estructura + PK (índice agrupado en InnoDB)
SHOW CREATE TABLE Estudiantes;
SHOW CREATE TABLE Participacion;
-- En InnoDB, la PK es el índice agrupado (clustered index)
-- Los demás índices son secundarios (no agrupados)

-- Índices creados
SHOW INDEX FROM Estudiantes;
SHOW INDEX FROM Participacion; -- por qué no muestra el índice por la FK idEstudiante (muestra el de idTrabajos)
SHOW INDEX FROM Tutelaje; -- por qué no muestra el índice por la FK idProfesor (muestra el de idTrabajos)
select * from Estudiantes;
ALTER TABLE Estudiantes 
DROP INDEX idx_dni;

CREATE UNIQUE INDEX `dni_UNIQUE` ON `Estudiantes` (`dni` ASC) VISIBLE;

DELETE FROM Estudiantes;

INSERT INTO Estudiantes VALUES
(1,'Perez','Juan','11111111',NULL),
(2,'Gomez','Ana','22222222',NULL),
(3,'Lopez','Luis','33333333',NULL),
(4,'Diaz','Maria','44444444',NULL),
(5,'Sosa','Pedro','55555555',NULL);

-- TABLE SCAN (escaneo completo)

EXPLAIN SELECT * 
FROM Estudiantes
WHERE nombres = 'Juan'; -- type: ALL (Table Scan: no hay índice sobre nombres)
-- Table scan: se leen todas las filas completas (costo: 1.25)

-- HAY un índice pero NO se usa

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE dni LIKE '%1111'; -- type: ALL (el % al inicio rompe el uso del índice. Costo: 1.25)

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE dni = '11111111'; -- type: const (usa el índice dni_UNIQUE)

-- Se fuerza el uso del índice

explain SELECT * 
FROM Estudiantes FORCE INDEX (dni_UNIQUE) 
WHERE dni LIKE '%1111'; -- costo: 3.75

-- Uso de índice agrupado (PK)

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE idEstudiante = 1; -- type: const o ref, key: PRIMARY (usa el índice agrupado)

-- Uso de índice NO agrupado

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE dni = '11111111'; -- type: const o ref, key: dni_UNIQUE (usa el índice NO agrupado)


-- Consulta ambigua (puede usar varios índices)
-- Una consulta puede usar varios índices:
--  * cuando hay múltiples columnas indexadas involucradas (en este caso podría usar idEstudiante o no usar un índice)
--  * cuando hay más de un índice que podría satisfacer la condición
--  * cuando hay varias condiciones (AND / OR) 
--  * cuando se necesiten distintas columnas (costo de lookup)

-- El optimizador PREFIERE el índice agrupado sobre el NO agrupado

INSERT INTO Estudiantes
SELECT 
  1000 + seq,
  'Apellido' ,
  'Nombre',
  LPAD(seq,8,'0'),
  NULL
FROM (
  SELECT 1 seq UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
) t;
SELECT * FROM Estudiantes;

CREATE UNIQUE INDEX `UI_idEstudiante` ON `Estudiantes` (`idEstudiante` ASC) VISIBLE;
SHOW INDEX FROM Estudiantes;

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE idEstudiante = 1; -- type: const o ref, key: PRIMARY (usa el índice agrupado)

/*EXPLAIN*/ SELECT idEstudiante 
FROM Estudiantes
WHERE idEstudiante > 0; -- (type: index => full index scan: sólo las columnas del índice)

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE idEstudiante > 0; -- (type: range => index range scan: usa un índice para recuperar un conjunto de filas dentro de un rango de valores, no una sola fila)

-- Evitar índice

/*EXPLAIN*/ SELECT * 
FROM Estudiantes IGNORE INDEX (dni_UNIQUE)
WHERE dni = '11111111'; -- full table scan

SELECT * 
FROM Estudiantes IGNORE INDEX (primary)
WHERE idEstudiante = 1;

ALTER TABLE Estudiantes 
DROP INDEX UI_idEstudiante;
-- No usa el índice NO agrupado debido a la cantidad de filas

DELETE FROM Estudiantes;

ALTER TABLE Estudiantes 
DROP INDEX dni_UNIQUE;
CREATE INDEX idx_dni ON Estudiantes(dni); -- ahora el índice no es único

INSERT INTO Estudiantes (idEstudiante, apellidos, nombres, dni)
SELECT 
  seq,
  'Apellido',
  'Nombre',
  LPAD(seq % 10, 8, '0')  -- MUY BAJA selectividad 
FROM (
  SELECT @row := @row + 1 AS seq
  FROM 
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) a,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) b,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) c,
    (SELECT @row := 0) r
) t;

SELECT * FROM Estudiantes; -- 4 x 4 x 4 = 64 filas

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE dni = '00000001'; -- (type: ref, non-unique key lookup, usa el índice idx_dni)
-- Non-unique key lookup: MySQL usa un índice NO único para buscar una o más filas que coinciden con un valor
-- MySQL todavía decide usar el índice (le sigue conviniendo)

DELETE FROM Estudiantes;

INSERT INTO Estudiantes (idEstudiante, apellidos, nombres, dni)
SELECT 
  seq,
  'Apellido',
  'Nombre',
  LPAD(seq % 10, 8, '0')  -- MUY BAJA selectividad 
FROM (
  SELECT @row := @row + 1 AS seq
  FROM 
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) a,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) b,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) c,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) d,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) e,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) f,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) g,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) h,
    (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3) i,
    (SELECT @row := 0) r
) t;

SELECT * FROM Estudiantes; -- 4 x 4 x 4 x 4 x 4 x 4 x 4 x 4 x 4 = 262144 filas

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE dni = '00000001'; -- (type: ref, non-unique key lookup, usa el índice idx_dni)
-- Devuelve 26215 filas

/*EXPLAIN*/ SELECT * 
FROM Estudiantes
WHERE dni >= '00000001'; -- (type: all, full table scan) 
-- Devuelve 235930 filas