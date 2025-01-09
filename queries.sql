USE assessmentnew_schema;

-- Step 1: Set the analysis date
SET @analysis_date = '2024-11-15';

-- Step 2: Calculate Recency, Frequency, and Monetary values, and segment customers
SELECT 
    `Customer ID` AS customer_id,
    -- Recency: Days since the last purchase
    DATEDIFF(@analysis_date, MAX(`Purchase Date`)) AS recency,
    
    -- Frequency: Total number of purchases by each customer
    COUNT(`Purchase Date`) AS frequency,
    
    -- Monetary: Total amount spent by each customer, removing commas and the currency symbol
    SUM(CAST(REPLACE(REPLACE(`Amount (N)`, ',', ''), '₦', '') AS DECIMAL(10, 2))) AS monetary,
    
    -- Segmentation based on Recency, Frequency, and Monetary values
    CASE
        -- High-Value Loyal: Active (recent), frequent, high spending
        WHEN DATEDIFF(@analysis_date, MAX(`Purchase Date`)) <= 35 AND COUNT(`Purchase Date`) >= 3 AND SUM(CAST(REPLACE(REPLACE(`Amount (N)`, ',', ''), '₦', '') AS DECIMAL(10, 2))) >= 100000 THEN 'High-Value Loyal'
        
        -- Occasional Buyer: Moderate recency and frequency, mid-level spending
        WHEN DATEDIFF(@analysis_date, MAX(`Purchase Date`)) > 35 AND DATEDIFF(@analysis_date, MAX(`Purchase Date`)) <= 95 AND COUNT(`Purchase Date`) >= 2 AND SUM(CAST(REPLACE(REPLACE(`Amount (N)`, ',', ''), '₦', '') AS DECIMAL(10, 2))) BETWEEN 65000 AND 135000 THEN 'Occasional Buyer'
        
        -- Low-Value Infrequent Shopper: Infrequent, low spending
        WHEN DATEDIFF(@analysis_date, MAX(`Purchase Date`)) > 90 AND COUNT(`Purchase Date`) <= 2 AND SUM(CAST(REPLACE(REPLACE(`Amount (N)`, ',', ''), '₦', '') AS DECIMAL(10, 2))) < 100000 THEN 'Low-Value Infrequent Shopper'
        
        -- Default: Uncategorized
        ELSE 'Uncategorized'
    END AS segment

FROM 
    `interview csv fmt`
GROUP BY 
    `Customer ID`
ORDER BY 
    `Customer ID`;
