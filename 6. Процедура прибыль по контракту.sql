USE Storehouse;
GO
CREATE PROCEDURE ProfitByContract
	@after DATE,
	@before DATE
AS
BEGIN
	SELECT 
		S.ContractNumber AS '��������',
		SUM(S.Quantity) AS '����������',
		SUM(S.CurrentProfit) AS '�������',
		SUM(S.CurrentProfit) / SUM(S.Quantity) AS '������� �� �����'
	FROM ShipmentOfGoods AS S JOIN Contracts AS C ON C.Number = S.ContractNumber
	WHERE S.ShippingDate > @after
	AND S.ShippingDate < IIF(@before < C.ExpirationDate, C.ExpirationDate, @before)
	GROUP BY ContractNumber
END;
