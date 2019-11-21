-- For each product in the database, calculate how many more orders where placed in 
-- each month compared to the previous month.

-- IMPORTANT! This is going to be a 2-day warmup! FOR NOW, assume that each product
-- has sales every month. Do the calculations so that you're comparing to the previous 
-- month where there were sales.
-- For example, product_id #1 has no sales for October 1996. So compare November 1996
-- to September 1996 (the previous month where there were sales):
-- So if there were 27 units sold in November and 20 in September, the resulting 
-- difference should be 27-7 = 7.
-- (Later on we will work towards filling in the missing months.)

-- BIG HINT: Look at the expected results, how do you convert the dates to the 
-- correct format (year and month)?


-- PART 1 (EXTRACT MONTH/DATE)

SELECT od.productid, EXTRACT(YEAR FROM OrderDate) AS year, EXTRACT(MONTH FROM OrderDate) AS month
FROM Orders o INNER JOIN OrderDetails od USING(OrderID)
ORDER BY od.productid, year, month;

-- PART 2 (ADD QUANTITY SOLD, MISSING GROUPING)

SELECT od.productid, EXTRACT(YEAR FROM OrderDate) AS year, EXTRACT(MONTH FROM OrderDate) AS month,
    SUM(quantity) OVER (PARTITION BY productid, EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate))
FROM Orders o INNER JOIN OrderDetails od USING(OrderID)
ORDER BY od.productid, year, month;

-- PART 3 (ADDED DISTINCT)

SELECT DISTINCT od.productid, EXTRACT(YEAR FROM OrderDate) AS year, EXTRACT(MONTH FROM OrderDate) AS month,
    SUM(quantity) OVER (PARTITION BY productid, EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate)) AS quantity
FROM Orders o INNER JOIN OrderDetails od USING(OrderID)
ORDER BY od.productid, year, month


--- PART 4 (ADDS LAG - PREVIOUS MONTH)

WITH product_totals_by_year_month AS (
SELECT DISTINCT od.productid, EXTRACT(YEAR FROM OrderDate) AS year, EXTRACT(MONTH FROM OrderDate) AS month,
    SUM(quantity) OVER (PARTITION BY productid, EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate)) AS quantity
FROM Orders o INNER JOIN OrderDetails od USING(OrderID)
ORDER BY od.productid, year, month
)
SELECT *, LAG(quantity,1) OVER (PARTITION BY productid)
FROM product_totals_by_year_month;

-- PART 5 (FINAL!)

WITH 
product_totals_by_year_month AS (
    SELECT DISTINCT od.productid, EXTRACT(YEAR FROM OrderDate) AS year, EXTRACT(MONTH FROM OrderDate) AS month,
        SUM(quantity) OVER (PARTITION BY productid, EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate)) AS quantity
    FROM Orders o INNER JOIN OrderDetails od USING(OrderID)
    ORDER BY od.productid, year, month),

month_to_month_product_total_comparison AS (
    WITH product_totals_by_year_month AS (
        SELECT DISTINCT od.productid, EXTRACT(YEAR FROM OrderDate) AS year, EXTRACT(MONTH FROM OrderDate) AS month,
            SUM(quantity) OVER (PARTITION BY productid, EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate)) AS quantity
        FROM Orders o INNER JOIN OrderDetails od USING(OrderID)
        ORDER BY od.productid, year, month)
    SELECT *, LAG(quantity,1) OVER (PARTITION BY productid) AS previous_month
    FROM product_totals_by_year_month
    )


SELECT *, quantity - COALESCE(previous_month,0) AS difference
FROM month_to_month_product_total_comparison;


-- ANSWER 

 productid | year | month | quantity | previous_month | difference
-----------+------+-------+----------+----------------+------------
         1 | 2014 |     8 |       63 |                |         63
         1 | 2014 |     9 |       20 |             63 |        -43
         1 | 2014 |    11 |       27 |             20 |          7
         1 | 2014 |    12 |       15 |             27 |        -12
         1 | 2015 |     1 |       34 |             15 |         19
         1 | 2015 |     3 |       15 |             34 |        -19
         1 | 2015 |     4 |       40 |             15 |         25
         1 | 2015 |     5 |        8 |             40 |        -32
         1 | 2015 |     6 |       10 |              8 |          2
         1 | 2015 |     7 |       29 |             10 |         19
         1 | 2015 |     8 |       40 |             29 |         11
         1 | 2015 |    10 |       70 |             40 |         30
         1 | 2015 |    11 |       58 |             70 |        -12
         1 | 2016 |     1 |       84 |             58 |         26
         1 | 2016 |     2 |       90 |             84 |          6
         1 | 2016 |     3 |       81 |             90 |         -9
         1 | 2016 |     4 |      104 |             81 |         23
...
