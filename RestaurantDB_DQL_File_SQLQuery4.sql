USE RestaurantDB;
GO

/*====================================
  SELECT + FROM + WHERE + ORDER BY
====================================*/
SELECT CustomerID, Name, Phone
FROM Customers
WHERE Address = 'Dhaka'
ORDER BY Name ASC;
GO

/*====================================
  DISTINCT
====================================*/
SELECT DISTINCT Category
FROM MenuItems;
GO

/*====================================
  JOIN + INNER JOIN + ON
====================================*/
SELECT O.OrderID, C.Name AS CustomerName, M.ItemName, OD.Quantity
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN MenuItems M ON OD.ItemID = M.ItemID;
GO

/*====================================
  LEFT JOIN
====================================*/
SELECT C.Name, R.ReservationTime, T.TableNo
FROM Customers C
LEFT JOIN Reservations R ON C.CustomerID = R.CustomerID
LEFT JOIN Tables T ON R.TableID = T.TableID;
GO

/*====================================
  OUTER JOIN (FULL OUTER JOIN)
====================================*/
SELECT S.SupplierName, I.ItemName--------------THIS WORK NOT EXECUTE 
FROM Suppliers S
FULL OUTER JOIN Inventory I ON S.SupplierID = I.SupplierID;
GO

/*====================================
  CROSS JOIN
====================================*/
SELECT M.ItemName, D.Description
FROM MenuItems M
CROSS JOIN Discounts D;
GO

/*====================================
  GROUP BY + HAVING + SUM() + AVG()
====================================*/
SELECT M.Category, SUM(OD.Quantity) AS TotalQty, AVG(M.Price) AS AvgPrice
FROM OrderDetails OD
JOIN MenuItems M ON OD.ItemID = M.ItemID
GROUP BY M.Category
HAVING SUM(OD.Quantity) > 1;
GO

/*====================================
  OFFSET + FETCH (Pagination)
====================================*/
SELECT OrderID, OrderDate, CustomerID
FROM Orders
ORDER BY OrderDate DESC
OFFSET 0 ROWS FETCH NEXT 2 ROWS ONLY;
GO

/*====================================
  LIKE
====================================*/
SELECT * FROM Customers
WHERE Name LIKE 'R%';
GO

/*====================================
  IS NULL + NOT NULL
====================================*/
SELECT * FROM Feedback
WHERE Comment IS NOT NULL;
GO

/*====================================
  CASE + BETWEEN + AND + OR + NOT
====================================*/
SELECT Name,
       CASE 
            WHEN Address = 'Dhaka' THEN 'Capital Customer'
            WHEN Address = 'Chittagong' THEN 'Port City Customer'
            ELSE 'Other'
       END AS LocationType
FROM Customers
WHERE CustomerID BETWEEN 1 AND 5
  AND (Phone LIKE '017%' OR Phone LIKE '018%')
  AND NOT Address = 'Sylhet';
GO

/*====================================
  UNION ALL
====================================*/
SELECT Name AS Person FROM Customers
UNION ALL
SELECT Name FROM Staff;
GO

/*====================================
  EXISTS
====================================*/
SELECT C.Name
FROM Customers C
WHERE EXISTS (
    SELECT 1 FROM Orders O WHERE O.CustomerID = C.CustomerID
);
GO

/*====================================
  ANY / ALL
====================================*/
-- ANY
SELECT ItemName, Price
FROM MenuItems
WHERE Price > ANY (SELECT Price FROM MenuItems WHERE Category = 'Drink');

-- ALL
SELECT ItemName, Price
FROM MenuItems
WHERE Price > ALL (SELECT Price FROM MenuItems WHERE Category = 'Drink');
GO

/*====================================
  WITH (CTE)
====================================*/
WITH CustomerOrders AS (
    SELECT C.CustomerID, C.Name, COUNT(O.OrderID) AS TotalOrders
    FROM Customers C
    LEFT JOIN Orders O ON C.CustomerID = O.CustomerID
    GROUP BY C.CustomerID, C.Name
)
SELECT * FROM CustomerOrders
WHERE TotalOrders >= 1;
GO

