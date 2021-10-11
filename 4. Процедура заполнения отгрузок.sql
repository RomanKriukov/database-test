USE Storehouse;
GO
CREATE PROCEDURE CalculationOfShipment AS
BEGIN

DECLARE @numberStorage INT, @maxQuantity INT, @quantity INT, @contractId INT
SET @contractId = 1;
SET @numberStorage = 1;
WHILE @contractId < ((SELECT MAX(Id) FROM Contracts) + 1)
	BEGIN
	IF (SELECT COUNT(Number) FROM Contracts AS C JOIN ShipmentOfGoods AS S ON C.Number = S.ContractNumber AND C.Id = @contractId) > 0
		OR @contractId <> (SELECT Id FROM Contracts WHERE Id = @contractId)
		BEGIN
			SET @contractId = @contractId + 1
			CONTINUE;
		END;
SET @maxQuantity = (SELECT Quantity FROM Contracts WHERE Id = @contractId);

WHILE @numberStorage <= (SELECT MAX(Storage) FROM RemainingGoods)
	
	BEGIN
		IF (SELECT COUNT(NameCulture) FROM RemainingGoods 
		WHERE Storage = @numberStorage AND NameCulture = (SELECT Culture FROM Contracts WHERE Id = @contractId)) !> 0
		BEGIN
			SET @numberStorage = @numberStorage + 1
			CONTINUE
		END;

		IF (SELECT CONVERT(INT, DAY(OnTheDate)) FROM RemainingGoods AS R JOIN Contracts AS C
			ON C.Id = @contractId AND R.NameCulture = C.Culture AND R.Storage = @numberStorage) >= 
			(SELECT CONVERT(INT, DAY(ExpirationDate)) FROM Contracts
			WHERE Id = @contractId)
			BEGIN
				IF (SELECT CONVERT(INT, MONTH(OnTheDate)) FROM RemainingGoods AS R JOIN Contracts AS C
					ON C.Id = @contractId AND R.NameCulture = C.Culture AND R.Storage = @numberStorage) >= 
					(SELECT CONVERT(INT, MONTH(ExpirationDate)) FROM Contracts
					WHERE Id = @contractId)
					BEGIN
						IF (SELECT CONVERT(INT, YEAR(OnTheDate)) FROM RemainingGoods AS R JOIN Contracts AS C
							ON C.Id = @contractId AND R.NameCulture = C.Culture AND R.Storage = @numberStorage) >= 
							(SELECT CONVERT(INT, YEAR(ExpirationDate)) FROM Contracts
							WHERE Id = @contractId)
							BEGIN
								SET @numberStorage = @numberStorage + 1
								CONTINUE
							END;
					END;
			END;
		SET @quantity = (SELECT 
					RemainingGoods.Quantity 
					FROM RemainingGoods JOIN Contracts 
					ON Contracts.Culture = RemainingGoods.NameCulture
					AND RemainingGoods.Storage = @numberStorage
					AND Contracts.Id = @contractId)

		INSERT INTO ShipmentOfGoods
		SELECT 
			C.Number, 
			R.Storage, 
			DATEADD(DAY, 1, R.OnTheDate), 
			IIF(
				R.Quantity < @maxQuantity, 
				R.Quantity, @maxQuantity), 
			IIF(
				R.Quantity < @maxQuantity,
				R.Quantity * C.Price - R.Quantity * R.Price,
				@maxQuantity * C.Price - @maxQuantity * R.Price)
		FROM Contracts AS C JOIN RemainingGoods AS R 
			ON C.Culture = R.NameCulture 
			AND R.Storage = @numberStorage
			AND C.Id = @contractId
		IF @maxQuantity > @quantity
			BEGIN
				SET @maxQuantity = @maxQuantity - @quantity
			END;
		SET @numberStorage = @numberStorage + 1
	
	END
	SET @contractId = @contractId + 1;
	SET @numberStorage = 1;
END
END;