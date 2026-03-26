-- Data Inspection
SELECT TOP 10 * FROM SalesOrders;


-- Operational Performance Questions

-- Day 1: Which products generate the highest total revenue?
SELECT 
    Product,
    SUM(Total_Price) AS Total_Revenue, 
    ROUND(
        100.0 * SUM(Total_Price) / SUM(SUM(Total_Price)) OVER (),
        2
    ) AS Revenue_Percentage
FROM SalesOrders
GROUP BY Product
ORDER BY Total_Revenue DESC;


-- Day 2: What are the top 5 customers by total spending?
SELECT TOP 5
    RANK() OVER (ORDER BY SUM(TOTAL_PRICE) DESC) AS RANK_NUM,
    CUSTOMER_ID,
    SUM(TOTAL_PRICE) AS PRODUCT_REVENUE
FROM SALESORDERS
GROUP BY CUSTOMER_ID
ORDER BY PRODUCT_REVENUE DESC;


-- Day 3: Which regions contribute the most orders and revenue?
SELECT 
    DENSE_RANK() OVER (ORDER BY SUM(Total_Price) DESC) AS Rank_Num,
    Region,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(
        COUNT(DISTINCT Order_ID) * 100.0 
        / SUM(COUNT(DISTINCT Order_ID)) OVER (),
        2
    ) AS Order_Percentage,
    SUM(Total_Price) AS Total_Revenue,
    ROUND(
        SUM(Total_Price) * 100.0 
        / SUM(SUM(Total_Price)) OVER (),
        2
    ) AS Revenue_Percentage
FROM SalesOrders
GROUP BY Region
ORDER BY Rank_Num;


-- Day 4: What is the average order value per customer type (B2B vs B2C)?
SELECT 
    Customer_Type,
    COUNT(DISTINCT Order_ID) AS Orders,
    SUM(Total_Price) AS Revenue,
    ROUND(SUM(Total_Price) / COUNT(DISTINCT Order_ID), 2) AS AOV
FROM SalesOrders
GROUP BY Customer_Type;

-- --AOV = Avg Quantity × Avg Unit Price × (1 − Avg Discount)
WITH metrics AS (
    SELECT 
        Customer_Type,
        AVG(Quantity) AS Avg_Quantity,
        SUM(Unit_Price * Quantity) / SUM(Quantity) AS Weighted_Avg_Price,
        SUM(Discount * Quantity) / SUM(Quantity) AS Weighted_Avg_Discount
    FROM SalesOrders
    GROUP BY Customer_Type
)
SELECT *,
       Avg_Quantity 
       * Weighted_Avg_Price 
       * (1 - Weighted_Avg_Discount) AS Estimated_AOV
FROM metrics;


-- Day 5: Which category sells the highest quantity of items?
WITH CategoryTotals AS (
    SELECT 
        Category, 
        SUM(Quantity) AS Total_Quantity
    FROM SalesOrders
    GROUP BY Category
)
SELECT
    Category,
    Total_Quantity,
    ROUND(Total_Quantity * 100.0 / SUM(Total_Quantity) OVER (),2) AS Percentage_of_Total
FROM CategoryTotals
ORDER BY Total_Quantity DESC;


-- Profitability & Pricing Insight

-- Day 6: Which products have the highest average discount applied?
SELECT 
    Product,
    SUM(Quantity) AS Units_Sold,
    SUM(Total_Price) AS Revenue,
    SUM(Discount * Quantity) / SUM(Quantity) AS Weighted_Discount
FROM SalesOrders
GROUP BY Product
ORDER BY Weighted_Discount DESC;

-- Follow-up: Which products have a discount above the overall average?
SELECT 
    Product,
    Units_Sold,
    Revenue,
    Weighted_Discount 
FROM (
    SELECT 
        Product,
        SUM(Quantity) AS Units_Sold,
        SUM(Total_Price) AS Revenue,
        SUM(Discount * Quantity) / SUM(Quantity) AS Weighted_Discount
    FROM SalesOrders
    GROUP BY Product
) AS sub
WHERE Weighted_Discount >= (
    SELECT SUM(Discount * Quantity) / SUM(Quantity) FROM SalesOrders
);


