--DIMENSION
-----------------------------------------------CustomerDimension
SELECT 
	CustomerId,
	CustomerName, 
	CustomerGender,
	CustomerDOB, 
	CustomerEmail, 
	CustomerAddress, 
	CustomerPhoneNumber 
FROM [Bitter Pill Pharmacy]..MsCustomer

SELECT * FROM CustomerDimension

-----------------------------------------------EmployeeDimension
SELECT
	EmployeeId, 
	EmployeeName,
	EmployeeSalary,
	EmployeeGender,
	EmployeeAddress, 
	EmployeePhoneNumber
FROM [Bitter Pill Pharmacy]..MsEmployee

SELECT * FROM EmployeeDimension

-----------------------------------------------DoctorDimension
SELECT
	DoctorId ,
	DoctorName,
	DoctorPhoneNumber,
	DoctorEmail
FROM [Bitter Pill Pharmacy]..MsDoctor

SELECT * FROM DoctorDimension

-----------------------------------------------SupplierDimension
SELECT	
	SupplierId, 
	SupplierName,
	SupplierAddress,
	CityName
FROM [Bitter Pill Pharmacy]..MsSupplier ms
JOIN [Bitter Pill Pharmacy]..MsCity mc
ON ms.CityId = mc.CityId

SELECT * FROM SupplierDimension

-----------------------------------------------MedicineDimension
SELECT 
	MedicineId,
	MedicineName,
	MedicineSellingPrice,
	MedicinePurchasePrice
FROM [Bitter Pill Pharmacy]..MsMedicine

SELECT * FROM MedicineDimension

-----------------------------------------------EquipmentDimension
SELECT
	 EquipmentId,
	 EquipmentPrice,
	 EquipmentName,
	 EquipmentTypeName
FROM [Bitter Pill Pharmacy]..MsEquipment me
JOIN [Bitter Pill Pharmacy]..MsEquipmentType mt
ON me.EquipmentTypeId = mt.EquipmentTypeId

SELECT * FROM EquipmentDimension

-----------------------------------------------BranchDimension
SELECT
	 BranchId,
	 BranchName,
	 BranchAddress,
	 BranchPhoneNumber,
	 CityName
FROM [Bitter Pill Pharmacy]..MsBranch mb
JOIN [Bitter Pill Pharmacy]..MsCity mc
ON mb.CityId = mc.CityId

SELECT * FROM BranchDimension

-----------------------------------------------TimeDimension
IF EXISTS(
	 SELECT * 
	 FROM FilterTimeStamp
	 WHERE TableName = 'TimeDimension'
) BEGIN 

 SELECT 
	  AllDate.Date AS [Date],
	  DAY(AllDate.Date) AS [Day],
	  Month(AllDate.Date) AS [Month],
	  DATEPART(QUARTER, AllDate.Date) AS [Quarter],
	  YEAR(AllDate.Date) AS [Year]

	 FROM(
	  SELECT MedicineSalesDate AS [Date]
	  FROM [Bitter Pill Pharmacy]..TrMedicineSalesHeader
	  UNION
	  SELECT MedicinePurchaseDate AS [Date]
	  FROM [Bitter Pill Pharmacy]..TrMedicinePurchaseHeader
	  UNION
	  SELECT EquipmentSalesDate AS [Date]
	  FROM [Bitter Pill Pharmacy]..TrMedicalEquipmentSalesHeader
	  UNION
	  SELECT ConsultationDate AS [Date]
	  FROM [Bitter Pill Pharmacy]..TrConsultationHeader
	 )AllDate
	 WHERE [Date] > (
	  SELECT LastETL
	  FROM FilterTimeStamp
	  WHERE TableName = 'TimeDimension'
	 )
END ELSE BEGIN 

