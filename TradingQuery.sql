--Maven NorthWind Challenge

--Selecting the main "Orders" Table

SELECT *
FROM master..orders$

--Adding a new "ProcessingTime" Column in the Table for future analysis

ALTER TABLE master..orders$
ADD ProcessingTime int

UPDATE master..orders$
SET ProcessingTime = DATEDIFF(DAY,orderDate ,shippedDate)

SELECT CAST(orderDate as date) as OrderDate, CAST(shippedDate as date) as ShippedDate, ProcessingTime
FROM master..orders$


--Adding a Revenue Column in OrderDetails Table

SELECT *
FROM master..order_details$

ALTER TABLE master..order_details$
ADD Revenue money 

UPDATE master..order_details$
SET Revenue = (1-discount)*(unitPrice*quantity)


--Adding a "Profit" Column in Orders Table

SELECT o.freight, o.ProcessingTime, od.Revenue, (od.Revenue - o.freight) as profit
FROM orders$ AS o
LEFT JOIN order_details$ AS od
on o.orderID = od.orderID


ALTER TABLE master..orders$
ADD profit int

UPDATE orders$
SET profit = (od.Revenue - o.freight)
FROM orders$ AS o
LEFT JOIN order_details$ AS od
on o.orderID = od.orderID

SELECT *
FROM master..orders$ 

--Adding a "Profit Margin" Column in OrderDetails Table

SELECT *
FROM master..order_details$

ALTER TABLE master..order_details$
ADD ProfitMargin float

UPDATE order_details$
SET ProfitMargin = (o.profit/od.Revenue)*100
FROM order_details$ as od
LEFT JOIN orders$ as o
on o.orderID = od.orderID

--Finding the Last Order Date in Data

SELECT Max(Cast(OrderDate AS date))
from orders$

--Finding the First Order Date in Data

SELECT Min(Cast(OrderDate AS date))
from orders$



--Adding a new "OrderYear" Column in the Orders Table for future analysis

ALTER TABLE master..orders$
ADD OrderYear int

UPDATE master..orders$
SET OrderYear = Year(orderDate)




--Adding a new "OrderMonth" Column in the Orders Table for future analysis

ALTER TABLE master..orders$
ADD OrderMonth int

UPDATE master..orders$
SET OrderMonth = Month(orderDate)



--Adding a new "OrderQuarter" Column in the Orders Table for future analysis

ALTER TABLE master..orders$
ADD OrderQuarter int

UPDATE master..orders$
SET OrderQuarter = DATEPART(Quarter, OrderDate)

-- Total Revenue

SELECT SUM(revenue)
FROM order_details$


--Viewing Revenue Each Year

SELECT SUM(od.Revenue) AS Revenue, o.OrderYear
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
group by o.OrderYear
order by OrderYear


--Viewing Revenue in Current Year Vs Previous Year

SELECT SUM(od.Revenue) AS Revenue, o.OrderMonth, o.OrderYear
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
group by OrderMonth, o.OrderYear
having OrderYear in (2015, 2014) and OrderMonth in (1, 2, 3, 4, 5)
order by OrderMonth, OrderYear


--Viewing Quantity Each Year

SELECT SUM(od.quantity) AS Quantity, o.OrderYear
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
group by o.OrderYear
order by OrderYear


--Viewing Quantity in Current Year Vs Previous Year

SELECT SUM(od.quantity) AS Quantity, o.OrderMonth, o.OrderYear
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
group by OrderMonth, o.OrderYear
having OrderYear in (2015, 2014) and OrderMonth in (1, 2, 3, 4, 5)
order by OrderMonth, OrderYear


--Viewing Avg. Processing Days Each Year

SELECT AVG(ProcessingTime) AS AvgProcessingDays, OrderYear
FROM orders$
GROUP BY OrderYear
ORDER BY OrderYear desc


--Quantity and Revenue trend per Quarter

SELECT SUM(od.quantity) AS Quantity, SUM(od.Revenue) AS Revenue, o.OrderYear, o.OrderQuarter
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
group by OrderQuarter, o.OrderYear
order by  OrderYear, OrderQuarter


--Top 5 Countries for Revenue, and their Profit



SELECT *
FROM master..order_details$


SELECT TOP(5)
SUM(od.Revenue) AS Revenue, SUM(o.profit) AS Profit, c.country
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
LEFT JOIN customers$ as c
on o.customerID = c.customerID
group by c.country
order by SUM(od.Revenue) desc


--Top 5 Customers for Revenue, and their Profit

SELECT TOP(5)
SUM(od.Revenue) AS Revenue, SUM(o.profit) AS Profit, c.contactName
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
LEFT JOIN customers$ as c
on o.customerID = c.customerID
group by c.contactName
order by SUM(od.Revenue) desc


--Top Employees for Revenue, and their Headquarter Location

SELECT 
SUM(od.Revenue) AS Revenue, SUM(o.profit) AS Profit, e.employeeName, e.country
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
LEFT JOIN employees$ as e
on o.employeeID = e.employeeID
group by e.employeeName, e.country
order by SUM(od.Revenue) desc


--Product Category Revenue Over Time

SELECT c.categoryName, SUM(od.revenue) as Revenue, o.OrderYear, o.OrderQuarter
FROM orders$ as o
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
LEFT JOIN products$ as p
on od.productID = p.productID
LEFT JOIN categories$ as c
on p.categoryID = c.categoryID
GROUP BY c.categoryName,  o.OrderYear, o.OrderQuarter


--Product Category percentage Contribution in Revenue

SELECT (SUM(od.Revenue)/(SELECT SUM(Revenue) From order_details$) *100) AS RevenuePercentage, ca.categoryName
FROM products$ as p 
LEFT JOIN order_details$ as od
on od.productID = p.productID
LEFT JOIN categories$ as ca
on p.categoryID = ca.categoryID
group by ca.categoryName
order by SUM(od.Revenue) desc

--Product Performance in Quantity, Revenue, and Avg Processing Time

SELECT SUM(od.Revenue) AS Revenue, SUM(od.quantity) AS quantity, Avg(o.ProcessingTime) as AvgProcessingDays, p.productName
FROM order_details$ as od 
LEFT JOIN orders$ as o
on o.orderID = od.orderID
LEFT JOIN products$ as p
on od.productID = p.productID
group by p.productName
order by SUM(od.Revenue) desc


--Shipping Companies and their shipping cost over the years


SELECT SUM(o.freight) as ShippingCosts, o.OrderYear, s.companyName
FROM orders$ as o
LEFT JOIN shippers$ as s
on o.shipperID = s.shipperID
group by s.companyName, o.OrderYear
order by s.companyName, o.OrderYear


--Shipping Companies and their percentage contribution in shipping costs

SELECT (SUM(o.freight) / (SELECT SUM(freight) From orders$) *100) as PercentageContribution, s.companyName
FROM orders$ as o
LEFT JOIN shippers$ as s
on o.shipperID = s.shipperID
group by s.companyName
order by PercentageContribution desc



--Shipping Companies and their percentage contribution in total quantity

SELECT (SUM(od.quantity) / (SELECT SUM(quantity) From order_details$) *100) as PercentageContribution, s.companyName
FROM orders$ as o 
LEFT JOIN order_details$ as od
on o.orderID = od.orderID
LEFT JOIN shippers$ as s
on o.shipperID = s.shipperID
group by s.companyName
order by PercentageContribution desc


--Shipping Companies and their percentage contribution in total processing time

SELECT (SUM(cast(o.ProcessingTime as float))/ (SELECT SUM(cast(ProcessingTime as Float)) From orders$) *100) as PercentageContribution, s.companyName
FROM orders$ as o 
LEFT JOIN shippers$ as s
on o.shipperID = s.shipperID
group by s.companyName
order by PercentageContribution desc
