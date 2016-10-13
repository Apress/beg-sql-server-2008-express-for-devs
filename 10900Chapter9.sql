-- Chapter 9
-- The First Set of Searches
-- Point 1
SELECT * FROM CustomerDetails.Customers

-- Point 3
SELECT CustomerFirstName,CustomerLastName,ClearedBalance
FROM CustomerDetails.Customers

-- Point 5
SELECT CustomerFirstName As 'First Name',
CustomerLastName AS 'Surname',
ClearedBalance Balance
FROM CustomerDetails.Customers

-- Putting the Results in Text and a File
-- Point 2
SELECT CustomerFirstName As 'First Name',
CustomerLastName AS 'Surname',
ClearedBalance Balance
FROM CustomerDetails.Customers

-- The WHERE Statement
-- Point 1
INSERT INTO ShareDetails.Shares
(ShareDesc, ShareTickerId,CurrentPrice)
VALUES ('FAT-BELLY.COM','FBC',45.20),
('NetRadio Inc','NRI',29.79),
('Texas Oil Industries','TOI',0.455),
('London Bridge Club','LBC',1.46)

-- Point 2
SELECT ShareDesc,CurrentPrice
FROM ShareDetails.Shares
WHERE ShareDesc = 'FAT-BELLY.COM'

-- Point 5
SELECT ShareDesc,CurrentPrice
FROM ShareDetails.Shares
WHERE ShareDesc > 'FAT-BELLY.COM'
AND ShareDesc < 'TEXAS OIL INDUSTRIES'

-- Point 7
SELECT ShareDesc,CurrentPrice
FROM ShareDetails.Shares
WHERE ShareDesc <> 'FAT-BELLY.COM'
SELECT ShareDesc,CurrentPrice
FROM ShareDetails.Shares
WHERE NOT ShareDesc = 'FAT-BELLY.COM'

-- SET ROWCOUNT
-- Point 1
SET ROWCOUNT 3
SELECT * FROM ShareDetails.Shares
SET ROWCOUNT 0
SELECT * FROM ShareDetails.Shares

-- TOP n
-- Point 1
SELECT TOP 3 * FROM ShareDetails.Shares
SET ROWCOUNT 3
SELECT TOP 2 * FROM ShareDetails.Shares
SET ROWCOUNT 2
SELECT TOP 3 * FROM ShareDetails.Shares
SET ROWCOUNT 0

-- String Functions
-- Point 1
SELECT CustomerFirstName + ' ' + CustomerLastName AS 'Name',
ClearedBalance Balance
FROM CustomerDetails.Customers

-- Point 3
SELECT LEFT(CustomerFirstName + ' ' + CustomerLastName,50) AS 'Name',
ClearedBalance Balance
FROM CustomerDetails.Customers

-- Point 5
SELECT RTRIM(CustomerFirstName + ' ' + CustomerLastName) AS 'Name',
ClearedBalance Balance
FROM CustomerDetails.Customers

-- Altering the Order
-- Point 1
SELECT LEFT(CustomerFirstName + ' ' + CustomerLastName,50) AS 'Name',
ClearedBalance Balance
FROM CustomerDetails.Customers
ORDER BY Balance

-- Point 3
SELECT LEFT(CustomerFirstName + ' ' + CustomerLastName,50) AS 'Name',
ClearedBalance Balance
FROM CustomerDetails.Customers
ORDER BY Balance DESC

-- The LIKE Operator
-- Point 1
SELECT CustomerFirstName + ' ' + CustomerLastName
FROM CustomerDetails.Customers
WHERE CustomerLastName LIKE '%Glynn'

-- Point 3
SELECT CustomerFirstName + ' ' + CustomerLastName AS [Name]
FROM CustomerDetails.Customers
WHERE CustomerFirstName + ' ' + CustomerLastName LIKE '%n%'

-- Point 5
SELECT CustomerFirstName + ' ' + CustomerLastName AS [Name]
FROM CustomerDetails.Customers
WHERE [Name] LIKE '%n%'

-- SELECT INTO
-- Point 1
SELECT CustomerFirstName + ' ' + CustomerLastName AS [Name],
ClearedBalance,UnclearedBalance
INTO CustomerDetails.CustTemp
FROM CustomerDetails.Customers

-- Updating a Row of Data
-- Point 1
UPDATE CustomerDetails.Customers
SET CustomerLastName = 'Brodie'
WHERE CustomerId = 1

-- Point 3
SELECT CustomerId,CustomerFirstName,CustomerLastName
FROM CustomerDetails.Customers
WHERE CustomerId = 1

-- Point 5
DECLARE @ValueToUpdate VARCHAR(30)
SET @ValueToUpdate = 'McGlynn'
UPDATE CustomerDetails.Customers
SET CustomerLastName = @ValueToUpdate,
ClearedBalance = ClearedBalance + UnclearedBalance ,
UnclearedBalance = 0
WHERE CustomerLastName = 'Brodie'

-- Point 7
SELECT CustomerFirstName, CustomerLastName,
ClearedBalance, UnclearedBalance
FROM CustomerDetails.Customers
WHERE CustomerId = 1

-- Point 8
DECLARE @WrongDataType VARCHAR(20)
SET @WrongDataType = '4311.22'
UPDATE CustomerDetails.Customers
SET ClearedBalance = @WrongDataType
WHERE CustomerId = 1

-- Point 10
SELECT CustomerFirstName, CustomerLastName,
ClearedBalance, UnclearedBalance
FROM CustomerDetails.Customers
WHERE CustomerId = 1

-- Point 11
DECLARE @WrongDataType VARCHAR(20)
SET @WrongDataType = '2.0'
UPDATE CustomerDetails.Customers
SET AddressId = @WrongDataType
WHERE CustomerId = 1

-- Using a Transaction with UPDATE
-- Point 1
SELECT 'Before',ShareId,ShareDesc,CurrentPrice
FROM ShareDetails.Shares
WHERE ShareId = 3
BEGIN TRAN ShareUpd
UPDATE ShareDetails.Shares
SET CurrentPrice = CurrentPrice * 1.1
WHERE ShareId = 3
COMMIT TRAN
SELECT 'After',ShareId,ShareDesc,CurrentPrice
FROM ShareDetails.Shares
WHERE ShareId = 3

-- Point 3
SELECT 'Before',ShareId,ShareDesc,CurrentPrice
FROM ShareDetails.Shares
-- WHERE ShareId = 3
BEGIN TRAN ShareUpd
UPDATE ShareDetails.Shares
SET CurrentPrice = CurrentPrice * 1.1
-- WHERE ShareId = 3
SELECT 'Within the transaction',ShareId,ShareDesc,CurrentPrice
FROM ShareDetails.Shares
ROLLBACK TRAN
SELECT 'After',ShareId,ShareDesc,CurrentPrice
FROM ShareDetails.Shares
-- WHERE ShareId = 3

-- Deleting Rows
-- Point 1
BEGIN TRAN
SELECT * FROM CustomerDetails.CustTemp
DELETE CustomerDetails.CustTemp
SELECT * FROM CustomerDetails.CustTemp
ROLLBACK TRAN
SELECT * FROM CustomerDetails.CustTemp

-- Point 3
BEGIN TRAN
SELECT * FROM CustomerDetails.CustTemp
DELETE TOP (3) CustomerDetails.CustTemp
SELECT * FROM CustomerDetails.CustTemp
ROLLBACK TRAN
SELECT * FROM CustomerDetails.CustTemp

