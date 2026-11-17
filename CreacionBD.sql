CREATE DATABASE BDD2_TPI;
GO

USE BDD2_TPI;
GO

CREATE TABLE Categoria(
    IDCategoria INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL UNIQUE,
    Descripcion VARCHAR(250) NULL,
    Activo BIT NOT NULL DEFAULT 1 -- Cambiando el valor a 0 cuando actualizamos produce una baja logica.
);

CREATE TABLE Cliente(
    IDCliente INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(80) NOT NULL,
    Apellido VARCHAR(80) NOT NULL,
    Documento VARCHAR(20) UNIQUE NOT NULL,
    Telefono VARCHAR(30) NULL,
    Email VARCHAR(120) NULL,
    Activo BIT NOT NULL DEFAULT 1, -- Cambiando el valor a 0 cuando actualizamos produce una baja logica.
    CondicionIVA VARCHAR(25) NOT NULL DEFAULT 'CONSUMIDOR_FINAL',
    MedioDePago VARCHAR(25) NOT NULL,
    
    CONSTRAINT CK_CLIENTE_CondicionIVA
        CHECK (CondicionIVA IN ('CONSUMIDOR_FINAL','RESPONSABLE_INSCRIPTO','MONOTRIBUTO','EXENTO')),
    CONSTRAINT CK_CLIENTE_MedioDePago
        CHECK (MedioDePago IN ('EFECTIVO','TRANSFERENCIA','CREDITO','DEBITO'))
);

CREATE TABLE Producto(
    IDProducto INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    IDCategoria INT NOT NULL REFERENCES Categoria(IDCategoria),
    Codigo VARCHAR(30) NOT NULL UNIQUE, -- SKU de producto
    Nombre VARCHAR(120) NOT NULL,
    Descripcion VARCHAR(250) NULL,
    CostoNeto DECIMAL(12,2) NOT NULL CHECK (CostoNeto > 0), -- Costo base sin añadidos
    MargenGanancia DECIMAL(5,2) NOT NULL CHECK (MargenGanancia >= 0),
    PorcentajeIVA DECIMAL(4,2) NOT NULL CHECK (PorcentajeIVA >= 0),
    PrecioVentaNeto AS (CostoNeto * (1.0 + MargenGanancia / 100.0)), -- Precio sin IVA con ganancia incluida
    StockActual INT NOT NULL DEFAULT 0 CHECK (StockActual >= 0),
    StockMinimo INT NOT NULL DEFAULT 0 CHECK (StockMinimo >= 0),
    Activo BIT NOT NULL DEFAULT 1 -- Cambiando el valor a 0 cuando actualizamos produce una baja logica.
);

CREATE TABLE Proveedor (
    IDProveedor INT IDENTITY(1,1) PRIMARY KEY,
    RazonSocial VARCHAR(120) NOT NULL,
    CUIT VARCHAR(13) NOT NULL UNIQUE,
    Telefono VARCHAR(20) NOT NULL,
    Email VARCHAR(120) NOT NULL,
    Activo BIT NOT NULL DEFAULT 1, -- Cambiando el valor a 0 cuando actualizamos produce una baja logica.
    DiasCredito TINYINT NOT NULL DEFAULT 0,
    TiempoEntregaDias TINYINT NOT NULL DEFAULT 0,
    MedioPago VARCHAR(20) NOT NULL,

    CONSTRAINT CK_Proveedor_DiasCredito
        CHECK (DiasCredito >= 0),
    CONSTRAINT CK_Proveedor_TiempoEntregaDias
        CHECK (TiempoEntregaDias >= 0),
    CONSTRAINT CK_Proveedor_MedioPago
        CHECK (MedioPago IN ('TRANSFERENCIA','CHEQUE','EFECTIVO'))
);

CREATE TABLE ProveedorContacto (
    IDContacto INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    IDProveedor INT NOT NULL REFERENCES Proveedor(IDProveedor),
    Puesto VARCHAR(20) NOT NULL,
    Telefono VARCHAR(20) NOT NULL,
    NombreCompleto VARCHAR(50) NOT NULL,
    Mail VARCHAR(50) NOT NULL
);

CREATE TABLE ProductoProveedor(
    IDProducto INT NOT NULL REFERENCES Producto(IDProducto),
    IDProveedor INT NOT NULL REFERENCES Proveedor(IDProveedor),
    PrecioCompraReferenciaNeto DECIMAL(12,2) NOT NULL,
    EsPrincipal BIT NOT NULL DEFAULT 0, -- Indica si es el proveedor principal del producto

    CONSTRAINT CK_ProductoProveedor_PrecioCompraReferenciaNeto
        CHECK (PrecioCompraReferenciaNeto > 0),
    CONSTRAINT PK_ProductoProveedor PRIMARY KEY (IDProducto, IDProveedor)
);

CREATE TABLE Compra(
    IDCompra INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    IDProveedor INT NOT NULL REFERENCES Proveedor(IDProveedor),
    Fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    NumeroComprobante VARCHAR(40) NOT NULL,
    Estado VARCHAR(15) NOT NULL DEFAULT 'RECIBIDA',
    Total DECIMAL(12,2) NOT NULL CHECK (Total >= 0),

    CONSTRAINT CK_Compra_Estado
        CHECK (Estado IN ('RECIBIDA', 'ANULADA'))
);

