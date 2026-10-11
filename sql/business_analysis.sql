
-- PROJECT: E-Commerce Business Intelligence
-- FILE: business_analysis.sql
-- DATABASE: ecommerce_business_intelligence
-- TABLE: online_retail
--
-- PURPOSE:
-- Analyze sales performance, customer behavior, product
-- performance, geographic concentration, and cancellation impact.
--
-- DATA NOTES:
-- 1. Sales revenue is stored in the sales_revenue column.
-- 2. transaction_type identifies SALE, CANCELLATION,
--    INVENTORY_ADJUSTMENT, and BAD_DEBT_ADJUSTMENT records.
-- 3. Customer analyses exclude missing CustomerID values.
-- 4. Customer behavior analyses also exclude zero-price sales.
-- 5. Cancellation-value rate is NOT a customer return rate.
-- 6. December 2011 is incomplete; the dataset ends on December 9.

USE ecommerce_business_intelligence;


-- BQ1. OVERALL SALES PERFORMANCE
-- Business question:
-- What are the overall sales KPIs?

SELECT
    ROUND(SUM(sales_revenue), 2) AS total_sales_revenue,
    SUM(CASE
        WHEN transaction_type = 'SALE' THEN 1
        ELSE 0
    END) AS sales_line_items,
    SUM(CASE
        WHEN transaction_type = 'SALE' THEN quantity
        ELSE 0
    END) AS units_sold,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'SALE' THEN invoice_no
    END) AS unique_orders,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'SALE' THEN stock_code
    END) AS unique_products,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'SALE'
         AND customer_id IS NOT NULL
        THEN customer_id
    END) AS identifiable_customers
FROM online_retail;



-- BQ2. MONTHLY SALES PERFORMANCE
-- Business question:
-- How do revenue, units sold, and orders change by month?


SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS sales_month,
    ROUND(SUM(sales_revenue), 2) AS sales_revenue,
    SUM(CASE
        WHEN transaction_type = 'SALE' THEN quantity
        ELSE 0
    END) AS units_sold,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'SALE' THEN invoice_no
    END) AS unique_orders
FROM online_retail
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY sales_month;



-- BQ3. GEOGRAPHIC SALES PERFORMANCE
-- Business question:
-- Which countries contribute the most sales revenue?


SELECT
    country,
    ROUND(SUM(sales_revenue), 2) AS sales_revenue,
    SUM(CASE
        WHEN transaction_type = 'SALE' THEN quantity
        ELSE 0
    END) AS units_sold,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'SALE' THEN invoice_no
    END) AS unique_orders,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'SALE'
         AND customer_id IS NOT NULL
        THEN customer_id
    END) AS identifiable_customers
FROM online_retail
GROUP BY country
ORDER BY sales_revenue DESC;



-- BQ4. PRODUCT PERFORMANCE
-- Business question:
-- Which products generate the most sales revenue?
--
-- Note:
-- Excludes known operational/non-merchandise codes DOT, POST,
-- and M. Other stock codes are retained.


SELECT
    stock_code,
    MAX(description) AS description,
    ROUND(SUM(sales_revenue), 2) AS sales_revenue,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT invoice_no) AS unique_orders
FROM online_retail
WHERE transaction_type = 'SALE'
  AND stock_code NOT IN ('DOT', 'POST', 'M')
GROUP BY stock_code
ORDER BY sales_revenue DESC
LIMIT 20;



-- BQ5. CUSTOMER REVENUE CONCENTRATION
-- Business question:
-- Who are the top 10 identifiable customers by revenue?
--
-- Scope:
-- Positive-price sales with a known CustomerID.


SELECT
    customer_id,
    ROUND(SUM(sales_revenue), 2) AS customer_revenue,
    SUM(quantity) AS units_purchased,
    COUNT(DISTINCT invoice_no) AS unique_orders
FROM online_retail
WHERE transaction_type = 'SALE'
  AND unit_price > 0
  AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY customer_revenue DESC
LIMIT 10;


-- BQ6. CANCELLATION / NEGATIVE TRANSACTION IMPACT
-- Business question:
-- What is the value of cancellation transactions relative
-- to sales revenue?
--
-- Warning:
-- This is NOT a pure customer return rate. Cancellation records
-- can include operational and financial transactions.


