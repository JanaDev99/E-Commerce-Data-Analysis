CREATE DATABASE EcommerceDB;

USE EcommerceDB;

SELECT name FROM sys.tables;

ALTER TABLE order_items_clean
ALTER COLUMN product_id INT;

ALTER TABLE reviews_clean
ALTER COLUMN product_id INT;

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME IN ('customer_id', 'order_id', 'product_id')
ORDER BY COLUMN_NAME, TABLE_NAME;

ALTER TABLE orders_clean
ADD CONSTRAINT FK_orders_customers
FOREIGN KEY (customer_id) REFERENCES customers_clean(customer_id);

ALTER TABLE order_items_clean
ADD CONSTRAINT FK_orderitems_orders
FOREIGN KEY (order_id) REFERENCES orders_clean(order_id);

ALTER TABLE order_items_clean
ADD CONSTRAINT FK_orderitems_products
FOREIGN KEY (product_id) REFERENCES products_clean(product_id);

ALTER TABLE payments_clean
ADD CONSTRAINT FK_payments_orders
FOREIGN KEY (order_id) REFERENCES orders_clean(order_id);

ALTER TABLE reviews_clean
ADD CONSTRAINT FK_reviews_customers
FOREIGN KEY (customer_id) REFERENCES customers_clean(customer_id);

ALTER TABLE reviews_clean
ADD CONSTRAINT FK_reviews_products
FOREIGN KEY (product_id) REFERENCES products_clean(product_id);


USE EcommerceDB;

-- 1. Top 5 best-selling products by revenue
SELECT TOP 5
    p.name AS product_name,
    p.category,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items_clean oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.name, p.category
ORDER BY total_revenue DESC;

-- 2. Total sales revenue per category
SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM order_items_clean oi
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 3. Top 5 customers by total spending
SELECT TOP 5
    c.name AS customer_name,
    c.city,
    SUM(o.total_amount) AS total_spent
FROM orders_clean o
JOIN customers_clean c ON o.customer_id = c.customer_id
WHERE o.status <> 'Cancelled'
GROUP BY c.name, c.city
ORDER BY total_spent DESC;

-- 4. Monthly sales trend
SELECT
    FORMAT(order_date, 'yyyy-MM') AS month,
    SUM(total_amount) AS monthly_sales
FROM orders_clean
WHERE status <> 'Cancelled'
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY month;

-- 5. Number of orders per status
SELECT
    status,
    COUNT(*) AS order_count
FROM orders_clean
GROUP BY status
ORDER BY order_count DESC;

-- 6. Average order value per city
SELECT
    shipping_city,
    AVG(total_amount) AS avg_order_value
FROM orders_clean
WHERE status <> 'Cancelled'
GROUP BY shipping_city
ORDER BY avg_order_value DESC;

-- 7. Products with low stock (below 20 units) that still sell well
SELECT
    p.name AS product_name,
    p.stock_quantity,
    SUM(oi.quantity) AS units_sold
FROM products_clean p
JOIN order_items_clean oi ON p.product_id = oi.product_id
WHERE p.stock_quantity < 20
GROUP BY p.name, p.stock_quantity
ORDER BY units_sold DESC;

-- 8. Most used payment methods
SELECT
    payment_method,
    COUNT(*) AS times_used,
    SUM(amount) AS total_amount_paid
FROM payments_clean
GROUP BY payment_method
ORDER BY times_used DESC;

-- 9. Average product rating per category
SELECT
    p.category,
    AVG(CAST(r.rating AS FLOAT)) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM reviews_clean r
JOIN products_clean p ON r.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_rating DESC;

-- 10. Customers who never placed an order (potential re-engagement targets)
SELECT
    c.customer_id,
    c.name,
    c.city
FROM customers_clean c
LEFT JOIN orders_clean o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;