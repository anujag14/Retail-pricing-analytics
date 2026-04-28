SELECT DISTINCT supermarket
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket NOT LIKE '%;%'
ORDER BY supermarket;

SELECT COUNT(DISTINCT supermarket) AS unique_supermarkets
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket NOT LIKE '%;%';

--1.Aggregation queries
--Average Price by Supermarket
SELECT 
    supermarket,
    ROUND(AVG("prices_(£)"), 2) AS avg_price,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket NOT LIKE '%;%'
GROUP BY supermarket
ORDER BY avg_price DESC;

--Category-level Insights
SELECT 
    category,
    ROUND(AVG("prices_(£)"), 2) AS avg_price,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket NOT LIKE '%;%'
GROUP BY category
ORDER BY avg_price DESC;

--Own Brand vs Branded Products
SELECT 
    own_brand,
    ROUND(AVG("prices_(£)"), 2) AS avg_price,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket NOT LIKE '%;%'
GROUP BY own_brand;

--2.Additional Queries for Deeper Analysis
--Average Price by Category
SELECT 
    category,
    ROUND(AVG("prices_(£)"), 2) AS avg_price,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket NOT LIKE '%;%'
GROUP BY category
ORDER BY avg_price DESC;

--Own Brand vs Branded Products
SELECT 
    own_brand,
    ROUND(AVG("prices_(£)"), 2) AS avg_price,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket NOT LIKE '%;%'
GROUP BY own_brand;

--Monthly Price Trends
SELECT 
    year,
    month,
    ROUND(AVG("prices_(£)"), 2) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket NOT LIKE '%;%'
GROUP BY year, month
ORDER BY year, month;

--3.Premium Products Analysis
--Using ROW_NUMBER() to Select One Entry per Product
SELECT supermarket, names, price
FROM (
    SELECT 
        supermarket,
        names,
        "prices_(£)" AS price,
        ROW_NUMBER() OVER (
            PARTITION BY supermarket, names 
            ORDER BY "prices_(£)" DESC
        ) AS rn
    FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
    WHERE "prices_(£)" > (
        SELECT AVG("prices_(£)") + 2 * STDDEV("prices_(£)")
        FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
    )
)
WHERE rn = 1
ORDER BY price DESC
LIMIT 20;

--Using GROUP BY to Aggregate Duplicates
--This provides cleaner analytical insights:
SELECT 
    supermarket,
    names,
    MAX("prices_(£)") AS price,
    COUNT(*) AS occurrences
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE "prices_(£)" > (
    SELECT AVG("prices_(£)") + 2 * STDDEV("prices_(£)")
    FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
)
GROUP BY supermarket, names
ORDER BY price DESC
LIMIT 20;

--Removing Duplicate Rows Using DISTINCT
--To display only unique premium products:
SELECT DISTINCT
    supermarket,
    names,
    "prices_(£)" AS price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE "prices_(£)" > (
    SELECT AVG("prices_(£)") + 2 * STDDEV("prices_(£)")
    FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
)
ORDER BY price DESC
LIMIT 20;

SELECT *
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
LIMIT 200000;

CREATE OR REPLACE VIEW SUPERMARKET_FORECASTING.PUBLIC.SUMMARY_BY_SUPERMARKET AS
SELECT
    supermarket,
    AVG("prices_(£)") AS avg_price,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
GROUP BY supermarket;

CREATE OR REPLACE VIEW SUPERMARKET_FORECASTING.PUBLIC.POWERBI_SUPERMARKET_SUMMARY AS
SELECT
    supermarket,
    AVG("prices_(£)") AS avg_price,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
GROUP BY supermarket;

SELECT * 
FROM SUPERMARKET_FORECASTING.PUBLIC.POWERBI_SUPERMARKET_SUMMARY;

CREATE OR REPLACE VIEW SUPERMARKET_FORECASTING.PUBLIC.POWERBI_SUPERMARKET_SUMMARY AS
SELECT
    supermarket,
    AVG("prices_(£)") AS avg_price,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_CLEAN_DATA
WHERE supermarket IN ('Aldi', 'Asda', 'Tesco', 'Morrisons', 'Sainsburys')
GROUP BY supermarket;

SELECT * 
FROM SUPERMARKET_FORECASTING.PUBLIC.POWERBI_SUPERMARKET_SUMMARY;