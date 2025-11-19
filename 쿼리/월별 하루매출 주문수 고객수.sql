WITH real_date AS
(
  SELECT 
        DATE_ADD('2010-12-01', INTERVAL n DAY) AS order_date
  FROM
        UNNEST(GENERATE_ARRAY(0, DATE_DIFF('2011-12-09', '2010-12-01', DAY))) AS n
), parsed_data AS(
  SELECT
        InvoiceNo,
        StockCode,
        Description,
        Quantity,
        TIMESTAMP(InvoiceDate) AS InvoiceDate,
        Unitprice,
        Coalesce(CAST(CustomerID AS STRING), "Guest") AS CustomerID,
        Country,
        Quantity * unitprice AS revenue
  FROM
        `prime_career.ecommerce_data`
  WHERE
        InvoiceNo NOT LIKE "C%" AND
        (Quantity > 0 AND Quantity < 74215) AND
        UnitPrice > 0
), daily_stat AS 
(
  SELECT
        R.order_date,
        FORMAT_DATE('%Y-%m', R.order_date) AS order_month,
        COALESCE(SUM(P.revenue), 0) AS daily_revenue,
        COALESCE(COUNT(DISTINCT P.CustomerID), 0) AS daily_customers,
        COALESCE(COUNT (DISTINCT P.invoiceNo), 0) AS daily_orders
  FROM
        real_date R
  LEFT JOIN
      parsed_data P ON R.order_date = DATE(P.InvoiceDate)
  GROUP BY
      order_date, order_month
)
SELECT
    order_month,
    ROUND(AVG(daily_revenue), 2) AS avg_daily_revenue,
    ROUND(AVG(daily_customers), 2) AS avg_daily_customers,
    ROUND(AVG(daily_orders), 2) AS avg_daily_orders
FROM
    daily_stat
GROUP BY 
    order_month;
    