/*====================================
  OVER (Window Functions)
====================================*/
SELECT OrderID, Amount,
       SUM(Amount) OVER (PARTITION BY PaymentMethod) AS TotalByMethod
FROM Payments;
GO

/*====================================
  ROLLUP
====================================*/
SELECT M.Category, SUM(OD.Quantity) AS TotalQty
FROM OrderDetails OD
JOIN MenuItems M ON OD.ItemID = M.ItemID
GROUP BY ROLLUP (M.Category);
GO

/*====================================
  CUBE
====================================*/
SELECT M.Category, M.ItemName, SUM(OD.Quantity) AS TotalQty
FROM OrderDetails OD
JOIN MenuItems M ON OD.ItemID = M.ItemID
GROUP BY CUBE (M.Category, M.ItemName);
GO

/*====================================
  GROUPING SETS
====================================*/
SELECT M.Category, M.ItemName, SUM(OD.Quantity) AS TotalQty
FROM OrderDetails OD
JOIN MenuItems M ON OD.ItemID = M.ItemID
GROUP BY GROUPING SETS ((M.Category), (M.ItemName));
GO

--------------------------------Functions & Operators-------------------------------------------------

USE RestaurantDB;
GO

/*====================================
  GETDATE() - Current date/time
====================================*/
SELECT GETDATE() AS CurrentDateTime;
GO

/*====================================
  DATEDIFF - Find difference in days
====================================*/
SELECT DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysSinceOrder
FROM Orders;
GO

/*====================================
  CAST / CONVERT
====================================*/
-- CAST
SELECT CAST(Amount AS INT) AS AmountInt
FROM Payments;

-- CONVERT
SELECT CONVERT(VARCHAR(20), PaymentDate, 103) AS PaymentDate_DDMMYYYY
FROM Payments;
GO

/*====================================
  SUM, AVG, MIN, MAX, COUNT
====================================*/
SELECT 
    SUM(Amount) AS TotalRevenue,
    AVG(Amount) AS AvgPayment,
    MIN(Amount) AS MinPayment,
    MAX(Amount) AS MaxPayment,
    COUNT(*) AS TotalPayments
FROM Payments;
GO

/*====================================
  Arithmetic Operators: /, %
====================================*/
-- Average price per item
SELECT SUM(Price) / COUNT(*) AS AvgPrice
FROM MenuItems;

-- Odd/Even OrderID using Modulus
SELECT OrderID, 
       CASE WHEN OrderID % 2 = 0 THEN 'Even' ELSE 'Odd' END AS OrderType
FROM Orders;
GO

/*====================================
  Comparison Operators: =, <, <=
====================================*/
SELECT * FROM MenuItems
WHERE Price <= 300;
GO

/*====================================
  @@ROWCOUNT
====================================*/
-- Example: update + check affected rows
UPDATE MenuItems
SET Price = Price + 10
WHERE Category = 'Drink';

PRINT 'Rows affected: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO


-----------------------------------------------TCL Queries--------------------------------------------------------

USE RestaurantDB;
GO

/*====================================
  BEGIN + COMMIT + ROLLBACK
====================================*/
BEGIN TRANSACTION;

    -- Example: Insert new order
    INSERT INTO Orders (CustomerID, StaffID, TableID)
    VALUES (1, 1, 1);

    INSERT INTO OrderDetails (OrderID, ItemID, Quantity)
    VALUES (SCOPE_IDENTITY(), 1, 2);

    -- If everything is fine, then I will commit.
COMMIT;
-- If there was any error, then the following rollback could be executed
-- ROLLBACK;
GO


/*====================================
  SAVE TRAN
====================================*/
BEGIN TRANSACTION;
    INSERT INTO Customers (Name, Phone, Address)
    VALUES ('Temporary User', '01999999999', 'Test City');

    SAVE TRAN SavePoint1;  -- savepoint create

    -- wrongh data insert
    INSERT INTO Customers (Name, Phone, Address)
    VALUES ('Duplicate User', '01999999999', 'Test City');

    -- This might fail due to the phone unique constraint
    -- So, a rollback savepoint can be used
ROLLBACK TRAN SavePoint1;