-- Day 7: Does offering discounts actually increase quantity sold?
SELECT
    Discount_Status,
    Orders,
    Avg_Quantity,
    Avg_Quantity
    - MAX(CASE WHEN Discount_Status = 'No Discount' THEN Avg_Quantity END) 
      OVER() AS Quantity_Lift_vs_NoDiscount
FROM (
    SELECT 
        CASE 
            WHEN Discount > 0 THEN 'Discounted'
            ELSE 'No Discount'
        END AS Discount_Status,
        COUNT(DISTINCT Order_ID) AS Orders,
        AVG(Quantity) AS Avg_Quantity
    FROM SalesOrders
    GROUP BY 
        CASE 
            WHEN Discount > 0 THEN 'Discounted'
            ELSE 'No Discount'
        END
) t;

-- Day 7: Discount-Quantity Correlation
SELECT
    (
        COUNT(*) * SUM(CAST(Discount AS FLOAT) * Quantity)
        - SUM(CAST(Discount AS FLOAT)) * SUM(CAST(Quantity AS FLOAT))
    )
    /
    NULLIF(
        SQRT(
            (COUNT(*) * SUM(CAST(Discount AS FLOAT) * Discount)
             - POWER(SUM(CAST(Discount AS FLOAT)), 2))
            *
            (COUNT(*) * SUM(CAST(Quantity AS FLOAT) * Quantity)
             - POWER(SUM(CAST(Quantity AS FLOAT)), 2))
        ),
        0
    ) AS Discount_Quantity_Correlation
FROM SalesOrders;


-- Day 8: What is the revenue difference between discounted vs non-discounted orders?
WITH totals AS (
    SELECT 
        SUM(Total_Price) AS Total_Revenue,
        SUM(CASE WHEN Discount > 0 THEN Total_Price END) AS Discounted_Revenue,
        SUM(CASE WHEN Discount <= 0 THEN Total_Price END) AS Non_Discounted_Revenue
    FROM SalesOrders
)
SELECT
    Total_Revenue,
    Discounted_Revenue,
    Non_Discounted_Revenue,
    Discounted_Revenue - Non_Discounted_Revenue AS Revenue_Diff,
    ROUND((Discounted_Revenue / Non_Discounted_Revenue - 1) * 100, 2) AS Percent_Diff
FROM totals;


-- Day 9: Are there products where discounting reduces total revenue?
SELECT
    Product,
    SUM(Unit_Price * Quantity) AS Full_Price_Revenue,
    SUM(Total_Price) AS Actual_Revenue,
    SUM(Total_Price) - SUM(Unit_Price * Quantity) AS Revenue_Loss_due_to_Discount
FROM SalesOrders
GROUP BY Product
ORDER BY Revenue_Loss_due_to_Discount ASC;


-- Day 10: Which category gives the highest revenue per unit sold?
SELECT
    Category,
    ROUND(SUM(Unit_Price * Quantity) / SUM(Quantity), 2) AS Revenue_Per_Unit,
    ROUND(SUM(Unit_Price * Quantity), 2) AS Total_Revenue,
    ROUND(SUM(Unit_Price * Quantity) * 100.0 / SUM(SUM(Unit_Price * Quantity)) OVER(), 2) AS Revenue_Percentage
FROM SalesOrders
GROUP BY Category
ORDER BY Revenue_Per_Unit DESC;


-- Customer Behavior Analysis

-- Day 11: What percentage of total revenue comes from repeat customers?
WITH customer_order_summary AS (
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS order_count,
        SUM(Total_Price) AS customer_revenue
    FROM SalesOrders
    GROUP BY Customer_ID
)
SELECT
    SUM(customer_revenue) AS Repeat_Revenue,
    SUM(customer_revenue) * 100.0 /
        (SELECT SUM(Total_Price) FROM SalesOrders) AS Percent_Revenue_From_Repeats
