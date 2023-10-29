-- Part 2: Data Cleaning

--------------------------------------------------------------------------------------
-- PRODUCTS TABLE
--------------------------------------------------------------------------------------
-- Look for null values
SELECT *
FROM products
WHERE NOT (products IS NOT NULL);

-- Look for duplicate skus
SELECT sku, count(*)
FROM products
GROUP BY sku
HAVING count(*) > 1;

-- TRIM sku and name columns for any extra space
-- Fill out with 0 null values from columns sentiment_score and sentiment_magnitude
-- Order table by sku
-- Create a view of the cleaned table
CREATE OR REPLACE VIEW working_products AS 
	SELECT 
		TRIM(sku) AS sku,
		TRIM(name) AS product_name,
		ordered_quantity,
		stock_level,
		restocking_lead_time,
		COALESCE(sentiment_score, 0) AS sentiment_score,
		COALESCE(sentiment_magnitude, 0) AS sentiment_magnitude
	FROM products
	ORDER BY sku;

-- Make an empty copy of the original table 
CREATE TABLE clean_products AS
TABLE products
WITH NO DATA;

-- Insert clean data from the view table into the new clean table
INSERT INTO clean_products
SELECT * FROM working_products;

-- Rename column name
ALTER TABLE clean_products
	RENAME COLUMN name TO product_name;

--------------------------------------------------------------------------------------
-- SALES REPORT TABLE
--------------------------------------------------------------------------------------
-- Look for null values
SELECT *
FROM sales_report
WHERE NOT (sales_report IS NOT NULL);

-- Look for duplicate skus
SELECT sku, count(*)
FROM sales_report
GROUP BY sku
HAVING count(*) > 1;

-- TRIM sku and name columns for any extra space
-- Calculate the ratio by dividing total_ordered / stock_level of all the null values
-- Order table by sku
-- Create a view of the cleaned table
CREATE OR REPLACE VIEW working_sales_report AS 
	SELECT 
		TRIM(sku) AS sku,
		total_ordered,
		TRIM(name) AS product_name,
		stock_level,
		restocking_lead_time,
		sentiment_score,
		sentiment_magnitude,
		CASE
			WHEN ratio IS NULL AND total_ordered = 0 THEN 0
			WHEN ratio IS NULL THEN total_ordered / stock_level
			ELSE ratio
		END AS ratio
	FROM sales_report
	ORDER BY sku;

-- Make an empty copy of the original table 
CREATE TABLE clean_sales_report AS
TABLE sales_report
WITH NO DATA;

-- Insert clean data from the view table into the new clean table
INSERT INTO clean_sales_report
SELECT * FROM working_sales_report;

-- Rename column name
ALTER TABLE clean_sales_report
	RENAME COLUMN name TO product_name;

--------------------------------------------------------------------------------------
-- SALES BY SKU TABLE
--------------------------------------------------------------------------------------
-- Look for null values
SELECT *
FROM sales_by_sku
WHERE NOT (sales_by_sku IS NOT NULL);

-- Look for duplicate skus
SELECT sku, count(*)
FROM sales_by_sku
GROUP BY sku
HAVING count(*) > 1;

SELECT *
FROM sales_by_sku
WHERE NOT EXISTS (
	SELECT *
	FROM products
	WHERE products.sku = sales_by_sku.sku
	)
	AND total_ordered != 0;
	
-- To identify orders on sales_by_sku not present on sales_report and products tables
SELECT *
FROM sales_by_sku
WHERE NOT EXISTS (
	SELECT *
	FROM sales_report
	WHERE sales_report.sku = sales_by_sku.sku
	)
	AND total_ordered != 0;
	
SELECT *
FROM sales_by_sku
WHERE NOT EXISTS (
	SELECT *
	FROM products
	WHERE products.sku = sales_by_sku.sku
	)
	AND total_ordered != 0;

-- Comparing the total ordered from sales_by_sku and sales_report
-- The difference of 5 units is the same as the orders on sales_by_sku not present on sales_report
SELECT 'total sales_by_sku' as table, SUM(total_ordered) AS total_ordered
FROM sales_by_sku
UNION ALL
SELECT 'total sales_report', SUM(total_ordered)
FROM sales_report;

