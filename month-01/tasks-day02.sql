-- Task 1
SELECT DISTINCT 
	customer_id,
	invoice,
	invoicedate,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY invoicedate) AS invoice_sequence
FROM bronze.online_retail_raw
WHERE customer_id IS NOT NULL
ORDER BY customer_id, invoicedate;

-- Task 2
SELECT
	country,
	SUM(quantity::NUMERIC) AS quantity_sum,
	ROW_NUMBER() OVER(ORDER BY SUM(quantity::NUMERIC) DESC) AS rw,
	RANK() OVER(  ORDER BY SUM(quantity::NUMERIC) DESC) AS rk,
	DENSE_RANK() OVER(  ORDER BY SUM(quantity::NUMERIC) DESC) AS dk
FROM bronze.online_retail_raw
GROUP BY country
ORDER BY quantity_sum DESC;

-- Task 3
WITH product_revenue AS (
    SELECT
        country,
        description,
        SUM(quantity::NUMERIC * price::NUMERIC) AS total_revenue
    FROM bronze.online_retail_raw
    GROUP BY country, description
),

ranked_products AS (
    SELECT
        country,
        description,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY country
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM product_revenue
)

SELECT
    country,
    description,
    total_revenue,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY country, product_rank;


-- Task 4
WITH invoice_totals AS (
    SELECT
        customer_id,
        invoice,
        invoicedate,
        SUM(quantity::NUMERIC * price::NUMERIC) AS total_revenue
    FROM bronze.online_retail_raw
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, invoice, invoicedate
),

ranked_invoices AS (
    SELECT
        customer_id,
        invoice,
        invoicedate,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY invoicedate, invoice
        ) AS invoice_rank
    FROM invoice_totals
)

SELECT
    customer_id,
    invoice,
    invoicedate,
    total_revenue
FROM ranked_invoices
WHERE invoice_rank = 1
ORDER BY customer_id;