FROM customer_order_summary
WHERE order_count > 1;

-- Day 11 Follow-up: Verify one-time vs repeat customer count
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers
FROM (
    SELECT Customer_ID, COUNT(DISTINCT Order_ID) AS order_count
    FROM SalesOrders
    GROUP BY Customer_ID
) t;


-- Day 12: Who is the highest-revenue customer in each region?
WITH region AS (
    SELECT 
        Region,
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Total_Order,
        SUM(Quantity) AS Total_Quantity,
        SUM(Total_Price) AS Revenue
    FROM SalesOrders
    GROUP BY Region, Customer_ID
)
SELECT 
    Region,
    Customer_ID,
    Total_Order,
    Total_Quantity,
    Revenue
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY Region ORDER BY Revenue DESC) AS rnk
    FROM region
) t
WHERE rnk = 1
ORDER BY Region;


-- Time-Based Trends

-- Day 13: How do monthly sales trends change over time?
WITH monthly AS (
    SELECT 
        YEAR(Order_Date) AS order_year,
        MONTH(Order_Date) AS order_month,
        COUNT(DISTINCT Order_ID) AS total_orders,
        SUM(Quantity) AS total_quantity,
        SUM(Total_Price) AS revenue
    FROM SalesOrders
    GROUP BY YEAR(Order_Date), MONTH(Order_Date)
)
SELECT
    *,
    total_orders - LAG(total_orders) OVER (ORDER BY order_year, order_month) AS order_change,
    total_quantity - LAG(total_quantity) OVER (ORDER BY order_year, order_month) AS quantity_change,
    revenue - LAG(revenue) OVER (ORDER BY order_year, order_month) AS revenue_change
FROM monthly
ORDER BY order_year, order_month;


-- Day 14: Which year had the highest revenue?
SELECT
	RANK() OVER (ORDER BY SUM(Total_Price) DESC) AS Revenue_Rank,
    YEAR(Order_Date) AS Year,
    SUM(Total_Price) AS Revenue
FROM SalesOrders
GROUP BY YEAR(Order_Date);


-- Day 15: What is the average daily revenue?
WITH daily_revenue AS (
    SELECT 
        Order_Date AS order_day,
        SUM(Total_Price) AS revenue
    FROM SalesOrders
    GROUP BY Order_Date
)
SELECT 
    AVG(revenue) AS avg_daily_revenue
FROM daily_revenue;


-- Day 16: For each year, which month had the highest average order value?
WITH MonthlyAOV AS (
    SELECT
        YEAR(Order_Date) AS Year,
        MONTH(Order_Date) AS Month,
        DATENAME(MONTH, Order_Date) AS Month_Name,
        ROUND(SUM(Total_Price) / COUNT(DISTINCT Order_ID), 2) AS AOV,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(Order_Date)
            ORDER BY SUM(Total_Price) / COUNT(DISTINCT Order_ID) DESC
        ) AS RN
    FROM SalesOrders
    GROUP BY 
        YEAR(Order_Date), 
        MONTH(Order_Date), 
        DATENAME(MONTH, Order_Date)
)
SELECT
    Year,
    Month,
    Month_Name,
    AOV
FROM MonthlyAOV
WHERE RN = 1
ORDER BY Year;


-- Regional Strategy Questions

-- Day 17: Which region has the highest average discount rate?
SELECT 
    Region, 
    SUM(Discount * Unit_Price * Quantity) 
    / SUM(Unit_Price * Quantity) AS Weighted_Discount_Rate 
FROM SalesOrders 
GROUP BY Region 
ORDER BY Weighted_Discount_Rate DESC;


-- Day 18: What products perform best in each region?
WITH ProductPerformance AS (
    SELECT 
        Region,
        Product,
        COUNT(DISTINCT Order_ID) AS Order_Count,
        SUM(Total_Price) AS Revenue,
        SUM(Quantity) AS Quantity_Sold
    FROM SalesOrders
    GROUP BY Region, Product
)
SELECT 
    Region,
    Product,
    Order_Count,
    Revenue,
    Quantity_Sold
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY Region ORDER BY Revenue DESC) AS rnk
    FROM ProductPerformance
) ranked
WHERE rnk = 1
ORDER BY Region;


