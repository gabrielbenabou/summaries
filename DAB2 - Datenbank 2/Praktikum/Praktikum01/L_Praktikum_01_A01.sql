---------------------------------------------------------------------
-- L_Praktikum_01_A01.sql: Erstellen der Übungsdatenbank DAB2Query
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Datenbank erzeugen
---------------------------------------------------------------------

USE master;

-- Falls vorhanden: DB löschen
IF DB_ID(N'DAB2Query') IS NOT NULL DROP DATABASE DAB2Query;

-- Falls noch aktive Verbindungen vorhanden: Abbruch
IF @@ERROR = 3702 
  RAISERROR(N'Datenbank DAB2Query kann nicht gelöscht werden da es noch aktive Verbindungen gibt.', 127, 127) WITH NOWAIT, LOG;

-- Datenbank erzeugen mit Standardoptionen
CREATE DATABASE DAB2Query;
GO

USE DAB2Query;
GO

---------------------------------------------------------------------
-- Schemas, Tabellen und Indexe erzeugen
---------------------------------------------------------------------

CREATE SCHEMA HR AUTHORIZATION dbo;
GO

CREATE SCHEMA Production AUTHORIZATION dbo;
GO

CREATE SCHEMA Sales AUTHORIZATION dbo;
GO

CREATE TABLE HR.Employees
(
  empid           INT          NOT NULL,
  lastname        NVARCHAR(20) NOT NULL,
  firstname       NVARCHAR(10) NOT NULL,
  title           NVARCHAR(30) NOT NULL,
  titleofcourtesy NVARCHAR(25) NOT NULL,
  birthdate       DATE         NOT NULL,
  hiredate        DATE         NOT NULL,
  address         NVARCHAR(60) NOT NULL,
  city            NVARCHAR(15) NOT NULL,
  region          NVARCHAR(15) NULL,
  postalcode      NVARCHAR(10) NULL,
  country         NVARCHAR(15) NOT NULL,
  phone           NVARCHAR(24) NOT NULL,
  mgrid           INT          NULL,
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
  CONSTRAINT FK_Employees_Employees FOREIGN KEY(mgrid)
    REFERENCES HR.Employees(empid),
  CONSTRAINT CHK_birthdate CHECK(birthdate <= CAST(SYSDATETIME() AS DATE))
);

CREATE NONCLUSTERED INDEX idx_nc_lastname   ON HR.Employees(lastname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode ON HR.Employees(postalcode);

CREATE TABLE Production.Suppliers
(
  supplierid   INT          NOT NULL,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Suppliers PRIMARY KEY(supplierid)
);

CREATE NONCLUSTERED INDEX idx_nc_companyname ON Production.Suppliers(companyname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode  ON Production.Suppliers(postalcode);

CREATE TABLE Production.Categories
(
  categoryid   INT           NOT NULL,
  categoryname NVARCHAR(15)  NOT NULL,
  description  NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_Categories PRIMARY KEY(categoryid)
);

CREATE NONCLUSTERED INDEX idx_nc_categoryname ON Production.Categories(categoryname);

CREATE TABLE Production.Products
(
  productid    INT          NOT NULL,
  productname  NVARCHAR(40) NOT NULL,
  supplierid   INT          NOT NULL,
  categoryid   INT          NOT NULL,
  unitprice    MONEY        NOT NULL
    CONSTRAINT DFT_Products_unitprice DEFAULT(0),
  discontinued BIT          NOT NULL 
    CONSTRAINT DFT_Products_discontinued DEFAULT(0),
  CONSTRAINT PK_Products PRIMARY KEY(productid),
  CONSTRAINT FK_Products_Categories FOREIGN KEY(categoryid)
    REFERENCES Production.Categories(categoryid),
  CONSTRAINT FK_Products_Suppliers FOREIGN KEY(supplierid)
    REFERENCES Production.Suppliers(supplierid),
  CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);

CREATE NONCLUSTERED INDEX idx_nc_categoryid  ON Production.Products(categoryid);
CREATE NONCLUSTERED INDEX idx_nc_productname ON Production.Products(productname);
CREATE NONCLUSTERED INDEX idx_nc_supplierid  ON Production.Products(supplierid);

CREATE TABLE Sales.Customers
(
  custid       INT          NOT NULL,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

CREATE NONCLUSTERED INDEX idx_nc_city        ON Sales.Customers(city);
CREATE NONCLUSTERED INDEX idx_nc_companyname ON Sales.Customers(companyname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode  ON Sales.Customers(postalcode);
CREATE NONCLUSTERED INDEX idx_nc_region      ON Sales.Customers(region);


CREATE TABLE Sales.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
    REFERENCES Sales.Customers(custid),
  CONSTRAINT FK_Orders_Employees FOREIGN KEY(empid)
    REFERENCES HR.Employees(empid)
);

CREATE NONCLUSTERED INDEX idx_nc_custid         ON Sales.Orders(custid);
CREATE NONCLUSTERED INDEX idx_nc_empid          ON Sales.Orders(empid);
CREATE NONCLUSTERED INDEX idx_nc_shipperid      ON Sales.Orders(shipperid);
CREATE NONCLUSTERED INDEX idx_nc_orderdate      ON Sales.Orders(orderdate);
CREATE NONCLUSTERED INDEX idx_nc_shippeddate    ON Sales.Orders(shippeddate);
CREATE NONCLUSTERED INDEX idx_nc_shippostalcode ON Sales.Orders(shippostalcode);

CREATE TABLE Sales.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES Sales.Orders(orderid),
  CONSTRAINT FK_OrderDetails_Products FOREIGN KEY(productid)
    REFERENCES Production.Products(productid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);

CREATE NONCLUSTERED INDEX idx_nc_orderid   ON Sales.OrderDetails(orderid);
CREATE NONCLUSTERED INDEX idx_nc_productid ON Sales.OrderDetails(productid);

