DELIMITER $$

CREATE PROCEDURE insertar_usuario()
BEGIN
   DECLARE v_error BOOLEAN DEFAULT FALSE;

   DECLARE CONTINUE HANDLER FOR 1062
   BEGIN
      SET v_error = TRUE;
   END;

   INSERT INTO `LBD2026-Prueba`.Personas VALUES (1, 'Apellido1', 'Nombre1');
   INSERT INTO `LBD2026-Prueba`.Personas VALUES (2, 'Apellido2', 'Nombre2');
   INSERT INTO `LBD2026-Prueba`.Personas VALUES (2, 'Apellido3', 'Nombre3');

   IF v_error THEN
      SELECT 'Se violó una restricción PK/UNIQUE';
   ELSE
      SELECT 'Insert correcto';
   END IF;
END$$

-- 1062 valor repetido (UNIQUE / PK)
-- 1452 violación de FK
-- 1048 columna no puede ser null

CALL insertar_usuario();

select * from `LBD2026-Prueba`.Personas;