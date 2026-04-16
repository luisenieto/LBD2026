-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema LBD2026
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `LBD2026` ;

-- -----------------------------------------------------
-- Schema LBD2026
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `LBD2026` ;
USE `LBD2026` ;

-- -----------------------------------------------------
-- Table `Estudiantes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Estudiantes` ;

CREATE TABLE IF NOT EXISTS `Estudiantes` (
  `idEstudiante` INT NOT NULL,
  `apellidos` VARCHAR(20) NOT NULL,
  `nombres` VARCHAR(45) NOT NULL,
  `dni` CHAR(8) NOT NULL,
  `cx` CHAR(10) NULL,
  PRIMARY KEY (`idEstudiante`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `dni_UNIQUE` ON `Estudiantes` (`dni` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Profesores`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Profesores` ;

CREATE TABLE IF NOT EXISTS `Profesores` (
  `idProfesor` INT NOT NULL,
  `apellidos` VARCHAR(20) NOT NULL,
  `nombres` VARCHAR(45) NOT NULL,
  `dni` CHAR(8) NOT NULL,
  `cargo` ENUM('ADG', 'JTP', 'Adjunto', 'Asociado', 'Titular') NOT NULL DEFAULT 'Adjunto',
  PRIMARY KEY (`idProfesor`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `dni_UNIQUE` ON `Profesores` (`dni` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Trabajos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Trabajos` ;

CREATE TABLE IF NOT EXISTS `Trabajos` (
  `idTrabajo` INT NOT NULL,
  `titulo` VARCHAR(45) NOT NULL,
  `areas` SET('HW', 'SW', 'Redes') NULL,
  `tiempo` INT NOT NULL DEFAULT 6,
  `fechaPresentacion` DATE NOT NULL,
  `fechaAprobacion` DATE NULL,
  `fechaDefensa` DATE NULL,
  PRIMARY KEY (`idTrabajo`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `titulo_UNIQUE` ON `Trabajos` (`titulo` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Participacion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Participacion` ;

CREATE TABLE IF NOT EXISTS `Participacion` (
  `idEstudiante` INT NOT NULL,
  `idTrabajo` INT NOT NULL,
  `desde` DATE NOT NULL,
  `hasta` DATE NULL,
  `razon` VARCHAR(45) NULL,
  PRIMARY KEY (`idEstudiante`, `idTrabajo`),
  CONSTRAINT `fk_Participacion_Estudiantes`
    FOREIGN KEY (`idEstudiante`)
    REFERENCES `Estudiantes` (`idEstudiante`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Participacion_Trabajos1`
    FOREIGN KEY (`idTrabajo`)
    REFERENCES `Trabajos` (`idTrabajo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Participacion_Trabajos1_idx` ON `Participacion` (`idTrabajo` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Tutelaje`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Tutelaje` ;

CREATE TABLE IF NOT EXISTS `Tutelaje` (
  `idProfesor` INT NOT NULL,
  `idTrabajo` INT NOT NULL,
  `rol` ENUM('Jurado', 'Tutor', 'Cotutor') NOT NULL,
  `desde` DATE NOT NULL,
  `hasta` DATE NULL,
  `razon` VARCHAR(45) NULL,
  PRIMARY KEY (`idProfesor`, `idTrabajo`),
  CONSTRAINT `fk_Tutelaje_Profesores1`
    FOREIGN KEY (`idProfesor`)
    REFERENCES `Profesores` (`idProfesor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Tutelaje_Trabajos`
    FOREIGN KEY (`idTrabajo`)
    REFERENCES `Trabajos` (`idTrabajo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Tutelaje_Trabajos_idx` ON `Tutelaje` (`idTrabajo` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Seminarios`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Seminarios` ;

CREATE TABLE IF NOT EXISTS `Seminarios` (
  `idSeminario` INT NOT NULL,
  `idTrabajo` INT NOT NULL,
  `nota` ENUM('Aprobado', 'Aprobado Con Observaciones', 'Desaprobado') NOT NULL DEFAULT 'Aprobado',
  `fecha` DATE NOT NULL,
  PRIMARY KEY (`idSeminario`, `idTrabajo`),
  CONSTRAINT `fk_Seminarios_Trabajos1`
    FOREIGN KEY (`idTrabajo`)
    REFERENCES `Trabajos` (`idTrabajo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Seminarios_Trabajos1_idx` ON `Seminarios` (`idTrabajo` ASC) VISIBLE;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

