Use master
go 
-- Create Database
Declare @data_path Nvarchar (256);

Set @data_path =(Select SUBSTRING(physical_name,1,CHARINDEX(N'master.mdf',LOWER(physical_name))-1)
				From master.sys.master_files
				Where database_id=1 And file_id=1);

Exec('Create Database RestaurantDB
On Primary (Name= RestaurantDB_Data_1, Filename= '''+ @data_path +'RestaurantDB_Data_1.mdf'', Size=25mb, maxsize=100mb, Filegrowth=5%)
Log On (Name= RestaurantDB_Log_1, Filename= '''+ @data_path +'RestaurantDB_Log_1.ldf'', Size=2mb, Maxsize=50mb, Filegrowth=1mb)
')
Go
 
-- Drop database if exists
IF DB_ID('RestaurantDB') IS NOT NULL
    DROP DATABASE RestaurantDB;
GO

-- Alter Database (set options)
ALTER DATABASE RestaurantDB 
SET RECOVERY SIMPLE;
GO

-- Use the new Database
USE RestaurantDB;
GO


-- Create custom schema
CREATE SCHEMA Restaurant AUTHORIZATION dbo;
GO

-- Alter Schema (move object)
-- Example: later we can move a table under Restaurant schema
-- ALTER SCHEMA Restaurant TRANSFER dbo.Customers;


/* ============================
   1. Customers
============================ */

CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) UNIQUE,
    Address VARCHAR(200)
);
GO
/* ============================
    2. MenuItems
 ============================ */
CREATE TABLE MenuItems
(
    ItemID INT PRIMARY KEY IDENTITY,
    ItemName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Price DECIMAL(10,2) NOT NULL
);
GO
/* ============================
    3. Staff
 ============================ */
CREATE TABLE Staff
(
    StaffID INT PRIMARY KEY IDENTITY,
    Name VARCHAR(100) NOT NULL,
    Role VARCHAR(50),
    Phone VARCHAR(20)
);
GO
/* ============================
    4. Tables (Restaurant Tables)
 ============================ */
CREATE TABLE [Tables]
(
    TableID INT PRIMARY KEY IDENTITY,
    TableNo VARCHAR(20) UNIQUE,
    Capacity INT CHECK (Capacity > 0),
    Status VARCHAR(20) DEFAULT 'Available'
);
GO
/* ============================
    5. Orders
 ============================ */
CREATE TABLE [Orders]
(
    OrderID INT PRIMARY KEY IDENTITY,
    OrderDate DATETIME DEFAULT GETDATE(),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    StaffID INT FOREIGN KEY REFERENCES Staff(StaffID),
    TableID INT FOREIGN KEY REFERENCES [Tables](TableID)
);
GO
/* ============================
    6. OrderDetails
 ============================ */
CREATE TABLE OrderDetails
(
    OrderDetailID INT PRIMARY KEY IDENTITY,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    OrderID INT FOREIGN KEY REFERENCES [Orders](OrderID),
    ItemID INT FOREIGN KEY REFERENCES MenuItems(ItemID)
);
GO
/* ============================
    7. Payments
 ============================ */
CREATE TABLE Payments
(
    PaymentID INT PRIMARY KEY IDENTITY,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod VARCHAR(50),
    PaymentDate DATETIME DEFAULT GETDATE(),
    OrderID INT FOREIGN KEY REFERENCES [Orders](OrderID)
);
GO
 /* ============================
    8. Attendance
 ============================ */
CREATE TABLE Attendance
(
    AttendanceID INT PRIMARY KEY IDENTITY,
    Date DATE NOT NULL,
    CheckIn TIME NOT NULL,
    CheckOut TIME,
    StaffID INT NOT NULL FOREIGN KEY REFERENCES Staff(StaffID)
);
GO
 /* ============================
    9. Reservations
 ============================ */
CREATE TABLE Reservations 
(
    ReservationID INT PRIMARY KEY IDENTITY,
    ReservationTime DATETIME NOT NULL,
    Status VARCHAR(20) DEFAULT 'Pending',
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    TableID INT NOT NULL FOREIGN KEY REFERENCES [Tables](TableID)
);
GO
 /* ============================
    10. Suppliers
 ============================ */
CREATE TABLE Suppliers
(
    SupplierID INT PRIMARY KEY IDENTITY,
    SupplierName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(200)
);
GO
 /* ============================
    11. InventoryItems
 ============================ */
CREATE TABLE InventoryItems
(
    InventoryItemID INT PRIMARY KEY IDENTITY,  
    ItemName VARCHAR(100) NOT NULL,
    Unit VARCHAR(20) NOT NULL
);
GO
 /* ============================
    12. Inventory (Stock)
 ============================ */
