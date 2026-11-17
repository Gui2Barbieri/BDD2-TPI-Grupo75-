USE BDD2_TPI;
GO

-- Catalogo activo con precio final calculado segun alicuota de IVA correspondiente
CREATE VIEW VW_CatalogoProductos
AS
SELECT
    p.Codigo,
    p.Nombre AS Producto,
    p.Descripcion,
    p.PrecioVentaNeto,
    p.StockActual,
    p.PorcentajeIVA,
    p.PrecioVentaNeto * (1.0 + p.PorcentajeIVA / 100.0) AS PrecioFinalConIVA,
    c.Nombre AS Categoria,
    c.Descripcion AS DescripcionCategoria
FROM Producto AS p
INNER JOIN Categoria AS c ON p.IDCategoria = c.IDCategoria
WHERE p.Activo = 1 AND c.Activo = 1;
GO

-- Permite visualizar el total neto y final facturado por cada ticket (incluyendo consumidor final anonimo)
CREATE VIEW VW_FacturacionVentas
AS
SELECT
    t.IDTicket,
    t.Fecha,
    t.Estado,
    t.MedioDePago,
    c.Nombre,
    c.Apellido,
    SUM(dv.SubtotalNeto) AS TotalNeto,
    SUM(dv.SubtotalFinal) AS TotalFinal
FROM Ticket AS t
LEFT JOIN Cliente AS c ON c.IDCliente = t.IDCliente
INNER JOIN DetalleVenta AS dv ON dv.IDTicket = t.IDTicket
GROUP BY t.IDTicket, t.Fecha, t.Estado, t.MedioDePago, c.Nombre, c.Apellido;
GO

-- Permite visualizar que productos se encuentran en niveles minimos o por debajo del stock critico
CREATE VIEW VW_AlertaStockCritico
AS
SELECT
    p.Codigo,
    p.Nombre AS Producto,
    c.Nombre AS Categoria,
    p.StockActual,
    p.StockMinimo,
    IIF(p.StockActual = p.StockMinimo, 'Stock Minimo alcanzado', CAST(p.StockMinimo - p.StockActual AS VARCHAR(20))) AS Faltante
FROM Producto AS p
INNER JOIN Categoria AS c ON p.IDCategoria = c.IDCategoria
WHERE p.StockActual <= p.StockMinimo AND p.Activo = 1;
GO