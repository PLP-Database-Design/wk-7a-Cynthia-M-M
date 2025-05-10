-- ✅ Use the correct database
USE normalizationdb;

-- ✅ STEP 0: Drop existing tables if they already exist
DROP TABLE IF EXISTS ProductDetail, Orders, Product;

-- ✅ Question 1: Achieving 1NF
-- No more multivalued columns — each product is in its own row
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(100)
);

INSERT INTO ProductDetail(OrderID, CustomerName, Products)
VALUES
(101, 'John Doe', 'Laptop'),
(101, 'John Doe', 'Mouse'),
(102, 'Jane Smith', 'Tablet'),
(102, 'Jane Smith', 'Keyboard'),
(102, 'Jane Smith', 'Mouse'),
(103, 'Emily Clark', 'Phone');

-- ✅ Verify 1NF
SELECT * FROM ProductDetail;

-- ✅ Question 2: Achieving 2NF
-- Separate Customer info (Orders) from product info (Product table)

-- Orders table (OrderID is the primary key)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

INSERT INTO Orders (OrderID, CustomerName)
VALUES
(101, 'John Doe'),
(102, 'Jane Smith'),
(103, 'Emily Clark');

-- Product table
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    productName VARCHAR(100),
    quantity INT,
    order_id INT,
    FOREIGN KEY (order_id) REFERENCES Orders(OrderID)
);

INSERT INTO Product (product_id, productName, quantity, order_id)
VALUES 
(1, 'Laptop', 2, 101),
(2, 'Mouse', 1, 101),
(3, 'Tablet', 3, 102),
(4, 'Keyboard', 2, 102),
(5, 'Mouse', 1, 102),
(6, 'Phone', 1, 103);

-- ✅ Verify 2NF result
SELECT * FROM Orders;
SELECT * FROM Product;

