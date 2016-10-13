--Chapter 13
-- Subqueries
ALTER TABLE ShareDetails.Shares
ADD MaximumSharePrice money
GO
DECLARE @MaxPrice money
SELECT @MaxPrice = MAX(Price)
FROM ShareDetails.SharePrices
WHERE ShareId = 1
SELECT @MaxPrice
UPDATE ShareDetails.Shares
SET MaximumSharePrice = @MaxPrice
WHERE ShareId = 1

-- Correlated Subquery
SELECT ShareId,MaximumSharePrice
FROM ShareDetails.Shares
UPDATE ShareDetails.Shares
SET MaximumSharePrice = (SELECT MAX(SharePrice)
FROM ShareDetails.SharePrices sp
WHERE sp.ShareId = s.ShareId)
FROM ShareDetails.Shares s
SELECT ShareId,MaximumSharePrice
FROM ShareDetails.Shares

-- IN
SELECT *
FROM ShareDetails.Shares
WHERE ShareId IN (1,3,5)

-- IN 2nd
SELECT *
FROM ShareDetails.Shares
WHERE ShareId IN (SELECT ShareId
FROM ShareDetails.Shares
WHERE CurrentPrice > (SELECT MIN(CurrentPrice)
FROM ShareDetails.Shares)
AND CurrentPrice < (SELECT MAX(CurrentPrice)
FROM ShareDetails.Shares))

-- EXISTS
SELECT *
FROM ShareDetails.Shares s
WHERE NOT EXISTS (SELECT 1
FROM TransactionDetails.Transactions t
WHERE t.RelatedShareId = s.ShareId)

-- Using a Scalar Function with Subqueries
-- Points 1-3
SELECT t1.TransactionId, t1.DateEntered,t1.Amount,
(SELECT MIN(DateEntered)
FROM TransactionDetails.Transactions t2
WHERE t2.CustomerId = t1.CustomerId
AND t2.DateEntered> t1.DateEntered) as 'To Date',
SELECT t1.TransactionId, t1.DateEntered,t1.Amount,
TransactionDetails.fn_IntCalc(10,t1.Amount,t1.DateEntered,
(SELECT MIN(DateEntered)
FROM TransactionDetails.Transactions t2
WHERE t2.CustomerId = t1.CustomerId
AND t2.DateEntered> t1.DateEntered)) AS 'Interest Earned'
FROM TransactionDetails.Transactions t1
WHERE CustomerId = 1

-- Table Function and CROSS APPLY
-- Point 1
CREATE FUNCTION TransactionDetails.ReturnTransactions
(@CustId bigint) RETURNS @Trans TABLE
(TransactionId bigint,
CustomerId bigint,
TransactionDescription nvarchar(30),
DateEntered datetime,
Amount money)
AS
BEGIN
INSERT INTO @Trans
SELECT TransactionId, CustomerId, TransactionDescription,
DateEntered, Amount
FROM TransactionDetails.Transactions t
JOIN TransactionDetails.TransactionTypes tt ON
tt.TransactionTypeId = t.TransactionType
WHERE CustomerId = @CustId
RETURN
END

-- Point 2
INSERT INTO TransactionDetails.Transactions
(CustomerId,TransactionType,DateEntered,Amount,RelatedProductId)
VALUES (2,1,'18 Dec 2008',1000,1)
SELECT c.CustomerFirstName, CustomerLastName,
Trans.TransactionId,TransactionDescription,
DateEntered,Amount
FROM CustomerDetails.Customers AS c
CROSS APPLY
TransactionDetails.ReturnTransactions(c.CustomerId)
AS Trans

-- Outer Apply
SELECT c.CustomerFirstName, CustomerLastName,
Trans.TransactionId,TransactionDescription,
DateEntered,Amount
FROM CustomerDetails.Customers AS c
OUTER APPLY
TransactionDetails.ReturnTransactions(c.CustomerId)
AS Trans

-- Common Table Expressions
WITH ProdList (ProductSubcategoryID,Name,ListPrice) AS
(
SELECT p.ProductSubcategoryID, s.Name,SUM(ListPrice) AS ListPrice
FROM Production.Product p
JOIN Production.ProductSubcategory s ON s.ProductSubcategoryID =
p.ProductSubcategoryID
WHERE p.ProductSubcategoryID IS NOT NULL
GROUP BY p.ProductSubcategoryID, s.Name
)
SELECT ProductSubcategoryID,Name,MAX(ListPrice)
FROM ProdList
GROUP BY ProductSubcategoryID, Name
HAVING MAX(ListPrice) = (SELECT MAX(ListPrice) FROM ProdList)

-- Recursive CTE
USE AdventureWorks2008
GO
WITH [EMP_cte]([BusinessEntityID], [OrganizationNode], [FirstName],
[LastName], [RecursionLevel]) -- CTE name and columns
AS (
SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName],
p.[LastName], 0
FROM [HumanResources].[Employee] e
INNER JOIN [Person].[Person] p
ON p.[BusinessEntityID] = e.[BusinessEntityID]
WHERE e.[BusinessEntityID] = 2
UNION ALL
SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName],
p.[LastName], [RecursionLevel] + 1 -- Join recursive member to anchor
FROM [HumanResources].[Employee] e
INNER JOIN [EMP_cte]
ON e.[OrganizationNode].GetAncestor(1) = [EMP_cte].[OrganizationNode]
INNER JOIN [Person].[Person] p
ON p.[BusinessEntityID] = e.[BusinessEntityID]
)
SELECT [EMP_cte].[RecursionLevel], [EMP_cte].[OrganizationNode].ToString() as
[OrganizationNode], p.[FirstName] AS 'ManagerFirstName', p.[LastName] AS
'ManagerLastName',
[EMP_cte].[BusinessEntityID], [EMP_cte].[FirstName], [EMP_cte].[LastName]
-- Outer select from the CTE
FROM [EMP_cte]
INNER JOIN [HumanResources].[Employee] e
ON [EMP_cte].[OrganizationNode].GetAncestor(1) = e.[OrganizationNode]
INNER JOIN [Person].[Person] p
ON p.[BusinessEntityID] = e.[BusinessEntityID]
ORDER BY [EMP_cte].[BusinessEntityID],[RecursionLevel],
[EMP_cte].[OrganizationNode].ToString()
OPTION (MAXRECURSION 25)

