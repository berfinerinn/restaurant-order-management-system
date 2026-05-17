

CREATE TABLE Customer (

    customer_id INT PRIMARY KEY,

    name VARCHAR(100),

    phone VARCHAR(20)

);

CREATE TABLE Role (

    role_id INT PRIMARY KEY,

    role_name VARCHAR(50)

);

CREATE TABLE Employee (

    employee_id INT PRIMARY KEY,

    name VARCHAR(100)

);



CREATE TABLE Shift (

    shift_id INT PRIMARY KEY,

    shift_name VARCHAR(50), -- e.g., 'Morning', 'Evening'

    start_time TIME,

    end_time TIME

);

CREATE TABLE MenuItem (

    item_id INT PRIMARY KEY,

    name VARCHAR(100),

    price DECIMAL(10,2)

);

CREATE TABLE Orders (

    order_id INT PRIMARY KEY,

    customer_id INT,

    employee_id INT,

    order_date DATE,

    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),

    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)

);

CREATE TABLE OrderItem (

    order_item_id INT PRIMARY KEY,

    order_id INT,

    item_id INT,

    quantity INT,

    FOREIGN KEY (order_id) REFERENCES Orders(order_id),

    FOREIGN KEY (item_id) REFERENCES MenuItem(item_id)

);

CREATE TABLE Payment (

    payment_id INT PRIMARY KEY,

    order_id INT,

    amount DECIMAL(10,2),

    payment_method VARCHAR(50),

    FOREIGN KEY (order_id) REFERENCES Orders(order_id)

);

-- =========================

-- 2. VIEW CREATION

-- =========================

--CREATE VIEW OrderSummary AS

--SELECT  o.order_id,

--        c.name AS customer_name,

--        SUM(m.price * oi.quantity) AS total

--FROM Orders o

--JOIN Customer c ON o.customer_id = c.customer_id

--JOIN OrderItem oi ON o.order_id = oi.order_id

--JOIN MenuItem m ON oi.item_id = m.item_id

--GROUP BY o.order_id, c.name;

-- =========================

-- 3. ALTER TABLE OPERATIONS

-- =========================

-- Employee tablosuna FK ekledik

ALTER TABLE Employee

ADD shift_id INT;

ALTER TABLE Employee

ADD FOREIGN KEY (shift_id)

REFERENCES Shift(shift_id);

ALTER TABLE Employee

ADD role_id INT;

ALTER TABLE Employee

ADD FOREIGN KEY (role_id)

REFERENCES Role(role_id);

-- =========================

-- 4. INSERT  DATA

-- =========================

-- Customers

INSERT INTO Customer VALUES (1, 'Ali', '5551111');

INSERT INTO Customer VALUES (2, 'Ayse', '5552222');

-- Employees

INSERT INTO Employee VALUES (1, 'Mehmet');

INSERT INTO Employee VALUES (2, 'Zeynep');

-- Shift verilerini ekle

INSERT INTO Shift VALUES (1, 'Morning', '08:00', '16:00');

INSERT INTO Shift VALUES (2, 'Evening', '16:00', '00:00');

-- Roles

INSERT INTO Role VALUES (1, 'Waiter');

INSERT INTO Role VALUES (2, 'Cashier');

-- Menu

INSERT INTO MenuItem VALUES (1, 'Burger', 150);

INSERT INTO MenuItem VALUES (2, 'Pizza', 200);

INSERT INTO MenuItem VALUES (3, 'Cola', 50);

-- Orders

INSERT INTO Orders VALUES (1, 1, 1, '2026-05-01');

INSERT INTO Orders VALUES (2, 2, 2, '2026-05-02');

-- Order Items

INSERT INTO OrderItem VALUES (1, 1, 1, 2); -- 2 x Burger

INSERT INTO OrderItem VALUES (2, 1, 3, 1); -- 1 x Cola

INSERT INTO OrderItem VALUES (3, 2, 2, 1); -- 1 x Pizza

-- Payments

