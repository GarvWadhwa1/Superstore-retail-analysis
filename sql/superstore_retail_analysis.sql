-- ============================================================
-- Superstore Retail Sales Analysis (2019-2020) | MySQL
-- Author: Garv Wadhwa
-- Sections: data checks, business performance, category, region,
-- customer, time, shipping/returns, payment mode, margin analysis,
-- margin erosion 2019 vs 2020
-- ============================================================

CREATE DATABASE IF NOT EXISTS retail_analytics;

USE retail_analytics;


SELECT COUNT(*) AS total_records
FROM superstore_staging;

SELECT *
FROM superstore_staging
LIMIT 100;


SELECT COUNT(*)
FROM retail_analytics.superstore_staging
WHERE `Order ID`IS NULL;

SELECT
    COUNT(*) - COUNT(`Row ID`) AS Row_ID,
    COUNT(*) - COUNT(`Order ID`) AS Order_ID,
    COUNT(*) - COUNT(`Order Date`) AS Order_Date,
    COUNT(*) - COUNT(`Ship Date`) AS Ship_Date,
    COUNT(*) - COUNT(`Sales`) AS Sales,
    COUNT(*) - COUNT(`Profit`) AS Profit,
    COUNT(*) - COUNT(`Returns`) AS Returns
FROM superstore_staging;

SELECT
    `Returns`,
    COUNT(*) AS total
FROM superstore_staging
GROUP BY `Returns`;

SELECT (`Row ID`),
      COUNT(*) AS Duplicate_count
FROM retail_analytics.superstore_staging
GROUP BY `Row ID`
HAVING COUNT(*)>1;

SELECT
    COUNT(DISTINCT `Order ID`) AS unique_orders,
    COUNT(*) AS total_records
FROM superstore_staging;

SELECT
      MIN(STR_TO_DATE(`Order Date`,"%d-%m-%Y")) AS First_order_date,
      MAX(STR_TO_DATE(`Order Date`,"%d-%m-%Y")) AS Last_order_date
FROM retail_analytics.superstore_staging;

SELECT
    Sum(CASE WHEN CAST(`Sales` AS DECIMAL(12,2)) <= 0 THEN 1 ELSE 0 END) AS invalid_sales,
    sum(CASE WHEN CAST(`Quantity` AS DECIMAL(12,2)) <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,
    sum(CASE WHEN CAST(`Profit` AS DECIMAL(12,2)) < 0 THEN 1 ELSE 0 END) AS negative_profit
FROM retail_analytics.superstore_staging;

DESCRIBE retail_analytics.superstore_staging;

-- Business performance analysis
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT `Customer ID`) AS total_customers,
    ROUND(SUM(`Sales`), 2) AS total_sales,
    ROUND(SUM(`Profit`), 2) AS total_profit,
    ROUND(
        SUM(`Profit`) / SUM(`Sales`) * 100,
        2
    ) AS overall_profit_margin
FROM retail_analytics.superstore_staging;

SELECT AVG(`Sales`) AS AVG_SALES
FROM retail_analytics.superstore_staging;

SELECT
    ROUND(
        (SUM(`Profit`) / SUM(`Sales`)) * 100,
        2
    ) AS overall_profit_margin
FROM retail_analytics.superstore_staging;

-- Average Order Value
SELECT
    ROUND(SUM(Sales) / COUNT(DISTINCT `Order ID`), 2) AS Average_Order_Value
FROM retail_analytics.superstore_staging;


-- Category and product analysis

-- What are the total sales and total profit?
SELECT Category,
       ROUND(SUM(Sales),2) AS Total_sales,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM retail_analytics.superstore_staging
GROUP BY Category
ORDER BY Total_sales DESC,
         Total_profit DESC;

-- Which products generate the highest sales? Show the top 10.
SELECT `Product Name`,
       ROUND(SUM(Sales),2) AS Total_sales
FROM retail_analytics.superstore_staging
GROUP BY `Product Name`
ORDER BY Total_sales DESC
LIMIT 10;

