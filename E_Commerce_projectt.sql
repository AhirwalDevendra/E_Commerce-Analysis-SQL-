Use E_Commerce;
Describe customers;
Describe orders;
Describe products;
Describe orderdetails;
Describe shippers;
Describe suppliers;
Describe payments;
Describe category;




-- 1.	Identify the Numbers of customers connected with the company each year.

   -- =>
   SELECT  YEAR(DateEntered) AS Year,
           COUNT(*)          AS No_Of_Customers
   FROM    customers
   GROUP BY YEAR(DateEntered);


-- 2.	Segment the customers into "New" and "Old" categories. Tag the customer as "New" if his database stored date is greater than "1st July 2020"
--  customer as "Old".Also, find the count of customers in both the categories.

-- =>
   SELECT  CASE
               WHEN DateEntered > '2020-07-01' THEN 'New'
               ELSE 'Old'
           END       AS Customer_Category,
           COUNT(*)  AS No_Of_Customers
   FROM    customers
   GROUP BY Customer_Category;


-- 3.	Identify the average order amount by each CustomerID in each month of Year "2020".

-- =>
   SELECT  CustomerID,
           MONTHNAME(OrderDate)              AS Month,
           ROUND(AVG(Total_order_amount), 2) AS Avg_Order_Amount
   FROM    orders
   WHERE   YEAR(OrderDate) = 2020
   GROUP BY CustomerID, MONTH(OrderDate), MONTHNAME(OrderDate)
   ORDER BY CustomerID, MONTH(OrderDate);


-- 4.	Identify the most selling Product in 2021. According to Number of orders .

-- =>
   SELECT  p.ProductID,
           p.Product                          AS Top_Selling_Product,
           COUNT(*)                           AS No_Of_Orders,
           ROUND(SUM(o.Total_order_amount), 2) AS Total_Order_Amount
   FROM    products     p
   JOIN    orderdetails od ON p.ProductID  = od.ProductID
   JOIN    orders       o  ON od.OrderID   = o.OrderID
   WHERE   YEAR(o.OrderDate) = 2021
   GROUP BY p.ProductID, p.Product
   ORDER BY No_Of_Orders DESC
   LIMIT 1;


-- 5.	Identify which Supplier Company supplied the least number of products;

-- =>
   SELECT  s.CompanyName                        AS Supplier,
           COUNT(DISTINCT p.ProductID)           AS No_Of_Products_Supplied
   FROM    suppliers    s
   JOIN    products     p  ON s.SupplierID  = p.SupplierID
   GROUP BY s.SupplierID, s.CompanyName
   ORDER BY No_Of_Products_Supplied
   LIMIT 1;


-- 6.  The company is tying up with a Bank for providing offers to a certain set of premium customers only.
      -- We want to know those CustomerIDs who have ordered for a total amount of more than 70000 in the past 3 months.

-- =>
   SELECT  CustomerID,
           ROUND(SUM(Total_order_amount), 2) AS Total_Order_Amount
   FROM    orders
   WHERE   OrderDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
   GROUP BY CustomerID
   HAVING  SUM(Total_order_amount) > 70000;


-- 6. The leadership wants to know which is their top-selling category and least-selling category in 2021.

-- =>
   SELECT (
       SELECT  c.CategoryName
       FROM    category     c
       JOIN    products     p  ON c.CategoryID = p.Category_id
       JOIN    orderdetails od ON p.ProductID  = od.ProductID
       JOIN    orders       o  ON o.OrderID    = od.OrderID
       WHERE   YEAR(o.OrderDate) = 2021
       GROUP BY c.CategoryName
       ORDER BY COUNT(o.OrderID) DESC
       LIMIT 1
   ) AS Most_Selling_Category,
   (
       SELECT  c.CategoryName
       FROM    category     c
       JOIN    products     p  ON c.CategoryID = p.Category_id
       JOIN    orderdetails od ON p.ProductID  = od.ProductID
       JOIN    orders       o  ON o.OrderID    = od.OrderID
       WHERE   YEAR(o.OrderDate) = 2021
       GROUP BY c.CategoryName
       ORDER BY COUNT(o.OrderID)
       LIMIT 1
   ) AS Least_Selling_Category;

------------------- OR ---------------------------

-- =>
   WITH CategorySales AS (
       SELECT  c.CategoryName,
               RANK() OVER (ORDER BY SUM(o.Total_order_amount) DESC) AS SalesRankDesc,
               RANK() OVER (ORDER BY SUM(o.Total_order_amount))      AS SalesRankAsc
       FROM    category     c
       JOIN    products     p  ON c.CategoryID = p.Category_id
       JOIN    orderdetails od ON od.ProductID = p.ProductID
       JOIN    orders       o  ON o.OrderID    = od.OrderID
       WHERE   YEAR(o.OrderDate) = 2021
       GROUP BY c.CategoryName
   )
   SELECT  MAX(CASE WHEN SalesRankDesc = 1 THEN CategoryName END) AS Top_Selling_Category,
           MAX(CASE WHEN SalesRankAsc  = 1 THEN CategoryName END) AS Least_Selling_Category
   FROM    CategorySales;