CREATE TABLE Inventory
(
    InventoryID INT PRIMARY KEY IDENTITY,
    Quantity DECIMAL(10,2) NOT NULL CHECK (Quantity >= 0),
    InventoryItemID INT NOT NULL FOREIGN KEY REFERENCES InventoryItems(InventoryItemID),
    SupplierID INT NOT NULL FOREIGN KEY REFERENCES Suppliers(SupplierID)
);
GO
 /* ============================
    13. Recipes
 ============================ */
CREATE TABLE Recipes 
(
    RecipeID INT PRIMARY KEY IDENTITY,
    QuantityNeeded DECIMAL(10,2) NOT NULL CHECK (QuantityNeeded > 0),
    MenuItemID INT NOT NULL FOREIGN KEY REFERENCES MenuItems(ItemID),
    InventoryItemID INT NOT NULL FOREIGN KEY REFERENCES InventoryItems(InventoryItemID)
);
GO
 /* ============================
    14. Discounts
 ============================ */
CREATE TABLE Discounts
(
    DiscountID INT PRIMARY KEY IDENTITY,
    Description VARCHAR(200) NOT NULL,
    Percentage DECIMAL(5,2) CHECK (Percentage BETWEEN 0 AND 100),
    StartDate DATE,
    EndDate DATE
);
GO
 /* ============================
    15. Feedback
 ============================ */
CREATE TABLE Feedback 
(
    FeedbackID INT PRIMARY KEY IDENTITY,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(MAX),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID)
);
GO



/* ------------------------------------
   STEP 4: INDEXES
------------------------------------ */
-- Create clustered index (default on PK but showing example)
CREATE INDEX idx_orders_orderdate ON Orders(OrderDate);
CREATE INDEX idx_payments_paymentdate ON Payments(PaymentDate);
CREATE INDEX idx_menuitems_name ON MenuItems(ItemName);
CREATE INDEX idx_inventory_itemid ON Inventory(InventoryItemID);
GO

-- Non-clustered index
CREATE NONCLUSTERED INDEX IX_MenuItems_Category ON MenuItems(Category);

-- Drop Index example
-- DROP INDEX IX_MenuItems_Category ON MenuItems;

-- Alter Index example (Rebuild)
ALTER INDEX idx_menuitems_name ON MenuItems REBUILD;


/* ------------------------------------
   STEP 5: VIEWS
------------------------------------ */
-- Create View
CREATE VIEW vw_DailySales
AS
SELECT 
    o.OrderID,
    SUM(od.Quantity * m.Price) AS TotalAmount,
    CAST(o.OrderDate AS DATE) AS OrderDay
FROM [Orders] o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN MenuItems m ON od.ItemID = m.ItemID
GROUP BY o.OrderID, CAST(o.OrderDate AS DATE);
GO
-- Alter View Example
ALTER VIEW vw_DailySales
AS
SELECT 
    o.OrderID,
    SUM(od.Quantity * m.Price) AS TotalAmount,
    CAST(o.OrderDate AS DATE) AS OrderDay,
    c.Name AS CustomerName
FROM [Orders] o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN MenuItems m ON od.ItemID = m.ItemID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, CAST(o.OrderDate AS DATE), c.Name;
GO
-- Drop View Example
-- DROP VIEW vw_DailySales;


/* ------------------------------------
   STEP 6: PROCEDURE
------------------------------------ */
CREATE PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.OrderID, o.OrderDate, SUM(od.Quantity * m.Price) AS TotalBill
    FROM [Orders] o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN MenuItems m ON od.ItemID = m.ItemID
    WHERE o.CustomerID = @CustomerID
    GROUP BY o.OrderID, o.OrderDate;
END;
GO

-- Drop Procedure Example
-- DROP PROCEDURE sp_GetCustomerOrders;


/* ------------------------------------
   STEP 7: FUNCTION
------------------------------------ */
CREATE FUNCTION fn_TotalPayments(@CustomerID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);
    SELECT @Total = SUM(p.Amount)
    FROM Payments p
    JOIN [Orders] o ON p.OrderID = o.OrderID
    WHERE o.CustomerID = @CustomerID;
    RETURN ISNULL(@Total,0);
END;
GO

-- Drop Function Example
-- DROP FUNCTION fn_TotalPayments;


/* ------------------------------------
   STEP 8: TRIGGER
------------------------------------ */
CREATE TRIGGER trg_UpdateTableStatus
ON [Orders]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE t
    SET Status = 'Occupied'
    FROM [Tables] t
    JOIN inserted i ON t.TableID = i.TableID;
END;
GO

-- Drop Trigger Example
-- DROP TRIGGER trg_UpdateTableStatus;