-- TRIM sku for any extra space
-- Decided to remove sku 'GGOEYAXR066128' and 'GGOEGALJ057912' because they are not present in any other table
-- Order table by sku
-- Create a view of the cleaned table
CREATE OR REPLACE VIEW working_sales_by_sku AS 
	SELECT
		TRIM(sku) AS sku,
		total_ordered
	FROM sales_by_sku
	WHERE sku NOT IN ('GGOEYAXR066128', 'GGOEGALJ057912')
	ORDER BY sku;
	
-- Make an empty copy of the original table 
CREATE TABLE clean_sales_by_sku AS
TABLE sales_by_sku
WITH NO DATA;

-- Insert clean data from the view table into the new clean table
INSERT INTO clean_sales_by_sku
SELECT * FROM working_sales_by_sku;

-- To verify if the totals from both tables clean_sales_by_sku and clean_sales_report match
SELECT 'total clean_sales_by_sku' as table, SUM(total_ordered) AS total_ordered
FROM clean_sales_by_sku
UNION ALL
SELECT 'total clean_sales_report', SUM(total_ordered)
FROM clean_sales_report;

--------------------------------------------------------------------------------------
-- ANALYTICS TABLE
--------------------------------------------------------------------------------------
-- Remove all duplicate rows
-- Convert the visit_star_time to timestamp
-- Convert the time_on_site from integer to interval and add 0 for null values
-- Fill out with 0 null values from columns bounces and revenue
-- Divide revenue and unit_price columns by 1,000,000 to get the correct value
-- Create a view of the cleaned table
CREATE OR REPLACE VIEW working_analytics AS 
	SELECT 
		DISTINCT 
		visit_number,
		visit_id,
		to_timestamp(visit_start_time) AS visit_start_time,
		date,
		full_visitor_id,
		user_id,
		channel_grouping,
		social_engagement_type,
		units_sold,
		page_views,
		COALESCE(make_interval(secs => time_on_site), make_interval(secs => 0)) AS  time_on_site,
		COALESCE(bounces, 0) AS bounces,
		COALESCE(ROUND(CAST(revenue AS NUMERIC)/1000000, 2), 0) AS revenue,
		ROUND(CAST(unit_price AS NUMERIC)/1000000, 2) AS unit_price
	FROM analytics;

-- Make an empty copy of the original table 
CREATE TABLE clean_analytics AS
TABLE analytics
WITH NO DATA;

-- Alter visit_start_time, time_on_site, revenue and unit_price columns from clean_analytics table to correct data types
ALTER TABLE clean_analytics
ALTER COLUMN visit_start_time TYPE timestamp with time zone USING to_timestamp(visit_start_time);

ALTER TABLE clean_analytics
ALTER COLUMN time_on_site TYPE interval USING make_interval(time_on_site); 

ALTER TABLE clean_analytics
ALTER COLUMN revenue TYPE NUMERIC;

ALTER TABLE clean_analytics
ALTER COLUMN unit_price TYPE NUMERIC;

-- Insert clean data from the view table into the new clean table
INSERT INTO clean_analytics
SELECT * FROM working_analytics;