-- Which products are generating losses?
SELECT `Product Name`,
      ROUND(SUM(Profit),2) AS Total_Profit
FROM retail_analytics.superstore_staging
GROUP BY `Product Name`
HAVING SUM(Profit) < 0
ORDER BY Total_Profit;

-- Regional analysis
-- Which state generates the highest profit?
SELECT State,
       ROUND(SUM(Profit),2) AS Total_profit
FROM retail_analytics.superstore_staging
GROUP BY State
ORDER BY Total_profit DESC
LIMIT 1;

-- HIGHEST PROFIT BY STATE OF CENTRAL REGION
 SELECT State,
       Region,
       ROUND(SUM(Profit),2) AS Total_profit
FROM retail_analytics.superstore_staging
WHERE Region="CENTRAL"
GROUP BY State,
         Region
ORDER BY Total_profit DESC
LIMIT 1;

-- What are the total sales in each region?
SELECT Region,
       ROUND(SUM(Sales),2) AS Total_sales
FROM retail_analytics.superstore_staging
GROUP BY Region
ORDER BY Total_sales DESC;

-- Which city has the highest sales?
SELECT City,
      ROUND(SUM(Sales),2) AS Total_sales
FROM retail_analytics.superstore_staging
GROUP BY City
ORDER BY Total_sales DESC
LIMIT 1;

-- Which regions have negative total profit?
SELECT Region,
	   ROUND(SUM(Profit),2) AS Total_profit
FROM retail_analytics.superstore_staging
GROUP BY Region
HAVING SUM(Profit)<0
ORDER BY Total_profit;

-- Compare sales and profit across regions.
SELECT
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_analytics.superstore_staging
GROUP BY Region
ORDER BY Total_Sales DESC;

-- Customer analysis
-- How many customers are there in each segment?
SELECT Segment,
       COUNT(DISTINCT `Customer ID`) AS Customer_Cnt
FROM retail_analytics.superstore_staging
GROUP BY Segment
ORDER BY Customer_Cnt Desc;

-- Which customer generates the highest sales?
SELECT `Customer ID`,
        `Customer Name`,
        ROUND(SUM(Sales),2) AS Highest_sales
FROM retail_analytics.superstore_staging
GROUP BY `Customer ID`,
        `Customer Name`
ORDER BY Highest_sales DESC
LIMIT 1;

-- Who are the top 10 customers by profit?
SELECT `Customer ID`,
        `Customer Name`,
        ROUND(SUM(Profit),2) AS Total_profit
FROM retail_analytics.superstore_staging
GROUP BY `Customer ID`,
        `Customer Name`
ORDER BY Total_profit DESC
LIMIT 10;

-- What is the average sales amount per customer?
SELECT `Customer ID`,
        `Customer Name`,
        ROUND(AVG(Sales),2) AS  Avg_Line_Item_Sales_Per_Customer
FROM retail_analytics.superstore_staging
GROUP BY `Customer ID`,
        `Customer Name`
ORDER BY Avg_Line_Item_Sales_Per_Customer DESC;


SELECT
    ROUND(
        SUM(customer_sales) / COUNT(*),
        2
    ) AS Avg_Total_Sales_Per_Customer
FROM (
    SELECT
        `Customer ID`,
        SUM(Sales) AS customer_sales
    FROM retail_analytics.superstore_staging
    GROUP BY `Customer ID`
) AS customer_summary;

-- Which segment generates the highest total profit?
SELECT
    Segment,
    SUM(Profit) AS Total_Profit
FROM retail_analytics.superstore_staging
GROUP BY Segment
ORDER BY Total_Profit DESC;


-- Time-based analysis
-- What are the total sales for each year?
SELECT
YEAR(STR_TO_DATE(`Order Date`,"%d-%m-%Y")) AS Order_year,
ROUND(SUM(Sales),2) AS Total_sales
FROM retail_analytics.superstore_staging
GROUP BY Order_year
ORDER BY Order_year;