-- Pivot
USE AdventureWorks2008
GO
SELECT ProductID,UnitPriceDiscount,SUM(LineTotal)
FROM Sales.SalesOrderDetail
WHERE ProductID IN (776,711,747)
GROUP BY ProductID,UnitPriceDiscount
ORDER BY ProductID,UnitPriceDiscount

-- Pivot 2nd
SELECT pt.Discount,ISNULL([711],0.00) As Product711,
ISNULL([747],0.00) As Product747,ISNULL([776],0.00) As Product776
FROM
(SELECT sod.LineTotal, sod.ProductID, sod.UnitPriceDiscount as Discount
FROM Sales.SalesOrderDetail sod) so
PIVOT
(
SUM(so.LineTotal)
FOR so.ProductID IN ([776], [711], [747])
) AS pt
ORDER BY pt.Discount

-- Unpivot
USE AdventureWorks2008
go
SELECT pt.Discount,ISNULL([711],0.00) As Product711,
ISNULL([747],0.00) As Product747,ISNULL([776],0.00) As Product776
INTO #Temp1
FROM
(SELECT sod.LineTotal, sod.ProductID, sod.UnitPriceDiscount as Discount
FROM Sales.SalesOrderDetail sod) so
PIVOT
(
SUM(so.LineTotal)
FOR so.ProductID IN ([776], [711], [747])
) AS pt
ORDER BY pt.Discount

-- Unpivot 2nd
SELECT ProductID,Discount, DiscountAppl
FROM (SELECT Discount, Product711, Product747, Product776
FROM #Temp1) up1
UNPIVOT ( DiscountAppl FOR ProductID
IN (Product711, Product747, Product776)) As upv2
WHERE DiscountAppl <> 0
ORDER BY ProductID

-- Row_Number
USE AdventureWorks2008
GO
SELECT ROW_NUMBER() OVER(ORDER BY LastName) AS RowNum,
FirstName + ' ' + LastName
FROM HumanResources.vEmployee
WHERE JobTitle = 'Production Technician - WC60'
ORDER BY LastName

-- ROW_NUMBER reset
USE AdventureWorks2008
GO
SELECT ROW_NUMBER()
OVER(PARTITION BY SUBSTRING(LastName,1,1)
ORDER BY LastName) AS RowNum, FirstName + ' ' + LastName
FROM HumanResources.vEmployee
WHERE JobTitle = 'Production Technician - WC60'
ORDER BY LastName

-- RANK
USE AdventureWorks2008
GO
SELECT ROW_NUMBER() OVER(ORDER BY d.DepartmentID) AS RowNum,
RANK() OVER(ORDER BY d.DepartmentID) AS Ranking,
p.FirstName + ' ' + p.LastName AS Employee, d.Name,
d.Name AS Department, d.DepartmentID
FROM HumanResources.Employee AS e INNER JOIN
Person.Person AS p ON p.BusinessEntityID = e.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh
ON e.BusinessEntityID = edh.BusinessEntityID
INNER JOIN HumanResources.Department AS d
ON edh.DepartmentID = d.DepartmentID
ORDER BY RowNum

-- DENSE_RANK
USE AdventureWorks2008
GO
SELECT ROW_NUMBER() OVER(ORDER BY d.DepartmentID) AS RowNum,
DENSE_RANK() OVER(ORDER BY d.DepartmentID) AS Ranking,
p.FirstName + ' ' + p.LastName AS Employee, d.Name,
d.Name AS Department, d.DepartmentID
FROM HumanResources.Employee AS e INNER JOIN
Person.Person AS p ON p.BusinessEntityID = e.BusinessEntityID INNER JOIN
HumanResources.EmployeeDepartmentHistory AS edh
ON e.BusinessEntityID = edh.BusinessEntityID INNER JOIN
HumanResources.Department AS d
ON edh.DepartmentID = d.DepartmentID

-- NTILE
USE AdventureWorks2008
GO
SELECT NTILE(25) OVER(ORDER BY d.DepartmentID) AS RowNum,
p.FirstName + ' ' + p.LastName AS Employee, d.Name,
d.Name AS Department, d.DepartmentID
FROM HumanResources.Employee AS e INNER JOIN
Person.Person AS p ON p.BusinessEntityID = e.BusinessEntityID INNER JOIN
HumanResources.EmployeeDepartmentHistory AS edh
ON e.BusinessEntityID = edh.BusinessEntityID INNER JOIN
HumanResources.Department AS d
ON edh.DepartmentID = d.DepartmentID

-- Finding a Missing Index
-- Point 1
USE AdventureWorks2008
GO
SELECT FirstName,LastName,NameStyle,ModifiedDate
FROM Person.Person
WHERE ModifiedDate > '1 Jan 2004'

-- Point 2
SELECT * FROM sys.dm_db_missing_index_details


