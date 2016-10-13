CREATE DATABASE ApressFinancial ON  PRIMARY 
( NAME = N'ApressFinancial', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ApressFinancial.mdf' , SIZE = 3072KB , 
MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'ApressFinancial_log', 
FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\ApressFinancial_log.ldf' , 
SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
 COLLATE SQL_Latin1_General_CP1_CI_AS
GO
