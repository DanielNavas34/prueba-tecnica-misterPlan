-- =============================================================================
-- Gestión de reservas — esquema y datos de demostración
-- Motor: MySQL 8+ / MariaDB 10.11+
-- Importación: base de datos vacía o recién creada (no incluye DROP DATABASE).
-- Campo «importe»: interpretación de «importar» del enunciado como errata tipográfica.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS reservas
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE reservas;

SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- Reinicio idempotente solo dentro de esta base (desarrollo / reimportación controlada).
DROP TABLE IF EXISTS reserva_evento;
DROP TABLE IF EXISTS reserva;

CREATE TABLE reserva (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre_huesped VARCHAR(255) NOT NULL,
    email_huesped VARCHAR(255) NOT NULL,
    nombre_alojamiento VARCHAR(255) NOT NULL,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    estado ENUM('pendiente', 'confirmada', 'cancelada') NOT NULL DEFAULT 'pendiente',
    importe DECIMAL(10, 2) NOT NULL,
    notas TEXT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT chk_reserva_fechas CHECK (fecha_salida > fecha_entrada),
    CONSTRAINT chk_reserva_importe CHECK (importe >= 0),
    INDEX idx_reserva_estado (estado),
    INDEX idx_reserva_fechas (fecha_entrada, fecha_salida),
    INDEX idx_reserva_email (email_huesped),
    INDEX idx_reserva_huesped (nombre_huesped)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reserva_evento (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    reserva_id INT UNSIGNED NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_reserva_evento_reserva
        FOREIGN KEY (reserva_id) REFERENCES reserva (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_reserva_evento_reserva (reserva_id),
    INDEX idx_reserva_evento_cronologia (reserva_id, fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Datos de demostración (ficticios)
-- -----------------------------------------------------------------------------

INSERT INTO reserva (
    id, nombre_huesped, email_huesped, nombre_alojamiento,
    fecha_entrada, fecha_salida, estado, importe, notas, fecha_creacion
) VALUES
    (1, 'Ana García López', 'ana.garcia.demo@example.com', 'Casa Rural El Roble',
     '2026-04-10', '2026-04-14', 'pendiente', 420.00,
     'Llegada prevista sobre las 16:00.', '2026-03-01 09:15:00'),
    (2, 'Bruno Méndez Ruiz', 'bruno.mendez.demo@example.com', 'Apartamento Centro Histórico',
     '2026-05-02', '2026-05-09', 'confirmada', 735.50,
     'Estancia de una semana.', '2026-02-20 11:40:00'),
    (3, 'Clara Ruiz O''Brien', 'clara.ruiz.demo@example.com', 'Hostal La Plaza',
     '2026-03-18', '2026-03-21', 'cancelada', 189.99,
     'Cancelación por cambio de planes.', '2026-02-10 08:05:00'),
    (4, 'Diego López Navarro', 'diego.lopez.demo@example.com', 'Villa Mar Azul',
     '2026-06-01', '2026-06-15', 'confirmada', 2100.00,
     NULL, '2026-03-05 14:22:00'),
    (5, 'Elena Torres Vega', 'elena.torres.demo@example.com', 'Cottage Norte',
     '2026-07-20', '2026-07-27', 'pendiente', 560.00,
     'Solicita cuna para bebé.', '2026-03-12 17:55:00'),
    (6, 'Farid Hassan', 'farid.hassan.demo@example.com', 'Loft Urbano 12',
     '2026-04-25', '2026-04-28', 'cancelada', 315.00,
     'Reserva corporativa no confirmada a tiempo.', '2026-01-28 10:30:00');

INSERT INTO reserva_evento (reserva_id, tipo, descripcion, fecha_creacion) VALUES
    (1, 'creada', 'Reserva registrada con estado pendiente.', '2026-03-01 09:15:00'),

    (2, 'creada', 'Reserva registrada con estado pendiente.', '2026-02-20 11:40:00'),
    (2, 'estado_cambiado', 'Estado actualizado de pendiente a confirmada.', '2026-02-21 09:00:00'),

    (3, 'creada', 'Reserva registrada con estado pendiente.', '2026-02-10 08:05:00'),
    (3, 'estado_cambiado', 'Estado actualizado de pendiente a confirmada.', '2026-02-11 12:30:00'),
    (3, 'estado_cambiado', 'Estado actualizado de confirmada a cancelada.', '2026-03-01 18:45:00'),

    (4, 'creada', 'Reserva registrada con estado pendiente.', '2026-03-05 14:22:00'),
    (4, 'estado_cambiado', 'Estado actualizado de pendiente a confirmada.', '2026-03-06 08:10:00'),

    (5, 'creada', 'Reserva registrada con estado pendiente.', '2026-03-12 17:55:00'),

    (6, 'creada', 'Reserva registrada con estado pendiente.', '2026-01-28 10:30:00'),
    (6, 'estado_cambiado', 'Estado actualizado de pendiente a cancelada.', '2026-02-05 16:20:00');