SELECT 
	  AllDate.Date AS [Date],
	  DAY(AllDate.Date) AS [Day],
	  Month(AllDate.Date) AS [Month],
	  DATEPART(QUARTER, AllDate.Date) AS [Quarter],
	  YEAR(AllDate.Date) AS [Year]

	 FROM(
	  SELECT MedicineSalesDate AS [Date]
	  FROM [Bitter Pill Pharmacy]..TrMedicineSalesHeader
	  UNION
	  SELECT MedicinePurchaseDate AS [Date]
	  FROM [Bitter Pill Pharmacy]..TrMedicinePurchaseHeader
	  UNION
	  SELECT EquipmentSalesDate AS [Date]
	  FROM [Bitter Pill Pharmacy]..TrMedicalEquipmentSalesHeader
	  UNION
	  SELECT ConsultationDate AS [Date]
	  FROM [Bitter Pill Pharmacy]..TrConsultationHeader
	 )AllDate
END

SELECT * FROM TimeDimension
------------------------------------------------------------------------------------FilteTimeStamp
IF EXISTS(
	SELECT * FROM FilterTimeStamp
	WHERE TableName = 'TimeDimension'
)BEGIN 
	 UPDATE FilterTimeStamp
	 SET LastETL = GETDATE()
	 WHERE TableName = 'TimeDimension'
END ELSE BEGIN

 INSERT INTO FilterTimeStamp VALUES
 ('TimeDimension', GETDATE())

END

SELECT * FROM FilterTimeStamp
------------------------------------------------------------------------------------FilteTimeStamp

--FACT
-----------------------------------------------MedicinePurchaseFact
IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'MedicinePurchaseFact'
) 
BEGIN 
	SELECT 
		 TimeCode,
		 SupplierCode,
		 EmployeeCode,
		 BranchCode,
		 MedicineCode,
		 [Total Purchase Cost] = SUM(Quantity*MedicinePurchasePrice),
		 [Total Purchase Medicine] = SUM(Quantity)
		 FROM [Bitter Pill Pharmacy]..TrMedicinePurchaseHeader TPH JOIN
		 [Bitter Pill Pharmacy]..TrMedicinePurchaseDetail TPD 
		 ON TPH.MedicinePurchaseId = TPD.MedicinePurchaseId JOIN
		 TimeDimension TD
		 ON TD.Date = TPH.MedicinePurchaseDate JOIN
		 SupplierDimension SD
		 ON SD.SupplierID = TPH.SupplierId JOIN
		 EmployeeDimension ED
		 ON ED.EmployeeID = TPH.EmployeeId JOIN
		 BranchDimension BD
		 ON BD.BranchID = TPH.BranchId JOIN
		 MedicineDimension MD
		 ON MD.MedicineID = TPD.MedicineId

	WHERE TPH.MedicinePurchaseDate > (
		SELECT LastETL FROM FilterTimeStamp
		WHERE TableName = 'MedicinePurchaseFact'
	)

	GROUP BY
		TimeCode,
		SupplierCode,
		EmployeeCode,
		BranchCode,
		MedicineCode
END 
ELSE 
BEGIN 
	SELECT 
		TimeCode,
		SupplierCode,
		EmployeeCode,
		BranchCode,
		MedicineCode,
		[Total Purchase Cost] = SUM(Quantity*MedicinePurchasePrice),
		[Total Purchase Medicine] = SUM(Quantity)
		FROM [Bitter Pill Pharmacy]..TrMedicinePurchaseHeader TPH JOIN
		[Bitter Pill Pharmacy]..TrMedicinePurchaseDetail TPD 
		ON TPH.MedicinePurchaseId = TPD.MedicinePurchaseId JOIN
		TimeDimension TD
		ON TD.Date = TPH.MedicinePurchaseDate JOIN
		SupplierDimension SD
		ON SD.SupplierID = TPH.SupplierId JOIN
		EmployeeDimension ED
		ON ED.EmployeeID = TPH.EmployeeId JOIN
		BranchDimension BD
		ON BD.BranchID = TPH.BranchId JOIN
		MedicineDimension MD
		ON MD.MedicineID = TPD.MedicineId

		GROUP BY
		TimeCode,
		SupplierCode,
		EmployeeCode,
		BranchCode,
		MedicineCode
END

IF EXISTS(
	SELECT * FROM FilterTimeStamp
	WHERE TableName = 'MedicinePurchaseFact'
) 
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'MedicinePurchaseFact'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp
	VALUES('MedicinePurchaseFact', GETDATE())
