USE RestaurantDB;
GO

/*====================================
  INSERT 
====================================*/
-- Customers
INSERT INTO Customers (Name, Phone, Address) VALUES
                      ('Rahim Uddin', '01711111111', 'Dhaka'),
                      ('Karim Mia', '01822222222', 'Chittagong');
GO

-- MenuItems
INSERT INTO MenuItems (ItemName, Category, Price)VALUES 
                      ('Chicken Burger', 'Fast Food', 250.00),
                      ('Coke', 'Drink', 50.00);
GO
-- Staff
INSERT INTO Staff (Name, Role, Phone)VALUES
                  ('Abdul Malek', 'Waiter', '01644444444');
GO
-- Tables
INSERT INTO Tables (TableNo, Capacity, Status)VALUES
                   ('T1', 4, DEFAULT); 
GO
-- Orders
INSERT INTO Orders (CustomerID, StaffID, TableID)VALUES
                   (1, 1, 1);
GO
-- OrderDetails
INSERT INTO OrderDetails (OrderID, ItemID, Quantity)VALUES 
                         (1, 1, 2);
GO
-- Payments
INSERT INTO Payments (OrderID, Amount, PaymentMethod)VALUES
                     (1, 500.00, 'Cash');
GO
-- Attendance
INSERT INTO Attendance (StaffID, Date, CheckIn, CheckOut)VALUES
                       (1, GETDATE(), '09:00:00', '18:00:00');
GO
-- Reservations
INSERT INTO Reservations (CustomerID, TableID, ReservationTime, Status)VALUES 
                         (2, 1, '2025-09-15 19:00:00', 'Confirmed');
GO
-- Suppliers
INSERT INTO Suppliers (SupplierName, Phone, Address)VALUES 
                      ('Fresh Foods Ltd', '01677777777', 'Dhaka');
GO
-- InventoryItems
INSERT INTO InventoryItems (ItemName, Unit)VALUES
                           ('Chicken', 'Kg');
GO
-- Inventory
INSERT INTO Inventory (ItemName, Quantity, InventoryItemID, SupplierID)VALUES 
                      ('Chicken', 50, 1, 1);
GO
-- Recipes
INSERT INTO Recipes (MenuItemID, InventoryItemID, QuantityNeeded)VALUES
                    (1, 1, 0.25);
GO
-- Discounts
INSERT INTO Discounts (Description, Percentage, StartDate, EndDate)VALUES 
                      ('New Year Offer', 10.00, '2025-01-01', '2025-01-10');

-- Feedback
INSERT INTO Feedback (CustomerID, OrderID, Rating, Comment)VALUES
                     (1, 1, 5, 'Excellent food!');
GO

/*====================================
  UPDATE + SET
====================================*/
UPDATE MenuItems
SET Price = Price * 0.9   -- 10% discount
WHERE Category = 'Fast Food';

UPDATE Customers
SET Address = 'Sylhet'
WHERE Name = 'Karim Mia';
GO

/*====================================
  DELETE
====================================*/
DELETE FROM Feedback
WHERE Rating < 3;
GO

/*====================================
  MERGE (USING + ON + AS)
====================================*/
MERGE Suppliers AS Target
USING (SELECT 'Agro Suppliers' AS SupplierName, '01788888888' AS Phone, 'Gazipur' AS Address) AS Source
ON Target.SupplierName = Source.SupplierName
WHEN MATCHED THEN
    UPDATE SET Phone = Source.Phone
WHEN NOT MATCHED THEN
    INSERT (SupplierName, Phone, Address)
    VALUES (Source.SupplierName, Source.Phone, Source.Address);
GO

/*====================================
  TOP
====================================*/
SELECT TOP 2 ItemName, Price
FROM MenuItems
ORDER BY Price DESC;
GO

/*====================================
  IN + NOT IN
====================================*/
-- IN
SELECT * FROM MenuItems
WHERE Category IN ('Drink','Fast Food');

-- NOT IN
SELECT * FROM Customers
WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders);
GO