CREATE DATABASE IF NOT EXISTS autofuturo;
USE autofuturo;

CREATE TABLE sedes (
    id_sede INT PRIMARY KEY,
    nombre_sede VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(150)
);

CREATE TABLE proveedores (
    id_proveedor INT PRIMARY KEY,
    nombre_proveedor VARCHAR(100) NOT NULL,
    contacto VARCHAR(50)
);

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARBINARY(255), 
    telefono VARCHAR(20)
);

CREATE TABLE empleados (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(50),
    id_sede INT,
    FOREIGN KEY (id_sede) REFERENCES sedes(id_sede)
);

CREATE TABLE vehiculos (
    id_vehiculo INT PRIMARY KEY,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    ano INT,
    precio DECIMAL(15,2),
    estado VARCHAR(20),
    id_proveedor INT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE ventas (
    id_venta INT PRIMARY KEY,
    id_cliente INT,
    id_vehiculo INT,
    id_empleado INT,
    fecha_venta DATE,
    monto_total DECIMAL(15,2),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

CREATE TABLE revisiones (
    id_revision INT PRIMARY KEY,
    id_vehiculo INT,
    id_empleado INT,
    fecha_revision DATE,
    descripcion TEXT,
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

CREATE ROLE 'administrador', 'operador_etl', 'analista', 'lector';

GRANT ALL PRIVILEGES ON autofuturo.* TO 'administrador';

GRANT SELECT, INSERT, UPDATE, DELETE ON autofuturo.* TO 'operador_etl';

GRANT SELECT ON autofuturo.ventas TO 'analista';
GRANT SELECT ON autofuturo.vehiculos TO 'analista';
GRANT SELECT ON autofuturo.empleados TO 'analista';
GRANT SELECT ON autofuturo.sedes TO 'analista';
GRANT SELECT ON autofuturo.revisiones TO 'analista';

GRANT SELECT ON autofuturo.vehiculos TO 'lector';
GRANT SELECT ON autofuturo.sedes TO 'lector';

CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'AdminAutofuturo2026*';
CREATE USER 'etl_script'@'localhost' IDENTIFIED BY 'EtlCargaDatos2026*';
CREATE USER 'analista_bi'@'localhost' IDENTIFIED BY 'AnalistaReportes2026*';
CREATE USER 'invitado'@'localhost' IDENTIFIED BY 'Invitado2026*';

GRANT 'administrador' TO 'admin_user'@'localhost';
GRANT 'operador_etl' TO 'etl_script'@'localhost';
GRANT 'analista' TO 'analista_bi'@'localhost';
GRANT 'lector' TO 'invitado'@'localhost';

GRANT SELECT ON autofuturo.* TO 'analista_bi'@'localhost';
GRANT SELECT, INSERT, UPDATE ON autofuturo.* TO 'etl_script'@'localhost';
GRANT ALL PRIVILEGES ON autofuturo.* TO 'admin_user'@'localhost';
GRANT SELECT ON autofuturo.* TO 'invitado'@'localhost';

FLUSH PRIVILEGES;

INSERT INTO clientes (id_cliente, nombre, correo, telefono) 
VALUES (
    100, 
    'Usuario de Prueba', 
    AES_ENCRYPT('prueba_segura@autofuturo.com', 'LlaveSeguraAuto2026'), 
    AES_ENCRYPT('3009998877', 'LlaveSeguraAuto2026')
);

SELECT * FROM clientes WHERE  id_cliente = '100'

SELECT 
    id_cliente, 
    nombre, 
    CAST(AES_DECRYPT(correo, 'LlaveSeguraAuto2026') AS CHAR) AS correo_real,
    CAST(AES_DECRYPT(telefono, 'LlaveSeguraAuto2026') AS CHAR) AS telefono_real
FROM clientes 
WHERE id_cliente = 100;

CREATE TABLE auditoria_ventas (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,                       
    accion VARCHAR(50) NOT NULL,                
    usuario_db VARCHAR(100) NOT NULL,            
    fecha_evento DATETIME NOT NULL               
);

DELIMITER //

CREATE TRIGGER trg_ventas_after_update
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_ventas (id_venta, accion, usuario_db, fecha_evento)
    VALUES (OLD.id_venta, 'ACTUALIZACIÓN', CURRENT_USER(), NOW());
END //

CREATE TRIGGER trg_ventas_after_delete
AFTER DELETE ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_ventas (id_venta, accion, usuario_db, fecha_evento)
    VALUES (OLD.id_venta, 'ELIMINACIÓN', CURRENT_USER(), NOW());
END //

DELIMITER ;