END

SELECT * FROM MedicinePurchaseFact
SELECT * FROM FilterTimeStamp
-----------------------------------------------MedicineSalesFact
IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'MedicineSalesFact'
) 
BEGIN 
	SELECT 
		 TimeCode,
		 CustomerCode,
		 EmployeeCode,
		 BranchCode,
		 MedicineCode,
		 [Total Earnings Medicine] = SUM(Quantity*MedicineSellingPrice),
		 [Total Sold Medicine] = SUM(Quantity)
		 FROM [Bitter Pill Pharmacy]..TrMedicineSalesHeader TSH JOIN
		 [Bitter Pill Pharmacy]..TrMedicineSalesDetail TSD 
		 ON TSH.MedicineSalesId = TSD.MedicineSalesId JOIN
		 TimeDimension TD
		 ON TD.Date = TSH.MedicineSalesDate JOIN
		 CustomerDimension CD
		 ON CD.CustomerId = TSH.CustomerId JOIN
		 EmployeeDimension ED
		 ON ED.EmployeeId = TSH.EmployeeId JOIN
		 BranchDimension BD
		 ON BD.BranchId = TSH.BranchId JOIN
		 MedicineDimension MD
		 ON MD.MedicineId = TSD.MedicineId

		 WHERE TSH.MedicineSalesDate > (
			SELECT LastETL FROM FilterTimeStamp
			WHERE TableName = 'MedicineSalesFact'
		 )

	GROUP BY
		TimeCode,
		CustomerCode,
		EmployeeCode,
		BranchCode,
		MedicineCode
END 
ELSE 
BEGIN 
	SELECT 
		 TimeCode,
		 CustomerCode,
		 EmployeeCode,
		 BranchCode,
		 MedicineCode,
		 [Total Earnings Medicine] = SUM(Quantity*MedicineSellingPrice),
		 [Total Sold Medicine] = SUM(Quantity)
		 FROM [Bitter Pill Pharmacy]..TrMedicineSalesHeader TSH JOIN
		 [Bitter Pill Pharmacy]..TrMedicineSalesDetail TSD 
		 ON TSH.MedicineSalesId = TSD.MedicineSalesId JOIN
		 TimeDimension TD
		 ON TD.Date = TSH.MedicineSalesDate JOIN
		 CustomerDimension CD
		 ON CD.CustomerId = TSH.CustomerId JOIN
		 EmployeeDimension ED
		 ON ED.EmployeeId = TSH.EmployeeId JOIN
		 BranchDimension BD
		 ON BD.BranchId = TSH.BranchId JOIN
		 MedicineDimension MD
		 ON MD.MedicineId = TSD.MedicineId

		GROUP BY
			TimeCode,
			CustomerCode,
			EmployeeCode,
			BranchCode,
			MedicineCode
END 

IF EXISTS(
	SELECT * FROM FilterTimeStamp
	WHERE TableName = 'MedicineSalesFact'
) 
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'MedicineSalesFact'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp
	VALUES('MedicineSalesFact', GETDATE())
END
-----------------------------------------------EquipmentSalesFact
IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'EquipmentSalesFact'
)
BEGIN 
	SELECT 
		 TimeCode,
		 CustomerCode,
		 EmployeeCode,
		 EquipmentCode,
		 [Total Earnings Medical Equipment] = SUM(Quantity*EquipmentPrice),
		 [Average Sold Medical Equipment] = AVG(Quantity)
		 FROM [Bitter Pill Pharmacy]..TrMedicalEquipmentSalesHeader ESH JOIN
		 [Bitter Pill Pharmacy]..TrMedicalEquipmentSalesDetail ESD 
		 ON ESH.EquipmentSalesId = ESD.EquipmentSalesId JOIN
		 TimeDimension TD
		 ON TD.Date = ESH.EquipmentSalesDate JOIN
		 CustomerDimension CD
		 ON CD.CustomerId = ESH.CustomerId JOIN
		 EmployeeDimension ED
		 ON ED.EmployeeId = ESH.EmployeeId JOIN
		 EquipmentDimension EQ
		 ON EQ.EquipmentId = ESD.EquipmentId
		 
	WHERE ESH.EquipmentSalesDate > (
		SELECT LastETL FROM FilterTimeStamp
		WHERE TableName = 'EquipmentSalesFact'
	)

	GROUP BY
		TimeCode,
		CustomerCode,
		EmployeeCode,
		EquipmentCode
