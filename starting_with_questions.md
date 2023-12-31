# Part 3: Starting with Questions
Answer the following questions and provide the SQL queries used to find the answer.

## Question 1: Which cities and countries have the highest level of transaction revenues on the site?

SQL Queries:
```sql
-- Calculating revenue by country using column total_transaction_revenue of all_sessions table
SELECT 
	country, 
	SUM(total_transaction_revenue) AS total_transaction_revenue
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
GROUP BY country
ORDER BY total_transaction_revenue DESC;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520880/sql-project/part3_q1_a_praptn.png)


```sql
-- Revenue by country/city
SELECT 
	country, 
	city,
	SUM(total_transaction_revenue) AS total_transaction_revenue
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
GROUP BY country, city
ORDER BY total_transaction_revenue DESC, country;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520881/sql-project/part3_q1_b_t2vvsr.png)

Answer:
The United States is by far the country that has the highest level of transaction revenues on the site.
Unfortunately, the majority of transactions from the United States do not state the city.
The top three cities with the highest level of transaction revenues are 
San Francisco ($1,564.32), Sunnyvale ($992.23), and Atlanta ($854.44)

## Question 2: What is the average number of products ordered from visitors in each city and country?

SQL Queries:
```sql
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
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520880/sql-project/part3_q2_a_mmimva.png)

Answer:
The United States is definitely the country with the highest average number of products ordered by visitors. 
San Francisco has the highest average (339), followed by New Work (238) and Palo Alto (213).

## Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?

SQL Queries:
```sql
-- All product categories -> 46
SELECT 
	product_category, 
	COUNT(product_category)
FROM clean_all_sessions
GROUP BY product_category
ORDER BY product_category;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520881/sql-project/part3_q3_a_ibtkfz.png)

```sql
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
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520882/sql-project/part3_q3_b_jkximc.png)

```sql
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
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520883/sql-project/part3_q3_c_koi9gw.png)

Answer:
Out of the 46 product categories available, only products of 23 categories were included in transactions.
Nest-USA was the highest type of product ordered (21), followed by Men's-T-Shirts (4).
Analyzing all the types of products ordered by city and country it was uncovered that Nest-USA was most ordered from customers from California-USA.

## Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?

SQL Queries:
```sql
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
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520883/sql-project/part3_q4_a_dwhzix.png)

SQL Queries:
```sql
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
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520884/sql-project/part3_q4_b_ailswi.png)

Answer:
Nest products are the top-selling products overall.
The top 5 top-selling products are:
1. Nest® Learning Thermostat 3rd Gen-USA - Stainless Steel (658 units)
2. Nest® Cam Outdoor Security Camera - USA (560 units)
3. Nest® Cam Indoor Security Camera - USA (408 units)
4. Leatherette Journal - (319 units)
5. Android 17oz Stainless Steel Sport Bottle - (167 units)

Therefore the Nest products are the top-selling products overall.
The top-selling product in Sydney, Australia is "Nest® Cam Indoor Security Camera - USA",
in Toronto, Canada is "Google Men's  Zip Hoodie" but interesting enough when it comes to top-selling products by 
city in the United States the "Android 17oz Stainless Steel Sport Bottle" is the highest, with 167 units sold in San Francisco.

## Question 5: Can we summarize the impact of revenue generated from each city/country?

SQL Queries:
```sql
-- Revenue percentage by country
SELECT 
	country, 
	SUM(total_transaction_revenue) AS total_transaction_revenue,
	FORMAT('%21s', Round(SUM(total_transaction_revenue) / (SELECT SUM(total_transaction_revenue) FROM clean_all_sessions) * 100, 2) || '%') AS percentage_total_sales
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
GROUP BY country
ORDER BY total_transaction_revenue DESC;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520884/sql-project/part3_q5_a_hugbzg.png)

```sql
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
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520885/sql-project/part3_q5_b_ydwzpo.png)

Answer:
The United States alone is reponsible for 92.11% of all the sales revenue.
Unfortunately, when it comes to city, 42.66% was not set on the dataset. 
San Francisco is the city with the highest revenue percentage, responsible for 10.95% of all the sales revenue, followed by Sunnyvale (6.95%) and Atlanta (5.98%).