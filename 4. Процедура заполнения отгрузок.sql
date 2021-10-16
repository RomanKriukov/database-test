USE Storehouse;
GO
CREATE PROCEDURE CalculationOfShipment 
	@contractNumber INT,
	@storage INT,
	@shippingDate DATE,
	@quantity INT
AS
BEGIN

DECLARE @maxQuantity INT, @nameCulture NVARCHAR(50)
SET @maxQuantity = (SELECT Quantity FROM Contracts WHERE Number = @contractNumber)
SET @nameCulture = (SELECT Culture FROM Contracts WHERE Number = @contractNumber)

IF (SELECT SUM(Quantity) FROM ShipmentOfGoods
	WHERE ContractNumber = @contractNumber) !< @maxQuantity
	BEGIN
		RAISERROR('�������� ��� ��������� �� ���������', 10, 2)
		RETURN
	END

IF (SELECT SUM(Quantity) FROM ShipmentOfGoods
	WHERE ContractNumber = @contractNumber) + @quantity > @maxQuantity
	OR @quantity > @maxQuantity
	BEGIN
		RAISERROR('�������� ����� �� ���������', 10, 2)
		RETURN
	END

IF (SELECT OnTheDate FROM RemainingGoods 
	WHERE NameCulture = @nameCulture
	AND Storage = @storage) > @shippingDate
	BEGIN
		RAISERROR('�� ���������� ������ � ����� �������� �� ���� ��������', 10, 2)
		RETURN
	END

IF (SELECT Quantity FROM RemainingGoods 
	WHERE NameCulture = @nameCulture
	AND Storage = @storage) < @quantity
	BEGIN
		RAISERROR('�� ���������� ������ � ����� ��������', 10, 2)
		RETURN
	END

DECLARE @purchasePrice INT, @sellingPrice INT
SET @purchasePrice = (SELECT Price FROM RemainingGoods WHERE NameCulture = @nameCulture AND Storage = @storage)
SET @sellingPrice = (SELECT Price FROM Contracts WHERE Number = @contractNumber)

INSERT INTO ShipmentOfGoods VALUES
(
	@contractNumber,
	@storage,
	@shippingDate,
	@quantity,
	@quantity * @sellingPrice - @quantity * @purchasePrice
)
END