--------------------------------------------------------------------------------------
-- ALL SESSIONS TABLE
--------------------------------------------------------------------------------------
-- Change '(not set)' on country and product_variant columns to 'n/a'
-- Change '(not set)' and 'not available in demo dataset' on city column to 'n/a'
-- Divide total_transaction_revenue, product_price, product_revenue and transaction_revenue columns by 1,000,000 to get the correct value
-- Convert the time_on_site from integer to interval and add 0 for null values
-- Fill out with 0 null values from column product_quantity
-- Trim sku and product_name columns for any extra space
-- Clean the product_category column using CASE expression
-- Fill out with 'USD' null values from currency_code column
-- Remove '\' from the end of page_path_level_1 column
-- Create a view of the cleaned table
CREATE OR REPLACE VIEW working_all_sessions AS
	SELECT
		full_visitor_id,
		channel_grouping,
		time, -- make_interval(secs => time) not sure how to handle!
		CASE
			WHEN country = '(not set)' THEN 'n/a'
			ELSE country
		END AS country,
		CASE
			WHEN city = '(not set)' THEN 'n/a'
			WHEN city = 'not available in demo dataset' THEN 'n/a'
			ELSE city
		END AS city,
		COALESCE(ROUND(CAST(total_transaction_revenue AS NUMERIC)/1000000, 2), 0) AS total_transaction_revenue,
		transactions,
		COALESCE(make_interval(secs => time_on_site), make_interval(secs => 0)) AS  time_on_site,
		page_views,
		session_quality_dim,
		date,
		visit_id,
		type,
		product_refund_amount,
		COALESCE(product_quantity, 0) AS product_quantity,
		ROUND(CAST(product_price AS NUMERIC)/1000000, 2) AS product_price,
		COALESCE(ROUND(CAST(product_revenue AS NUMERIC)/1000000, 2), 0) AS product_revenue,
		TRIM(sku) AS SKU,
		TRIM(product_name) AS product_name,
		CASE 
			WHEN product_category = 'Home/Accessories/'
				OR product_category = 'Home/Apparel/'
				OR product_category = 'Home/Bags/'
				OR product_category = 'Home/Brands/'
				OR product_category = 'Home/Drinkware/'
				OR product_category = 'Home/Electronics/'
				OR product_category = 'Home/Clearance Sale/'
				OR product_category = 'Home/Fruit Games/'
				OR product_category = 'Home/Gift Cards/'
				OR product_category = 'Home/Lifestyle/'
				OR product_category = 'Home/Fun/'
				OR product_category = 'Home/Office/'
				OR product_category = 'Home/Shop by Brand/'
				OR product_category = 'Home/Limited Supply/'
				OR product_category = 'Home/Spring Sale!/'
				THEN RTRIM(REPLACE(product_category, 'Home/', ''), '/')
			WHEN product_category = 'Home/Kids/' THEN 'Kid''s'
			WHEN product_category = 'Home/Apparel/Kid''s/Kids-Youth/' THEN 'Kid''s-Youth'
			WHEN product_category LIKE (('Home/Apparel/Kid''s/%')) AND length(product_category) > 19 THEN RTRIM(REPLACE(product_category, 'Home/Apparel/Kid''s/', ''), '/')
			WHEN product_category = 'Wearables/Men''s T-Shirts/' THEN 'Men''s-T-Shirts'
			WHEN product_category LIKE (('Home/Apparel/Men''s/%')) AND length(product_category) > 19 THEN RTRIM(REPLACE(product_category, 'Home/Apparel/Men''s/', ''), '/')
			WHEN product_category LIKE (('Home/Apparel/Women''s/%')) AND length(product_category) > 21 THEN RTRIM(REPLACE(product_category, 'Home/Apparel/Women''s/', ''), '/')
			WHEN product_category LIKE ('Home/Accessories/%') AND length(product_category) > 17 THEN RTRIM(REPLACE(product_category, 'Home/Accessories/', ''), '/')	
			WHEN product_category LIKE ('Home/Apparel/%') AND length(product_category) > 13 THEN RTRIM(REPLACE(product_category, 'Home/Apparel/', ''), '/')
			WHEN product_category = 'Home/Bags/More Bags/' THEN 'Bags'
			WHEN product_category LIKE ('Home/Bags/%') AND length(product_category) > 10 THEN RTRIM(REPLACE(product_category, 'Home/Bags/', ''), '/')
			WHEN product_category LIKE ('Home/Brands/%') AND length(product_category) > 12 THEN RTRIM(REPLACE(product_category, 'Home/Brands/', ''), '/')
			WHEN product_category = 'Home/Electronics/Accessories/Drinkware/' THEN RTRIM(REPLACE(product_category, 'Home/Electronics/Accessories/', ''), '/')
			WHEN product_category = 'Bottles/' 
				OR product_category = 'Home/Drinkware/Mugs and Cups/' 
				OR product_category = 'Home/Drinkware/Water Bottles and Tumblers/' 
				THEN 'Drinkware'
			WHEN product_category LIKE ('Home/Drinkware/%') AND length(product_category) > 15 THEN RTRIM(REPLACE(product_category, 'Home/Drinkware/', ''), '/')
			WHEN product_category LIKE ('Home/Electronics/%') AND length(product_category) > 17 THEN RTRIM(REPLACE(product_category, 'Home/Electronics/', ''), '/')
			WHEN product_category LIKE ('Home/Lifestyle/%') AND length(product_category) > 15 THEN RTRIM(REPLACE(product_category, 'Home/Lifestyle/', ''), '/')
			WHEN product_category = 'Home/Limited Supply/Bags/Backpacks/' THEN RTRIM(REPLACE(product_category, 'Home/Limited Supply/Bags/', ''), '/')
			WHEN product_category LIKE ('Home/Limited Supply/%') AND length(product_category) > 20 THEN RTRIM(REPLACE(product_category, 'Home/Limited Supply/', ''), '/')
			WHEN product_category = 'Home/Nest/Nest-USA/' THEN RTRIM(REPLACE(product_category, 'Home/Nest/', ''), '/')
			WHEN product_category = 'Home/Office/Office Other/' THEN 'Office'
			WHEN product_category LIKE ('Home/Office/%') AND length(product_category) > 12 THEN RTRIM(REPLACE(product_category, 'Home/Office/', ''), '/')
			WHEN product_category LIKE ('Home/Shop by Brand/%') AND length(product_category) > 19 THEN RTRIM(REPLACE(product_category, 'Home/Shop by Brand/', ''), '/')
			WHEN product_category = '${escCatTitle}' OR product_category = '(not set)' THEN 'n/a'
			WHEN RIGHT(product_category, 1) = '/' THEN RTRIM(product_category, '/')
			ELSE product_category
		END AS product_category,
		CASE
			WHEN product_variant = '(not set)' THEN 'n/a'
			ELSE product_variant
		END AS product_variant,
		COALESCE(currency_code, 'USD') AS currency_code,
		item_quantity,
		item_revenue,
		COALESCE(ROUND(CAST(transaction_revenue AS NUMERIC)/1000000, 2), 0) AS transaction_revenue,
		transaction_id,
		page_title,
		search_keyword,
		RTRIM(page_path_level_1, '/') AS page_path_level_1,
		ecommerce_action_type,
		ecommerce_action_step,
		ecommerce_action_option
	FROM all_sessions;

