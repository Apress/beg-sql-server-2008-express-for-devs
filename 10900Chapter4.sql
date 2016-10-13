-- Logins and SQL Server access
-- Point 17 
USE [master]
GO
CREATE LOGIN [FAT-BELLY\AJMason] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
USE [ApressFinancial]
GO
CREATE USER [FAT-BELLY\AJMason] FOR LOGIN [FAT-BELLY\AJMason]
GO

-- T-SQL, Logins, and SQL Server Access
-- Point 1
USE [master]
GO
CREATE LOGIN [FAT-BELLY\AJMason]
FROM WINDOWS
WITH DEFAULT_DATABASE=[master],
DEFAULT_LANGUAGE=[us_english]
GO

-- Point 3
ALTER LOGIN [FAT-BELLY\AJMason]
WITH DEFAULT_DATABASE=ApressFinancial

-- Point 4
USE ApressFinancial
GO
CREATE USER [FAT-BELLY\AJMason]
FOR LOGIN [FAT-BELLY\AJMason]

-- Creating Schemas and Adding Objects
-- Point 1
USE ApressFinancial
GO
CREATE SCHEMA TransactionDetails AUTHORIZATION dbo

-- Point 3
CREATE SCHEMA ShareDetails AUTHORIZATION dbo
GO
CREATE SCHEMA CustomerDetails AUTHORIZATION dbo