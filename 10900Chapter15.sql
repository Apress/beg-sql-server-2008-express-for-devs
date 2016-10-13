-- Chapter 15
-- Using the Report Wizard
-- Point 5
SELECT c.CustomerFirstName + ' ' + c.CustomerLastName as 'Name',
t.DateEntered, tt.TransactionDescription,t.Amount
FROM CustomerDetails.Customers c
JOIN TransactionDetails.Transactions t ON
t.CustomerId = c.CustomerId
JOIN TransactionDetails.TransactionTypes tt ON
tt.TransactionTypeId = t.TransactionType

-- Point 10
WHERE c.CustomerId = @CustId

