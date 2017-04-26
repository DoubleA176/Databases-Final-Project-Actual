
IF db_id('FinalProject') IS NOT NULL
	BEGIN
	USE master
	DROP DATABASE FinalProject
	END


GO



SET NOCOUNT ON

CREATE DATABASE FinalProject
GO

USE FinalProject
GO



/*
Create tables
*/


Create TABLE tblCustomer
(
 CustomerID INT IDENTITY(1,1) PRIMARY KEY,
 FirstName NVARCHAR(100)NOT NULL,
 LastName  NVARCHAR(100)NOT NULL,
 BillStreet NVARCHAR(50),
 BillCity NVARCHAR (25),
 BillSt CHAR (2),
 BillZIP CHAR (5),
 Phone CHAR (10),)

GO

Create TABLE tblItem(
ItemID INT IDENTITY(1,1) PRIMARY KEY,
UnitPrice FLOAT NOT NULL,
ItemDesc NVARCHAR(250),
)
GO

Create TABLE tblSalesPerson(
SalesPersonID INT IDENTITY(1,1) PRIMARY KEY,
SFirstName NVARCHAR(100) NOT NULL,
SLastName NVARCHAR(100) NOT NULL,
)
GO

Create TABLE tblInvoice(
InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
CustomerID INT NOT NULL FOREIGN KEY REFERENCES tblCustomer(CustomerID),
SalesPersonID INT FOREIGN KEY REFERENCES tblSalesPerson(SalesPersonID),
ShipStreet NVARCHAR(50),
ShipCity NVARCHAR (25),
ShipSt CHAR (2),
ShipZIP CHAR (5),
InvoiceDate DATETIME NOT NULL,
ShipDate DATETIME,
SalesTax FLOAT NOT NULL,
ShipHandle FLOAT NOT NULL,
Terms NVARCHAR(250),
Subtotal FLOAT NOT NULL,
Total FLOAT NOT NULL,
)
GO

Create TABLE tblOrder(
OrderID INT IDENTITY(1,1) PRIMARY KEY,
InvoiceID INT NOT NULL FOREIGN KEY REFERENCES tblInvoice(InvoiceID),
ItemID INT NOT NULL FOREIGN KEY REFERENCES tblItem(ItemID),
ItemQuantity INT NOT NULL,
OrderPrice FLOAT NOT NULL,
)
GO

ALTER TABLE tblCustomer
ADD CONSTRAINT FnLnPhn UNIQUE(FirstName, LastName, Phone)
GO

ALTER TABLE tblOrder
ADD CONSTRAINT ItemListedOnce UNIQUE (ItemID, InvoiceID)
GO

--If all of the shipping address values are NULL, then shipping address is billing address
CREATE TRIGGER BillIsShip ON tblInvoice
FOR INSERT
AS
BEGIN
IF(SELECT ShipStreet FROM INSERTED) IS NULL AND (SELECT ShipCity FROM INSERTED) IS NULL AND (SELECT ShipSt FROM INSERTED) IS NULL AND (SELECT ShipZIP FROM INSERTED) IS NULL
	UPDATE tblInvoice
	SET
	ShipStreet = (SELECT BillStreet FROM tblCustomer JOIN INSERTED ON tblCustomer.CustomerID = INSERTED.CustomerID)
	WHERE tblInvoice.InvoiceID = (SELECT InvoiceID FROM INSERTED)

	UPDATE tblInvoice
	SET
	ShipCity = (SELECT BillCity FROM tblCustomer JOIN INSERTED ON tblCustomer.CustomerID = INSERTED.CustomerID)
	WHERE tblInvoice.InvoiceID = (SELECT InvoiceID FROM INSERTED)

	UPDATE tblInvoice
	SET
	ShipSt =(SELECT BillSt FROM tblCustomer JOIN INSERTED ON tblCustomer.CustomerID = INSERTED.CustomerID)
	WHERE tblInvoice.InvoiceID = (SELECT InvoiceID FROM INSERTED)

	UPDATE tblInvoice
	SET
	ShipZIP = (SELECT BillZIP FROM tblCustomer JOIN INSERTED ON tblCustomer.CustomerID = INSERTED.CustomerID)
	WHERE tblInvoice.InvoiceID = (SELECT InvoiceID FROM INSERTED)
