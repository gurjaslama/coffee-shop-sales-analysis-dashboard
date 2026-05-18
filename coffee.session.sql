-- =========================================================
-- COFFEE SHOP SALES ANALYSIS PROJECT
-- Professional SQL Project for Data Analytics Internship
-- Database: PostgreSQL
-- =========================================================


-- =========================================================
-- CREATE TABLE
-- Stores all coffee shop transaction data
-- =========================================================

CREATE TABLE coffee_shop_sales (
    transaction_id      INT PRIMARY KEY,
    transaction_date    DATE,
    transaction_time    TIME,
    transaction_qty     INT,
    store_id            INT,
    store_location      VARCHAR(100),
    product_id          INT,
    unit_price          NUMERIC(10,2),
    product_category    VARCHAR(100),
    product_type        VARCHAR(100),
    product_detail      VARCHAR(200)
);


-- =========================================================
-- IMPORT CSV FILE
-- Replace path with your actual CSV location
-- =========================================================

COPY coffee_shop_sales
FROM 'C:/Coffee project 7/Coffee_Shop_Sales.csv'
DELIMITER ','
CSV HEADER;

-- =========================================================
-- VIEW DATA
-- Check first few rows
-- =========================================================

SELECT *
FROM coffee_shop_sales
LIMIT 10;


-- =========================================================
-- TOTAL RECORDS
-- Counts total transactions
-- =========================================================

SELECT COUNT(*) AS total_transactions
FROM coffee_shop_sales;


-- =========================================================
-- CHECK NULL VALUES
-- Data Cleaning Step
-- =========================================================

SELECT
    COUNT(*) FILTER (WHERE transaction_id IS NULL) AS null_transaction_id,
    COUNT(*) FILTER (WHERE transaction_date IS NULL) AS null_transaction_date,
    COUNT(*) FILTER (WHERE transaction_time IS NULL) AS null_transaction_time,
    COUNT(*) FILTER (WHERE transaction_qty IS NULL) AS null_transaction_qty,
    COUNT(*) FILTER (WHERE store_location IS NULL) AS null_store_location,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS null_unit_price
FROM coffee_shop_sales;


-- =========================================================
-- REMOVE DUPLICATES
-- Keeps only unique transactions
-- =========================================================

DELETE FROM coffee_shop_sales
WHERE transaction_id NOT IN (
    SELECT MIN(transaction_id)
    FROM coffee_shop_sales
    GROUP BY
        transaction_date,
        transaction_time,
        product_id,
        store_id
);


-- =========================================================
-- TOTAL SALES REVENUE
-- Revenue = Quantity × Unit Price
-- =========================================================

SELECT
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM coffee_shop_sales;


-- =========================================================
-- AVERAGE ORDER VALUE
-- =========================================================

SELECT
    ROUND(AVG(transaction_qty * unit_price), 2) AS average_order_value
FROM coffee_shop_sales;


-- =========================================================
-- TOP 10 BEST SELLING PRODUCTS
-- Based on quantity sold
-- =========================================================

SELECT
    product_detail,
    SUM(transaction_qty) AS total_quantity_sold
FROM coffee_shop_sales
GROUP BY product_detail
ORDER BY total_quantity_sold DESC
LIMIT 10;


-- =========================================================
-- TOP PRODUCT CATEGORIES
-- Based on revenue generated
-- =========================================================

SELECT
    product_category,
    ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_shop_sales
GROUP BY product_category
ORDER BY revenue DESC;


-- =========================================================
-- SALES BY STORE LOCATION
-- =========================================================

SELECT
    store_location,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_sales
FROM coffee_shop_sales
GROUP BY store_location
ORDER BY total_sales DESC;


-- =========================================================
-- MONTHLY SALES TREND
-- Useful for dashboard visualization
-- =========================================================

SELECT
    TO_CHAR(transaction_date, 'Month') AS month,
    ROUND(SUM(transaction_qty * unit_price), 2) AS monthly_sales
FROM coffee_shop_sales
GROUP BY month
ORDER BY monthly_sales DESC;


-- =========================================================
-- DAILY SALES ANALYSIS
-- =========================================================

SELECT
    transaction_date,
    ROUND(SUM(transaction_qty * unit_price), 2) AS daily_sales
FROM coffee_shop_sales
GROUP BY transaction_date
ORDER BY transaction_date;


-- =========================================================
-- PEAK SALES HOURS
-- Finds busiest time of day
-- =========================================================

SELECT
    EXTRACT(HOUR FROM transaction_time) AS sales_hour,
    COUNT(*) AS total_orders
FROM coffee_shop_sales
GROUP BY sales_hour
ORDER BY total_orders DESC;


-- =========================================================
-- MOST PROFITABLE PRODUCTS
-- Based on generated revenue
-- =========================================================

SELECT
    product_detail,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM coffee_shop_sales
GROUP BY product_detail
ORDER BY total_revenue DESC
LIMIT 10;


-- =========================================================
-- SALES PERFORMANCE BY PRODUCT TYPE
-- =========================================================

SELECT
    product_type,
    SUM(transaction_qty) AS quantity_sold,
    ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_shop_sales
GROUP BY product_type
ORDER BY revenue DESC;


-- =========================================================
-- WEEKDAY SALES ANALYSIS
-- Determines strongest business days
-- =========================================================

SELECT
    TO_CHAR(transaction_date, 'Day') AS weekday,
    ROUND(SUM(transaction_qty * unit_price), 2) AS sales
FROM coffee_shop_sales
GROUP BY weekday
ORDER BY sales DESC;


-- =========================================================
-- HIGH VALUE TRANSACTIONS
-- Orders above average revenue
-- =========================================================

SELECT *
FROM coffee_shop_sales
WHERE (transaction_qty * unit_price) >
(
    SELECT AVG(transaction_qty * unit_price)
    FROM coffee_shop_sales
)
ORDER BY unit_price DESC;


-- =========================================================
-- CUSTOMER PURCHASE INSIGHTS
-- Quantity distribution
-- =========================================================

SELECT
    transaction_qty,
    COUNT(*) AS total_orders
FROM coffee_shop_sales
GROUP BY transaction_qty
ORDER BY transaction_qty;


-- =========================================================
-- CREATE SALES VIEW
-- Simplifies dashboard connections
-- =========================================================

CREATE VIEW sales_summary AS
SELECT
    transaction_id,
    transaction_date,
    store_location,
    product_category,
    product_type,
    product_detail,
    transaction_qty,
    unit_price,
    ROUND(transaction_qty * unit_price, 2) AS total_sale
FROM coffee_shop_sales;


-- =========================================================
-- VIEW SALES SUMMARY
-- =========================================================

SELECT *
FROM sales_summary
LIMIT 20;


-- =========================================================
-- INDEXING FOR PERFORMANCE OPTIMIZATION
-- Improves query speed
-- =========================================================

CREATE INDEX idx_transaction_date
ON coffee_shop_sales(transaction_date);

CREATE INDEX idx_store_location
ON coffee_shop_sales(store_location);

CREATE INDEX idx_product_category
ON coffee_shop_sales(product_category);


-- =========================================================
-- FINAL BUSINESS INSIGHTS QUERY
-- Executive Summary Metrics
-- =========================================================

SELECT
    COUNT(*) AS total_orders,
    ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue,
    ROUND(AVG(transaction_qty * unit_price), 2) AS avg_order_value,
    MAX(transaction_qty * unit_price) AS highest_order_value,
    MIN(transaction_qty * unit_price) AS lowest_order_value
FROM coffee_shop_sales;