-- Make an empty copy of the original table 
CREATE TABLE clean_all_sessions AS
TABLE all_sessions
WITH NO DATA;

-- Alter time_on_site, total_transaction_revenue, product_price, product_revenue 
-- and transaction_revenue columns from clean_all_sessions table to correct data types
ALTER TABLE clean_all_sessions
ALTER COLUMN time_on_site TYPE interval USING make_interval(time_on_site);

ALTER TABLE clean_all_sessions
ALTER COLUMN total_transaction_revenue TYPE NUMERIC;

ALTER TABLE clean_all_sessions
ALTER COLUMN product_price TYPE NUMERIC;

ALTER TABLE clean_all_sessions
ALTER COLUMN product_revenue TYPE NUMERIC;

ALTER TABLE clean_all_sessions
ALTER COLUMN transaction_revenue TYPE NUMERIC;

-- Insert clean data from the view table into the new clean table
INSERT INTO clean_all_sessions
SELECT * FROM working_all_sessions;

-- Delete unnecessary columns
ALTER TABLE clean_all_sessions
DROP COLUMN product_refund_amount, -- all nulls
DROP COLUMN item_quantity, -- all nulls
DROP COLUMN item_revenue, -- all nulls
DROP COLUMN search_keyword, -- all nulls
DROP COLUMN transaction_revenue; -- Same values as total_transaction_revenue column
