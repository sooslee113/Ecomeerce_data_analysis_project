WITH TEMP AS(
SELECT
      DISTINCT
            CustomerID,
            FORMAT_DATE("%Y-%m", InvoiceDate) AS purchase_month
FROM
      `prime_career.ecommerce_data`
WHERE 
      CustomerID IS NOT NULL AND
      InvoiceNo NOT LIKE "C%" AND
      (Quantity > 0 AND Quantity < 74215) AND
      UnitPrice > 0      
ORDER BY
      CustomerId, purchase_month
), cohort AS (
SELECT
      CustomerID,
      MIN(purchase_month) AS first_month
FROM
      TEMP
GROUP BY
      CustomerID
), first_month AS (
SELECT
      first_month,
      COUNT(DISTINCT CustomerID) AS new_customer_cnt
FROM
      cohort
GROUP BY
      first_month
), repurchase_month AS (
SELECT
      first_month,
      purchase_month,
      COUNT(DISTINCT T.CustomerID) AS purchase_cnt
FROM
      TEMP t
JOIN
      cohort C ON T.CustomerID = C.CustomerID
GROUP BY
      first_month, purchase_month 
ORDER BY 
      first_month, purchase_month
)
SELECT
      R.first_month AS cohort_month,
      purchase_month AS repurchase_month,
      DATE_DIFF(
            PARSE_DATE('%Y-%m', purchase_month),
            PARSE_DATE('%Y-%m', R.first_month),
            MONTH
      ) AS MONTH_DIFF,
      F.new_customer_cnt,
      purchase_cnt,
      ROUND(purchase_cnt / F.new_customer_cnt * 100, 2) AS retention_rate   
FROM
      repurchase_month R
JOIN 
      first_month F ON F.first_month = R.first_month
WHERE R.first_month != '2011-11' -- 2011년 11월 Cohort 제거
AND purchase_month != '2011-12' -- 2011년 12월 구매이력 제거
ORDER BY 
      cohort_month, purchase_month