-- The first insert will remain, the second one will be undone
COMMIT;
GO


/*====================================
  READ UNCOMMITTED (Dirty Read)
====================================*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRANSACTION;
    SELECT * FROM Payments;  -- 
COMMIT;
GO


/*====================================
  READ COMMITTED (Default Isolation)
====================================*/
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;
    SELECT * FROM Orders;  
COMMIT;
GO


---------------------------------------==========================--------------------------------------
USE RestaurantDB;
GO

/*====================================
  IF...ELSE + BEGIN...END + RETURN
====================================*/
DECLARE @CustomerPhone VARCHAR(20) = '01711111111';

IF EXISTS (SELECT 1 FROM Customers WHERE Phone = @CustomerPhone)
BEGIN
    PRINT 'Customer already exists!';
    RETURN; -- এখানেই থেমে যাবে
END
ELSE
BEGIN
    INSERT INTO Customers (Name, Phone, Address)
    VALUES ('New IF ELSE Customer', @CustomerPhone, 'Dhaka');
END
GO


/*====================================
  WHILE + BREAK + CONTINUE
====================================*/
DECLARE @Counter INT = 1;

WHILE (@Counter <= 5)
BEGIN
    IF @Counter = 3
    BEGIN
        PRINT 'Skipping 3';
        SET @Counter = @Counter + 1;
        CONTINUE; 
    END

    IF @Counter = 5
    BEGIN
        PRINT 'Breaking at 5';
        BREAK; 
    END

    PRINT 'Current Count = ' + CAST(@Counter AS VARCHAR);
    SET @Counter = @Counter + 1;
END
GO


/*====================================
  TRY...CATCH + GOTO
====================================*/
BEGIN TRY
   
    INSERT INTO Payments (OrderID, Amount, PaymentDate, PaymentID)
    VALUES (9999, -500, GETDATE(), 1);
END TRY
BEGIN CATCH
    PRINT 'Error Occurred: ' + ERROR_MESSAGE();
    GOTO HandleError;
END CATCH;

HandleError:
PRINT 'Jumped to error handler using GOTO';
GO


/*====================================
  EXEC + sp_executesql
====================================*/
DECLARE @sql NVARCHAR(MAX) = N'SELECT TOP 3 Name, Price FROM MenuItems ORDER BY Price DESC';----This query not working 
EXEC sp_executesql @sql;  
GO


/*====================================
  PRINT + DECLARE + SET
====================================*/
DECLARE @TodayDate DATE;
SET @TodayDate = GETDATE();

PRINT 'Today is: ' + CAST(@TodayDate AS VARCHAR);
GO


/*====================================
  SET ANSI_NULLS, SET ANSI_PADDING, SET NOCOUNT, SET DATEFORMAT
====================================*/
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET NOCOUNT ON;
SET DATEFORMAT DMY;

SELECT GETDATE() AS CurrentDate;
GO


/*====================================
  sys.tables, sys.columns, sys.objects
====================================*/
SELECT name FROM sys.tables;

-- Orders Tables column
SELECT name, column_id, system_type_id
FROM sys.columns
WHERE object_id = OBJECT_ID('Orders');

-- Objects (Tables, Views, Procedures Etc.)
SELECT name, type_desc
FROM sys.objects;
GO


/*====================================
  sys.foreign_keys, sys.foreign_key_columns
====================================*/
SELECT name, parent_object_id
FROM sys.foreign_keys;

SELECT fkc.constraint_column_id, c.name AS ColumnName
FROM sys.foreign_key_columns fkc
JOIN sys.columns c
    ON fkc.parent_column_id = c.column_id
   AND fkc.parent_object_id = c.object_id;
GO


/*====================================
  sys.key_constraints, sys.schemas, sys.views, sys.sequences
====================================*/
SELECT name, type_desc FROM sys.key_constraints;

SELECT name FROM sys.schemas;

SELECT name FROM sys.views;

-- sequence create + use
CREATE SEQUENCE OrderSeq START WITH 100 INCREMENT BY 1;

SELECT NEXT VALUE FOR OrderSeq AS NextOrderNumber;
GO