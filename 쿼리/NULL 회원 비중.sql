WITH TEMP AS
(
SELECT
      *
FROM
    `prime_career.ecommerce_data`
WHERE
    InvoiceNo NOT LIKE "C%" AND
    (Quantity > 0 AND Quantity < 74215) AND
    UnitPrice > 0
), null_customer AS (
SELECT
        FORMAT_DATE("%Y-%m", InvoiceDate) AS date_month,
        COUNT(DISTINCT InvoiceNo) AS null_purchase_cnt,
        SUM(UnitPrice * Quantity) AS null_revenue
FROM
        TEMP
WHERE
        CustomerID IS NULL
GROUP BY
        FORMAT_DATE("%Y-%m", InvoiceDate)

), total_stat AS (
SELECT
        FORMAT_DATE("%Y-%m", InvoiceDate) AS date_month,
        COUNT(DISTINCT InvoiceNo) AS total_cnt_invoice,
        SUM(UnitPrice * Quantity) AS total_revenue
FROM
        TEMP T
GROUP BY
        FORMAT_DATE("%Y-%m", InvoiceDate)
)
SELECT
        T.date_month,
        ROUND(MAX(null_purchase_cnt) / MAX(total_cnt_invoice) * 100, 2) AS null_purchase_rate,
        ROUND(MAX(N.null_revenue) / MAX(T.total_revenue) * 100, 2) AS null_revenue_rate,
        ROUND(MAX(N.null_revenue) / MAX(N.null_purchase_cnt), 2) AS null_AOV
FROM
        total_stat T
JOIN
        null_customer N ON T.date_month = N.date_month
GROUP BY
        date_month
ORDER BY 
        date_month