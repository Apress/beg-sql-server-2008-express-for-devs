-- Chapter 10
-- Creating a View in SSMSE
-- Point 7
SELECT TOP (100) PERCENT
ShareDesc AS Description,
ShareTickerId AS Ticker,
CurrentPrice AS [Latest Price]
FROM ShareDetails.Shares
WHERE (CurrentPrice > 0)
ORDER BY Description

-- Creating a View with a View
-- Point 10
SELECT TOP (100) PERCENT
ShareDetails.vw_CurrentShares.ShareDesc,
ShareDetails.SharePrices.Price,
ShareDetails.SharePrices.PriceDate
FROM ShareDetails.SharePrices
INNER JOIN ShareDetails.vw_CurrentShares
ON ShareDetails.SharePrices.ShareId =
ShareDetails.vw_CurrentShares.ShareId
ORDER BY ShareDetails.vw_CurrentShares.ShareDesc,
ShareDetails.SharePrices.PriceDate DESC

-- Point 11
INSERT INTO ShareDetails.SharePrices (ShareId, Price, PriceDate)
VALUES (1,2.155,'19 Oct 2008 10:10AM'),
(1,2.2125,'19 Oct 2008 10:12AM'),
(1,2.4175,'19 Oct 2008 10:16AM'),
(1,2.21,'19 Oct 2008 11:22AM'),
(1,2.17,'19 Oct 2008 14:54'),
(1,2.34125,'19 Oct 2008 16:10'),
(2,41.10,'19 Oct 2008 10:10AM'),
(2,43.22,'20 Oct 2008 10:10AM'),
(2,45.20,'21 Oct 2008 10:10AM')

-- Creating a View in a Query Editor Pane
-- Point 1
SELECT c.AccountNumber,c.CustomerFirstName,c.CustomerOtherInitials,
tt.TransactionDescription,t.DateEntered,t.Amount,t.ReferenceDetails
FROM CustomerDetails.Customers c
JOIN TransactionDetails.Transactions t ON t.CustomerId = c.CustomerId
JOIN TransactionDetails.TransactionTypes tt ON
tt.TransactionTypeId = t.TransactionType
ORDER BY c.AccountNumber ASC, t.DateEntered DESC

-- Point 3
CREATE VIEW CustomerDetails.vw_CustTrans
AS
SELECT TOP 100 PERCENT
c.AccountNumber,c.CustomerFirstName,c.CustomerOtherInitials,
tt.TransactionDescription,t.DateEntered,t.Amount,t.ReferenceDetails
FROM CustomerDetails.Customers c
JOIN TransactionDetails.Transactions t ON t.CustomerId = c.CustomerId
JOIN TransactionDetails.TransactionTypes tt ON
tt.TransactionTypeId = t.TransactionType
ORDER BY c.AccountNumber ASC, t.DateEntered DESC

-- Creating a View with SCHEMABINDING
-- Point 1
SELECT c.CustomerFirstName + ' ' + c.CustomerLastName AS CustomerName,
c.AccountNumber, fp.ProductName, cp.AmountToCollect, cp.Frequency,
cp.LastCollected
FROM CustomerDetails.Customers c
JOIN CustomerDetails.CustomerProducts cp ON cp.CustomerId = c.CustomerId
JOIN CustomerDetails.FinancialProducts fp ON
fp.ProductId = cp.FinancialProductId

-- Point 2
INSERT INTO CustomerDetails.FinancialProducts (ProductName)
VALUES ('Regular Savings'),
('Bonds Account'),
('Share Account'),
('Life Insurance')
INSERT INTO CustomerDetails.CustomerProducts
(CustomerId,FinancialProductId,
AmountToCollect,Frequency,LastCollected,LastCollection,Renewable)
VALUES (1,1,200,1,'31 October 2008','31 October 2025',0),
(1,2,50,1,'24 October 2008','24 March 2011',0),
(2,4,150,3,'20 October 2008','20 October 2008',1),
(3,3,500,0,'24 October 2008','24 October 2008',0)

-- Point 4
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = N'vw_CustFinProducts'
AND TABLE_SCHEMA = N'CustomerDetails')
DROP VIEW CustomerDetails.vw_CustFinProducts
GO
CREATE VIEW CustomerDetails.vw_CustFinProducts WITH SCHEMABINDING
AS
SELECT c.CustomerFirstName + ' ' + c.CustomerLastName AS CustomerName,
c.AccountNumber, fp.ProductName, cp.AmountToCollect, cp.Frequency,
cp.LastCollected
FROM CustomerDetails.Customers c
JOIN CustomerDetails.CustomerProducts cp ON cp.CustomerId = c.CustomerId
JOIN CustomerDetails.FinancialProducts fp ON
fp.ProductId = cp.FinancialProductId

-- Point 6
ALTER TABLE CustomerDetails.Customers
ALTER COLUMN CustomerFirstName nvarchar(100)

-- Indexing a View
-- Point 1
CREATE UNIQUE CLUSTERED INDEX ix_CustFinProds
ON CustomerDetails.vw_CustFinProducts (AccountNumber,ProductName)

-- Point 4
USE [ApressFinancial]
GO
/****** Object: View [CustomerDetails].[vw_CustFinProducts]
Script Date: 08/07/2005 12:31:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP VIEW CustomerDetails.vw_CustFinProducts
GO
CREATE VIEW [CustomerDetails].[vw_CustFinProducts] WITH SCHEMABINDING
AS
SELECT c.CustomerFirstName + ' ' + c.CustomerLastName AS CustomerName,
c.AccountNumber, fp.ProductName, cp.AmountToCollect,
cp.Frequency, cp.LastCollected
FROM CustomerDetails.Customers c
JOIN CustomerDetails.CustomerProducts cp ON cp.CustomerId = c.CustomerId
JOIN CustomerDetails.FinancialProducts fp ON
fp.ProductId = cp.FinancialProductId
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF

