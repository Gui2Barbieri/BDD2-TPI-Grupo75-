USE BDD2_TPI;
GO

CREATE TRIGGER TR_ActualizarStockPorMovimiento
ON MovimientoStock
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.StockActual += (
        CASE
            WHEN i.TipoMovimiento IN ('COMPRA','AJUSTE_POSITIVO') THEN i.Cantidad
            WHEN i.TipoMovimiento IN ('VENTA','AJUSTE_NEGATIVO') THEN -i.Cantidad
            ELSE 0
        END
    )
    FROM Producto AS p
    INNER JOIN inserted AS i ON p.IDProducto = i.IDProducto;
END;
GO

CREATE TRIGGER TR_DetalleCompraMovStock
ON DetalleCompra
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Aprovecha la cascada para registrar el ingreso en MovimientoStock y actualizar el stock del producto
    INSERT INTO MovimientoStock (TipoMovimiento, Cantidad, IDCompra, IDProducto)
    SELECT 'COMPRA', Cantidad, IDCompra, IDProducto
    FROM inserted;
END;
GO

CREATE TRIGGER TR_DetalleVenta_ReponerStock
ON DetalleVenta
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Aprovecha la cascada para registrar la reposicion en MovimientoStock y restituir el stock
    INSERT INTO MovimientoStock (TipoMovimiento, Cantidad, IDVenta, Motivo, IDProducto)
    SELECT 'AJUSTE_POSITIVO', Cantidad, IDTicket, 'Venta Cancelada', IDProducto
    FROM deleted;
END;
GO