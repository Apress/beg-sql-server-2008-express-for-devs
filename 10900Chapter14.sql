-- Chapter 14
-- Creating a Trigger in Query Editor
-- Points 1-2
CREATE TRIGGER trgInsTransactions
ON TransactionDetails.Transactions
AFTER INSERT
AS
UPDATE CustomerDetails.Customers
SET ClearedBalance = ClearedBalance +
(SELECT CASE WHEN CreditType = 0
THEN i.Amount * -1
ELSE i.Amount
END
FROM INSERTED i
JOIN TransactionDetails.TransactionTypes tt
ON tt.TransactionTypeId = i.TransactionType
WHERE AffectCashBalance = 1)
FROM CustomerDetails.Customers c
JOIN INSERTED i ON i.CustomerId = c.CustomerId

-- Point 3
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE customerId=1
INSERT INTO TransactionDetails.Transactions (CustomerId,TransactionType,
Amount,RelatedProductId, DateEntered)
VALUES (1,2,200,1,GETDATE())
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE customerId=1

-- Point 5
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE customerId=1
INSERT INTO TransactionDetails.Transactions (CustomerId,TransactionType,
Amount,RelatedProductId, DateEntered)
VALUES (1,3,200,1,GETDATE())
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE customerId=1

-- Point 7
SELECT *
FROM TransactionDetails.Transactions
WHERE CustomerId=1

-- Point 8
ALTER TRIGGER TransactionDetails.trgInsTransactions
ON TransactionDetails.Transactions
AFTER INSERT
AS
UPDATE CustomerDetails.Customers
SET ClearedBalance = ClearedBalance +
ISNULL((SELECT CASE WHEN CreditType = 0
THEN i.Amount * -1
ELSE i.Amount
END
FROM INSERTED i
JOIN TransactionDetails.TransactionTypes tt
ON tt.TransactionTypeId = i.TransactionType
WHERE AffectCashBalance = 1),0)
FROM CustomerDetails.Customers c
JOIN INSERTED i ON i.CustomerId = c.CustomerId

-- Point 9
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE customerId=1
INSERT INTO TransactionDetails.Transactions (CustomerId,TransactionType,
Amount,RelatedProductId, DateEntered)
VALUES (1,3,200,1,GETDATE())
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE customerId=1

-- UPDATE() Function
-- Points 1-3
ALTER TRIGGER TransactionDetails.trgInsTransactions
ON TransactionDetails.Transactions
AFTER INSERT,UPDATE
AS
UPDATE CustomerDetails.Customers
SET ClearedBalance = ClearedBalance -
ISNULL((SELECT CASE WHEN CreditType = 0
THEN d.Amount * -1
ELSE d.Amount
END
FROM DELETED d
JOIN TransactionDetails.TransactionTypes tt
ON tt.TransactionTypeId = d.TransactionType
WHERE AffectCashBalance = 1),0)
FROM CustomerDetails.Customers c
JOIN DELETED d ON d.CustomerId = c.CustomerId
UPDATE CustomerDetails.Customers
SET ClearedBalance = ClearedBalance +
ISNULL((SELECT CASE WHEN CreditType = 0
THEN i.Amount * -1
ELSE i.Amount
END
FROM INSERTED i
JOIN TransactionDetails.TransactionTypes tt
ON tt.TransactionTypeId = i.TransactionType
WHERE AffectCashBalance = 1),0)
FROM CustomerDetails.Customers c
JOIN INSERTED i ON i.CustomerId = c.CustomerId

-- Point 4
SELECT *
FROM TransactionDetails.Transactions
WHERE CustomerId = 1
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE CustomerId = 1
UPDATE TransactionDetails.Transactions
SET Amount = 100
WHERE TransactionId = 5
SELECT *
FROM TransactionDetails.Transactions
WHERE CustomerId = 1
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE CustomerId = 1

