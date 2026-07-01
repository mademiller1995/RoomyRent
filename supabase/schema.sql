-- =====================================================
-- BBDD: ROOMYRENT
-- =====================================================
CREATE DATABASE IF NOT EXISTS roomyrent;
USE roomyrent;

-- =====================================================
-- TABLA: Propiedades
-- =====================================================
CREATE TABLE IF NOT EXISTS properties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    category ENUM('villa', 'house', 'apartment', 'bungalow') NOT NULL,
    rental_type ENUM('complete', 'rooms') NOT NULL DEFAULT 'rooms',
    beds INT NOT NULL DEFAULT 1,
    baths INT NOT NULL DEFAULT 1,
    sqm INT NOT NULL DEFAULT 50,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    services TEXT,
    image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLA: Inquilinos
-- =====================================================
CREATE TABLE IF NOT EXISTS tenants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLA: Habitaciones
-- =====================================================
CREATE TABLE IF NOT EXISTS rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) DEFAULT 'Estándar',
    status ENUM('libre', 'ocupada', 'reservada') DEFAULT 'libre',
    tenant_id INT NULL,
    price DECIMAL(10,2) DEFAULT 0,
    image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE SET NULL
);

-- =====================================================
-- TABLA: Contratos
-- =====================================================
CREATE TABLE IF NOT EXISTS contracts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    room_id INT NULL,
    property_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status ENUM('active', 'expiring', 'expired', 'rejected') DEFAULT 'active',
    contract_file VARCHAR(500),
    rejection_file VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id)
);

-- =====================================================
-- TABLA: Pagos
-- =====================================================
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    room_id INT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('paid', 'pending', 'overdue') DEFAULT 'pending',
    file VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL
);

-- =====================================================
-- TABLA: Gastos compartidos
-- =====================================================
CREATE TABLE IF NOT EXISTS expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    type ENUM('luz', 'agua', 'internet') NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    per_person DECIMAL(10,2) NOT NULL,
    tenant_ids TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id)
);

-- =====================================================
-- TABLA: Incidencias
-- =====================================================
CREATE TABLE IF NOT EXISTS incidents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    property_id INT NOT NULL,
    tenant_id INT NULL,
    description TEXT NOT NULL,
    priority ENUM('baja', 'media', 'alta') DEFAULT 'media',
    status ENUM('pendiente', 'resuelta') DEFAULT 'pendiente',
    file VARCHAR(500),
    resolution TEXT,
    resolved_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE SET NULL
);

-- =====================================================
-- TABLA: Usuarios (para login)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('owner', 'tenant') DEFAULT 'owner',
    phone VARCHAR(20),
    image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================================================
-- INSERTS DE PRUEBA
-- =====================================================
-- Usuario por defecto
INSERT INTO users (name, email, password, role) VALUES 
('Carlos Rodríguez', 'propietario@roomyrent.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mr/.ZxZ.n9z5s5A9yR5hKqL9H7yY6zW', 'owner'),
('María González', 'inquilino@roomyrent.com', '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mr/.ZxZ.n9z5s5A9yR5hKqL9H7yY6zW', 'tenant');

-- Propiedades de ejemplo
INSERT INTO properties (title, address, city, province, category, rental_type, beds, baths, sqm, price, services, image) VALUES
('Brookside Haven', 'Brookside Estate 42', 'Mistybrook', 'Oregon', 'villa', 'rooms', 3, 2, 390, 875000, 'wifi,piscina,garaje', 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800&h=400&fit=crop');

-- Habitaciones de ejemplo
INSERT INTO rooms (property_id, name, type, status, price) VALUES
(1, 'Habitación 1', 'Individual', 'libre', 750),
(1, 'Habitación 2', 'Doble', 'libre', 950),
(1, 'Habitación 3', 'Suite', 'libre', 1200);

-- Inquilinos de ejemplo
INSERT INTO tenants (name, dni, email, phone) VALUES
('Juan Pérez', '12345678A', 'juan@email.com', '+34 600 000 000'),
('Ana Martínez', '87654321B', 'ana@email.com', '+34 611 111 111');

-- Contratos de ejemplo
INSERT INTO contracts (tenant_id, room_id, property_id, start_date, end_date, price, status) VALUES
(1, 1, 1, '2024-01-01', '2024-12-31', 750, 'active'),
(2, 2, 1, '2024-02-01', '2025-01-31', 950, 'active');

-- Pagos de ejemplo
INSERT INTO payments (tenant_id, room_id, month, year, amount, status) VALUES
(1, 1, 1, 2024, 750, 'paid'),
(2, 2, 1, 2024, 950, 'paid');