-- Step 1: Create original data
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

INSERT INTO ProductDetail (OrderID, CustomerName, Products)
VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- optional to see if the records are there
SELECT * FROM ProductDetail;

-- Step 2: Create Numbers helper table
CREATE TABLE Numbers (n INT);
INSERT INTO Numbers (n)
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

-- Question 1: Creating the new table to store normalized data in 1NF
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100)
);
-- Normalize the ProductDetail table to 1NF by splitting comma-separated products into individual rows
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
            ',', -1
        )
    ) <> ''; 

-- Verify that the data is correctly split into 1NF
SELECT * FROM ProductDetail_1NF
ORDER BY OrderID, Product;

-- Question 2: Achieving 2NF
-- Task: Remove partial dependencies by separating OrderDetails into Orders and OrderItems
-- Create initial 1NF OrderDetails table
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

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Insert unique OrderID-CustomerName pairs
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert the product & quantity data (OrderID stays as the foreign key)
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Verify orders (no duplication of customer)
SELECT * FROM Orders ORDER BY OrderID;

-- Verify order items (products and quantities per order)
SELECT * FROM OrderItems ORDER BY OrderID, Product;
