SELECT id_venta, monto_total FROM ventas WHERE id_venta = 1002;

UPDATE ventas 
SET monto_total = 98500000 
WHERE id_venta = 1002;

SELECT * FROM auditoria_ventas