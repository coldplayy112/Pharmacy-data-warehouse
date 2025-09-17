CREATE DATABASE [OLAP_BitterPillPharmacy]
USE OLAP_BitterPillPharmacy
SELECT * FROM SYSOBJECTS WHERE xtype = 'U';
GO
EXEC sp_spaceused
---------------------------------------------DIMENSION
CREATE TABLE CustomerDimension(
	CustomerCode INT PRIMARY KEY IDENTITY,
	CustomerId CHAR(10),
	CustomerName VARCHAR(100),
	CustomerGender VARCHAR(10),
	CustomerDOB DATE,
	CustomerEmail VARCHAR(100),
	CustomerAddress VARCHAR(100),
	CustomerPhoneNumber VARCHAR(15)
)

CREATE TABLE EmployeeDimension(
	EmployeeCode INT PRIMARY KEY IDENTITY,
	EmployeeId CHAR(10),
	EmployeeName VARCHAR(100),
	EmployeeSalary MONEY,
	EmployeeGender VARCHAR(10),
	EmployeeAddress VARCHAR(100),
	EmployeePhoneNumber VARCHAR (15),
	ValidFrom DATETIME,
	ValidTo DATETIME
)

CREATE TABLE DoctorDimension(
	DoctorCode INT PRIMARY KEY IDENTITY,
	DoctorId CHAR(10),
	DoctorName VARCHAR(100),
	DoctorPhoneNumber VARCHAR(15),
	DoctorEmail VARCHAR(100)
)

CREATE TABLE SupplierDimension(
	SupplierCode INT PRIMARY KEY IDENTITY,
	SupplierId CHAR(10),
	SupplierName VARCHAR(100),
	SupplierAddress VARCHAR(100),
	CityName VARCHAR(100)
)
DROP TABLE SupplierDimension

SELECT * FROM SupplierDimension


CREATE TABLE MedicineDimension (
	 MedicineCode INT PRIMARY KEY IDENTITY,
	 MedicineId CHAR(10),
	 MedicineName VARCHAR(100),
	 MedicineSellingPrice MONEY,
	 MedicinePurchasePrice MONEY,
	 validFrom DATETIME,
	 validTo DATETIME
)

CREATE TABLE EquipmentDimension (
	 EquipmentCode INT PRIMARY KEY IDENTITY,
	 EquipmentId CHAR(10),
	 EquipmentPrice MONEY,
	 EquipmentName VARCHAR(100),
	 EquipmentTypeName VARCHAR(100),
	 validFrom DATETIME,
	 validTo DATETIME
)

CREATE TABLE BranchDimension (
	 BranchCode INT PRIMARY KEY IDENTITY,
	 BranchId CHAR(10),
	 BranchName VARCHAR(100),
	 BranchAddress VARCHAR(100),
	 BranchPhoneNumber VARCHAR(15),
	 CityName VARCHAR(100)
)

CREATE TABLE TimeDimension(
	TimeCode INT PRIMARY KEY IDENTITY,
	[Date] DATE,
	[Day] INT,
	[Month] INT,
	[Quarter] INT,
	[Year] INT
)
---------------------------------------------FACT
CREATE TABLE MedicinePurchaseFact (
	 SupplierCode INT,
	 EmployeeCode INT,
	 BranchCode INT,
	 MedicineCode INT,
	 TimeCode INT,
	 [Total Purchase Cost] BIGINT, 
	 [Total Purchase Medicine] BIGINT
)
DROP TABLE MedicinePurchaseFact

CREATE TABLE MedicineSalesFact (
	 CustomerCode INT,
	 EmployeeCode INT,
	 BranchCode INT,
	 MedicineCode INT,
	 TimeCode INT,
	 [Total Earnings Medicine] BIGINT,
	 [Total Sold Medicine] BIGINT
)

SELECT * FROM MedicineSalesFact

CREATE TABLE EquipmentSalesFact (
	 CustomerCode INT,
	 EmployeeCode INT,
	 EquipmentCode INT,
	 TimeCode INT,
	 [Total Earnings Medical Equipment] BIGINT, 
	 [Average Sold Medical Equipment] BIGINT
)

CREATE TABLE ConsultationFact (
	 CustomerCode INT,
	 DoctorCode INT,
	 TimeCode INT,
	 [Average Consultation Price] BIGINT,
	 [Count of Customer Consultation] BIGINT
)
---------------------------------------------FiltrTimeStamp (Keperluan ad-hoc)
CREATE TABLE FilterTimeStamp(
	TableName VARCHAR(50) PRIMARY KEY,
	LastETL DATETIME
)