CREATE TABLE DetalleCompra(
    IDDetalleCompra INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    IDCompra INT NOT NULL REFERENCES Compra(IDCompra),
    IDProducto INT NOT NULL REFERENCES Producto(IDProducto),
    Cantidad INT NOT NULL,
    CostoUnitarioNeto DECIMAL(12,2) NOT NULL,
    PorcentajeDescuento DECIMAL(5,2) NOT NULL,
    PorcentajeIVA DECIMAL(4,2) NOT NULL,
    PrecioConDescuento AS (CostoUnitarioNeto * (1.0 - PorcentajeDescuento / 100.0)),
    SubtotalNeto AS ((CostoUnitarioNeto * (1.0 - PorcentajeDescuento / 100.0)) * Cantidad),
    SubtotalFinal AS (((CostoUnitarioNeto * (1.0 - PorcentajeDescuento / 100.0)) * Cantidad) * (1.0 + PorcentajeIVA / 100.0)),

    CONSTRAINT CK_DetalleCompra_Cantidad
        CHECK (Cantidad > 0),
    CONSTRAINT CK_DetalleCompra_CostoUnitarioNeto
        CHECK (CostoUnitarioNeto > 0),
    CONSTRAINT CK_DetalleCompra_PorcentajeDescuento
        CHECK (PorcentajeDescuento >= 0 AND PorcentajeDescuento <= 100),
    CONSTRAINT CK_DetalleCompra_PorcentajeIVA
        CHECK (PorcentajeIVA >= 0)
);

CREATE TABLE Ticket(
    IDTicket INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    IDCliente INT NULL REFERENCES Cliente(IDCliente),
    Fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Estado VARCHAR(10) NOT NULL,
    NumeroOrdenCompra VARCHAR(50) NULL, -- No aplica a consumidor final, va NULL; se usa solo en B2B
    MedioDePago VARCHAR(25) NOT NULL,
    ImporteTotal DECIMAL(12,2) NOT NULL CHECK (ImporteTotal >= 0),
    ImporteRecibido DECIMAL(12,2) NOT NULL CHECK (ImporteRecibido >= 0),
    Vuelto AS (ImporteRecibido - ImporteTotal),

    CONSTRAINT CK_Ticket_Estado
        CHECK (Estado IN ('EMITIDO', 'ANULADO')),
    CONSTRAINT CK_Ticket_MedioDePago
        CHECK (MedioDePago IN ('EFECTIVO','TRANSFERENCIA','CREDITO','DEBITO'))
);

CREATE TABLE DetalleVenta(
    IDDetalleVenta INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    IDTicket INT NOT NULL REFERENCES Ticket(IDTicket),
    IDProducto INT NOT NULL REFERENCES Producto(IDProducto),
    Cantidad INT NOT NULL,
    PrecioUnitarioNeto DECIMAL(12,2) NOT NULL,
    PorcentajeDescuento DECIMAL(5,2) NOT NULL,
    PorcentajeIVA DECIMAL(4,2) NOT NULL,
    PrecioConDescuento AS (PrecioUnitarioNeto * (1.0 - PorcentajeDescuento / 100.0)),
    SubtotalNeto AS ((PrecioUnitarioNeto * (1.0 - PorcentajeDescuento / 100.0)) * Cantidad),
    SubtotalFinal AS (((PrecioUnitarioNeto * (1.0 - PorcentajeDescuento / 100.0)) * Cantidad) * (1.0 + PorcentajeIVA / 100.0)),

    CONSTRAINT CK_DetalleVenta_Cantidad
        CHECK (Cantidad > 0),
    CONSTRAINT CK_DetalleVenta_PrecioUnitarioNeto
        CHECK (PrecioUnitarioNeto > 0),
    CONSTRAINT CK_DetalleVenta_PorcentajeDescuento
        CHECK (PorcentajeDescuento >= 0 AND PorcentajeDescuento <= 100),
    CONSTRAINT CK_DetalleVenta_PorcentajeIVA
        CHECK (PorcentajeIVA >= 0)
);

CREATE TABLE MovimientoStock ( -- Kardex: tabla para trazabilidad sobre que sucede con el stock en cada variacion
    IDMovimiento INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TipoMovimiento VARCHAR(20) NOT NULL,
    Cantidad INT NOT NULL,
    FechaMovimiento DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    IDVenta INT NULL REFERENCES Ticket(IDTicket),
    IDCompra INT NULL REFERENCES Compra(IDCompra),
    Motivo VARCHAR(250) NULL,
    IDProducto INT NOT NULL REFERENCES Producto(IDProducto),

    CONSTRAINT CK_MovimientoStock_Tipo
        CHECK (TipoMovimiento IN ('VENTA','COMPRA','AJUSTE_POSITIVO','AJUSTE_NEGATIVO')),
    CONSTRAINT CK_MovimientoStock_Cantidad
        CHECK (Cantidad > 0)
);
GO