END

GO

ALTER TABLE tblInvoice
ADD CONSTRAINT All_Adds_Up
CHECK(SalesTax + ShipHandle + Subtotal = Total)
GO

BEGIN TRANSACTION
INSERT INTO tblCustomer(FirstName, LastName, BillStreet, BillCity, BillSt, BillZIP, Phone)
	VALUES('Alec', 'Austin', 'ajsdjkdsjahfaj', 'Mobile', 'AL', '12345', '1234567890')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblCustomer(FirstName, LastName, BillStreet, BillCity, BillSt, BillZIP, Phone)
	VALUES('Michael', 'Roark', 'Fish Drive', 'Jackson', 'MS', '98765', '2518675309')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblCustomer(FirstName, LastName, BillStreet, BillCity, BillSt, BillZIP, Phone)
	VALUES('Ronald', 'McDonald', 'Burger Lane', 'Burger Town', 'MD', '99999', '9999999999')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblCustomer(FirstName, LastName, BillStreet, BillCity, BillSt, BillZIP, Phone)
	VALUES('Super', 'Hero', 'Comic Street', 'Marvel', 'DC', '22555', '2255522555')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblCustomer(FirstName, LastName, BillStreet, BillCity, BillSt, BillZIP, Phone)
	VALUES('Michael', 'Bolton', 'Pirate Ship', 'Caribbean', 'CS', '80219', '3334445556')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblItem(UnitPrice, ItemDesc)
	VALUES(17.50, 'Widget')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblItem(UnitPrice, ItemDesc)
	VALUES(199.99, 'Wodget')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblItem(UnitPrice, ItemDesc)
	VALUES(2.99, 'Ice Cream Cone')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblItem(UnitPrice, ItemDesc)
	VALUES(4.99, 'Toy Boat')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblItem(UnitPrice, ItemDesc)
	VALUES(97.28, 'Really Good Blender')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblSalesPerson(SFirstName, SLastName)
	VALUES('Darkwing', 'Duck')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblSalesPerson(SFirstName, SLastName)
	VALUES('Sonic', 'the Hedgehog')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblSalesPerson(SFirstName, SLastName)
	VALUES('Julia', 'Howard')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblSalesPerson(SFirstName, SLastName)
	VALUES('Luke', 'Skywalker')
	COMMIT TRANSACTION
GO

BEGIN TRANSACTION
INSERT INTO tblSalesPerson(SFirstName, SLastName)
	VALUES('Ricky', 'Slick')
	COMMIT TRANSACTION
GO

Declare @CustomerID INT
Declare @SalesPersonID INT
SET @CustomerID = (SELECT CustomerID FROM tblCustomer WHERE LastName = 'Austin' AND Phone = '1234567890')
SET @SalesPersonID = (SELECT SalesPersonID FROM tblSalesPerson WHERE SFirstName = 'Sonic' AND SLastName = 'the Hedgehog')

BEGIN TRANSACTION
INSERT INTO tblInvoice(CustomerID, SalesPersonID, ShipStreet, ShipCity, ShipSt, ShipZIP, InvoiceDate, ShipDate, SalesTax, ShipHandle, Terms, Subtotal, Total)
	VALUES(@CustomerID, @SalesPersonID, NULL, NULL, NULL, NULL, GETDATE(), NULL, 15, 8, 'Make it Blue', 20, 43)
	COMMIT TRANSACTION
GO

Declare @CustomerID INT
Declare @ShipST CHAR(2)
Declare @ShipCity NVARCHAR(25)
SET @CustomerID = (SELECT CustomerID FROM tblCustomer WHERE LastName = 'Roark' AND Phone = '2518675309')
SET @ShipST = (SELECT BillSt FROM tblCustomer WHERE LastName = 'Roark' AND Phone = '2518675309')
SET @ShipCity = (SELECT BillCity FROM tblCustomer WHERE LastName = 'Roark' AND Phone = '2518675309')


