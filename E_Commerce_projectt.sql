
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
   select  year(DateEntered) As Year,count(*) As No_Of_Customers 
                        					From customers 
                        					        Group By  year(DateEntered);
                                                    
-- 2.	Segment the customers into “New” and “Old” categories. Tag the customer as “New” if his database stored date is greater than “1st July 2020” 
--  customer as “Old”.Also, find the count of customers in both the categories.       

-- =>    
          select CASE
                     WHEN DateEntered > '2020-07-01' THEN 'New'
                   ELSE 'Old'
                           END AS 'Customer_Category',
                                                        Count(*)
                                                        FROM customers GROUP BY Customer_Category;
            
-- 3.	Identify the average order amount by each CustomerID in each month of Year “2020”.
       
-- => 
	   SELECT customerid,
              MONTHNAME(OrderDate) AS 'Month',
              ROUND(AVG(Total_order_amount)) AS 'AVG_ORDER_AMMOUNT' 
                                                    FROM orders
                                                    WHERE year(OrderDate) = 2020
                                                    GROUP BY CustomerID,MONTHNAME(OrderDate);
                                                    
-- 4.	Identify the most selling Product in 2021. According to Number of orders .
    
-- =>   
 
    SELECT  T1.ProductId,
			T1.Product As 'Top_Selling_ProductID',
		    Count(*) AS 'NO_of_orders',
			Sum(t3.Total_order_amount) AS 'Total_of_order_AMT'
								  FROM products T1 
									JOIN orderdetails T2
										ON T1.ProductID = T2.ProductID 
									JOIN orders T3
										ON T2.orderid = T3. orderid
									            WHERE Year(T3.OrderDate)= 2021
																				GROUP BY T1.ProductId,T1.product
																				ORDER BY COUNT(*) desc 
																				LIMIT 1;

-- 5.	Identify which Supplier Company supplied the least number of products;
     
-- => 

   SELECT  T1.CompanyName As 'Least_Selling_SupplierID',
            COUNT(distinct T3.Productid ) AS 'NO_of_orders' 
                                 FROM Suppliers T1 
					 JOIN orderdetails T2
						  ON T1.SupplierID = T2.SupplierID 
					 JOIN products T3
						  ON T2.productid = T3. productid
							GROUP BY T1.CompanyName
							ORDER BY NO_of_orders
							LIMIT 1;
			
		     
                                                                        
-- 6.  The company is tying up with a Bank for providing offers to a certain set of premium customers only. 
        --We want to know those CustomerIDs who have ordered for a total amount of more than 70000 in the past 3 months.

-- =>
       
       SELECT CustomerID,
	            ROUND(SUM(Total_order_amount)) as 'Total_order_amount'
							FROM orders
								 WHERE orderdate = DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
								 GROUP BY CustomerID
								 HAVING SUM(Total_order_amount)>7000;

-- 6. The leadership wants to know which is their top-selling category and least-selling category in 2021.
      
-- =>  
        select(
	select T1.CategoryName from category T1 
          join products T2
          on T1.categoryid= T2.category_id 
          join orderdetails T3 
          on T2. productid=t3.productid
          join orders T4
          on T4.orderid=T3.orderid
          where year(orderdate)=2021
          group by T1.CategoryName order by count(T4.orderid) desc limit 1 )most_Selling_Category
          ,
          (select T1.CategoryName from category T1 
          join products T2
          on T1.categoryid= T2.category_id 
          join orderdetails T3 
          on T2. productid=T3.productid
          join orders T4
          on t4.orderid=T3.orderid
          where year(orderdate)=2021
          group by T1.CategoryName order by count(T4.orderid) limit 1)as least_selling_category;

------------------- OR ---------------------------

-- => 
        WITH CategorySales AS (
		SELECT T1.CategoryName,
			RANK() OVER (ORDER BY SUM(T4.Total_order_amount) DESC) AS SalesRankDesc,
			RANK() OVER (ORDER BY SUM(T4.Total_order_amount)) AS SalesRankAsc
				FROM Category T1
				JOIN Products T2 
					 ON T1.Categoryid = T2.Category_id
				JOIN orderdetails T3 
					 ON T3.Productid = T2.Productid
				JOIN Orders T4 
					 ON T4.orderid = T3.orderid
								WHERE YEAR(T4.orderdate) = 2021
								GROUP BY T1.CategoryName)
										SELECT 
											(SELECT CategoryName FROM CategorySales WHERE SalesRankDesc = 1) AS 'Top_Selling_Category',
											(SELECT CategoryName FROM CategorySales WHERE SalesRankAsc = 1) AS 'Least_Selling_Category';

