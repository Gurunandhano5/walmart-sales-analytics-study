
-- Overall sales summary

SELECT
    ROUND(SUM(Weekly_Sales), 2) AS total_sales,
    ROUND(AVG(Weekly_Sales), 2) AS average_weekly_sales,
    COUNT(*) AS total_records,
    COUNT(DISTINCT Store) AS number_of_stores
FROM walmart_sales;


-- Top 10 stores based on total sales

SELECT
    Store,
    ROUND(SUM(Weekly_Sales), 2) AS total_sales
FROM walmart_sales
GROUP BY Store
ORDER BY total_sales DESC
LIMIT 10;


-- Holiday and non-holiday sales comparison

SELECT
    CASE
        WHEN Holiday_Flag = 1 THEN 'Holiday'
        ELSE 'Non-Holiday'
    END AS week_type,
    COUNT(*) AS number_of_records,
    ROUND(AVG(Weekly_Sales), 2) AS average_weekly_sales,
    ROUND(SUM(Weekly_Sales), 2) AS total_sales
FROM walmart_sales
GROUP BY Holiday_Flag
ORDER BY average_weekly_sales DESC;


-- Contribution of the top 5 stores to total sales

WITH store_sales AS (
    SELECT
        Store,
        SUM(Weekly_Sales) AS store_total_sales
    FROM walmart_sales
    GROUP BY Store
),

top_five AS (
    SELECT
        Store,
        store_total_sales
    FROM store_sales
    ORDER BY store_total_sales DESC
    LIMIT 5
)

SELECT
    ROUND(SUM(store_total_sales), 2) AS top_5_sales,
    ROUND(
        SUM(store_total_sales) * 100.0 /
        (SELECT SUM(Weekly_Sales) FROM walmart_sales),
        2
    ) AS top_5_percentage
FROM top_five;


-- Monthly sales trend

SELECT
    Year_Month,
    ROUND(SUM(Weekly_Sales), 2) AS monthly_total_sales,
    ROUND(AVG(Weekly_Sales), 2) AS average_store_week_sales,
    COUNT(*) AS number_of_records
FROM walmart_sales
GROUP BY Year_Month
ORDER BY Year_Month;


-- Rank stores by total sales

WITH store_sales AS (
    SELECT
        Store,
        SUM(Weekly_Sales) AS total_sales
    FROM walmart_sales
    GROUP BY Store
)

SELECT
    Store,
    ROUND(total_sales, 2) AS total_sales,
    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM store_sales
ORDER BY sales_rank;


-- Month-over-month sales change

WITH monthly_sales AS (
    SELECT
        Year_Month,
        SUM(Weekly_Sales) AS monthly_sales
    FROM walmart_sales
    GROUP BY Year_Month
),

monthly_comparison AS (
    SELECT
        Year_Month,
        monthly_sales,
        LAG(monthly_sales) OVER (
            ORDER BY Year_Month
        ) AS previous_month_sales
    FROM monthly_sales
)

SELECT
    Year_Month,
    ROUND(monthly_sales, 2) AS monthly_sales,
    ROUND(previous_month_sales, 2) AS previous_month_sales,
    ROUND(
        (monthly_sales - previous_month_sales)
        * 100.0 / previous_month_sales,
        2
    ) AS mom_growth_percentage
FROM monthly_comparison
ORDER BY Year_Month;
