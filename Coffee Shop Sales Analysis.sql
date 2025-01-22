/*
DROP DATABASE IF EXISTS coffee_shop_sales_db;
CREATE DATABASE coffee_shop_sales_db;
USE coffee_shop_sales_db;

DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
	transaction_id INT,
    transaction_date TEXT,
    transaction_time TIME,
    transaction_qty INT, 
    store_id INT,
    store_location VARCHAR(20),
    product_id INT,
    unit_price FLOAT,
	product_category VARCHAR(25),
    product_type VARCHAR(30),
    product_detail VARCHAR(35)
);
										
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA INFILE 'Coffee Shop Sales.csv' INTO TABLE transactions
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
*/
/*
UPDATE transactions
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

ALTER TABLE transactions
MODIFY COLUMN transaction_date DATE;
*/

/* CREATING A NEW COLUMN: MONTH
SELECT 
	*,
    MONTH(transaction_date) as month
FROM transactions;

ALTER TABLE transactions
ADD COLUMN month INT;

UPDATE transactions
SET month = MONTH(transaction_date);
*/

/* CREATING  A NEW COLUMN: MONTHNAME
ALTER TABLE transactions
ADD COLUMN month_name TEXT;

UPDATE transactions
SET month_name = MONTHNAME(transaction_date);
*/


/* CREATING A NEW COLUMN: HOUR
SELECT 
	*,
    HOUR(transaction_time) AS hour
FROM transactions;

ALTER TABLE transactions
ADD COLUMN hour INT;

UPDATE transactions
SET hour = HOUR(transaction_time);
*/

/* CREATING A NEW COLUMN: REVENUE
SELECT 
	*,
    transaction_qty * unit_price AS revenue
FROM transactions;

ALTER TABLE transactions
ADD COLUMN revenue FLOAT;

UPDATE transactions
SET revenue = transaction_qty * unit_price;
*/

-- KPI Requirements
-- 1. Total Sales Analysis
SELECT
	CONCAT('$', ROUND(SUM(revenue)/1000), 'K') AS total_revenue
FROM transactions;

-- Calculate the total sales for each respective month.
SELECT 
	`month`,
    CONCAT('$', ROUND(SUM(revenue)/1000, 1), 'K') AS total_revenue
FROM transactions
GROUP BY `month`;

-- Determine the month-on-month increase or decrease in sales.
WITH mom_sales AS (
SELECT 
	`month`,
    ROUND(SUM(revenue), 2) AS total_sales,
    LAG(ROUND(SUM(revenue), 2), 1, 0) OVER(ORDER BY `month`) AS last_month
FROM transactions
GROUP BY `month`
)
SELECT 
	*,
    ROUND(total_sales - last_month, 2) AS MoM_difference,
    CONCAT(ROUND((total_sales - last_month) * 100 / last_month), '%') AS MoM_percentage
FROM mom_sales
;

-- Calculate the difference in sales between the selected month and the previous month.
WITH selected_month AS (
SELECT 
	`month`,
    ROUND(SUM(revenue), 2) AS total_sales,
    LAG(ROUND(SUM(revenue), 2), 1, 0) OVER(ORDER BY `month`) AS prev_month
FROM transactions
GROUP BY `month`
)
SELECT 
	*,
    ROUND(total_sales - prev_month, 2) AS difference
FROM selected_month
WHERE 
	`month` = 2
;



-- 2. Total Order Analysis
SELECT
	COUNT(transaction_id) AS total_orders
FROM transactions;

-- Calculate the total number of orders for each respective month.
SELECT 
	`month`,
    COUNT(transaction_id) AS total_orders
FROM transactions
GROUP BY `month`;

-- Determine the month-on-month increase or decrease in the number of orders.
WITH mom_orders AS (
SELECT
	`month`,
    COUNT(transaction_id) AS total_orders,
    LAG(COUNT(transaction_id)) OVER(ORDER BY `month`) AS prev_month_orders
FROM transactions
GROUP BY `month`
)
SELECT 
	*,
    total_orders - prev_month_orders AS MoM_orders,
    CONCAT(ROUND((total_orders - prev_month_orders) * 100 / prev_month_orders, 2), '%') 
    AS MoM_percentage
FROM mom_orders;

-- Calculate the difference in the number of orders between the selected month 
-- and the previous month.
WITH selection AS (
SELECT
	`month`,
    COUNT(transaction_id) AS total_orders,
    LAG(COUNT(transaction_id)) OVER(ORDER BY `month`) AS prev_month_orders
FROM transactions
GROUP BY `month`
)
SELECT 
	*,
    total_orders - prev_month_orders AS MoM_difference