-- What are the monthly sales trends?
SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 1 THEN Sales ELSE 0 END), 2) AS Jan,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2 THEN Sales ELSE 0 END), 2) AS Feb,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 3 THEN Sales ELSE 0 END), 2) AS Mar,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 4 THEN Sales ELSE 0 END), 2) AS Apr,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 5 THEN Sales ELSE 0 END), 2) AS May,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 6 THEN Sales ELSE 0 END), 2) AS Jun,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 7 THEN Sales ELSE 0 END), 2) AS Jul,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 8 THEN Sales ELSE 0 END), 2) AS Aug,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 9 THEN Sales ELSE 0 END), 2) AS Sep,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 10 THEN Sales ELSE 0 END), 2) AS Oct,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 11 THEN Sales ELSE 0 END), 2) AS Nov,

    ROUND(SUM(CASE WHEN MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 12 THEN Sales ELSE 0 END), 2) AS `Dec`

FROM retail_analytics.superstore_staging
GROUP BY Order_Year
ORDER BY Order_Year;

-- Which month has the highest sales?
WITH Monthly_Sales AS (
    SELECT
        YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,
        MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Month_Number,
        MONTHNAME(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Month_Name,
        ROUND(SUM(Sales), 2) AS Total_Sales
    FROM retail_analytics.superstore_staging
    WHERE YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) IN (2019, 2020)
    GROUP BY
        Order_Year,
        Month_Number,
        Month_Name
),
Ranked_Months AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Order_Year
            ORDER BY Total_Sales DESC
        ) AS Sales_Rank
    FROM Monthly_Sales
)
SELECT
    Order_Year,
    Month_Name,
    Total_Sales
FROM Ranked_Months
WHERE Sales_Rank = 1
ORDER BY Order_Year;


-- Compare sales and profit by year.
SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS YEARS,
    MONTHNAME(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS MONTH_N,
    ROUND(SUM(Sales), 2) AS Total_sales,
    ROUND(SUM(Profit), 2) AS Total_profit
FROM retail_analytics.superstore_staging
WHERE YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) IN(2019,2020)
GROUP BY
    YEARS,
    MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')),
    MONTH_N
ORDER BY
    MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) ASC;

