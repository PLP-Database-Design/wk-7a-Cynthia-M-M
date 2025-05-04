-- ✅ Use the correct database
USE normalizationdb;

-- ✅ STEP 0: Drop existing tables to redo the assignment cleanly
DROP TABLE IF EXISTS ProductDetail, ProductDetail_1NF, Numbers, OrderDetails, Orders, OrderItems;

-- Question 1
-- ✅ STEP 1: Original Data - Not in 1NF (multivalued Products column)
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255) -- Contains comma-separated product list (violates 1NF)
);

INSERT INTO ProductDetail (OrderID, CustomerName, Products)
VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- ✅ VERIFY STEP 1: Show unnormalized table
SELECT * FROM ProductDetail;

-- ✅ STEP 2: Create Helper Table for splitting product values (supporting 1NF)
CREATE TABLE Numbers (n INT);

INSERT INTO Numbers (n)
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

-- ✅ VERIFY STEP 2: Confirm helper table was created
SELECT * FROM Numbers;

-- ✅ STEP 3: Convert to 1NF by splitting multivalued products into rows(answer)
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100) -- Each product now in its own row
);

INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT
    pd.OrderID,
    pd.CustomerName,
    TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(pd.Products, ',', n.n),
            ',', -1
        )
    ) AS Product
FROM ProductDetail pd
JOIN Numbers n ON n.n <= 1 + LENGTH(pd.Products) - LENGTH(REPLACE(pd.Products, ',', ''))
WHERE TRIM(
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(pd.Products, ',', n.n),
            ',', -1)
    ) <> '';

-- ✅ VERIFY STEP 3: Check 1NF table
SELECT * FROM ProductDetail_1NF ORDER BY OrderID, Product;

-- Question 2
-- ✅ STEP 4: Create data with quantities to demonstrate 2NF issues (OrderDetails)
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT
);

INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity)
VALUES 
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- ✅ VERIFY STEP 4: Show 1NF-like data that still violates 2NF (due to partial dependency)
SELECT * FROM OrderDetails;

-- ✅ STEP 5: Convert to Second Normal Form (2NF)

-- 5a: Orders table (CustomerName depends only on OrderID)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- ✅ VERIFY STEP 5a: Unique orders and customers
SELECT * FROM Orders ORDER BY OrderID;

-- 5b: OrderItems table (Product and Quantity now only linked to OrderID)
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- ✅ VERIFY STEP 5b: View normalized items
SELECT * FROM OrderItems ORDER BY OrderID, Product;




