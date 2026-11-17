USE BDD2_TPI;
GO

INSERT INTO Categoria (Nombre, Descripcion)
VALUES
    ('Componentes de Hardware', 'Procesadores, placas de video, memorias y almacenamiento'),
    ('Perifericos y Monitores', 'Teclados, mouses, auriculares y pantallas'),
    ('Equipos y Estaciones', 'Computadoras armadas, notebooks y estaciones de trabajo');

INSERT INTO Cliente (Nombre, Apellido, Documento, Telefono, Email, CondicionIVA, MedioDePago)
VALUES
    ('Lucas', 'Fernandez', '38451209', '1155443322', 'lucas.fernandez@gmail.com', 'CONSUMIDOR_FINAL', 'EFECTIVO'),
    ('Estudio Tech', 'S.R.L.', '30-71543210-9', '1147889900', 'compras@estudiotech.com.ar', 'RESPONSABLE_INSCRIPTO', 'TRANSFERENCIA'),
    ('Sofia', 'Martinez', '40123987', NULL, NULL, 'MONOTRIBUTO', 'DEBITO');

INSERT INTO Proveedor (RazonSocial, CUIT, Telefono, Email, DiasCredito, TiempoEntregaDias, MedioPago)
VALUES
    ('Distribuidora NewBytes S.A.', '30-70987654-3', '1143218765', 'ventas@newbytes.com.ar', 30, 3, 'TRANSFERENCIA'),
    ('Mayorista Elit Informatica S.R.L.', '30-71223344-8', '1149876543', 'cuentas@elit.com.ar', 15, 5, 'CHEQUE');

INSERT INTO ProveedorContacto (IDProveedor, Puesto, Telefono, NombreCompleto, Mail)
VALUES
    (1, 'Ejecutivo Cuentas', '1155667788', 'Martin Gomez', 'mgomez@newbytes.com.ar'),
    (1, 'Soporte RMA', '1155667799', 'Carla Ruiz', 'rma@newbytes.com.ar'),
    (2, 'Asesor Comercial', '1166778899', 'Diego Torres', 'dtorres@elit.com.ar');

INSERT INTO Producto (IDCategoria, Codigo, Nombre, Descripcion, CostoNeto, MargenGanancia, PorcentajeIVA, StockActual, StockMinimo)
VALUES
    (1, 'GPU-4060', 'Placa de Video RTX 4060 8GB', 'NVIDIA GeForce RTX 4060 GDDR6', 300000.00, 25.00, 21.00, 5, 4),
    (1, 'CPU-14600K', 'Procesador Intel Core i5-14600K', '14 Nucleos LGA 1700 (IVA reducido)', 250000.00, 20.00, 10.50, 0, 5),
    (2, 'MON-LG24', 'Monitor LG UltraGear 24 144Hz', 'Panel IPS 1ms Full HD', 180000.00, 30.00, 21.00, 5, 5),
    (3, 'WS-DGX', 'Estacion IA NVIDIA DGX Spark', 'Plataforma de IA Local de alto rendimiento', 3500000.00, 30.00, 10.50, 3, 1);

INSERT INTO ProductoProveedor (IDProducto, IDProveedor, PrecioCompraReferenciaNeto, EsPrincipal)
VALUES
    (1, 1, 300000.00, 1),
    (1, 2, 312000.00, 0),
    (2, 1, 250000.00, 1),
    (3, 2, 180000.00, 1),
    (4, 1, 3500000.00, 1);

-- Compra 1: 5 unidades de Producto 1 ($1.815.000) + 3 unidades de Producto 2 con 10% dto ($745.875) = $2.560.875,00
-- 300000*5*1.21 + 3*(250000*0.9)*1.105
INSERT INTO Compra (IDProveedor, NumeroComprobante, Estado, Total)
VALUES (1, 'FC-A-0001-00004512', 'RECIBIDA', 2560875.00);

INSERT INTO DetalleCompra (IDCompra, IDProducto, Cantidad, CostoUnitarioNeto, PorcentajeDescuento, PorcentajeIVA)
VALUES
    (1, 1, 5, 300000.00, 0.00, 21.00),
    (1, 2, 3, 250000.00, 10.00, 10.50);

-- Ticket 1: Consumidor final registrado, pago en efectivo con vuelto ($46.250,00)
INSERT INTO Ticket (IDCliente, Estado, NumeroOrdenCompra, MedioDePago, ImporteTotal, ImporteRecibido)
VALUES (1, 'EMITIDO', NULL, 'EFECTIVO', 453750.00, 500000.00);

-- Ticket 2: Empresa Responsable Inscripto con Orden de Compra (B2B)
INSERT INTO Ticket (IDCliente, Estado, NumeroOrdenCompra, MedioDePago, ImporteTotal, ImporteRecibido)
VALUES (2, 'EMITIDO', 'OC-2026-0084', 'TRANSFERENCIA', 5027750.00, 5027750.00);

-- Ticket 3: Mostrador anonimo (IDCliente = NULL), pago con debito y 5% de descuento
INSERT INTO Ticket (IDCliente, Estado, NumeroOrdenCompra, MedioDePago, ImporteTotal, ImporteRecibido)
VALUES (NULL, 'EMITIDO', NULL, 'DEBITO', 268983.00, 268983.00);

INSERT INTO DetalleVenta (IDTicket, IDProducto, Cantidad, PrecioUnitarioNeto, PorcentajeDescuento, PorcentajeIVA)
VALUES
    (1, 1, 1, 375000.00, 0.00, 21.00),
    (2, 4, 1, 4550000.00, 0.00, 10.50),
    (3, 3, 1, 234000.00, 5.00, 21.00);

-- Movimientos de salida y ajuste manual para enriquecer el historial del Kardex (Producto 1 baja de 10 a 8)
INSERT INTO MovimientoStock (TipoMovimiento, Cantidad, IDVenta, Motivo, IDProducto)
VALUES
    ('VENTA', 1, 1, NULL, 1),
    ('AJUSTE_NEGATIVO', 1, NULL, 'Unidad retirada para RMA por falla de fabrica', 1);
GO