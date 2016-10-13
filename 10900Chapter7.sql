-- Taking a database offline
-- Point 1

USE master
GO
ALTER DATABASE ApressFinancial
SET OFFLINE

-- Point 2
USE master
go
ALTER DATABASE ApressFinancial
SET ONLINE

-- Bakcing up a database
-- Point 2
BACKUP DATABASE ApressFinancial
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\Backup\ ApressFinancial.bak'WITH NAME = 'ApressFinancial-Full Database Backup',
SKIP,
NOUNLOAD,
STATS = 10

-- Point 6
BACKUP DATABASE ApressFinancial
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\Backup\ApressFinancial.bak'
WITH DIFFERENTIAL ,
DESCRIPTION = N'ApressFinancial-Differential Database Backup',
RETAINDAYS = 60,
NOFORMAT, NOINIT,
NAME = 'ApressFinancial-Differential Database Backup',
SKIP, NOREQIND, NOUNLOAD,
STATS = 10,
CHECKSUM,
CONTINUE_AFTER_ERROR
GO

-- Point 7
declare @backupSetId as int
select @backupSetId = position
from msdb..backupset
where database_name=N'ApressFinancial'
and backup_set_id=
(select max(backup_set_id)
from msdb..backupset
where database_name=N'ApressFinancial' )
if @backupSetId is null
begin
raiserror(N'Verify failed. Backup information for database
''ApressFinancial'' not found.', 16, 1)
end
RESTORE VERIFYONLY
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\Backup\ApressFinancial.bak'
WITH FILE = @backupSetId,
NOUNLOAD,
NOREWIND

-- Transaction Log Backup
-- Point 1
BACKUP LOG ApressFinancial
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\Backup\ApressFinancial.bak'
WITH NAME = 'ApressFinancial-Transaction Log Backup',
SKIP,
NOREWIND,
NOUNLOAD,
STATS = 10

-- Point 3
ALTER DATABASE ApressFinancial
SET RECOVERY FULL
GO
BACKUP DATABASE ApressFinancial
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\Backup\ApressFinancial.bak'
WITH NAME = 'ApressFinancial-Full Database Backup' ,
SKIP,
NOUNLOAD,
NOREWIND,
STATS = 10
GO
BACKUP LOG ApressFinancial
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\Backup\ApressFinancial.bak'
WITH NAME = 'ApressFinancial-Transaction Log Backup' ,
SKIP,
NOUNLOAD,
NOREWIND,
STATS = 10

-- Restoring using T-SQL
-- Point 1
USE ApressFinancial
GO
ALTER TABLE ShareDetails.Shares
ADD DummyColumn varchar(30)

-- Point 2
USE Master
GO
RESTORE DATABASE [ApressFinancial]
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\Backup\ApressFinancial.bak' WITH FILE = 4,
NORECOVERY, NOUNLOAD, REPLACE, STATS = 10
GO

-- Point 3
RESTORE LOG [ApressFinancial]
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10.SQLEXPRESS\MSSQL\Backup\ApressFinancial.bak' WITH FILE = 5,
RECOVERY, NOUNLOAD, STATS = 10

-- Detatching and attaching using T-SQL
-- Point 1
USE master
GO
sp_detach_db 'ApressFinancial'

-- Point 4
CREATE DATABASE ApressFinancial
ON (FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\ApressFinancial.MDF')
FOR ATTACH