-- Point 7
ALTER TRIGGER TransactionDetails.trgInsTransactions
ON TransactionDetails.Transactions
AFTER INSERT,UPDATE
AS
IF UPDATE(Amount) OR Update(TransactionType)
BEGIN
UPDATE CustomerDetails.Customers
SET ClearedBalance = ClearedBalance -
ISNULL((SELECT CASE WHEN CreditType = 0
THEN d.Amount * -1
ELSE d.Amount
END
FROM DELETED d
JOIN TransactionDetails.TransactionTypes tt
ON tt.TransactionTypeId = d.TransactionType
WHERE AffectCashBalance = 1),0)
FROM CustomerDetails.Customers c
JOIN DELETED d ON d.CustomerId = c.CustomerId
UPDATE CustomerDetails.Customers
SET ClearedBalance = ClearedBalance +
ISNULL((SELECT CASE WHEN CreditType = 0
THEN i.Amount * -1
ELSE i.Amount
END
FROM INSERTED i
JOIN TransactionDetails.TransactionTypes tt
ON tt.TransactionTypeId = i.TransactionType
WHERE AffectCashBalance = 1),0)
FROM CustomerDetails.Customers c
JOIN INSERTED i ON i.CustomerId = c.CustomerId
RAISERROR ('We have completed an update',10,1)
END
ELSE
RAISERROR ('Updates have been skipped',10,1)

-- Point 8
SELECT *
FROM TransactionDetails.Transactions
WHERE TransactionId=5
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE CustomerId = 1
UPDATE TransactionDetails.Transactions
SET DateEntered = DATEADD(dd,-1,DateEntered)
WHERE TransactionId = 5
SELECT *
FROM TransactionDetails.Transactions
WHERE TransactionId=5
SELECT ClearedBalance
FROM CustomerDetails.Customers
WHERE CustomerId = 1

-- COLUMNS_UPDATED()
ALTER TRIGGER TransactionDetails.trgInsTransactions
ON TransactionDetails.Transactions
AFTER UPDATE,INSERT
AS
IF (SUBSTRING(COLUMNS_UPDATED(),1,1) = power(2,(3-1))
OR SUBSTRING(COLUMNS_UPDATED(),1,1) = power(2,(5-1)))
BEGIN
UPDATE CustomerDetails.Customers
SET ClearedBalance = ClearedBalance -
ISNULL((SELECT CASE WHEN CreditType = 0
THEN d.Amount * -1
ELSE d.Amount
END
FROM DELETED d
JOIN TransactionDetails.TransactionTypes tt
ON tt.TransactionTypeId = d.TransactionType
WHERE AffectCashBalance = 1),0)
FROM CustomerDetails.Customers c
JOIN DELETED d ON d.CustomerId = c.CustomerId
UPDATE CustomerDetails.Customers
SET ClearedBalance = ClearedBalance +
ISNULL((SELECT CASE WHEN CreditType = 0
THEN i.Amount * -1
ELSE i.Amount
END
FROM INSERTED i
JOIN TransactionDetails.TransactionTypes tt
ON tt.TransactionTypeId = i.TransactionType
WHERE AffectCashBalance = 1),0)
FROM CustomerDetails.Customers c
JOIN INSERTED i ON i.CustomerId = c.CustomerId
RAISERROR ('We have completed an update ',10,1)
END
ELSE
RAISERROR ('Updates have been skipped',10,1)

-- DDL Trigger
-- Point 1
CREATE TRIGGER trgSprocs
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE
AS
IF DATEPART(hh,GETDATE()) > 9 AND DATEPART(hh,GETDATE()) < 17
BEGIN
DECLARE @Message nvarchar(max)
SELECT @Message =
'Completing work during core hours. Trying to release - '
+ EVENTDATA().value
('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)')
RAISERROR (@Message, 16, 1)
ROLLBACK
END

-- Point 2
CREATE PROCEDURE Test1
AS
SELECT 'Hello all'

-- Point 4
DROP TRIGGER trgSprocs ON DATABASE

-- Point 5
CREATE TRIGGER trgDBDump
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
SELECT EVENTDATA()

-- Point 6
CREATE PROCEDURE Test1
AS
SELECT 'Hello all'