BEGIN TRANSACTION
INSERT INTO tblInvoice(CustomerID, SalesPersonID, ShipStreet, ShipCity, ShipSt, ShipZIP, InvoiceDate, ShipDate, SalesTax, ShipHandle, Terms, Subtotal, Total)
	VALUES(@CustomerID, NULL, 'Other Shipping Street', @ShipCity, @ShipST, '98764', GETDATE(), GETDATE() + 3, 20, 20, 'Make it Green', 20, 60)
	COMMIT TRANSACTION
GO

Declare @CustomerID INT
Declare @ShipST CHAR(2)
Declare @ShipCity NVARCHAR(25)
Declare @ShipZIP CHAR(5)
SET @CustomerID = (SELECT CustomerID FROM tblCustomer WHERE LastName = 'McDonald' AND Phone = '9999999999')
SET @ShipST = (SELECT BillSt FROM tblCustomer WHERE LastName = 'McDonald' AND Phone = '9999999999')
SET @ShipCity = (SELECT BillCity FROM tblCustomer WHERE LastName = 'McDonald' AND Phone = '9999999999')
SET @ShipZIP = (SELECT BillZIP FROM tblCustomer WHERE LastName = 'McDonald' AND Phone = '9999999999')


BEGIN TRANSACTION
INSERT INTO tblInvoice(CustomerID, SalesPersonID, ShipStreet, ShipCity, ShipSt, ShipZIP, InvoiceDate, ShipDate, SalesTax, ShipHandle, Terms, Subtotal, Total)
	VALUES(@CustomerID, NULL, 'Nugget Blvd', @ShipCity, @ShipST, @ShipZIP, GETDATE(), NULL, 6, 8.50, 'Covered in Sprinkles', 3000, 3014.50)
	COMMIT TRANSACTION
GO

Declare @CustomerID INT
Declare @SalesPersonID INT
SET @CustomerID = (SELECT CustomerID FROM tblCustomer WHERE LastName = 'Hero' AND Phone = '2255522555')
SET @SalesPersonID = (SELECT SalesPersonID FROM tblSalesPerson WHERE SFirstName = 'Julia' AND SLastName = 'Howard')

BEGIN TRANSACTION
INSERT INTO tblInvoice(CustomerID, SalesPersonID, ShipStreet, ShipCity, ShipSt, ShipZIP, InvoiceDate, ShipDate, SalesTax, ShipHandle, Terms, Subtotal, Total)
	VALUES(@CustomerID, @SalesPersonID, NULL, NULL, NULL, NULL, GETDATE(), GETDATE() - 1, 5.22, 900.37, 'I want it yesterday.', 2.99, 5.22 + 900.37 + 2.99)
	COMMIT TRANSACTION
GO

Declare @CustomerID INT
Declare @SalesPersonID INT
Declare @ShipST CHAR(2)
Declare @ShipCity NVARCHAR(25)
SET @CustomerID = (SELECT CustomerID FROM tblCustomer WHERE LastName = 'Bolton' AND Phone = '3334445556')
SET @SalesPersonID = (SELECT SalesPersonID FROM tblSalesPerson WHERE SFirstName = 'Julia' AND SLastName = 'Howard')
SET @ShipST = (SELECT BillSt FROM tblCustomer WHERE LastName = 'Bolton' AND Phone = '3334445556')
SET @ShipCity = (SELECT BillCity FROM tblCustomer WHERE LastName = 'Bolton' AND Phone = '3334445556')

BEGIN TRANSACTION
INSERT INTO tblInvoice(CustomerID, SalesPersonID, ShipStreet, ShipCity, ShipSt, ShipZIP, InvoiceDate, ShipDate, SalesTax, ShipHandle, Terms, Subtotal, Total)
	VALUES(@CustomerID, @SalesPersonID, NULL, @ShipCity, @ShipST, NULL, GETDATE(), NULL, 200.00, 10.00, 'No holes.', 600.00, 810.00)
	COMMIT TRANSACTION
GO




