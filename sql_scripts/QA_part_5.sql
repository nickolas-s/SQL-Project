-- Part 5: QA Your Data

-- What are your risk areas? Identify and describe them.
-- The risky areas are mostly duplicates and missing or inaccurate data.

-- 01: Identify if there are products listed on clean_sales_report table that are not listed on clean_products table.
-- 02: Check if there is more than one sku for the same product name on products table as well as duplicate and null sku.
-- 03: Check for missing cities and counties onclean_all_sessions table.


-- QA Process: Describe your QA process and include the SQL queries used to execute it.

---------------------------------------------------------------------------------------------------------------------------
-- 01: Identify if there are products listed on clean_sales_report table that are not listed on clean_products table.
---------------------------------------------------------------------------------------------------------------------------
SELECT
	sku,
	'SKU not listed on produts tb' AS reason
FROM clean_sales_report csr
WHERE NOT EXISTS (
	SELECT *
	FROM clean_products cp
	WHERE cp.sku = csr.sku
	)
UNION
SELECT
	sku,
	'SKU is null'
FROM clean_sales_report
WHERE sku IS NULL
UNION
SELECT
	sku,
	'SKU duplicated' AS reason
FROM
	(
	SELECT sku, count(*) AS count
	FROM clean_sales_report
	GROUP BY sku
	)
WHERE count > 1;

/*
The query above will show any sku that is listed on sales_report table but not listed on the products table.
It will also show any null or duplicated sku. The clean_sales_report table passed all the checks.
*/

---------------------------------------------------------------------------------------------------------------------------
-- 02: Check if there is more than one sku for the same product name on products table as well as duplicate and null sku
---------------------------------------------------------------------------------------------------------------------------
-- Query summarizing any discrepancy
WITH cte_product_names AS (
	SELECT
		name, 
		COUNT(name) AS total
	FROM products
	GROUP BY name
	HAVING COUNT(*) > 1
)
SELECT
	'Same product name diff SKU' AS description,
	SUM(total) AS total
FROM cte_product_names
UNION
SELECT
	'Duplicated SKU',
	COUNT(*)
FROM products p1
WHERE EXISTS(
	SELECT p2.sku, COUNT(*) AS count
	FROM products p2
	WHERE p1.sku = p2.sku
	GROUP BY sku
	HAVING COUNT(*) > 1
	)
UNION
SELECT
	'Null SKU',
	COUNT(*) 
FROM products 
WHERE sku IS NULL
ORDER BY 2 DESC;

-- Query to find all info regarding duplicates: sku and product name
SELECT
	p1.sku,
	TRIM(p1.name) AS product_name,
	'Duplicated SKU' AS reason
FROM products p1
WHERE EXISTS(
	SELECT p2.sku, COUNT(*) AS count
	FROM products p2
	WHERE p1.sku = p2.sku
	GROUP BY sku
	HAVING COUNT(*) > 1
	)
UNION
SELECT
	p1.sku,
	TRIM(p1.name),
	'Same product name diff SKU'
FROM products p1
WHERE EXISTS (
	SELECT
		p2.name, 
		COUNT(p2.name) AS total
	FROM products p2
	WHERE p1.name = p2.name
	GROUP BY p2.name
	HAVING COUNT(*) > 1
)
ORDER BY 2;

/*
The first query above summarizes all the discrepancies regarding missing or duplicate SKU and product names.
There are no duplicate or missing SKUs, however, there are several different SKUs for identical product names.
This flags a severe inconsistency in the dataset. There isn't enough information to fix this issue.
The second query above identifies all the products with discrepancies.
*/

---------------------------------------------------------------------------------------------------------------------------
-- 03: Check for missing cities and counties on clean_all_sessions table.
---------------------------------------------------------------------------------------------------------------------------
SELECT 
	'Missing Country and City' 
	AS category, COUNT(*) AS total
FROM clean_all_sessions
WHERE 
	country = 'n/a'
	AND city = 'n/a'
UNION
SELECT 
	'Missing just City',
	COUNT(*)
FROM clean_all_sessions
WHERE 
	country != 'n/a'
	AND city = 'n/a'
UNION
SELECT 
	'Missing just Country',
	COUNT(*)
FROM clean_all_sessions
WHERE 
	country = 'n/a'
	AND city != 'n/a';
	
/*
The query counts all the rows that just the country, just the city, and both are missing.
There are only 24 instances where both city and country are missing, however, there are 8632 instances where the city is missing.
This is a major issue for the shipping process and makes the insights from the analysis process less accurate.
*/