INSERT INTO Payment VALUES (1, 1, 350, 'Cash');

INSERT INTO Payment VALUES (2, 2, 200, 'Credit Card');

-- =========================

-- 5. UPDATE 

-- =========================

-- Employee kayýtlarýna shift atadýk

UPDATE Employee

SET shift_id = 1

WHERE employee_id = 1;

UPDATE Employee

SET shift_id = 2

WHERE employee_id = 2;

-- Employee kayýtlarýna role ata

UPDATE Employee

SET role_id = 1

WHERE employee_id = 1;

UPDATE Employee

SET role_id = 2

WHERE employee_id = 2;

-- =========================

-- 6. QUERIES

-- =========================

-- Revenue by Shift

SELECT 

    s.shift_name,

    AVG(p.amount) AS avg_order_value

FROM Orders o

JOIN Employee e ON o.employee_id = e.employee_id

JOIN Shift s ON e.shift_id = s.shift_id

JOIN Payment p ON o.order_id = p.order_id

GROUP BY s.shift_name;

-- Employee & Role Query

SELECT 

    e.name AS employee_name,

    r.role_name

FROM Employee e

JOIN Role r

ON e.role_id = r.role_id;

--All data from Customer
SELECT * FROM Customer;

--All data from Orders
SELECT * FROM Orders;

--Which employee handled each order 
SELECT Orders.order_id, Employee.name
FROM Orders
JOIN Employee ON Orders.employee_id = Employee.employee_id;

--Menu ýtems and quantities included in each order.
SELECT Orders.order_id, MenuItem.name, OrderItem.quantity
FROM OrderItem
JOIN Orders ON OrderItem.order_id = Orders.order_id
JOIN MenuItem ON OrderItem.item_id = MenuItem.item_id;

--Calculates the total price of each order
SELECT Orders.order_id, SUM(MenuItem.price * OrderItem.quantity) AS total_price
FROM OrderItem
JOIN Orders ON OrderItem.order_id = Orders.order_id
JOIN MenuItem ON OrderItem.item_id = MenuItem.item_id
GROUP BY Orders.order_id;

--Ranks menu items based on total quantity sold.
SELECT MenuItem.name, SUM(OrderItem.quantity) AS total_sold
FROM OrderItem
JOIN MenuItem ON OrderItem.item_id = MenuItem.item_id
GROUP BY MenuItem.name
ORDER BY total_sold DESC;

--Restaurants total revenue
SELECT SUM(amount) AS total_revenue
FROM Payment;


--How many orders each customer has placed
SELECT Customer.name, COUNT(Orders.order_id) AS total_orders
FROM Customer
LEFT JOIN Orders ON Customer.customer_id = Orders.customer_id
GROUP BY Customer.name;

CREATE VIEW OrderSummary AS
SELECT Orders.order_id, Customer.name AS customer_name,
       SUM(MenuItem.price * OrderItem.quantity) AS total
FROM Orders
JOIN Customer ON Orders.customer_id = Customer.customer_id
JOIN OrderItem ON Orders.order_id = OrderItem.order_id
JOIN MenuItem ON OrderItem.item_id = MenuItem.item_id
GROUP BY Orders.order_id, Customer.name;

--Calculates and ranks customers based on the total amount they have spent
SELECT Customer.name, SUM(Payment.amount) AS total_spent
FROM Customer
JOIN Orders ON Customer.customer_id = Orders.customer_id
JOIN Payment ON Orders.order_id = Payment.order_id
GROUP BY Customer.name
ORDER BY total_spent DESC;


--Total revenue for each day
SELECT Orders.order_date, SUM(Payment.amount) AS daily_total
FROM Orders
JOIN Payment ON Orders.order_id = Payment.order_id
GROUP BY Orders.order_date
ORDER BY Orders.order_date;

--Customers who are registered but have never placed an order
SELECT Customer.name
FROM Customer
LEFT JOIN Orders ON Customer.customer_id = Orders.customer_id
WHERE Orders.order_id IS NULL;
