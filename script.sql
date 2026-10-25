-- =========================================================================
-- SCRIPT DE PRÁCTICA AVANZADA DE SQL - TIENDA DE ROPA EN LÍNEA
-- =========================================================================

-- 1. Creación de la Base de Datos
DROP DATABASE IF EXISTS tienda_ropa_db;
CREATE DATABASE tienda_ropa_db;
USE tienda_ropa_db;

-- 2. Creación de Tablas con Claves Primarias y Foráneas
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    direccion VARCHAR(150),
    correo VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20)
);

CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    stock INT NOT NULL
);

CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha DATETIME NOT NULL,
    estado VARCHAR(30) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id),
    FOREIGN KEY (id_producto) REFERENCES productos(id)
);

-- 3. Inserción de Registros de Prueba
INSERT INTO clientes (nombre, apellido, direccion, correo, telefono) VALUES
('Carlos', 'Pérez', 'Av. Bolívar, Calle 4', 'carlos.perez@email.com', '0414-1234567'),
('Ana', 'Gómez', 'Urbanización El Centro', 'ana.gomez@email.com', '0424-9876543'),
('Luis', 'Rodríguez', 'Sector Los Mangos', 'luis.rodriguez@email.com', '0412-5554433');

INSERT INTO productos (nombre, descripcion, precio, categoria, stock) VALUES
('Camisa Casual', 'Camisa manga larga de algodón', 20.00, 'Camisetas', 50),
('Camiseta Deportiva', 'Camiseta dry-fit para correr', 15.00, 'Camisetas', 40),
('Jeans Clásicos', 'Pantalón de mezclilla corte recto', 35.00, 'Pantalones', 30),
('Vestido de Verano', 'Vestido floreado casual', 40.00, 'Vestidos', 20);

-- Pedidos recientes (dentro de los últimos 30 días y último año)
INSERT INTO pedidos (id_cliente, fecha, estado, total) VALUES
(1, NOW() - INTERVAL 10 DAY, 'Completado', 35.00),
(2, NOW() - INTERVAL 15 DAY, 'Completado', 40.00),
(3, NOW() - INTERVAL 40 DAY, 'Completado', 35.00),
(1, NOW() - INTERVAL 5 DAY, 'Pendiente', 20.00);

-- Pedido sin ventas asociadas (para la prueba de DELETE)
INSERT INTO pedidos (id_cliente, fecha, estado, total) VALUES
(2, NOW() - INTERVAL 2 DAY, 'Cancelado', 0.00);

INSERT INTO ventas (id_pedido, id_producto, cantidad, precio_venta) VALUES
(1, 3, 1, 35.00),
(2, 4, 1, 40.00),
(3, 3, 1, 35.00),
(4, 1, 1, 20.00);


-- =========================================================================
-- 4. OPERACIONES SOLICITADAS EN EL DESAFÍO
-- =========================================================================

-- a) Consultas avanzadas con SELECT:
-- Consulta 1: Obtener nombre completo, dirección y correo de clientes con pedidos en los últimos 30 días
SELECT DISTINCT 
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo, 
    c.direccion, 
    c.correo
FROM clientes c
JOIN pedidos p ON c.id = p.id_cliente
WHERE p.fecha >= (NOW() - INTERVAL 30 DAY);

-- Consulta 2: Productos con mayor cantidad de ventas en el último mes junto al total vendido
SELECT 
    pr.nombre AS producto, 
    SUM(v.cantidad) AS total_unidades_vendidas, 
    SUM(v.cantidad * v.precio_venta) AS total_ingresos
FROM ventas v
JOIN pedidos p ON v.id_pedido = p.id.id -- o p.id
JOIN productos pr ON v.id_producto = pr.id
WHERE p.fecha >= (NOW() - INTERVAL 1 MONTH)
GROUP BY pr.id, pr.nombre
ORDER BY total_unidades_vendidas DESC;

-- Consulta 3: Clientes que han realizado más pedidos en el último año, ordenados de mayor a menor
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS cliente, 
    COUNT(p.id) AS total_pedidos
FROM clientes c
JOIN pedidos p ON c.id = p.id_cliente
WHERE p.fecha >= (NOW() - INTERVAL 1 YEAR)
GROUP BY c.id, c.nombre, c.apellido
ORDER BY total_pedidos DESC;


-- b) Actualizaciones con UPDATE:
-- Actualización 1: Aumentar el precio de todos los productos de la categoría "Camisetas" en un 10%
UPDATE productos 
SET precio = precio * 1.10 
WHERE categoria = 'Camisetas';


-- c) Eliminaciones con DELETE:
-- Eliminación 2: Eliminar los pedidos que no tengan ventas asociadas
DELETE FROM pedidos 
WHERE id NOT IN (SELECT DISTINCT id_pedido FROM ventas);


-- d) Creación de vistas:
-- Vista 1: Crear una vista llamada "vista_clientes_pedidos" con nombre completo, fecha y total del pedido
CREATE OR REPLACE VIEW vista_clientes_pedidos AS
SELECT 
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo, 
    p.fecha AS fecha_pedido, 
    p.total AS total_pedido
FROM clientes c
JOIN pedidos p ON c.id = p.id_cliente;

-- Para consultar la vista creada:
-- SELECT * FROM vista_clientes_pedidos;