-- Day 19: Are there regions where B2C dominates over B2B?
WITH RegionAggregates AS (
    SELECT 
        Region,
        SUM(CASE WHEN Customer_Type = 'B2B' THEN Quantity END) AS B2B_Quantity,
        SUM(CASE WHEN Customer_Type = 'B2C' THEN Quantity END) AS B2C_Quantity,
        SUM(CASE WHEN Customer_Type = 'B2B' THEN Total_Price END) AS B2B_Revenue,
        SUM(CASE WHEN Customer_Type = 'B2C' THEN Total_Price END) AS B2C_Revenue,
        COUNT(DISTINCT CASE WHEN Customer_Type = 'B2B' THEN Order_ID END) AS B2B_Order_Count,
        COUNT(DISTINCT CASE WHEN Customer_Type = 'B2C' THEN Order_ID END) AS B2C_Order_Count
    FROM SalesOrders
    GROUP BY Region
)
SELECT *,
       CASE 
           WHEN B2C_Revenue > B2B_Revenue THEN 'Revenue Dominated'
           WHEN B2C_Quantity > B2B_Quantity THEN 'Quantity Dominated'
           WHEN B2C_Order_Count > B2B_Order_Count THEN 'Orders Dominated'
       END AS Dominance_Type
FROM RegionAggregates
WHERE (B2C_Revenue > B2B_Revenue) 
   OR (B2C_Quantity > B2B_Quantity) 
   OR (B2C_Order_Count > B2B_Order_Count)
ORDER BY Region;


-- Day 20: Which region has the highest revenue per customer?
WITH RegionCustomerRevenue AS (
    SELECT 
        Region,
        Customer_ID,
        SUM(Total_Price) AS Customer_Revenue
    FROM SalesOrders
    GROUP BY Region, Customer_ID
)
SELECT 
    Region,
    ROUND(AVG(Customer_Revenue), 2) AS Avg_Revenue_Per_Customer,
    COUNT(DISTINCT Customer_ID) AS Num_Customers,
    SUM(Customer_Revenue) AS Total_Revenue
FROM RegionCustomerRevenue
GROUP BY Region
ORDER BY Avg_Revenue_Per_Customer DESC;


-- Day 21: Where should the company focus marketing based on sales performance?
WITH RegionPerformance AS (
    SELECT
        Region,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        COUNT(DISTINCT Customer_ID) AS Total_Customers,
        SUM(Total_Price) AS Total_Revenue,
        SUM(Total_Price) * 1.0 / COUNT(DISTINCT Order_ID) AS Avg_Order_Value
    FROM SalesOrders
    GROUP BY Region
),
Benchmark AS (
    SELECT
        AVG(Total_Orders) AS Avg_Orders,
        AVG(Avg_Order_Value) AS Avg_AOV
    FROM RegionPerformance
)
SELECT
    r.Region,
    r.Total_Orders,
    r.Total_Customers,
    r.Total_Revenue,
    ROUND(r.Avg_Order_Value, 2) AS Avg_Order_Value,
    ROUND(Total_Revenue * 100.0 / SUM(Total_Revenue) OVER (), 2) AS Revenue_Contribution_Percent,
    CASE
        WHEN r.Total_Orders >= b.Avg_Orders AND r.Avg_Order_Value >= b.Avg_AOV THEN 'High Value Market'
        WHEN r.Total_Orders >= b.Avg_Orders AND r.Avg_Order_Value < b.Avg_AOV THEN 'Growth Opportunity'
        WHEN r.Total_Orders < b.Avg_Orders AND r.Avg_Order_Value >= b.Avg_AOV THEN 'Emerging Market'
        ELSE 'Underdeveloped Market' 
    END AS Market_Category
