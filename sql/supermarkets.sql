-- Counting rows in dataset
SELECT COUNT(*) 
FROM SUPERMARKET_FORECASTING.PUBLIC."RAW_SAMPLE_COMBINED";

-- Creating a new table named Processed Data
CREATE OR REPLACE TABLE SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA AS
SELECT 
    *,
    
    "prices_(£)" AS price_clean,
    
    CASE 
        WHEN "prices_(£)" > 10 THEN 'High'
        ELSE 'Low'
    END AS price_category

FROM SUPERMARKET_FORECASTING.PUBLIC."RAW_SAMPLE_COMBINED"
WHERE "prices_(£)" IS NOT NULL;

SELECT COUNT(*) 
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA;

--1. Distribution & Summary
--Price distribution buckets
SELECT 
    CASE 
        WHEN price_clean < 2 THEN 'Very Low'
        WHEN price_clean BETWEEN 2 AND 5 THEN 'Low'
        WHEN price_clean BETWEEN 5 AND 10 THEN 'Medium'
        ELSE 'High'
    END AS price_range,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY price_range
ORDER BY total_products DESC;

--Average price per unit
SELECT 
    unit,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY unit
ORDER BY avg_price DESC;

--2. Business Insights
--Top 5 most expensive supermarkets
SELECT 
    supermarket,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY supermarket
ORDER BY avg_price DESC
LIMIT 5;

--Cheapest 5 supermarkets
SELECT 
    supermarket,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY supermarket
ORDER BY avg_price ASC
LIMIT 5;

--Most expensive category
SELECT 
    category,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY category
ORDER BY avg_price DESC
LIMIT 1;

--3. Advanced Analytics
--Standard deviation (price variability)
SELECT 
    category,
    AVG(price_clean) AS avg_price,
    STDDEV(price_clean) AS price_variability
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY category
ORDER BY price_variability DESC;

--Detect premium products
SELECT *
FROM (
    SELECT 
        supermarket,
        category,
        price_clean,
        ROW_NUMBER() OVER (
            PARTITION BY supermarket 
            ORDER BY price_clean DESC
        ) AS rank
    FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
) t
WHERE rank <= 5;

--4. Window Functions
--Rank products by price within category
SELECT 
    category,
    price_clean,
    RANK() OVER (PARTITION BY category ORDER BY price_clean DESC) AS rank_in_category
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA;

--Running average price
SELECT 
    category,
    price_clean,
    AVG(price_clean) OVER (PARTITION BY category) AS avg_category_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA;

--5. Brand Analysis
--Own brand vs others
SELECT 
    CASE 
        WHEN own_brand = TRUE THEN 'Own Brand'
        WHEN own_brand = FALSE THEN 'Branded'
        ELSE 'Unknown'
    END AS brand_type,
    
    AVG(price_clean) AS avg_price,
    COUNT(*) AS total_products

FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY brand_type;

--Price difference by brand type
SELECT 
    own_brand,
    MIN(price_clean) AS min_price,
    MAX(price_clean) AS max_price,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY own_brand;

--6. Category + Supermarket Combination
--Average price per category per supermarket
SELECT 
    supermarket,
    category,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY supermarket, category
ORDER BY avg_price DESC;

--7. Outlier Detection
SELECT *
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
WHERE price_clean > (
    SELECT AVG(price_clean) + 2 * STDDEV(price_clean)
    FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
);

--1. Own Brand vs Branded per Supermarket
SELECT 
    supermarket,
    CASE 
        WHEN own_brand = TRUE THEN 'Own Brand'
        ELSE 'Branded'
    END AS brand_type,
    COUNT(*) AS total_products,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY supermarket, brand_type
ORDER BY supermarket, avg_price DESC;

--2. % Contribution of Own Brand
SELECT 
    supermarket,
    COUNT(CASE WHEN own_brand = TRUE THEN 1 END) * 100.0 / COUNT(*) AS own_brand_percentage
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY supermarket
ORDER BY own_brand_percentage DESC;

--3. Cheapest Own Brand vs Branded
SELECT 
    CASE 
        WHEN own_brand = TRUE THEN 'Own Brand'
        ELSE 'Branded'
    END AS brand_type,
    MIN(price_clean) AS min_price,
    MAX(price_clean) AS max_price,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY brand_type;

--4. Category-wise Brand Strategy
SELECT 
    category,
    CASE 
        WHEN own_brand = TRUE THEN 'Own Brand'
        ELSE 'Branded'
    END AS brand_type,
    COUNT(*) AS total_products,
    AVG(price_clean) AS avg_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY category, brand_type
ORDER BY category, avg_price DESC;

--5. Most Expensive Own Brand Products
SELECT 
    supermarket,
    category,
    price_clean
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
WHERE own_brand = TRUE
ORDER BY price_clean DESC
LIMIT 500;

--6. Price Gap
SELECT 
    supermarket,
    AVG(CASE WHEN own_brand = TRUE THEN price_clean END) AS own_brand_price,
    AVG(CASE WHEN own_brand = FALSE THEN price_clean END) AS branded_price,
    
    AVG(CASE WHEN own_brand = FALSE THEN price_clean END) -
    AVG(CASE WHEN own_brand = TRUE THEN price_clean END) AS price_gap

FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY supermarket
ORDER BY price_gap DESC;

--7. Rank Supermarkets by Pricing Strategy
SELECT 
    supermarket,
    AVG(price_clean) AS avg_price,
    RANK() OVER (ORDER BY AVG(price_clean) DESC) AS price_rank
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY supermarket;

--8. Which supermarket is cheapest for own brand?
SELECT 
    supermarket,
    AVG(price_clean) AS avg_own_brand_price
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
WHERE own_brand = TRUE
GROUP BY supermarket
ORDER BY avg_own_brand_price ASC
LIMIT 1;

--9. Product diversity per supermarket
SELECT 
    supermarket,
    COUNT(DISTINCT category) AS category_count,
    COUNT(*) AS total_products
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
GROUP BY supermarket
ORDER BY total_products DESC;

--10. Premium products per supermarket (balanced)
SELECT *
FROM (
    SELECT 
        supermarket,
        category,
        price_clean,
        ROW_NUMBER() OVER (
            PARTITION BY supermarket 
            ORDER BY price_clean DESC
        ) AS rank
    FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
) t
WHERE rank <= 5;

SELECT *
FROM SUPERMARKET_FORECASTING.PUBLIC.PROCESSED_DATA
LIMIT 500000;