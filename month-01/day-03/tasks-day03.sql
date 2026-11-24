-- Task 1
WITH invoice_revenue AS (
    SELECT
        customer_id,
        invoice,
        SUM(quantity::NUMERIC * price::NUMERIC) AS invoice_revenue
    FROM bronze.online_retail_raw
    WHERE customer_id IS NOT NULL
      AND invoice NOT LIKE 'C%'
    GROUP BY customer_id, invoice
)
SELECT
    customer_id,
    invoice,
    invoice_revenue,
    SUM(invoice_revenue) OVER(PARTITION BY customer_id) AS customer_total_revenue,
    ROUND(
        invoice_revenue * 100.0
        / NULLIF(SUM(invoice_revenue) OVER(PARTITION BY customer_id), 0),
        2
    ) AS invoice_percentage
FROM invoice_revenue
ORDER BY customer_id, invoice;

-- Task 2
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', invoicedate) AS month,
        SUM(quantity::NUMERIC * price::NUMERIC) AS revenue
    FROM bronze.online_retail_raw
    WHERE invoice NOT LIKE 'C%'
    GROUP BY DATE_TRUNC('month', invoicedate)
)
SELECT
    month,
    revenue,

    SUM(revenue) OVER (
        ORDER BY month
    ) AS cumulative_revenue,

    SUM(revenue) OVER () AS total_revenue

FROM monthly_revenue
ORDER BY month;


-- Task 3
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', invoicedate) AS month,
        SUM(quantity::NUMERIC * price::NUMERIC) AS revenue
    FROM bronze.online_retail_raw
    WHERE invoice NOT LIKE 'C%'
    GROUP BY DATE_TRUNC('month', invoicedate)
)
SELECT
    month,
    revenue,

    SUM(revenue) OVER ( 
		PARTITION BY month
        ORDER BY month
    ) AS cumulative_revenue,

    SUM(revenue) OVER () AS total_revenue

FROM monthly_revenue
ORDER BY month;

-- Task 4
WITH invoice_revenue AS (
    SELECT
        invoice,
        country,
        SUM(quantity::NUMERIC * price::NUMERIC) AS revenue
    FROM bronze.online_retail_raw
    WHERE invoice NOT LIKE 'C%'
    GROUP BY invoice, country
),
country_averages AS (
    SELECT
        invoice,
        country,
        revenue,
        AVG(revenue) OVER(PARTITION BY country) AS avg_country_revenue
    FROM invoice_revenue
),
flagged_invoices AS (
    SELECT
        invoice,
        country,
        revenue,
        avg_country_revenue,
        CASE
            WHEN revenue > avg_country_revenue THEN 'Above Average'
            ELSE 'Not Above Average'
        END AS invoice_status
    FROM country_averages
)
SELECT *
FROM flagged_invoices
WHERE country = 'United Kingdom'
  AND invoice_status = 'Above Average'
ORDER BY revenue DESC;