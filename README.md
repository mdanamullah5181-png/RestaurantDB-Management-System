# RestaurantDB - Restaurant Management System

A comprehensive SQL-based restaurant management database system.

## 📋 Project Overview

RestaurantDB is a complete database solution designed to manage all operations of a restaurant. This project includes:

- Customer Management
- Menu Items and Pricing
- Staff Management and Attendance Tracking
- Table and Seating Management
- Orders and Order Details
- Payment Processing
- Reservation System
- Supplier and Inventory Management
- Recipe Management
- Discounts and Promotions
- Customer Feedback and Ratings

## 🗂️ File Structure

```
SQL_Project/
├── RestaurantDB_DDL_FILE_SQLQuery1.sql   # Database schema and table creation
├── RestaurantDB_DML_File_SQLQuery3.sql   # Data INSERT, UPDATE, DELETE, and MERGE
├── RestaurantDB_DQL_File_SQLQuery4.sql   # SELECT queries and reports
└── README.md                             # This file
```

## 🗄️ Database Tables

### Core Tables

| Table | Description |
|-------|-------------|
| **Customers** | Customer information (ID, Name, Phone, Address) |
| **MenuItems** | Menu items, categories and pricing |
| **Staff** | Employee information (ID, Name, Role, Phone) |
| **Tables** | Restaurant tables and seating capacity |
| **Orders** | Order information and dates |
| **OrderDetails** | Order items and quantities |
| **Payments** | Payment methods and amounts |
| **Reservations** | Table reservations |
| **Attendance** | Employee attendance records |
| **Suppliers** | Supplier information |
| **Inventory** | Inventory stock and supplier relationships |
| **InventoryItems** | Inventory items measurements and units |
| **Recipes** | Recipes and ingredient combinations |
| **Discounts** | Discounts and promotional offers |
| **Feedback** | Customer ratings and comments |

## 🔧 SQL Features Used

### DDL (Data Definition Language)
- ✅ CREATE DATABASE
- ✅ CREATE TABLE
- ✅ CREATE SCHEMA
- ✅ ALTER DATABASE
- ✅ PRIMARY KEY, FOREIGN KEY
- ✅ CHECK, DEFAULT, UNIQUE Constraints

### DML (Data Manipulation Language)
- ✅ INSERT INTO
- ✅ UPDATE SET
- ✅ DELETE FROM
- ✅ MERGE (USING, ON, WHEN MATCHED)

### DQL (Data Query Language)
- ✅ SELECT, WHERE, ORDER BY
- ✅ DISTINCT
- ✅ INNER JOIN
- ✅ LEFT JOIN
- ✅ FULL OUTER JOIN
- ✅ CROSS JOIN
- ✅ GROUP BY, HAVING
- ✅ Aggregate Functions: SUM(), AVG()
- ✅ OFFSET, FETCH (Pagination)
- ✅ LIKE, BETWEEN, CASE
- ✅ IS NULL, NOT NULL
- ✅ AND, OR, NOT Operators

## 🚀 Setup Instructions

### Requirements
- SQL Server 2016 or higher
- SQL Server Management Studio (SSMS)

### Installation

1. **Run the DDL file first:**
   ```sql
   -- Open SQL Server Management Studio
   -- Open RestaurantDB_DDL_FILE_SQLQuery1.sql and Execute
   ```

2. **Then run the DML file:**
   ```sql
   -- Open RestaurantDB_DML_File_SQLQuery3.sql and Execute
   -- This will add sample data
   ```

3. **Finally run the DQL file:**
   ```sql
   -- Open RestaurantDB_DQL_File_SQLQuery4.sql and Execute
   -- This will display various reports and queries
   ```

## 📊 Sample Query Examples

### Get Customer Order Information
```sql
SELECT O.OrderID, C.Name AS CustomerName, M.ItemName, OD.Quantity
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN MenuItems M ON OD.ItemID = M.ItemID;
```

### Total Sales by Category
```sql
SELECT M.Category, SUM(OD.Quantity) AS TotalQty, AVG(M.Price) AS AvgPrice
FROM OrderDetails OD
JOIN MenuItems M ON OD.ItemID = M.ItemID
GROUP BY M.Category
HAVING SUM(OD.Quantity) > 1;
```

### Reservations and Table Information
```sql
SELECT C.Name, R.ReservationTime, T.TableNo
FROM Customers C
LEFT JOIN Reservations R ON C.CustomerID = R.CustomerID
LEFT JOIN Tables T ON R.TableID = T.TableID;
```

## 💡 Possible Enhancements

- Web Application Development (C#, Python, Node.js)
- Adding Stored Procedures
- Creating Views and Triggers
- Extended Reporting System
- API Development

## 📝 License

This project is open for educational purposes.

## 👨‍💻 Author

Your Project ✨

---

**Note:** This is an educational database project. Before using in production environment, apply appropriate changes and optimizations.