FROM selection
WHERE
	`month` = 2;



-- 3. Total Quantity Sold Analysis
SELECT 
	SUM(transaction_qty) AS total_qty_sold
FROM transactions;

-- Calculate the total quantity sold for each respective month.
SELECT 
	`month`,
	SUM(transaction_qty) AS total_qty_sold
FROM transactions
GROUP BY `month`;

-- Determine the month-on-month increase or decrease in the total quantity sold.
WITH mom_qty_sold AS (
SELECT
	`month`,
    SUM(transaction_qty) AS total_qty_sold,
    LAG(SUM(transaction_qty), 1, 0) OVER(ORDER BY `month`) AS prev_month_qty
FROM transactions
GROUP BY `month`
)
SELECT 
	*,
    total_qty_sold - prev_month_qty AS MoM_difference,
    CONCAT(ROUND((total_qty_sold - prev_month_qty) * 100 / prev_month_qty), '%')
    AS MoM_percentage
FROM mom_qty_sold;

-- Calculate the difference in the total quantity sold between the selected month 
-- and the previous month.
WITH selected_month AS (
SELECT
	`month`,
    SUM(transaction_qty) AS total_qty_sold,
    LAG(SUM(transaction_qty)) OVER(ORDER BY `month`) AS prev_month_qty
FROM transactions
GROUP BY `month`
)
SELECT
	*,
    total_qty_sold - prev_month_qty AS MoM_difference
FROM selected_month
WHERE
	`month` = 2;

-- Total Sales, Total Orders, Total Quantity Sold
SELECT
	CONCAT('$', ROUND(SUM(revenue)/1000), 'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id)/1000), 'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty)/1000), 'K') AS total_qty_sold
FROM transactions;



-- Other Requirements
/*
Weekdays:
0 - Monday
1 - Tuesday
2 - Wednesday
3 - Thursday
4 - Friday
5 - Saturday
6 - Sunday
*/
-- 1. Sales Analysis by Weekdays and Weekends
WITH weekdays_sales AS (
SELECT
	CASE
		WHEN WEEKDAY(transaction_date) IN (0, 1, 2, 3, 4) THEN 'Weekdays'
        ELSE 'Weekends'
	END AS `week`,
    ROUND(SUM(revenue)) AS total_sales
FROM transactions
GROUP BY
	`week`
ORDER BY 
	total_sales DESC
)
SELECT
	*,
    CONCAT(ROUND(total_sales * 100 / (SELECT SUM(revenue) FROM transactions)), '%')
    AS percentage_of_total
FROM weekdays_sales
;


-- 2. Sales Analysis by Store Location
SELECT 
	store_location,
    CONCAT('$', ROUND(SUM(revenue)/1000), 'K') AS total_sales
FROM transactions
GROUP BY 
	store_location
ORDER BY
	total_sales DESC;
    
/* CREATING A NEW COLUMN: DAYNAME 
ALTER TABLE transactions
ADD COLUMN day_name TEXT;

UPDATE transactions
SET day_name = DAYNAME(transaction_date);
*/

/* CREATING A NEW COLUMN: DAY
ALTER TABLE transactions
ADD COLUMN day_of_week INT;

UPDATE transactions
SET day_of_week = DAY(transaction_date);

ALTER TABLE transactions
RENAME COLUMN day_of_week TO day_of_month;
*/


-- 3. Daily sales analysis with average line  
WITH average_sales AS (
SELECT
	day_of_month,
    ROUND(SUM(revenue)) AS total_sales,
    ROUND(AVG(SUM(revenue)) OVER()) AS avg_sales
FROM transactions
GROUP BY 
	day_of_month
)
SELECT 
	*,
    CASE 
		WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
		ELSE 'Average'
	END AS sales_status
FROM average_sales;


-- 4. Sales Analysis by Product Category
SELECT
	product_category,
    ROUND(SUM(revenue)) AS total_sales
FROM transactions
GROUP BY 
	product_category
ORDER BY 
	total_sales DESC
;


-- 5. Top 10 Products by Sales
SELECT 
	product_type,
    ROUND(SUM(revenue)) AS total_sales
FROM transactions
GROUP BY 
	product_type
ORDER BY 
	total_sales DESC
LIMIT 10;


-- 6. Sales Analysis by days
SELECT
	day_name,
    ROUND(SUM(revenue)) AS total_sales
FROM transactions
GROUP BY 
	day_name
ORDER BY 
	total_sales DESC;


-- 7. Sales Analysis by hours
SELECT
	`hour`,
    ROUND(SUM(revenue)) AS total_sales
FROM transactions 
GROUP BY 
	`hour`
ORDER BY 
	total_sales DESC;
































