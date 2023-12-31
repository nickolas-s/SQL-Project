# Part 4: Starting with Data

## Question 1: Find the channel groupings for customers who made a purchase

SQL Queries:
```sql
-- To visualize all channel groupings
SELECT channel_grouping, COUNT(channel_grouping)
FROM clean_all_sessions
GROUP BY channel_grouping
ORDER BY COUNT(*) DESC;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520886/sql-project/part4_q1_a_aznpln.png)

```sql
-- Channel groupings filtered by transaction revenue
SELECT 
	channel_grouping,
	COUNT(channel_grouping) AS total
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
GROUP BY channel_grouping
ORDER BY total DESC;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520887/sql-project/part4_q1_b_ts02b9.png)

Answer: 
Even though the top channel grouping of all sessions is 'Organic Search' the top channel grouping 
that generated revenue was 'Referral', followed by 'Direct' and just then 'Organic Search'.


## Question 2: What is the percentage of visitors to the site that made a purchase?

SQL Queries:
```sql
-- To find the distinct total number of visitors --> 120018
SELECT COUNT(DISTINCT(full_visitor_id))
FROM clean_analytics;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520887/sql-project/part4_q2_a_hxsdbi.png)

```sql
-- To find the distinct total number of visitors that made a purchase --> 80
SELECT COUNT(DISTINCT(full_visitor_id))
FROM clean_all_sessions
WHERE total_transaction_revenue != 0;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520887/sql-project/part4_q2_b_jcdple.png)

```sql
-- To calculate percentages of visitors who have and have not made a purchase
SELECT
	'Visitors who made a purchase' AS type_of_visitors,
	ROUND(CAST(COUNT(DISTINCT(full_visitor_id)) AS NUMERIC) / 
		  (SELECT CAST(COUNT(DISTINCT(full_visitor_id)) AS NUMERIC) FROM clean_analytics) * 100, 3) || '%' AS percentage
FROM clean_all_sessions
WHERE total_transaction_revenue != 0
UNION
SELECT
	'Visitors who have not made a purchase',
	ROUND((COUNT(DISTINCT(full_visitor_id)) - 
	(SELECT COUNT(DISTINCT(full_visitor_id))
	 FROM clean_all_sessions
	WHERE total_transaction_revenue != 0)) /  
	CAST(COUNT(DISTINCT(full_visitor_id)) AS NUMERIC) * 100, 3) || '%' 
FROM clean_analytics
ORDER BY 2;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520888/sql-project/part4_q2_c_i2ifen.png)

Answer:
Only 0.067% of the distinct total number of visitors made a purchase.

## Question 3: What is the average of page views and the total number of visits per visit that did not bounce and bounce?

SQL Queries:
```sql
SELECT
	'Not bounced' AS visit_type,
	COUNT(*) AS numer_of_visits,
	ROUND(CAST(AVG(page_views) AS NUMERIC)) AS avg_of_pages_visited
FROM 
	(SELECT DISTINCT(visit_id), page_views, bounces FROM clean_analytics)
WHERE bounces !=1
UNION
SELECT
	'Bounced' AS visit_type,
	COUNT(*) AS numer_of_visits,
	ROUND(CAST(AVG(page_views) AS NUMERIC)) AS avg_of_pages_visited
FROM 
	(SELECT DISTINCT(visit_id), page_views, bounces FROM clean_analytics)
WHERE bounces !=0
ORDER BY 1 DESC;
```
![](https://res.cloudinary.com/dnfecsurp/image/upload/v1698520888/sql-project/part4_q3_a_l2qpka.png)

Answer:
The average page views of the 101133 visits that did not bounce is 8 pages per visit.
A total of 49157 visits viewed only one page which is considered a bounce.