-- Calculate month-wise profit margin.
SELECT
      MONTHNAME(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS MONTH_NAME,
      ROUND(SUM(Sales), 2) AS Total_sales,
     ROUND(SUM(Profit), 2) AS Total_profit,
     ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM retail_analytics.superstore_staging
WHERE YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2019
GROUP BY   MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')),
         MONTH_NAME
ORDER BY
          MONTH(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) ASC;

-- Shipping and returns analysis
-- How many orders use each shipping mode?
SELECT `Ship Mode`,
        COUNT(DISTINCT `Order ID`) AS Total_orders
FROM retail_analytics.superstore_staging
GROUP BY `Ship Mode`
ORDER BY Total_orders DESC;

-- What is the average shipping time?
SELECT AVG(`Shipping Days`) AS Avg_shipping_days
FROM retail_analytics.superstore_staging;

-- Which shipping mode generates the highest sales?
SELECT `Ship Mode`,
       ROUND(SUM(Sales),2) AS Total_sales
FROM retail_analytics.superstore_staging
GROUP BY `Ship Mode`
ORDER BY Total_sales DESC
LIMIT 1;

-- How many records are marked as returned?
SELECT COUNT(*) AS Returns_cnt
FROM retail_analytics.superstore_staging
WHERE Returns = 1;

-- Compare profit for returned and non-returned records.
SELECT
CASE
    WHEN Returns = 1 THEN 'Returned'
    WHEN Returns = 0 OR Returns IS NULL THEN 'Non-Returned'
    ELSE 'Unknown'
END AS Return_Status,
  COUNT(*) AS Total_Records,
  ROUND(SUM(Profit),2) AS Total_profit
FROM retail_analytics.superstore_staging
GROUP BY Return_Status;

-- Count returned records and distinct returned orders
SELECT
    COUNT(*) AS Returned_Records,
    COUNT(DISTINCT `Order ID`) AS Returned_Orders
FROM retail_analytics.superstore_staging
WHERE Returns = 1;

-- Payment Mode Analysis
-- -- How many orders are made through each payment mode?
SELECT
    `Payment Mode`,
    COUNT(DISTINCT `Order ID`) AS Total_Orders
FROM retail_analytics.superstore_staging
GROUP BY `Payment Mode`
ORDER BY Total_Orders DESC;

-- Which payment mode generates the highest total sales?
SELECT `Payment Mode`,
       ROUND(SUM(Sales),2) AS Total_sales
FROM retail_analytics.superstore_staging
GROUP BY `Payment Mode`
ORDER BY  Total_sales DESC;

-- Which payment mode generates the highest total profit?
 SELECT `Payment Mode`,
       ROUND(SUM(Profit),2) AS Total_Profit
FROM retail_analytics.superstore_staging
GROUP BY `Payment Mode`
ORDER BY  Total_Profit DESC;

-- What is the average sales value for each payment mode?
SELECT `Payment Mode`,
       ROUND(AVG(Sales),2) AS Avg_Line_Item_Sales
FROM retail_analytics.superstore_staging
GROUP BY `Payment Mode`
ORDER BY  Avg_Line_Item_Sales DESC;

-- Which payment mode has the highest profit margin?
SELECT
    `Payment Mode`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM retail_analytics.superstore_staging
GROUP BY `Payment Mode`
ORDER BY Profit_Margin_Percent DESC;

-- Average Order Value by Payment Mode
SELECT
    `Payment Mode`,
    ROUND(
        SUM(Sales) / COUNT(DISTINCT `Order ID`),
        2
    ) AS Average_Order_Value
FROM retail_analytics.superstore_staging
GROUP BY `Payment Mode`
ORDER BY Average_Order_Value DESC;

-- Profit Margin Analysis

-- Profit Margin by Payment Mode
SELECT
    `Payment Mode`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) / SUM(Sales) * 100,
        2
    ) AS Profit_Margin_Percentage
FROM retail_analytics.superstore_staging
GROUP BY `Payment Mode`
ORDER BY Profit_Margin_Percentage DESC;

-- Category-wise Sales, Profit and Profit Margin
SELECT
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)
        AS Profit_Margin_Percentage
FROM retail_analytics.superstore_staging
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Sub-Category Sales, Profit and Profit Margin
SELECT
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)
        AS Profit_Margin_Percentage
FROM retail_analytics.superstore_staging
GROUP BY `Sub-Category`
ORDER BY Total_Sales DESC;

-- Year Wise Analysis

-- Year-wise Business Performance
SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)
        AS Profit_Margin_Percentage
FROM retail_analytics.superstore_staging
GROUP BY YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y'))
ORDER BY Order_Year;

-- Year-over-Year Sales and Profit Growth
WITH Yearly_Performance AS (
    SELECT
        YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,
        SUM(Sales) AS Total_Sales,
        SUM(Profit) AS Total_Profit
    FROM retail_analytics.superstore_staging
    GROUP BY YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y'))
),
Growth_Analysis AS (
    SELECT
        Order_Year,
        Total_Sales,
        Total_Profit,
        LAG(Total_Sales) OVER (ORDER BY Order_Year) AS Previous_Year_Sales,
        LAG(Total_Profit) OVER (ORDER BY Order_Year) AS Previous_Year_Profit
    FROM Yearly_Performance
)
SELECT
    Order_Year,
    ROUND(Total_Sales, 2) AS Total_Sales,
    ROUND(Total_Profit, 2) AS Total_Profit,
    ROUND(
        (Total_Sales - Previous_Year_Sales)
        / Previous_Year_Sales * 100, 2
    ) AS Sales_Growth_Percentage,
    ROUND(
        (Total_Profit - Previous_Year_Profit)
        / Previous_Year_Profit * 100, 2
    ) AS Profit_Growth_Percentage
FROM Growth_Analysis
ORDER BY Order_Year;

-- Advance Analysis
SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Year,
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) / SUM(Sales) * 100, 2
    ) AS Profit_Margin