-- 8.	8. Identify the shipper companies whose average delivery time exceeds 3 days, so that they can be flagged for delivery performance improvement.

-- =>          
         SELECT T1.CompanyName ,
                AVG(DATEDIFF(DeliveryDate,ShipDate)) AS 'AVG_Delivery_days'
        					 FROM Shippers T1						  
        							 JOIN orders T2 
        								  ON T1.Shipperid = T2.Shipperid 
        										 GROUP BY T1.CompanyName 
        										 HAVING AVG(DATEDIFF(DeliveryDate,ShipDate))>3;
						   
					
-- 9.	Find out the Average delivery time for each category by each shipper.
  
-- => 
        SELECT T1.CategoryName,T5.Shipperid,
               ROUND(AVG(DATEDIFF(DeliveryDate,ShipDate)),1) AS "Avg_DeliveryTime"
        				FROM Category T1 					
        						JOIN Products T2
        							 ON T1.Categoryid = T2.Category_id 
        						JOIN  orderdetails T3
        							  ON T3.Productid = T2.Productid
        						JOIN Orders T4
        							 ON T4.orderid = T3.orderid
        						JOIN Shippers T5 
        							ON T4.shipperId=T5.ShipperId
        										GROUP BY T1.CategoryName ,T5.Shipperid
        										ORDER BY T5.Shipperid ;
        
-- 10.	We need to see the most used Payment method by customers such that we can tie-up with those Banks in order to attract more customers to our website

-- => 
                     WITH TOP AS 
                                (
                                  SELECT COUNT(T1.PaymentID) AS CNT,
                                        T2.PaymentType,
                                   RANK() OVER(ORDER BY COUNT(T1.PaymentID) DESC) RNK 
                                   FROM 
                                	    orders T1
                                   JOIN 
                                        Payments T2 
			                    ON  T1.PaymentID=T2.PaymentID
		                                   GROUP BY T2.PaymentType)
		                                   SELECT PaymentType,CNT FROM TOP WHERE RNK =1;
                                   
                    -------------- OR ---------------------
                       
-- =>   
                     select T2.PaymentType,
                    		COUNT(*) AS CNT 
					   FROM Orders T1  
					   JOIN Payments T2
							 ON T1.PaymentID = T2.PaymentID 
								   group by T2.PaymentType 
								   ORDER BY CNT DESC		
								   LIMIT 1;
                    
-- 11.	Write a query to show the number of customers, number of orders placed, and total order amount per month in the year 2021. Assume that we are only interested 
        --  in the monthly reports for a single year (January-December).

-- => 
		SELECT MONTHNAME(OrderDate) 'Months', 
                        	   COUNT(*) 'No_Of_Orders',
                               COUNT(distinct(CUSTOMERID)) 'No_Of_Customers',
                               Round(SUM(Total_order_amount),2) 'Total_Order_Amount'  
								   FROM orders 
								   WHERE YEAR(OrderDate)=2021													  
								   GROUP BY MONTH(OrderDate),MONTHNAME(OrderDate) ;
											
                        
-- 12.	Derive a monthly cumulative sum of total order amounts for the year 2021,showcase month-wise aggregation and cumulative 
        -- totals for analytical purposes.

-- => 
		SELECT Monthwise,
			   SUM(Total) OVER(ORDER BY month) 'Monthly_Growth' 
									FROM 
									   (select month(orderdate) 'Month',monthname(orderdate) Monthwise,
												SUM(Total_order_amount) 'Total'
													from orders																			
													WHERE YEAR(OrderDate) = 2021
													GROUP BY 
													month(orderdate), Monthwise)  T1 ;	 
															  
                    															
-- 13. Find Category with highest revenue.

-- => 
	SELECT distinct t3.Category_ID,
					SUM(t1.Total_order_amount) AS SUMM
						  FROM Orders T1 
							JOIN Orderdetails T2 
								  on T1.orderid=T2.orderid
							JOIN Products T3 
								  ON T2.ProductId = T3.ProductID
										group by t3.Category_ID
										order by summ desc
										LIMIT 1;
		
