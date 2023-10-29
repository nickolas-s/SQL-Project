-- Part 3: Starting with Questions

--------------------------------------------------------------------------------------------------------------------------------
-- Question 1: Which cities and countries have the highest level of transaction revenues on the site?
--------------------------------------------------------------------------------------------------------------------------------

-- SQL Queries:
-- Calculating revenue by country using column total_transaction_revenue of all_sessions table
SELECT 
	country, 
	SUM(total_transaction_revenue) AS total_transaction_revenue
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
GROUP BY country
ORDER BY total_transaction_revenue DESC;

-- Revenue by country/city
SELECT 
	country, 
	city,
	SUM(total_transaction_revenue) AS total_transaction_revenue
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
GROUP BY country, city
ORDER BY total_transaction_revenue DESC, country;

-- Answer:
/*
The United States is by far the country that has the highest level of transaction revenues on the site.
Unfortunately, the majority of transactions from the United States do not state the city.
The top three cities with the highest level of transaction revenues are 
San Francisco ($1,564.32), Sunnyvale ($992.23), and Atlanta ($854.44)
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Question 2: What is the average number of products ordered from visitors in each city and country?
--------------------------------------------------------------------------------------------------------------------------------

-- SQL Queries:
SELECT 
	cas.country,
	cas.city,
	SUM(csr.total_ordered) AS total_ordered_sales_report
FROM clean_all_sessions cas
JOIN clean_sales_report csr USING(sku)
WHERE 
	cas.transactions IS NOT NULL
	AND csr.total_ordered IS NOT NULL
GROUP BY cas.country, cas.city
ORDER BY total_ordered_sales_report DESC;

-- Answer:
/*
The United States is definitely the country with the highest average number of products ordered by visitors. 
San Francisco has the highest average (339), followed by New Work (238) and Palo Alto (213).
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?
--------------------------------------------------------------------------------------------------------------------------------

-- SQL Queries:
-- All product categories -> 46
SELECT 
	product_category, 
	COUNT(product_category)
FROM clean_all_sessions
GROUP BY product_category
ORDER BY product_category;

-- Product categories that had transactions -> 23
SELECT 
	cas.product_category,
	COUNT(cas.product_category)
FROM clean_all_sessions cas
JOIN clean_sales_report csr USING(sku)
WHERE 
	cas.transactions IS NOT NULL
	AND csr.total_ordered IS NOT NULL
GROUP BY cas.product_category
ORDER BY COUNT(cas.product_category) DESC;

-- Product category by country/city
SELECT 
	cas.country,
	cas.city,
	cas.product_category,
	COUNT(cas.product_category)
FROM clean_all_sessions cas
JOIN clean_sales_report csr USING(sku)
WHERE 
	cas.transactions IS NOT NULL
	AND csr.total_ordered IS NOT NULL
GROUP BY cas.country, cas.city, cas.product_category
ORDER BY COUNT(cas.product_category) DESC;

-- Answer:
/*
Out of the 46 product categories available, only products of 23 categories were included in transactions.
Nest-USA was the highest type of product ordered (21), followed by Men's-T-Shirts (4).
Analyzing all the types of products ordered by city and country it was uncovered that Nest-USA was most ordered from customers from California-USA.
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?
--------------------------------------------------------------------------------------------------------------------------------

-- SQL Queries:
-- All products sold ordered by total sales
SELECT
	cas.sku,
	cas.product_name,
	SUM(csr.total_ordered) AS total_ordered_sales_report
FROM clean_all_sessions cas
JOIN clean_sales_report csr USING(sku)
WHERE 
	cas.transactions IS NOT NULL
	AND csr.total_ordered IS NOT NULL
GROUP BY cas.sku, cas.product_name
ORDER BY total_ordered_sales_report DESC;

-- Products sold by country/city
SELECT 
	cas.country, 
	cas.city,
	cas.sku,
	cas.product_name,
	SUM(csr.total_ordered) AS total_ordered_sales_report
FROM clean_all_sessions cas
JOIN clean_sales_report csr USING(sku)
WHERE 
	cas.transactions IS NOT NULL
	AND csr.total_ordered IS NOT NULL
GROUP BY cas.country, cas.city, cas.sku, cas.product_name
ORDER BY country, city, total_ordered_sales_report DESC;

-- Answer:
/*
Nest products are the top-selling products overall.
The top 5 top-selling products are:
#01 - Nest® Learning Thermostat 3rd Gen-USA - Stainless Steel (658 units)
#02 - Nest® Cam Outdoor Security Camera - USA (560 units)
#03 - Nest® Cam Indoor Security Camera - USA (408 units)
#04 - Leatherette Journal - (319 units)
#05 - Android 17oz Stainless Steel Sport Bottle - (167 units)
Therefore the Nest products are the top-selling products overall.
The top-selling product in Sydney, Australia is "Nest® Cam Indoor Security Camera - USA",
in Toronto, Canada is "Google Men's  Zip Hoodie" but interesting enough when it comes to top-selling products by 
city in the United States the "Android 17oz Stainless Steel Sport Bottle" is the highest, with 167 units sold in San Francisco.
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Question 5: Can we summarize the impact of revenue generated from each city/country?
--------------------------------------------------------------------------------------------------------------------------------

-- SQL Queries:
-- Revenue percentage by country
SELECT 
	country, 
	SUM(total_transaction_revenue) AS total_transaction_revenue,
	FORMAT('%21s', Round(SUM(total_transaction_revenue) / (SELECT SUM(total_transaction_revenue) FROM clean_all_sessions) * 100, 2) || '%') AS percentage_total_sales
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
GROUP BY country
ORDER BY total_transaction_revenue DESC;

-- Revenue by country/city
SELECT 
	country, 
	city,
	SUM(total_transaction_revenue) AS total_transaction_revenue,
	FORMAT('%21s', Round(SUM(total_transaction_revenue) / (SELECT SUM(total_transaction_revenue) FROM clean_all_sessions) * 100, 2) || '%') AS percentage_total_sales
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
GROUP BY country, city
ORDER BY total_transaction_revenue DESC, country;

-- Answer:
/*
The United States alone is reponsible for 92.11% of all the sales revenue.
Unfortunately, when it comes to city, 42.66% was not set on the dataset. 
San Francisco is the city with the highest revenue percentage, responsible for 10.95% of all the sales revenue, 
followed by Sunnyvale (6.95%) and Atlanta (5.98%).
*/