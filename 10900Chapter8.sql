-- Chapter 8
-- Query Editor Scripting
-- Point 4
SET QUOTED_IDENTIFIER OFF
GO

-- Point 5
INSERT INTO [ApressFinancial].[ShareDetails].[Shares]
([ShareDesc]
,[ShareTickerId]
,[CurrentPrice])
VALUES
("ACME'S HOMEBAKE COOKIES INC",
'AHCI',
2.34125)

-- Values and SSMSE Compared to T-SQL
-- Point 7
USE ApressFinancial
GO
INSERT INTO CustomerDetails.Customers (CustomerTitleId) VALUES ('Mr')

-- Point 9
USE ApressFinancial
GO
INSERT INTO CustomerDetails.Customers (CustomerTitleId) VALUES (1)

-- Point 11
INSERT INTO CustomerDetails.Customers
(CustomerTitleId,CustomerLastName,CustomerFirstName,
CustomerOtherInitials,AddressId,AccountNumber,AccountTypeId,
ClearedBalance,UnclearedBalance)
VALUES (3,'Mason','Jack',NULL,145,53431993,1,437.97,-10.56)

-- DBCC CHECKIDENT
DELETE FROM CustomerDetails.Customers
DBCC CHECKIDENT('CustomerDetails.Customers',RESEED,0)
INSERT INTO CustomerDetails.Customers
(CustomerTitleId,CustomerFirstName,CustomerOtherInitials,
CustomerLastName,AddressId,AccountNumber,AccountTypeId,
ClearedBalance,UnclearedBalance)
VALUES (1,'Vic',NULL,'McGlynn',111,87612311,1,4311.22,213.11)
INSERT INTO CustomerDetails.Customers
(CustomerTitleId,CustomerLastName,CustomerFirstName,
CustomerOtherInitials,AddressId,AccountNumber,AccountTypeId,
ClearedBalance,UnclearedBalance)
VALUES (3,'Mason','Jack',NULL,145,53431993,1,437.97,-10.56)

-- Altering a Table for a Default Value in Query Editor
-- Point 1
USE ApressFinancial
GO
ALTER TABLE CustomerDetails.CustomerProducts
ADD CONSTRAINT PK_CustomerProducts
PRIMARY KEY CLUSTERED
(CustomerFinancialProductId) ON [PRIMARY]
GO

-- Point 2
ALTER TABLE CustomerDetails.CustomerProducts
WITH NOCHECK
ADD CONSTRAINT CK_CustProds_AmtCheck
CHECK ((AmountToCollect > 0))
GO

-- Point 3
ALTER TABLE CustomerDetails.CustomerProducts WITH NOCHECK
ADD CONSTRAINT DF_CustProd_Renewable
DEFAULT (0)
FOR Renewable

-- Point 11
INSERT INTO CustomerDetails.CustomerProducts
(CustomerId,FinancialProductId,AmountToCollect,Frequency,
LastCollected,LastCollection,Renewable)
VALUES (1,1,-100,0,'24 Aug 2008','24 Aug 2008',0)

-- Point 13
INSERT INTO CustomerDetails.CustomerProducts
(CustomerId,FinancialProductId,AmountToCollect,Frequency,
LastCollected,LastCollection)
VALUES (1,1,100,0,'24 Aug 2008','23 Aug 2008')

-- Inserting Several Rows At Once
-- Point 1
INSERT INTO CustomerDetails.Customers
(CustomerTitleId,CustomerFirstName,CustomerOtherInitials,
CustomerLastName,AddressId,AccountNumber,AccountTypeId,
ClearedBalance,UnclearedBalance)
VALUES (3,'Bernie','I','McGee',314,65368765,1,6653.11,0.00),
(2,'Julie','A','Dewson',2134,81625422,1,53.32,-12.21),
(1,'Kirsty',NULL,'Hull',4312,96565334,1,1266.00,10.32)

-- Nested Transactions
BEGIN TRAN ShareUpd
SELECT '1st TranCount',@@TRANCOUNT
BEGIN TRAN ShareUpd2
SELECT '2nd TranCount',@@TRANCOUNT
COMMIT TRAN ShareUpd2
SELECT '3rd TranCount',@@TRANCOUNT
COMMIT TRAN -- It is at this point that data modifications will be committed
SELECT 'Last TranCount',@@TRANCOUNT

-- Transactions and INSERT
-- Point 1
SELECT * FROM CustomerDetails.Customers
BEGIN TRAN
INSERT INTO CustomerDetails.Customers
(CustomerTitleId,CustomerFirstName,CustomerOtherInitials,
CustomerLastName,AddressId,AccountNumber,AccountTypeId,
ClearedBalance,UnclearedBalance)
VALUES (3,'Aubrey',NULL,'Lomas',652,11198734,1,653.11,3.21),
(2,'Carl','A','McConville',12345,18171622,1,257.41,988.12),
(1,'John',NULL,'Doe',9166,86765622,1,1781.01,-14.32)
SELECT * FROM CustomerDetails.Customers
ROLLBACK TRAN
SELECT * FROM CustomerDetails.Customers
