USE BDD2_TPI;
GO

-- Reporte parametrizado para consultar el historial de movimientos de un producto
CREATE PROCEDURE SP_ConsultarMovimientosPorProducto
    @IDProducto INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Producto WHERE IDProducto = @IDProducto)
    BEGIN
        PRINT 'El producto especificado no existe';
        RETURN;
    END

    SELECT
        ms.FechaMovimiento,
        ms.TipoMovimiento,
        ms.Cantidad,
        ms.Motivo,
        ms.IDVenta,
        ms.IDCompra
    FROM MovimientoStock AS ms
    WHERE ms.IDProducto = @IDProducto
    ORDER BY ms.FechaMovimiento DESC;
END;
GO

-- Procedimiento transaccional para anular un ticket emitido con manejo de errores
CREATE PROCEDURE SP_AnularTicket
    @IDTicket INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
            IF EXISTS (SELECT 1 FROM Ticket WHERE IDTicket = @IDTicket AND Estado = 'EMITIDO')
            BEGIN
                UPDATE Ticket
                SET Estado = 'ANULADO'
                WHERE IDTicket = @IDTicket;
            END
            ELSE
            BEGIN
                RAISERROR('El ticket no existe, o ya esta anulado.', 16, 1);
            END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO