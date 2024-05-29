use AdventureWorks2014
--1. List of all customers
select * from Person.Person;

--2. list of all customers where company name ending in N
select * from Person.AddressType where Name LIKE '%n'

--3. list of all customers who live in Berlin or London
select * from Person.Address where City = 'berlin' or City = 'london'

--4. list of all customers who live in UK or USA
select * from Person.CountryRegion where CountryRegionCode = 'USA' or CountryRegionCode = 'UK'

--5. list of all products sorted by product name
--check
select * from Sales.Store order by Name

--6. list of all products where product name starts with an A
select * from Sales.Store where Name like 'A%'

--7. List of customers who ever placed an order

select * from Sales.Store

--8. list of Customers who live in London and have bought chai

--11. Details of first order of the system

select * from sales.SalesOrderHeader GROUP BY MIN(OrderDate);


--12. Find the details of most expensive order date
select * from sales.SalesOrderHeader where SubTotal=(select MAX(SubTotal) from sales.SalesOrderHeader); 



--13. For each order get the OrderID and Average quantity of items in that order
select SalesOrderID , AVG(OrderQty) from sales.SalesOrderDetail GROUP BY SalesOrderID;

--14. For each order get the orderID, minimum quantity and maximum quantity for that order

select ProductID,MaxOrderQty,MinOrderQty from Purchasing.ProductVendor ;

--15. Get a list of all managers and total number of employees who report to them

--16. Get the OrderlD and the total quantity for each order that has a total quantity of greater than 300
select ProductID, OnorderQty from Purchasing.ProductVendor where OnOrderQty > 300;

--17. list of all orders placed on or after 1996/12/31
select * from Purchasing.PurchaseOrderHeader where OrderDate >= '1996-12-31';

--18. list of all orders shipped to Canada
select * from Person.Address where city = 'Canada';

--19. list of all orders with order total > 200
select SalesOrderID, OrderQty from Sales.SalesOrderDetail where OrderQty > 200;

--20. List of countries and sales made in each country
select * from [Sales].[SalesOrderHeader]

--21. List of Customer ContactName and number of orders they placed
select * from Sales.SalesOrderDetail

--22. List of customer contactnames who have placed more than 3 orders
select SalesOrderID , OrderQty from Sales.SalesOrderDetail where OrderQty>3

--23. List of discontinued products which were ordered between 1/1/1997 and 1/1/1998

--24. List of employee firsname, lastName, superviser FirstName, LastName
select FirstName, LastName  from Person.Person

--25. List of Employees id and total sale condcuted by employee
select SalesPersonID,SubTotal from Sales.SalesOrderHeader;

--26. list of employees whose FirstName contains character a
select FirstName from Person.Person where FirstName like '%a%'

--27. List of managers who have more than four people reporting to them.

--28. List of Orders and ProductNames
select BusinessEntityID,Name from Sales.Store 

--29. List of orders place by the best customer
select * from sales.SalesOrderHeader where SubTotal=(select MAX(SubTotal) from sales.SalesOrderHeader)

--30. List of orders placed by customers who do not have a Fax number
select * from Person.PersonPhone;
--31. List of Postal codes where the product Tofu was shipped

--32. List of product Names that were shipped to France
select * from Person.Address where city = 'France';

--33. List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.
select name from Sales.Store where name = 'specialty biscuit';

--34. List of products that were never ordered
select * from sales.SalesOrderDetail where OrderQty<0

--35. List of products where units in stock is less than 10 and units on order are 0.

--36. List of top 10 countries by sales

--37. Number of orders each employee has taken for customers with CustomerlDs between A and AO


--38. Orderdate of most expensive order
select * from sales.SalesOrderHeader where SubTotal=(select MAX(SubTotal) from sales.SalesOrderHeader)

--39. Product name and total revenue from that product
--40. Supplierid and number of products offered
select SalesOrderID, OrderQty from Sales.SalesOrderDetail

--41. Top ten customers based on their business
select top 10 * from sales.SalesOrderDetail ORDER BY OrderQty DESC;

--42. What is the total revenue of the company.
select SalesOrderID,  sum(SubTotal)
from Sales.SalesOrderHeader
group by SalesOrderID with rollup