SELECT * FROM tblCustomer
SELECT * FROM tblItem
SELECT * FROM tblSalesPerson
SELECT * FROM tblInvoice
SELECT * FROM tblOrder
/*
--Echo a print statement that confirms result.
PRINT 'Tables successfully constructed...'

SET NOCOUNT OFF


ALTER TABLE tblwhatever
ADD CONSTRAINT Customer_ID_fk FOREIGN KEY (CustomerID)
REFERENCES tblCustomer(CustomerID)
GO

PRINT 'Foreign Key Constraints successfully applied...'

-- Alters tblWhatever to require CustomerID 
 
ALTER TABLE tblWhatever
ALTER COLUMN CustomerID INT NOT NULL
GO


--Cannot give away orders....must have a total

ALTER TABLE tblWhatever
ALTER COLUMN Total MONEY NOT NULL
GO


PRINT 'NOT NULL Constraints successfully applied...'



--If you have any default constraints

PRINT 'DEFAULT Constraints successfully applied...'


ALTER TABLE tblCustomer
ADD CONSTRAINT FirstName_Phone_Unique UNIQUE(FirstName, Phone) -- makes this an alternate key
GO


PRINT 'UNQUE Constraints successfully applied...'


--Check to make sure Ship Date is in the future
ALTER TABLE tblInvoice
ADD CONSTRAINT ShipDate_Future_Check
CHECK (ShipDate > InvoiceDate)
GO

PRINT 'CHECK Constraints successfully applied...'


SET NOCOUNT ON

GO

--Insert Customers

BEGIN TRY
  BEGIN TRANSACTION

--INSERT INTO tblCustomer 

    INSERT INTO tblCustomer (FirstName, LastName, Street, City, St, ZIP, Phone)
    VALUES ('Larry', 'Bond', '12225 Hederson St', 'Wiggins', 'MS', '39589', '2286562989')
  
  COMMIT TRANSACTION

  PRINT 'Customers successfully inserted...'

END TRY
BEGIN CATCH
  DECLARE @ErrorMessage VARCHAR(500)
  SET @ErrorMessage = ERROR_MESSAGE() + ' Rolledback transaction: Customer insertions.'
  ROLLBACK TRANSACTION
  RAISERROR (@ErrorMessage, 16,1)
END CATCH
GO



--SELECT * FROM tblCustomer





--Insert Invoice And SaleItem

BEGIN TRY

  BEGIN TRANSACTION
  
  DECLARE @CustomerID INT
  SET @CustomerID = (SELECT CustomerID FROM tblCustomer WHERE FirstName = 'Jeffrey' AND Phone = '2285882673')
  
  DECLARE @RepID INT
  SET @RepID = (SELECT RepID FROM tblRep WHERE Email = 'RandyLee@wood.com')
  
  DECLARE @ShipToID INT
  SET @ShipToID = (SELECT ShipToID FROM tblShipTo WHERE FirstName = 'Jeffrey' AND Street = '19925 Holifield Rd')
  
  INSERT INTO tblInvoice (InvoiceDATE, CustomerID, RepID, Total, TAX, ShipDate, Shiping, ShipVIA, PayBy, TrackNumber, ShipToID)
    VALUES ('2010-8-5 8:30 am', @CustomerID, @RepID, '174.44', '17.44', '2010-8-6 8:45 am', '10.99', 'FedEx', 'M/C', '1234567', @ShipToID)
  
  
    --Retrieve the newly created primary key to insert as a foreign key in tblSaleItem
  DECLARE @InvoiceID INT
  DECLARE @ItemID INT
  
  SET @InvoiceID = @@Identity

  --Retrieve primary key of product for current listitem
  --Insert new row in tblSaleItem
  SET @ItemID = (SELECT ItemID FROM tblItem WHERE ItemDescription ='Palermo Basket Weave Corbal 10 X 4 X 5 Red Oak')

  INSERT INTO tblSaleItem (Quantity, UnitPrice, ExtendedPrice, InvoiceID, ItemID)
   VALUES (2, 52.66, 105.20, @InvoiceID, @ItemID)

  SET @ItemID = (SELECT ItemID FROM tblItem WHERE ItemDescription ='Stain 1 Gal Goalden Oak')

  INSERT INTO tblSaleItem (Quantity, UnitPrice, ExtendedPrice, InvoiceID, ItemID)
   VALUES (1, 18.97, 18.97, @InvoiceID, @ItemID)
   

--New Invoice
    
  
 




SET NOCOUNT OFF
*/


