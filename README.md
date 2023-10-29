# Final Project  - Transforming and Analyzing Data with SQL

## Project/Goals
This is the final project to apply all the SQL knowledge acquired throughout the Data Analytics course.   
The goal is to create a new database in PostgreSQL from .csv files, clean the tables, explore and analyze the data, and execute a QA process.

## Process
- Create a new database and load the csv files into it.
- Create views to work on data cleaning. Once the views are clean, load them into a copy of the original table. Leave the original tables untouched.
- Explore and analyze the data using several queries to obtain useful insights.
- Develop and execute a QA process to identify risk areas.
- Generate an Entity Relationship Diagram (ERD) for the database.

## Results
After exploring and analyzing the dataset, the following insights were aquaired:
- The United States is by far the country that has the highest level of transaction revenues on the site.
    - The top three cities with the highest level of transaction revenues are San Francisco ($1,564.32), Sunnyvale ($992.23), and Atlanta ($854.44).
- The United States is the country with the highest average number of products ordered by visitors. 
    - San Francisco has the highest average (339), followed by New Work (238) and Palo Alto (213).
- Out of the 46 product categories available, only products of 23 categories were included in transactions.
    - Nest-USA was the highest type of product ordered (21), followed by Men's-T-Shirts (4).
    - Analyzing all the types of products ordered by city and country it was uncovered that Nest-USA was most ordered from customers from California-USA.
- The top 5 top-selling products are:
    1. Nest® Learning Thermostat 3rd Gen-USA - Stainless Steel (658 units)
    2. Nest® Cam Outdoor Security Camera - USA (560 units)
    3. Nest® Cam Indoor Security Camera - USA (408 units)
    4. Leatherette Journal - (319 units)
    5. Android 17oz Stainless Steel Sport Bottle - (167 units)
- The United States alone is reponsible for 92.11% of all the sales revenue.
    - Unfortunately, when it comes to city, 42.66% was not set on the dataset. 
    - San Francisco is the city with the highest revenue percentage, responsible for 10.95% of all the sales revenue, followed by Sunnyvale (6.95%) and Atlanta (5.98%).
- Even though the top channel grouping of all sessions is 'Organic Search' the top channel grouping that generated revenue was 'Referral', followed by 'Direct' and just then 'Organic Search'.
 - Only 0.067% of the distinct total number of visitors made a purchase.
 - The average page views of the 101133 visits that did not bounce is 8 pages per visit. A total of 49157 visits viewed only one page which is considered a bounce.

## Challenges
Due to the amount of incomplete data, duplicates, and inconsistencies of the dataset the most challenging part of this project was cleaning the data.

## Future Goals
If more time was available, it would probably be to further work on data cleaning to allow better insights.