FROM RegionPerformance r
CROSS JOIN Benchmark b
ORDER BY r.Total_Revenue DESC;


-- Advanced Analytical / Decision-Maker Questions

-- Day 22: Which category has declining performance over time?

WITH Monthly_Category_Performance AS (
    SELECT
        Category,
        DATEFROMPARTS(YEAR(Order_Date), MONTH(Order_Date), 1) AS Month_Start,
        SUM(Total_Price) AS Revenue
    FROM SalesOrders
    GROUP BY 
        Category,
        DATEFROMPARTS(YEAR(Order_Date), MONTH(Order_Date), 1)
),

Trend AS (
    SELECT
        Category,
        Month_Start,
        Revenue,
        Revenue - LAG(Revenue) OVER (
            PARTITION BY Category 
            ORDER BY Month_Start
        ) AS Revenue_Change
    FROM Monthly_Category_Performance
),

Decline_Summary AS (
    SELECT
        Category,
        COUNT(*) AS Total_Periods,
        COUNT(CASE WHEN Revenue_Change < 0 THEN 1 END) AS Decline_Periods
    FROM Trend
    GROUP BY Category
)

SELECT
    Category,
    Total_Periods,
    Decline_Periods,
    ROUND(Decline_Periods * 100.0 / Total_Periods, 2) AS Decline_Rate_Percentage
FROM Decline_Summary
ORDER BY Decline_Rate_Percentage DESC;


-- Day 23: Which product should be promoted based on high revenue but low sales volume?

WITH Product_Performance AS (
    SELECT
        Product,
        SUM(Total_Price) AS Total_Revenue,
        SUM(Quantity) AS Total_Quantity
    FROM SalesOrders
    GROUP BY Product
),

Ranked AS (
    SELECT
        Product,
        Total_Revenue,
        Total_Quantity,
        NTILE(4) OVER (ORDER BY Total_Revenue DESC) AS Revenue_Quartile,
        NTILE(4) OVER (ORDER BY Total_Quantity ASC) AS Quantity_Quartile
    FROM Product_Performance
)

SELECT
    Product,
    Total_Revenue,
    Total_Quantity,
    'Promote (High Revenue, Low Volume)' AS Recommendation
FROM Ranked
WHERE 
    Revenue_Quartile = 1   -- Top 25% revenue
    AND Quantity_Quartile = 1  -- Bottom 25% quantity
ORDER BY Total_Revenue DESC;


-- Day 24: Which products are frequently bought in large quantities and should be stocked more?

WITH Product_Stats AS (
    SELECT
        Product,
        COUNT(DISTINCT Order_ID) AS Order_Frequency,
        AVG(Quantity * 1.0) AS Avg_Quantity_per_Order
    FROM SalesOrders
    GROUP BY Product
),

Ranked AS (
    SELECT
        Product,
        Order_Frequency,
        Avg_Quantity_per_Order,
        NTILE(4) OVER (ORDER BY Order_Frequency DESC) AS Frequency_Quartile,
        NTILE(4) OVER (ORDER BY Avg_Quantity_per_Order DESC) AS Quantity_Quartile
    FROM Product_Stats
)

SELECT
    Product,
    Order_Frequency,
    Avg_Quantity_per_Order,
    'Stock More' AS Recommendation
FROM Ranked
WHERE 
    Frequency_Quartile = 1
    AND Quantity_Quartile = 1
ORDER BY Order_Frequency DESC;


-- Day 25: Which combination of region + category is most profitable?

WITH Region_Category AS (
    SELECT
        Region,
        Category,
        SUM(Total_Price) AS Revenue
    FROM SalesOrders
    GROUP BY Region, Category
)

SELECT
    Region,
    Category,
    Revenue,
    ROUND(
        Revenue * 100.0 / SUM(Revenue) OVER (), 2
    ) AS Revenue_Contribution_Percentage,
    RANK() OVER (ORDER BY Revenue DESC) AS Revenue_Rank
FROM Region_Category
ORDER BY Revenue DESC;