SELECT
    ROUND(
        -SUM(CASE
            WHEN transaction_type = 'CANCELLATION'
            THEN revenue
            ELSE 0
        END),
        2
    ) AS cancellation_value,
    ROUND(SUM(sales_revenue), 2) AS sales_revenue,
    ROUND(
        -SUM(CASE
            WHEN transaction_type = 'CANCELLATION'
            THEN revenue
            ELSE 0
        END)
        / NULLIF(SUM(sales_revenue), 0) * 100,
        2
    ) AS cancellation_value_rate_pct,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'SALE' THEN invoice_no
    END) AS sales_orders,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'CANCELLATION' THEN invoice_no
    END) AS cancellation_invoices
FROM online_retail;



-- BQ7. AVERAGE ORDER VALUE (AOV)
-- Business question:
-- What is the average sales revenue per sales invoice?


SELECT
    ROUND(SUM(sales_revenue), 2) AS total_sales_revenue,
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'SALE' THEN invoice_no
    END) AS total_orders,
    ROUND(
        SUM(sales_revenue)
        / NULLIF(
            COUNT(DISTINCT CASE
                WHEN transaction_type = 'SALE' THEN invoice_no
            END),
            0
        ),
        2
    ) AS average_order_value
FROM online_retail;



-- BQ8. REPEAT VS. ONE-TIME CUSTOMERS
-- Business question:
-- What proportion of identifiable customers placed one order
-- versus multiple orders?
--
-- Scope:
-- Positive-price sales with a known CustomerID.


WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders
    FROM online_retail
    WHERE transaction_type = 'SALE'
      AND unit_price > 0
      AND customer_id IS NOT NULL
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM customer_orders
GROUP BY customer_type
ORDER BY customer_count DESC;



-- BQ9. REVENUE: REPEAT VS. ONE-TIME CUSTOMERS
-- Business question:
-- How much customer-attributed revenue comes from repeat
-- versus one-time customers?
--
-- Scope:
-- Positive-price sales with a known CustomerID.
-- Revenue percentages use this customer subset as the denominator.


WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders,
        SUM(sales_revenue) AS customer_revenue
    FROM online_retail
    WHERE transaction_type = 'SALE'
      AND unit_price > 0
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),

customer_types AS (
    SELECT
        customer_id,
        total_orders,
        customer_revenue,
        CASE
            WHEN total_orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS customer_type
    FROM customer_orders
)

SELECT
    customer_type,
    COUNT(*) AS customer_count,
    ROUND(SUM(customer_revenue), 2) AS total_revenue,
    ROUND(
        SUM(customer_revenue) * 100.0
        / SUM(SUM(customer_revenue)) OVER (),
        2
    ) AS revenue_percentage
FROM customer_types
GROUP BY customer_type
ORDER BY total_revenue DESC;



-- BQ10. CUSTOMER VALUE TIERS
-- Business question:
-- How is customer-attributed revenue distributed across
-- fixed revenue-based customer tiers?
--
-- Tier definitions:
-- High Value:   >= 10,000
-- Medium Value: >= 1,000 and < 10,000
-- Low Value:    < 1,000
--
-- These are descriptive thresholds, not profitability rankings.


WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(sales_revenue) AS total_revenue
    FROM online_retail
    WHERE transaction_type = 'SALE'
      AND unit_price > 0
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),

customer_tiers AS (
    SELECT
        customer_id,
        total_revenue,
        CASE
            WHEN total_revenue >= 10000 THEN 'High Value'
            WHEN total_revenue >= 1000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS value_tier
    FROM customer_revenue
)

SELECT
    value_tier,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(
        SUM(total_revenue) * 100.0
        / SUM(SUM(total_revenue)) OVER (),
        2
    ) AS revenue_percentage,
    ROUND(AVG(total_revenue), 2) AS average_customer_revenue
FROM customer_tiers
GROUP BY value_tier
ORDER BY CASE value_tier
    WHEN 'High Value' THEN 1
    WHEN 'Medium Value' THEN 2
    WHEN 'Low Value' THEN 3
END;
```