FROM retail_analytics.superstore_staging
GROUP BY
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')),
    Category
ORDER BY Year, Category;

SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Year,
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2)
        AS Profit_Margin
FROM retail_analytics.superstore_staging
GROUP BY
    Year,
    Category,
    `Sub-Category`
ORDER BY
    Category,
    `Sub-Category`,
    Year;

-- Cities with loss-making line items, by year
SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,
    City,
    ROUND(SUM(Profit), 2) AS Total_Loss
FROM retail_analytics.superstore_staging
WHERE YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) IN (2019, 2020)
  AND Profit < 0
GROUP BY Order_Year, City
ORDER BY Order_Year, Total_Loss;

SELECT
    City,

    SUM(CASE
        WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2019
        THEN Profit
        ELSE 0
    END) AS Profit_2019,

    SUM(CASE
        WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2020
        THEN Profit
        ELSE 0
    END) AS Profit_2020

FROM retail_analytics.superstore_staging

GROUP BY City

HAVING Profit_2019 < 0 AND Profit_2020 < 0

ORDER BY Profit_2019, Profit_2020;

-- ============================================================
-- Margin Erosion Analysis: why did margin fall in 2020?
-- Finding: sales +77% but profit +14%, margin 14.5% -> 9.3%
-- ============================================================

-- 1) Margin by region and year (South fell sharply; Central is distorted, see 5-7)
SELECT
    Region,
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Percent
FROM retail_analytics.superstore_staging
GROUP BY Region, Order_Year
ORDER BY Region, Order_Year;

-- 2) Region margin 2019 vs 2020 side by side (conditional aggregation)
SELECT
    Region,
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2019 THEN Profit END)
        / SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2019 THEN Sales END) * 100, 2) AS Margin_2019,
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2020 THEN Profit END)
        / SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2020 THEN Sales END) * 100, 2) AS Margin_2020
FROM retail_analytics.superstore_staging
GROUP BY Region
ORDER BY Region;

-- 3) Category share of yearly sales (product mix shift to Office Supplies)
SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Sales) / SUM(SUM(Sales)) OVER (PARTITION BY YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y'))) * 100, 2) AS Sales_Share_Percent
FROM retail_analytics.superstore_staging
GROUP BY Order_Year, Category
ORDER BY Order_Year, Sales_Share_Percent DESC;

-- 4) Sub-category margin 2019 vs 2020 (Binders, Paper fell; Tables, Machines loss-making)
SELECT
    `Sub-Category`,
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2019 THEN Profit END)
        / SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2019 THEN Sales END) * 100, 2) AS Margin_2019,
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2020 THEN Profit END)
        / SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2020 THEN Sales END) * 100, 2) AS Margin_2020
FROM retail_analytics.superstore_staging
GROUP BY `Sub-Category`
ORDER BY Margin_2020;

-- 5) Data quality check: rows where profit is greater than sales (not possible in real retail)
SELECT
    COUNT(*) AS rows_profit_gt_sales,
    ROUND(SUM(Profit), 2) AS their_profit,
    ROUND(SUM(Sales), 2) AS their_sales
FROM retail_analytics.superstore_staging
WHERE Profit > Sales;

-- 6) Re-test: yearly margin without those rows (decline still holds: about 11.9% to 8.0%)
SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS Order_Year,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Percent
FROM retail_analytics.superstore_staging
WHERE Profit <= Sales
GROUP BY Order_Year
ORDER BY Order_Year;

-- 7) Re-test: region margin 2019 vs 2020 without those rows
-- (South still falls sharply; Central's 2019 margin was inflated by the bad rows)
SELECT
    Region,
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2019 THEN Profit END)
        / SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2019 THEN Sales END) * 100, 2) AS Margin_2019,
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2020 THEN Profit END)
        / SUM(CASE WHEN YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) = 2020 THEN Sales END) * 100, 2) AS Margin_2020
FROM retail_analytics.superstore_staging
WHERE Profit <= Sales
GROUP BY Region
ORDER BY Region;
