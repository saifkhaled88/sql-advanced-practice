-- TASK 1 

WITH invoice_totals AS (
	SELECT invoice, country , SUM(quantity::NUMERIC * price::NUMERIC) AS revenue
	FROM bronze.online_retail_raw
	WHERE invoice NOT LIKE 'C%'
	GROUP BY invoice, country
	HAVING SUM(quantity::NUMERIC * price::NUMERIC) > 0
	
)

SELECT
    country,
    ROUND(AVG(revenue),2) AS avg_invoice_revenue
FROM invoice_totals
GROUP BY country
ORDER BY avg_invoice_revenue DESC;


-- TASK 2
WITH customer_revenue AS (
	SELECT 
	customer_id,
	SUM(quantity::NUMERIC * price::NUMERIC) AS total_revenue
	FROM bronze.online_retail_raw
	WHERE customer_id IS NOT NULL
	GROUP BY customer_id
)
, 
customer_share AS (
	SELECT 
	customer_id,
	total_revenue,
	total_revenue / SUM(total_revenue) OVER() * 100 AS revenue_percentage
	FROM customer_revenue
)


SELECT 
	customer_id,
	total_revenue,
	ROUND(revenue_percentage,2) AS revenue_percentage 
FROM customer_share
ORDER BY total_revenue DESC
LIMIT 10;


-- TASK 3 ( TASK 1 REFACTOR WITH SUB-QUERIES)
SELECT
    country,
    ROUND(AVG(revenue),2) AS avg_invoice_revenue
FROM (
	SELECT invoice, country , SUM(quantity::NUMERIC * price::NUMERIC) AS revenue
	FROM bronze.online_retail_raw
	WHERE invoice NOT LIKE 'C%'
	GROUP BY invoice, country
	HAVING SUM(quantity::NUMERIC * price::NUMERIC) > 0
	)
GROUP BY country
ORDER BY avg_invoice_revenue DESC;



-- TASK 4
WITH RECURSIVE dates AS (
    SELECT DATE '2010-12-01' AS sales_date

    UNION ALL

    SELECT sales_date + 1
    FROM dates
    WHERE sales_date < DATE '2010-12-07'
),

daily_revenue AS (
    SELECT
        invoicedate::DATE AS sales_date,
        SUM(quantity::NUMERIC * price::NUMERIC) AS revenue
    FROM bronze.online_retail_raw
    GROUP BY invoicedate::DATE
)

SELECT
    d.sales_date,
    COALESCE(r.revenue, 0) AS daily_revenue
FROM dates d
LEFT JOIN daily_revenue r
    ON d.sales_date = r.sales_date
ORDER BY d.sales_date;

