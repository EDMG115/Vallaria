-- =====================================================
-- Base de datos: vallaria
-- Plataforma educativa tipo Duolingo
-- =====================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE;
SET SQL_MODE='STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- =====================================================
-- Crear esquema
-- =====================================================
CREATE SCHEMA IF NOT EXISTS `vallaria` DEFAULT CHARACTER SET utf8mb4;
USE `vallaria`;

-- =====================================================
-- Tabla: materias
-- =====================================================
CREATE TABLE materias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  icono_path TEXT NOT NULL
) ENGINE=InnoDB;

-- =====================================================
-- Tabla: cursos
-- =====================================================
CREATE TABLE cursos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  materia_id INT NOT NULL,
  titulo VARCHAR(150) NOT NULL,
  descripcion TEXT,
  nivel INT NOT NULL,
  estado ENUM('borrador','activo') DEFAULT 'borrador',
  FOREIGN KEY (materia_id) REFERENCES materias(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Tabla: modulos
-- =====================================================
CREATE TABLE modulos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  curso_id INT NOT NULL,
  titulo VARCHAR(150) NOT NULL,
  orden INT NOT NULL,
  descripcion_corta TEXT,
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Tabla: lecciones
-- =====================================================
CREATE TABLE lecciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  modulo_id INT NOT NULL,
  titulo VARCHAR(255) NOT NULL,
  teoria_path TEXT NOT NULL,
  ejercicios_path TEXT NOT NULL,
  dificultad INT NOT NULL,
  orden INT NOT NULL,
  xp INT NOT NULL,
  FOREIGN KEY (modulo_id) REFERENCES modulos(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Tabla: usuarios
-- =====================================================
CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100),
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  rol ENUM('admin','usuario') DEFAULT 'usuario',
  avatar_path TEXT,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- Tabla: inscripciones
-- =====================================================
CREATE TABLE inscripciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  curso_id INT NOT NULL,
  fecha_inscripcion DATE,
  estado ENUM('activo','completado','abandonado') DEFAULT 'activo',
  progreso_general TINYINT UNSIGNED DEFAULT 0,
  UNIQUE (usuario_id, curso_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (curso_id) REFERENCES cursos(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Tabla: progreso_usuario
-- =====================================================
CREATE TABLE progreso_usuario (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  leccion_id INT NOT NULL,
  completada BOOLEAN DEFAULT FALSE,
  fecha_completado DATE,
  UNIQUE (usuario_id, leccion_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (leccion_id) REFERENCES lecciones(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Tabla: intentos_ejercicios
-- =====================================================
CREATE TABLE intentos_ejercicios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  leccion_id INT NOT NULL,
  ejercicio_uid VARCHAR(100) NOT NULL,
  respuesta_usuario TEXT,
  es_correcta BOOLEAN,
  puntaje INT,
  fecha_intento DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (leccion_id) REFERENCES lecciones(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- Restaurar configuración
-- =====================================================
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
