-- Chapter 12
-- Creating a Stored Procedure Using SSMSE
-- Point 5
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Robin Dewson
-- Create date: 15 Oct 2008
-- Description: Used to insert a customer
-- =============================================
CREATE PROCEDURE apf_insCustomer
-- Add the parameters for the stored procedure here
@FirstName nvarchar(50) = ,
@LastName nvarchar(50) =
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
-- Insert statements for procedure here
SELECT @FirstName, @LastName
END
GO

-- Points 6-7
CREATE PROCEDURE CustomerDetails.apf_InsertCustomer
-- Add the parameters for the function here
@FirstName nvarchar(50) ,
@LastName nvarchar(50),
@CustTitle int,
@CustInitials nvarchar(10),
@AddressId int,
@AccountNumber nvarchar(15),
@AccountTypeId int
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
INSERT INTO CustomerDetails.Customers
(CustomerTitleId,CustomerFirstName,CustomerOtherInitials,CustomerLastName,
AddressId,AccountNumber,AccountTypeId,ClearedBalance,UnclearedBalance)
VALUES (@CustTitle,@FirstName,@CustInitials,@LastName,
@AddressId,@AccountNumber,@AccountTypeId,0,0)
END
GO

-- Point 10
CustomerDetails.apf_InsertCustomer 'Henry','Williams',1,NULL,431,'22067531',1

-- Point 12
CustomerDetails.apf_InsertCustomer @CustTitle=1,@FirstName='Julie',
@CustInitials='A',@LastName='Dewson',@AddressId=6643,
@AccountNumber='SS865',@AccountTypeId=6

-- Using RETURN and Output Parameters
-- Points 4-7
-- ===============================================
-- Create stored procedure with OUTPUT parameters
-- ===============================================
-- Drop stored procedure if it already exists
IF EXISTS (
SELECT *
FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'CustomerDetails'
AND SPECIFIC_NAME = N'apf_CustBalances'
)
DROP PROCEDURE CustomerDetails.apf_CustBalances
GO
CREATE PROCEDURE CustomerDetails.apf_CustBalances
@CustId int,
@ClearedBalance money OUTPUT,
@UnclearedBalance money OUTPUT
AS
SELECT @ClearedBalance = ClearedBalance,
@UnclearedBalance = UnclearedBalance
FROM Customers
WHERE CustomerId = @CustId
RETURN @@Error
GO

-- Point 8
-- =============================================
-- Example to execute the stored procedure
-- =============================================
DECLARE @ClearedBalance Money, @UnclearedBalance Money
DECLARE @RetVal int
EXECUTE @RetVal=CustomerDetails.apf_CustBalances 1, @ClearedBalance OUTPUT,
@UnclearedBalance OUTPUT
SELECT @RetVal AS ReturnValue, @ClearedBalance AS ClearedBalance,
@UnclearedBalance AS UnclearedBalance
GO

-- Point 10
DECLARE @ClearedBalance Money, @UnclearedBalance Money
DECLARE @RetVal int
EXECUTE @RetVal=CustomerDetails.apf_CustBalances 1, @ClearedBalance OUTPUT,
@UnclearedBalance OUTPUT
SELECT @RetVal AS ReturnValue, @ClearedBalance AS ClearedBalance,
@UnclearedBalance AS UnclearedBalance
GO

-- WHILE...BREAK
-- Point 1
DECLARE @LoopCount int, @TestCount int
SET @LoopCount = 0
SET @TestCount = 0
WHILE @LoopCount < 20
BEGIN
SET @LoopCount = @LoopCount + 1
SET @TestCount = @TestCount + 1
SELECT @LoopCount, @TestCount
IF @TestCount > 10
BREAK
ELSE
CONTINUE
SELECT @LoopCount, @TestCount
END

-- Point 3
DECLARE @LoopCount int, @TestCount int
SET @LoopCount = 0
SET @TestCount = 0
WHILE @LoopCount < 20
BEGIN
SET @LoopCount = @LoopCount + 1
SET @TestCount = @TestCount + 1
SELECT @LoopCount, @TestCount
IF @TestCount > 10
BREAK
--- ELSE
--- CONTINUE
SELECT @LoopCount, @TestCount
END

-- Using the CASE Statement
-- Point 1
INSERT INTO TransactionDetails.TransactionTypes
(TransactionDescription,CreditType,AffectCashBalance)
VALUES ('Deposit',1,1),
('Withdrawal',0,1),
('BoughtShares',1,0)
SELECT TransactionDescription,
CASE CreditType
WHEN 0 THEN 'Debiting the account'
WHEN 1 THEN 'Crediting the account'
END
FROM TransactionDetails.TransactionTypes

-- Point 3
SELECT CustomerId,
CASE
WHEN ClearedBalance < 0 THEN 'OverDrawn'
WHEN ClearedBalance > 0 THEN ' In Credit'
ELSE 'Flat'
END, ClearedBalance
FROM CustomerDetails.Customers

-- Bringing It All Together
-- Points 1-5
CREATE PROCEDURE CustomerDetails.apf_CustMovement @CustId bigint,
@FromDate datetime, @ToDate datetime
AS
BEGIN
DECLARE @RunningBal money, @StillCalc Bit, @LastTran bigint
SELECT @StillCalc = 1, @LastTran = 0, @RunningBal = 0
WHILE @StillCalc = 1
BEGIN
SELECT TOP 1 @RunningBal = @RunningBal + CASE
WHEN tt.CreditType = 1 THEN t.Amount
ELSE t.Amount * -1 END,
@LastTran = t.TransactionId
FROM CustomerDetails.Customers c
JOIN TransactionDetails.Transactions t ON t.CustomerId = c.CustomerId
JOIN TransactionDetails.TransactionTypes tt ON
tt.TransactionTypeId = t.TransactionType
WHERE t.TransactionId > @LastTran
AND tt.AffectCashBalance = 1
AND DateEntered BETWEEN @FromDate AND @ToDate
ORDER BY DateEntered
IF @@ROWCOUNT > 0
-- Perform some interest calculation here...
CONTINUE
ELSE
BREAK
END
SELECT @RunningBal AS 'End Balance'
END
GO

-- Point 6
INSERT INTO TransactionDetails.Transactions
(CustomerId,TransactionType,DateEntered,Amount,RelatedProductId)
VALUES (1,1,'1 Aug 2008',100.00,1),
(1,1,'3 Aug 2008',75.67,1),
(1,2,'5 Aug 2008',35.20,1),
(1,2,'6 Aug 2008',20.00,1)
EXEC CustomerDetails.apf_CustMovement 1,'1 Aug 2008','31 Aug 2008'

-- A Scalar Function to Calculate Interest
-- Points 1-5
CREATE FUNCTION TransactionDetails.fn_IntCalc
(@InterestRate numeric(6,3)=10,@Amount numeric(18,5),
@FromDate Date, @ToDate Date)
RETURNS numeric(18,5)
WITH EXECUTE AS CALLER
AS
BEGIN
DECLARE @IntCalculated numeric(18,5)
SELECT @IntCalculated = @Amount *
((@InterestRate/100.00) * (DATEDIFF(d,@FromDate, @ToDate) / 365.00))
RETURN(ISNULL(@IntCalculated,0))
END
GO

-- Point 6
SELECT TransactionDetails.fn_IntCalc(DEFAULT,2000,'Mar 1 2008','Mar 10 2008')

-- Point 7
SELECT OBJECTPROPERTY(OBJECT_ID('TransactionDetails.fn_IntCalc'),
'IsDeterministic');
GO