-- 8.	Identify the shipper companies whose average delivery time exceeds 3 days, so that they can be flagged for delivery performance improvement.

-- =>
   SELECT  s.CompanyName,
           ROUND(AVG(DATEDIFF(o.DeliveryDate, o.ShipDate)), 1) AS Avg_Delivery_Days
   FROM    shippers s
   JOIN    orders   o ON s.ShipperID = o.ShipperID
   GROUP BY s.ShipperID, s.CompanyName
   HAVING  AVG(DATEDIFF(o.DeliveryDate, o.ShipDate)) > 3
   ORDER BY Avg_Delivery_Days DESC;


-- 9.	Find out the Average delivery time for each category by each shipper.

-- =>
   SELECT  c.CategoryName,
           s.ShipperID,
           s.CompanyName,
           ROUND(AVG(DATEDIFF(o.DeliveryDate, o.ShipDate)), 1) AS Avg_Delivery_Time
   FROM    category     c
   JOIN    products     p  ON c.CategoryID = p.Category_id
   JOIN    orderdetails od ON od.ProductID = p.ProductID
   JOIN    orders       o  ON o.OrderID    = od.OrderID
   JOIN    shippers     s  ON o.ShipperID  = s.ShipperID
   GROUP BY c.CategoryName, s.ShipperID, s.CompanyName
   ORDER BY s.ShipperID, c.CategoryName;


-- 10.	We need to see the most used Payment method by customers such that we can tie-up with those Banks in order to attract more customers to our website

-- =>
   WITH PaymentRank AS (
       SELECT  py.PaymentType,
               COUNT(*)                                     AS Cnt,
               RANK() OVER (ORDER BY COUNT(*) DESC)         AS Rnk
       FROM    orders   o
       JOIN    payments py ON o.PaymentID = py.PaymentID
       GROUP BY py.PaymentType
   )
   SELECT  PaymentType,
           Cnt AS Usage_Count
   FROM    PaymentRank
   WHERE   Rnk = 1;

   -------------- OR ---------------------

-- =>
   SELECT  py.PaymentType,
           COUNT(*) AS Usage_Count
   FROM    orders   o
   JOIN    payments py ON o.PaymentID = py.PaymentID
   GROUP BY py.PaymentType
   ORDER BY Usage_Count DESC
   LIMIT 1;


-- 11.	Write a query to show the number of customers, number of orders placed, and total order amount per month in the year 2021. Assume that we are only interested
      --  in the monthly reports for a single year (January-December).

-- =>
   SELECT  MONTHNAME(OrderDate)                     AS Month,
           COUNT(*)                                 AS No_Of_Orders,
           COUNT(DISTINCT CustomerID)               AS No_Of_Customers,
           ROUND(SUM(Total_order_amount), 2)        AS Total_Order_Amount
   FROM    orders
   WHERE   YEAR(OrderDate) = 2021
   GROUP BY MONTH(OrderDate), MONTHNAME(OrderDate)
   ORDER BY MONTH(OrderDate);


-- 12.	Derive a monthly cumulative sum of total order amounts for the year 2021,showcase month-wise aggregation and cumulative
      -- totals for analytical purposes.

-- =>
   SELECT  Monthwise,
           ROUND(SUM(Monthly_Total) OVER (ORDER BY Month_Num), 2) AS Cumulative_Total
   FROM (
       SELECT  MONTH(OrderDate)       AS Month_Num,
               MONTHNAME(OrderDate)   AS Monthwise,
               SUM(Total_order_amount) AS Monthly_Total
       FROM    orders
       WHERE   YEAR(OrderDate) = 2021
       GROUP BY MONTH(OrderDate), MONTHNAME(OrderDate)
   ) t
   ORDER BY Month_Num;


-- 13. Find Category with highest revenue.

-- =>
   SELECT  p.Category_ID,
           c.CategoryName,
           ROUND(SUM(o.Total_order_amount), 2) AS Total_Revenue
   FROM    orders       o
   JOIN    orderdetails od ON o.OrderID    = od.OrderID
   JOIN    products     p  ON od.ProductID = p.ProductID
   JOIN    category     c  ON p.Category_ID = c.CategoryID
   GROUP BY p.Category_ID, c.CategoryName
   ORDER BY Total_Revenue DESC
   LIMIT 1;