END 
ELSE 
BEGIN 
	SELECT 
		 TimeCode,
		 CustomerCode,
		 EmployeeCode,
		 EquipmentCode,
		 [Total Earnings Medical Equipment] = SUM(Quantity*EquipmentPrice),
		 [Average Sold Medical Equipment] = AVG(Quantity)
		 FROM [Bitter Pill Pharmacy]..TrMedicalEquipmentSalesHeader ESH JOIN
		 [Bitter Pill Pharmacy]..TrMedicalEquipmentSalesDetail ESD 
		 ON ESH.EquipmentSalesId = ESD.EquipmentSalesId JOIN
		 TimeDimension TD
		 ON TD.Date = ESH.EquipmentSalesDate JOIN
		 CustomerDimension CD
		 ON CD.CustomerId = ESH.CustomerId JOIN
		 EmployeeDimension ED
		 ON ED.EmployeeId = ESH.EmployeeId JOIN
		 EquipmentDimension EQ
		 ON EQ.EquipmentId = ESD.EquipmentId

	GROUP BY
		TimeCode,
		CustomerCode,
		EmployeeCode,
		EquipmentCode
END 

IF EXISTS(
	SELECT * FROM FilterTimeStamp
	WHERE TableName = 'EquipmentSalesFact'
) 
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'EquipmentSalesFact'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp
	VALUES('EquipmentSalesFact', GETDATE())
END

-----------------------------------------------ConsultationFact
IF EXISTS (
	SELECT *
	FROM FilterTimeStamp
	WHERE TableName = 'ConsultationFact'
)
BEGIN 
	SELECT 
		 TimeCode,
		 CustomerCode,
		 DoctorCode,
		 [Average Consultation Price] = AVG(ConsultationPrice),
		 [Count of Customer Consultation] = COUNT(TCH.CustomerId)
		 FROM [Bitter Pill Pharmacy]..TrConsultationHeader TCH JOIN
		 TimeDimension TD
		 ON TD.Date = TCH.ConsultationDate JOIN
		 CustomerDimension CD
		 ON CD.CustomerId = TCH.CustomerId JOIN
		 DoctorDimension DD
		 ON DD.DoctorId = TCH.DoctorId

	WHERE TCH.ConsultationDate > (
		SELECT LastETL FROM FilterTimeStamp
		WHERE TableName = 'ConsultationFact'
	)

	GROUP BY
		TimeCode,
		CustomerCode,
		DoctorCode
END 
ELSE 
BEGIN 
	SELECT
		 TimeCode,
		 CustomerCode,
		 DoctorCode,
		 [Average Consultation Price] = AVG(ConsultationPrice),
		 [Count of Customer Consultation] = COUNT(TCH.CustomerId)
		 FROM [Bitter Pill Pharmacy]..TrConsultationHeader TCH JOIN
		 TimeDimension TD
		 ON TD.Date = TCH.ConsultationDate JOIN
		 CustomerDimension CD
		 ON CD.CustomerId = TCH.CustomerId JOIN
		 DoctorDimension DD
		 ON DD.DoctorId = TCH.DoctorId

	GROUP BY
		TimeCode,
		CustomerCode,
		DoctorCode
END 

IF EXISTS(
	SELECT * FROM FilterTimeStamp
	WHERE TableName = 'ConsultationFact'
) 
BEGIN
	UPDATE FilterTimeStamp
	SET LastETL = GETDATE()
	WHERE TableName = 'ConsultationFact'
END
ELSE
BEGIN
	INSERT INTO FilterTimeStamp
	VALUES('ConsulationFact', GETDATE())
END

SELECT * FROM FilterTimeStamp
SELECT * FROM MedicineSalesFact
SELECT * FROM EquipmentSalesFact
SELECT * FROM ConsultationFact


